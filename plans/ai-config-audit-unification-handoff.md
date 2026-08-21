# Handoff — auditoría y unificación de `ia-config` (Claude Code / OpenCode / Codex)

## Estado

Cerrado por ahora, nada a medias. No hay tarea pendiente de terminar — esto es un checkpoint de fin de sesión larga, no una interrupción a mitad de trabajo. Repo limpio, todo commiteado y pusheado a `origin/main`.

Commits de esta sesión (orden cronológico, ver mensajes completos con `git show <sha>`):
`5b0ca80` `fc4cbf9` `109b25c` `992c9cd` `d341d75` `f37c42e` `8d1f9e5` `4e347c6`

No repito el contenido de cada commit acá — están en el log con mensajes largos y explicativos. Esto es el resumen de qué cambió *de fondo* y qué queda abierto.

## Qué se hizo (temas, no diffs)

- **Bug real de portabilidad**: OpenCode no cargaba `CORE.md`/`WORKFLOW.md` en Linux/Mac (`{env:USERPROFILE}` vacío, sin fallback) — corría a ciegas sin que nadie lo notara. Arreglado en `opencode/opencode.jsonc`.
- **Seguridad/limpieza**: hooks apuntando a un path Windows no reconocido (`aylen/.orca`) eliminados de `settings.json`. Warp (plugin roto) eliminado de Claude Code y OpenCode, cache y estado en disco incluido. `user_preferences` en `settings.json` eliminado — no era una clave real, no la leía nadie.
- **Duplicados de skills** resueltos: `grill-me`, `find-docs`, `diagnosing-bugs`, `ui-design` eliminados por duplicar `grilling`, la regla `context7.md`, `/debug-root-cause` e `impeccable` respectivamente. Esto dejó referencias colgantes en `ask-matt/SKILL.md` (el router recomendaba activamente 2 skills que ya no existen) y en `README.md`/`WORKFLOW_REVIEW.md` — todas corregidas.
- **Workflow nuevo** (vive en `WORKFLOW.md`/`CLAUDE.md`/skills, compartido por las 3 herramientas):
  - Una tarea = una sesión, `/handoff` obligatorio antes de pausar/cerrar sin terminar (este mismo documento es un ejemplo de eso, aunque acá no había nada a medias).
  - Rutear comandos (`/analyze-feature` → `/create-plan` → `/dev-pipeline` → `/review-work`) es responsabilidad del asistente, no algo que el usuario tenga que recordar.
  - `/create-plan` ahora persiste a `plans/<slug>.md` en el repo (antes solo vivía en el chat) y declara `Scope` explícito (`Goal` / `In scope` / `Out of scope`).
  - `/dev-pipeline` marca `[x]` paso a paso en ese archivo (retomable si se corta la sesión), acepta rango de pasos o modelo puntual por paso, y frena si el diff crece fuera de lo declarado en scope. Build local: 100% manual, sin excepciones — tests dirigidos + typecheck son el check por defecto.
  - `/handoff` (esta skill) ahora guarda en `plans/<slug>-handoff.md` del repo, no en el temp del SO — antes era invisible para una sesión nueva en otra herramienta.
  - `/review-work` cubre explícito el caso sin plan previo (cambios manuales) y chequea scope creep / cambios colaterales / decisiones arquitectónicas no documentadas como ítems propios, no implícitos.
- **Codex** (`codex/AGENTS.md`) tenía un path Windows hardcodeado como única fuente de verdad — ahora lista candidatos Linux/Mac y Windows, mismo patrón que `opencode.jsonc`.
- Verificado contra el código fuente de cada herramienta (no asumido): las skills se comparten de verdad — mismo archivo físico vía symlink en las 3, y la política manual-vs-automático (`disable-model-invocation` / `agents/openai.yaml` con `allow_implicit_invocation: false`) está correctamente implementada también en Codex, no solo en Claude Code.

## Qué NO se tocó, y por qué

- **Definition of Done centralizada**: una propuesta externa sugirió unificar los criterios de "listo" (hoy repetidos con matices entre `dev-pipeline` y `review-work`). No hay evidencia de que hayan divergido en la práctica todavía — se evaluó y se descartó por ahora. Si en algún momento se nota que los criterios de una skill contradicen a la otra, ahí sí vale la pena.
- **Paquete de Matt Pocock** (13 skills: `ask-matt`, `wayfinder`, `to-tickets`, `to-spec`, `triage`, `implement`, `teach`, `handoff`, `grilling`, `grill-with-docs`, `wait-what`, `to-questionnaire`, `improve-codebase-architecture`, `setup-matt-pocock-skills`): se mantiene completo. Decisión explícita del usuario — ya usa `implement` y `grill-with-docs`, y trabaja para clientes donde el orden extra vale la pena.
- **Multi-agente/orquestación**: quedó como aprendizaje conceptual, no como algo a implementar. El pipeline actual (contrato primero vía `/create-plan`, delegar después si hace falta, gate de calidad al final) ya cubre lo que se necesitaba sin agregar infraestructura nueva.

## Abierto / a verificar (no bugs confirmados, señales a vigilar)

- **La prueba real de portabilidad de `/handoff` no se hizo todavía**: arrancar en una herramienta, cerrar, abrir en otra sin explicarle nada extra, y ver si retoma bien leyendo repo + plan + handoff. Con el fix de ubicación (este mismo documento es la primera prueba real) debería andar, pero no fue validado en un caso real de trabajo a medias.
- **OpenCode y `disable-model-invocation`**: no se confirmó línea por línea (a diferencia de Claude Code y Codex, que sí se verificaron contra código fuente) si OpenCode respeta la política de invocación manual tan estricto. Bajo riesgo — si algún skill tipo `/to-tickets` se dispara solo sin pedirlo, ahí está la señal.
- **Estado local, no versionado, cambiado esta sesión** (no viaja a otra máquina con `git pull`):
  - `~/.local/state/opencode/model.json`: variants de `gpt-5.6-terra` y `gpt-5.6-sol` bajados de `xhigh`/`high` a `default` (sospecha de causa de una sesión que tardó 45 min).
  - `~/.zshrc`: función `opencode()` que bloquea correrlo parado en `$HOME` (causa confirmada de esa lentitud — indexaba todo el home). Vale la pena evaluar si esto debería vivir en el repo `ia-config` (ej. como parte de `install.sh`) para que se propague a otras máquinas, en vez de quedar solo acá.
- Durante la sesión, `git commit` falló varias veces con `index.lock` transitorio (probablemente VS Code/GitHub Copilot tocando el repo por un instante) — se resolvió reintentando. No es un bug del repo, pero si vuelve a pasar seguido, no hace falta investigar de cero: es ruido conocido.

## Suggested skills

- `writing-for-agents` — si la próxima sesión sigue editando `SKILL.md`/`AGENTS.md` de este mismo repo.
- `review-work` — antes de dar por buena cualquier iteración más sobre este repo de config, como chequeo rápido de que no se rompió nada (`Sin plan de referencia` es el caso esperado acá, no un problema).
- Nada más específico — no hay una tarea de código a medias que retomar.
