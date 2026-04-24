---
name: deploy
description: Panorama pre-promoción a producción para servicios de UMA en Cloud Deploy. Muestra qué versión está en dev/staging/prod, las PRs pendientes, y genera un bloque listo para pegar al canal de Slack. Soporta megalito, pacientes, doctor, portal, nodeserver y shifts.
allowed-tools: Bash(gcloud *), Bash(gh *), Bash(grep *), Bash(echo *)
---

# Deploy — Panorama pre-promoción a producción

**IMPORTANTE: Respondé SIEMPRE en español.**

Este skill genera un panorama rápido para decidir si se puede promover un servicio de UMA a producción. Muestra qué versión hay en cada target de Cloud Deploy, qué PRs están pendientes de prod, quién las subió, y deja un mensaje listo para pegar al canal de Slack del equipo.

Todos los servicios soportados son **trunk-based** (PRs a `main`). El cuello de botella es la promoción manual entre targets de Cloud Deploy (`development` → `staging` → `production`). Por eso el reporte compara la versión desplegada en cada target.

---

## Uso

```
/deploy <alias>
```

Ejemplos: `/deploy megalito`, `/deploy OD`, `/deploy pacientes`, `/deploy node`.

Si el usuario corre `/deploy` sin alias, preguntá en una línea "¿Para qué servicio?" y esperá su respuesta. **Nunca muestres un menú enumerado** — el usuario lo tipea.

---

## Servicios soportados

Todos comparten proyecto GCP (`uma-devops-cicd`), región (`us-central1`) y targets (`development`, `staging`, `production`). Solo varían el pipeline y el repo.

| Alias reconocidos | Pipeline GCP | Repo GitHub | Nombre amigable |
|---|---|---|---|
| `megalito`, `megalith` | `megalith-service-pipeline` | `umahealth/CD-svc-megalith` | megalito |
| `pacientes`, `patient`, `pat` | `patient-app-pipeline` | `umahealth/CD-web-patient` | pacientes |
| `od`, `doctor`, `prestadores`, `prestador`, `onlinedoctor` | `doctor-app-pipeline` | `umahealth/CD-web-doctor` | doctor |
| `portal` | `portal-app-pipeline` | `umahealth/CD-web-portal` | portal |
| `node`, `nodeserver`, `umanodeserver` | `nodeserver-service-pipeline` | `umahealth/CD-svc-nodeserver` | nodeserver |
| `shifts`, `turnos` | `shifts-service-pipeline` | `umahealth/CD-svc-shifts` | shifts |

**Resolución del alias**: case-insensitive, matcheo por substring o apodo. Si es ambiguo o no matchea nada, frená y pedile al usuario que aclare. Nunca inventes un pipeline que no esté en la tabla.

**Naming de releases**: el prefix varía por pipeline (`megalith-v1-43-0`, `patient-app-v2-9-5`, `doctor-app-v2-28-0`, `nodeserver-v1-2-7`, etc.). No asumas el prefix — leé `annotations.version` tal cual viene de Cloud Deploy.

---

## Regla global del skill

**Nunca uses shell loops** (`for`, `while`, `xargs` con substitution, `find -exec`, pipes con `read`, etc.). Claude Code los marca como "Contains simple_expansion" y pide permiso explícito aunque haya allowlist — eso rompe la experiencia de `/deploy`.

En su lugar, hacé **múltiples tool calls Bash en paralelo**, cada uno con argumentos literales (sin `$variable`, sin `$(...)`). Claude puede mandar varios tool uses en un solo mensaje — usá eso.

Si necesitás procesar N elementos (releases, commits, PRs), mandá N tool calls en paralelo. Si son más de ~30, partí en batches. Nunca un `for x in ...; do`.

---

## Flujo

### 1. Resolver alias y validar auth local

Matcheá el alias contra la tabla de "Servicios soportados" y extraé `<PIPELINE>` y `<REPO>`. Si no hay match claro, frená y preguntá.

Chequeá que gcloud y gh estén autenticados:

```bash
gcloud auth list --filter=status:ACTIVE --format='value(account)' | grep -q .
gh auth status
```

Si `gcloud` falla → guiá al usuario a correr `gcloud auth login` y frená.
Si `gh` falla → guiá al usuario a correr `gh auth login` y frená.

### 2. Obtener la release desplegada en cada target

