# ai-config

Configuracion personal para asistentes IA de codigo: Claude Code, OpenCode y Codex.

El objetivo es mejorar decisiones y respuestas en cualquier CLI/modelo sin cargar instrucciones innecesarias ni forzar procesos largos para tareas simples.

## Que Es Esto

`ai-config` es el source of truth versionado para comportamiento, workflow, comandos, skills e instalacion.

Arquitectura actual:

| Archivo | Rol |
|---|---|
| `CORE.md` | Reglas globales minimas, neutrales y siempre reutilizables. |
| `WORKFLOW.md` | Matriz para decidir entre chat directo, investigacion, analisis, plan, implementacion y review. |
| `CLAUDE.md` | Adapter liviano para Claude Code. Carga `CORE.md` y `WORKFLOW.md`. |
| `opencode/opencode.jsonc` | Config global de OpenCode. Carga `CORE.md` y `WORKFLOW.md`. |
| `codex/AGENTS.md` | Adapter global de Codex. Resume y apunta al criterio neutral. |
| `codex/rules/default.rules` | Reglas/permisos operativos de Codex. No contiene workflow. |
| `commands/` | Slash commands para analisis, plan, debug, implementacion, review y PR. |
| `skills/` | Contexto especializado bajo demanda. |
| `install.ps1`, `install.sh`, `ai.sh` | Instalacion/sync. No contienen reglas de comportamiento. |

## Principio Central

Usar el menor proceso que preserve correctness.

- Tareas simples: resolver directo y resumir breve.
- Tareas medianas: analisis compacto y plan corto.
- Tareas grandes/riesgosas: analisis, decision explicita y aprobacion antes de implementar.
- Reviews: findings primero.
- Si falta informacion que afecta correctness: preguntar una cosa concreta, no inventar.

## Workflow

La decision inicial vive en `WORKFLOW.md`:

| Tipo | Accion default |
|---|---|
| `trivial` | resolver directo |
| `small` | resolver directo + resumen breve |
| `medium` | analisis compacto + plan corto |
| `large` | analisis completo + aprobacion |
| `risky` | frenar, analizar y pedir aprobacion |
| `investigation` | explicar flujo, no editar |
| `review` | findings primero |

No usar comandos pesados para cambios chicos salvo pedido explicito.

## Comandos

| Command | Cuando usarlo |
|---|---|
| `/debug-root-cause` | Bugs, errores, stack traces, builds fallidos o comportamiento inesperado. |
| `/analyze-feature` | Features/refactors medianos, grandes, riesgosos o ambiguos. |
| `/create-plan` | Cuando ya hay solucion elegida y hace falta plan ejecutable. |
| `/dev-pipeline` | Solo con plan aprobado, scope claro, criterios, checks y riesgos. |
| `/review-work` | Review de diff, PR, arquitectura o cambio significativo. |
| `/create-pr` | Preparar descripcion de PR breve, honesta y revisable. |

Los comandos fueron ajustados para tener salida compacta por defecto y modo completo solo cuando el riesgo/tamano lo justifica.

## Skills

| Skill | Uso |
|---|---|
| `code-investigator` | Entender flujos/codigo sin editar. |
| `dev-pipeline` | Ejecutar un plan aprobado. |
| `engineering-standards` | Estilo, boundaries, errores y performance en TS/JS. |
| `typescript` | TypeScript strict, tipos, interfaces, generics. |
| `react-19` | React 19, componentes, hooks y React Compiler. |
| `nextjs` | Next.js App Router, RSC, data fetching, Server Actions. |
| `nestjs` | NestJS modules, controllers, services, guards, DTOs. |
| `tailwind-4` | Tailwind CSS 4, `cn()`, tokens y clases. |
| `ui-design` | UI/UX, responsive, layout, color, motion y performance visual. |
| `feature-slice` | FSD solo para reestructuras frontend grandes o acoplamiento real. |
| `design-init` | Generar `DESIGN.md` desde tokens existentes. |
| `deslop` | Limpiar codigo AI-generated o inconsistente. |
| `grill-with-docs` | Entrevista tecnica para sharpenear planes y documentacion. |

Las skills se usan como contexto puntual, no como reglas globales.

### Skills de mattpocock/skills

Copiadas (no instaladas como plugin) desde [`mattpocock/skills`](https://github.com/mattpocock/skills),
carpetas `engineering/` y `productivity/`. Se editan y versionan aca como cualquier otra skill.

| Grupo | Skills |
|---|---|
| Alineacion | `grilling`, `grill-me`, `grill-with-docs`, `wait-what`, `to-questionnaire` |
| Spec y tickets | `to-spec`, `to-tickets`, `triage`, `implement` |
| Ingenieria | `tdd`, `diagnosing-bugs`, `codebase-design`, `improve-codebase-architecture`, `prototype`, `research`, `resolving-merge-conflicts`, `wizard`, `wayfinder` |
| Docs y contexto | `domain-modeling`, `writing-for-agents`, `handoff`, `teach`, `ask-matt` |
| Setup | `setup-matt-pocock-skills` (correr una vez por repo) |

No se copio `code-review`: choca con el `/code-review` nativo de Claude Code y `commands/review-work.md`
ya cubre ese rol.

Para actualizarlas: `npx skills@latest add mattpocock/skills`, o copiar a mano desde el repo upstream.

## Instalacion

Requiere tener instalada la herramienta que vayas a usar: Claude Code, OpenCode o Codex.

### Windows

```powershell
git clone https://github.com/Ezequielpereyraa/ai-config.git ~/ai-config
cd ~/ai-config
.\install.ps1
```

El script intenta crear symlinks. Si Windows no lo permite, copia archivos como fallback.

Para symlinks en Windows, activar Modo desarrollador o ejecutar PowerShell como administrador.

### Linux / macOS

```bash
git clone https://github.com/Ezequielpereyraa/ai-config.git ~/ai-config
cd ~/ai-config
chmod +x ai.sh
./ai.sh install
```

## CLI

```bash
./ai.sh install           # instala todo (claude + opencode + codex)
./ai.sh install claude    # solo claude
./ai.sh install opencode  # solo opencode
./ai.sh install codex     # solo codex

./ai.sh update            # git pull + sincroniza todo
./ai.sh update claude     # git pull + solo claude
./ai.sh update opencode   # git pull + solo opencode
./ai.sh update codex      # git pull + solo codex
```

Reiniciar las herramientas abiertas despues de instalar para que carguen la configuracion nueva.

## Que Instala

| Target | Instala |
|---|---|
| `~/.claude` | `CLAUDE.md`, `settings.json`, `statusline.sh`, `commands/`, `skills/` |
| `~/.config/opencode` | `opencode.jsonc`, `commands/`, `skills/` |
| `~/.codex` | `AGENTS.md` |
| `~/.codex/rules` | `default.rules` |
| `~/.codex/skills` | cada skill de `skills/` por separado (no se linkea el dir entero: ahi vive `.system/`) |

## Mantenimiento

- Cambiar comportamiento global en `CORE.md`.
- Cambiar decision de proceso en `WORKFLOW.md`.
- Cambiar reglas especificas de Claude en `CLAUDE.md`.
- Cambiar reglas especificas de OpenCode en `opencode/opencode.jsonc`.
- Cambiar adapter de Codex en `codex/AGENTS.md`.
- Mantener `codex/rules/default.rules` solo para permisos/comandos.
- No duplicar reglas de proyecto aca: cada repo debe tener su propio `AGENTS.md`.
