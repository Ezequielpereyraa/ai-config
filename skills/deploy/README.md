# deploy

Skill de Claude Code / Cursor para el **panorama pre-promoción a producción** de los servicios de UMA en Cloud Deploy.

## Qué hace

Cuando estás por promover un servicio a producción, necesitás saber:
- Qué versión está en cada ambiente (dev, staging, prod)
- Qué PRs están pendientes de prod
- Quién las mergeó
- Un mensaje listo para pegar al canal de Slack del equipo

Este skill hace todo eso con un solo comando.

## Servicios soportados

Todos son **trunk-based** (PRs directo a `main`) con Cloud Deploy en `uma-devops-cicd` / `us-central1`.

| Alias | Pipeline | Repo |
|---|---|---|
| `megalito` / `megalith` | `megalith-service-pipeline` | `CD-svc-megalith` |
| `pacientes` / `patient` / `pat` | `patient-app-pipeline` | `CD-web-patient` |
| `od` / `doctor` / `prestadores` / `onlinedoctor` | `doctor-app-pipeline` | `CD-web-doctor` |
| `portal` | `portal-app-pipeline` | `CD-web-portal` |
| `node` / `nodeserver` / `umanodeserver` | `nodeserver-service-pipeline` | `CD-svc-nodeserver` |
| `shifts` / `turnos` | `shifts-service-pipeline` | `CD-svc-shifts` |

Los aliases son case-insensitive y se matchean por substring. Si tipeás algo ambiguo, el skill te pregunta.

## Qué genera

### 1. Reporte técnico (para vos)

```
Panorama pacientes · 2026-04-23 ART

Pipeline (trunk-based, todas las PRs van a main)
| Ambiente | Versión | SHA     | Deployado  |
|----------|---------|---------|------------|
| dev      | v2.9.5  | 3d45954 | hoy 12:31  |
| staging  | v2.9.5  | 3d45954 | hoy 12:32  |
| prod     | v2.9.1  | 83db6e6 | ayer 14:13 |

Pendiente de prod: 3 PRs (v2.9.1 → v2.9.5)
| #    | Título                    | Autor         | Mergeado   | Stg |
|------|---------------------------|---------------|------------|-----|
| 5180 | ...                       | @boniSantana  | hoy 11:52  | ✓   |
...
```

Con columna `Stg` para saber si cada PR ya pasó por staging.

### 2. Bloque listo para Slack

```
Buenas equipo! 🚀 Vamos con la promoción de pacientes a prod?
v2.9.1 → v2.9.5 — 3 PRs esperando el OK 👇

@Boni Fede 🐛
 • RSC env config and timestamps — https://github.com/...
 • unbreak staging (env-config race + Timestamp RSC) — https://github.com/...

@Javier Sankowicz 🛠️
 • Init firebase — https://github.com/...
```

Agrupa por autor, elige un emoji por área predominante de sus PRs (🐛 bugs, 🛠️ infra, 🎨 UI, 🔐 auth, 💳 pagos, etc.), y mapea los handles de GitHub a los nombres de Slack.

## Qué NO hace

- **No ejecuta deploys ni promociones.** Es 100% solo lectura — no corre `gcloud deploy releases promote` ni nada similar.
- **No manda mensajes a Slack automáticamente.** Solo genera el bloque; lo copiás y pegás vos.

## Requisitos

- `gcloud` CLI autenticado con acceso al proyecto `uma-devops-cicd`
- `gh` CLI autenticado con acceso a la org `umahealth`
- Claude Code o Cursor instalado

## Instalación

### Claude Code

```bash
git clone https://github.com/umahealth/uma-skills.git
cp -r uma-skills/skills/deploy ~/.claude/skills/deploy
```

### Cursor

```bash
cp -r uma-skills/skills/deploy ~/.cursor/skills/deploy
```

## Uso

```
/deploy <alias>
```

Ejemplos:

```
/deploy megalito
/deploy od
/deploy pacientes
/deploy node
```

Si no pasás alias, el skill te pregunta "¿Para qué servicio?" y esperás.

## Flujo interno (para curiosos)

1. Resuelve el alias contra la tabla de servicios.
2. Chequea auth de `gcloud` y `gh`.
3. Trae la release actual de dev / staging / prod en paralelo.
4. Lista las 30 releases más recientes del pipeline para resolver versión + SHA.
5. Compara `prod...dev` para obtener commits pendientes.
6. Compara `prod...staging` para marcar cuáles ya pasaron por staging.
7. Agrupa commits en PRs únicas (deduplica por número de PR).
8. Filtra PRs del bot de changesets (`umahealth-bot` + título "Version Packages").
9. Para backends, detecta si algún PR toca migrations de DB.
10. Renderiza el reporte + el bloque de Slack.

## Consideraciones de seguridad

- **Read-only**: el skill tiene permitido solo `Bash(gcloud *)`, `Bash(gh *)`, `Bash(grep *)` y `Bash(echo *)`. No puede escribir archivos, hacer commits, ni ejecutar comandos destructivos.
- **No expone credenciales**: el check de auth usa `gcloud auth list`, que solo devuelve nombres de cuenta (nunca tokens).
- **No hace escrituras a GitHub**: todos los `gh api` son GET.