Para cada target (`development`, `staging`, `production`), consultá su estado actual. Mandá los 3 calls **en paralelo** (un solo mensaje con 3 tool uses), reemplazando `<PIPELINE>` con el literal resuelto:

```bash
gcloud deploy targets describe development \
  --delivery-pipeline=<PIPELINE> \
  --region=us-central1 --project=uma-devops-cicd \
  --format="json(Deployed,\"Latest release\",\"Latest rollout\")"
```

(Idem `staging` y `production` en calls separados.)

De cada respuesta extraé:
- **Release name**: último segmento del path en `"Latest release"` (ej: `megalith-v1-43-0`, `patient-app-v2-9-5`)
- **Deployed at**: campo `"Deployed"` (timestamp ISO)

Después, listá las releases recientes del pipeline en **una sola llamada** para enriquecer versión y SHA:

```bash
gcloud deploy releases list \
  --delivery-pipeline=<PIPELINE> \
  --region=us-central1 --project=uma-devops-cicd \
  --limit=30 --sort-by="~createTime" \
  --format="value(name.basename(),annotations.version,annotations.git-sha,createTime)"
```

Cruzá por release name para obtener `{version, sha}` de cada target.

**Edge case**: el campo `"Latest rollout"` puede corresponder a un rollout NO exitoso. Si sospechás (ej: `Deployed` está vacío o el release no existe en el listado), hacé un describe adicional:

```bash
gcloud deploy rollouts describe <ROLLOUT_NAME> \
  --release=<RELEASE_NAME> \
  --delivery-pipeline=<PIPELINE> \
  --region=us-central1 --project=uma-devops-cicd \
  --format="value(state)"
```

Si no es `SUCCEEDED`, marcá el target como "último deploy falló" en el reporte.

**Fallback de SHA**: si una release no tiene `annotations.git-sha` (releases viejas), resolvé el SHA vía `gh api repos/<REPO>/git/ref/tags/v<version>` y usá el `object.sha`.

### 3. Calcular las PRs pendientes

El universo principal es `production → development` (todo lo que ya está en `main` pero todavía no llegó a prod):

```bash
gh api "repos/<REPO>/compare/<sha_prod>...<sha_dev>" \
  --jq '.commits[] | {sha, message: .commit.message, author: .author.login, date: .commit.author.date}'
```

Calculá también el subconjunto `production → staging`:

```bash
gh api "repos/<REPO>/compare/<sha_prod>...<sha_staging>" \
  --jq '[.commits[].sha]'
```

Para cada commit del diff principal, obtené la PR. **NO uses shell loops** — hacé N tool calls Bash paralelos con el SHA literal en cada uno:

```bash
gh api "repos/<REPO>/commits/<SHA_LITERAL>/pulls" \
  --jq '.[] | select(.merged_at != null and .base.ref == "main") | {number, title, author: .user.login, merged_at, html_url, additions, deletions, labels: [.labels[].name], merge_commit_sha}'
```

Si hay muchos commits (>10), priorizá hacer todos los calls **en un solo mensaje con múltiples tool uses paralelos**. Si son >30, partí en 2 batches paralelos. Nunca un `for sha in ...; do`.

**Importante**: si los merges NO son squash (caso megalito), un mismo PR aparece en múltiples commits del compare. **Deduplicá por `number`** — el universo final son PRs únicas, no commits. Tip: después del primer batch de 5-10 calls ya solés tener todas las PRs únicas — si no aparecen más PRs nuevas, podés parar y ahorrarte los calls restantes.

Si un commit devuelve varias PRs (cherry-pick), quedate con la que tenga `merged_at` no null y `base.ref == "main"`.

**Filtrá siempre** los PRs del bot de changesets (solo aparecen en repos con changesets; en otros es no-op):
- `user.login == "umahealth-bot"` **y**
- `title == "Version Packages"` (match exacto)

Etiquetá cada PR con `enStaging: true|false` usando el set de SHAs del diff `prod...staging`: `enStaging=true` si el `merge_commit_sha` del PR está en ese set.

### 4. Detectar migrations (solo servicios backend)

**Aplica solo a**: `megalito`, `nodeserver`, `shifts`. Para `pacientes`, `doctor`, `portal` → saltate este paso.

Para cada PR única, obtené la lista de files — múltiples tool calls paralelos con el número literal:

```bash
gh api "repos/<REPO>/pulls/<N_LITERAL>/files" --jq '[.[] | .filename]'
```

Si algún file matchea `**/migrations/**`, marcá la PR con `tieneMigration: true`. Guardá esta señal para el reporte.

### 5. Renderizar el reporte

Fechas relativas cortas (`hoy HH:MM`, `ayer HH:MM`, `hace N días`), SHAs a 7 chars, versiones tal como vienen de `annotations.version`.

```
Panorama <servicio> · <fecha-hora ART>

Pipeline (trunk-based, todas las PRs van a main)
| Ambiente | Versión | SHA     | Deployado  |
|----------|---------|---------|------------|
| dev      | <vX>    | <sha7>  | <rel>      |
| staging  | <vX>    | <sha7>  | <rel>      |
| prod     | <vX>    | <sha7>  | <rel>      |

Pendiente de prod: <N> PRs (<vProd> → <vDev>)
| #    | Título                            | Autor      | Mergeado   | Stg |
|------|-----------------------------------|------------|------------|-----|
| <n>  | <título>                          | @<login>   | <rel>      | ✓/✗ |
...

Columna "Stg" indica si el PR ya está en staging (✓) o solo en dev (✗).

Consideraciones
- Prod requiere aprobación manual (requireApproval=true).
- <si algún PR tiene tieneMigration: Incluye migration de DB ⚠>
- Último deploy a prod: <rel>.

Links
- #<n>  <html_url>
...
```

- Reemplazá `<servicio>` con el **nombre amigable** de la tabla (`megalito`, `pacientes`, `doctor`, `portal`, `nodeserver`, `shifts`).
- Ordená las PRs de la tabla de más nueva a más vieja por `merged_at`.
- Truncá títulos a ~45 chars si no entran.
- La línea de migration solo aparece si hay al menos una PR con `tieneMigration=true`. Si no, omitila (no mostrar "Sin migrations de DB").

**Casos especiales**:
- Si no hay PRs pendientes (prod == dev): mostrá solo la tabla de pipeline y `Pendiente de prod: nada, todo al día 🎉`. Omití las demás secciones y el bloque de Slack.
- Si hay commits sin PR asociada (commit directo a `main`): agregá sección extra antes de "Consideraciones":
  ```
  Commits sin PR
  - <sha7> — <primer línea del mensaje> — @<author>
  ```

### 6. Bloque de Slack

Al final del reporte, mostrá un bloque listo para copiar al canal del equipo.

**Formato exacto** — header con 🚀, línea de versiones con 👇, un emoji por autor según el área que tocan sus PRs, bullets con `•`:

```
Buenas equipo! 🚀 Vamos con la promoción <de-servicio> a prod?
<vProd> → <vDev> — <N> PR<s> esperando el OK 👇

@<DevA> <emoji-área>
 • <título corto> — <url>
 • <título corto> — <url>

@<DevB> <emoji-área>
 • <título corto> — <url>
```

**Reglas de armado**:
- Línea 1 con artículo natural según el servicio:
  - `megalito` → "del megalito"
  - `pacientes` → "de pacientes"
  - `doctor` → "del doctor"
  - `portal` → "del portal"
  - `nodeserver` → "del nodeserver"
  - `shifts` → "de shifts"
- Agrupar las PRs únicas por autor (`user.login` de GitHub).
- Ordenar los grupos por cantidad de PRs descendente; dentro de cada grupo, ordenar por `merged_at` descendente.
- Una línea en blanco entre grupos.
- **Sin `#<n>`** al principio de cada bullet — el link al final ya lleva el número.
- Usar `•` (U+2022) con un espacio adelante, no `-`.
- Títulos cortos: quitar prefijos `feat:`, `fix:`, `chore:`, `refactor:` si aprieta el espacio. Max ~60 chars.
- Link completo de la PR al final de cada línea (no acortar — ej: `umahealth/CD-svc-megalith/pull/<n>` según el repo resuelto).
- Pluralizar: `1 PR esperando` vs `N PRs esperando`.
- **No agregar líneas de cierre** tipo "si nadie dice nada promuevo en 15min". Terminar directo después de la última PR.
- **No** mencionar migrations, aprobaciones ni nada extra.

**Emoji por autor** — elegir uno según el área predominante de sus PRs en esta ronda (NO fijo por persona):

| Área                                   | Emoji |
|----------------------------------------|-------|
| Tenants / multi-org                    | 🏢    |
| Turnos / sobreturnos / Chaski / agenda | 📬    |
| Especialidades / providers / salud     | 🩺    |
| Auth / 2FA / OTP / security            | 🔐    |
| Pagos / billing / checkout             | 💳    |
| Infra / devops / CI / env-config       | 🛠️    |
| Bugs / fixes                           | 🐛    |
| Refactor / limpieza                    | 🧹    |
| DB / migrations                        | 🗃️    |
| UI / componentes / estilos / layout    | 🎨    |
| Forms / validación / inputs            | 📝    |
| Integraciones 3rd-party (Firebase, maps, analytics) | 🔥 |
| Performance / bundle / SSR / RSC       | ⚡    |
| Chat / notificaciones in-app           | 💬    |
| Landing / SEO / marketing              | 🪧    |
| Features genéricos / varios            | ✨    |

Si el autor tiene PRs en varias áreas, usar el emoji del scope dominante o `✨` como fallback.

**Mapping GitHub → Slack** (para las menciones `@<Dev>`):

| GitHub handle      | Slack               |
|--------------------|---------------------|
| `boniSantana`      | Boni Fede           |
| `umahealth-bot`    | Boni Fede           |
| `eacz`             | Esteban Canteros    |
| `Ezequielpereyraa` | Ezequiel Pereyra    |
| `Faridmurzone`     | Farid Murzone       |
| `isoria`           | Ivo Soria           |
| `javisank`         | Javier Sankowicz    |
| `lucaspereyradev`  | Lucas Pereyra       |
| `lucianocasini`    | Luciano Casini      |
| `parconico`        | Nicolas Parco       |
| `Sofialay`         | Sofía Lay           |
| `tomasgoyret`      | Tomás Goyret        |

**Fallback**: si el handle de GitHub no está en la tabla, usar el handle tal cual sin mapear (ej: `@matipaler`).

---

## Edge cases

- **Alias ambiguo o desconocido**: parar y preguntar al usuario. No inventes un pipeline que no esté en la tabla.
- **Pipeline sin releases** (`gcloud deploy releases list` devuelve "Listed 0 items" o salida vacía): el servicio no tiene deploys registrados. Puede significar que el pipeline está recién creado, o que el servicio se deploya por otro mecanismo (GH Actions directo, Firebase Hosting, etc.). Frená y avisá: "El servicio `<nombre>` no tiene releases en Cloud Deploy. Chequeá con devops cómo se deploya." Ejemplo real: `portal` al momento de escribir esto.
- **Target individual sin deploy** (la respuesta del `describe` es literalmente `null` o sin campo `Deployed`): ese target nunca recibió un deploy. Marcalo en la tabla como `— | — | nunca`. Si es `dev` el vacío y `staging`/`prod` tienen deploy, seguí igual (nada que promover de dev → stg). Si es `prod` el vacío, no hay base para calcular "pendiente de prod" — avisá "prod vacío, no hay nada que promover todavía".
- **Staging == prod**: todas las PRs quedan con `Stg = ✗`. El bloque de Slack ignora staging y dice directo `<vProd> → <vDev>`.
- **Dev == staging == prod**: mostrar "todo al día 🎉", sin tabla de PRs ni bloque de Slack.
- **`gcloud` falla con exit 120** (AppArmor/snap): capturá stderr, reintentá 1x; si persiste, imprimí el stderr y pedile al usuario que corra el comando gcloud manual para diagnosticar.
- **Muchos commits pendientes** (>30): partí los tool calls en batches paralelos de 15-20, esperando el resultado de un batch antes de mandar el siguiente. Nunca usar `sleep` con loop shell.
- **Release sin `annotations.git-sha`**: fallback a resolver el tag `v<version>` vía GitHub API.

---

## Reglas

- **Respondé SIEMPRE en español**
- El reporte va en un solo bloque, escaneable, sin texto largo
- Filtrá siempre el PR de `umahealth-bot` titulado `Version Packages`
- Usá el repo canónico resuelto (ej: `umahealth/CD-svc-megalith`, `umahealth/CD-web-patient`, etc.) en todos los links
- No hagas `gcloud deploy releases promote` ni ninguna acción mutante — este skill es solo lectura
- No mandes nada a Slack automáticamente — solo dejá el bloque listo para copiar
