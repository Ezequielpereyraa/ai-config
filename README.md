# ai-config

Configuracion personal de Claude Code — comportamiento, convenciones, comandos y skills para un flujo de trabajo senior fullstack/SaaS centrado en analisis, arquitectura, planificacion, implementacion controlada y review.

## Que es esto

Un conjunto de archivos que configuran como se comporta Claude Code en todos tus proyectos:

- **`CLAUDE.md`** — Instrucciones globales: personalidad, tono, convenciones de codigo, reglas de auto-carga de skills y perfil de usuario. Claude lo lee en cada conversacion.
- **`settings.json`** — Permisos (que herramientas puede usar Claude, cuales estan bloqueadas, cuales requieren confirmacion), status line personalizado y preferencias de output.
- **`statusline.sh`** — Barra de estado personalizada dentro de Claude Code: muestra el modelo activo, directorio actual, rama de git, lineas agregadas/eliminadas y uso de la ventana de contexto como barra de progreso.
- **`commands/`** — Slash commands del workflow: analizar, planificar, ejecutar, revisar, preparar PR y debuggear causa raiz.
- **`skills/`** — Skills modulares. Cada skill es un `SKILL.md` que Claude lee antes de escribir o revisar codigo en ese contexto (React, Next.js, NestJS, Tailwind, testing, arquitectura, etc.). Incluye `dev-pipeline`, que ahora es motor de implementacion post-plan.

## Para quien es

Desarrolladores senior que usan Claude Code a diario y quieren que se comporte como un ingeniero senior competente, no como un bot de tutoriales. Util especificamente si trabajas con:

- Next.js (App Router, RSC, Server Actions)
- TypeScript strict
- NestJS (Controller → Service → Repository)
- Firebase / Firestore o Supabase / PostgreSQL
- Tailwind CSS v4
- TanStack Query, React Hook Form, Framer Motion, Zustand

No esta disenado para principiantes. Claude esta configurado para hacer push back en codigo-sin-contexto, analizar opciones, desafiar soluciones, estimar incertidumbre, aplicar convenciones y explicar tradeoffs — no para hacer lo que le pidas sin cuestionarlo.

## Workflow recomendado

```text
Ticket
  -> /analyze-feature
  -> /create-plan
  -> /dev-pipeline
  -> /review-work
  -> /create-pr
```

Para bugs:

```text
Bug
  -> /debug-root-cause
  -> fix minimo o /dev-pipeline si toca varios archivos
  -> /review-work
  -> /create-pr
```

Regla clave: `/dev-pipeline` no es el primer paso para features/refactors medianos o grandes. Primero tiene que existir analisis, solucion elegida, plan aprobado, criterios de aceptacion, riesgos y fuera de scope.

## Que enforcea

- Analisis antes de implementacion para cambios no triviales
- Opciones, challenge y estimacion dentro de `/analyze-feature`
- Plan tecnico ejecutable antes de `/dev-pipeline`
- Review antes de PR
- Funciones `const` en todos lados — nunca keyword `function`
- Patron `interface IXxxProps` para props de React
- Separacion estricta de modulos: `components/` / `hooks/` / `utils/` / `services/` / `mappers/` / `types/`
- Max ~100 lineas por componente, ~150 por archivo
- Patron early return, lookup objects en vez de switch/if-else chains
- TypeScript strict — sin `any`, sin casteos sin validar
- Sin `useEffect` para data fetching — Server Components o TanStack Query
- Sin `"use client"` por defecto — Server Component primero
- `export default` por archivo de componente + re-export en `index.ts` — sin imports con nombre repetido

## Como instalar y actualizar

Requiere [Claude Code](https://docs.anthropic.com/en/docs/claude-code) instalado.

### Linux / macOS

```bash
git clone https://github.com/Ezequielpereyraa/ai-config.git ~/ai-config
cd ~/ai-config
chmod +x ai.sh
./ai.sh install
```

### Windows

```powershell
git clone https://github.com/Ezequielpereyraa/ai-config.git ~/ai-config
cd ~/ai-config
.\install.ps1
```

El script de Windows intenta crear symlinks primero. Si no puede (sin permisos), copia los archivos como fallback.

**Para tener symlinks en Windows** (recomendado):
- Ir a **Configuracion → Para desarrolladores** y activar **Modo desarrollador**, o
- Ejecutar PowerShell como Administrador

---

Los archivos existentes se respaldan con sufijo `.backup` antes de ser reemplazados.

Reinicia Claude Code despues de instalar para que los cambios tomen efecto.

## CLI — ai.sh

Punto de entrada unificado para instalar y actualizar todo:

```bash
./ai.sh install           # instala todo (claude + cursor)
./ai.sh install claude    # solo claude
./ai.sh install cursor    # solo cursor

./ai.sh update            # git pull + sincroniza todo
./ai.sh update claude     # git pull + solo claude
./ai.sh update cursor     # git pull + solo cursor
```

**Por que re-ejecutar en vez de solo `git pull`:**
Las skills existentes se actualizan solas (son symlinks). Pero si se agrega una skill nueva al repo, hay que re-ejecutar el script para crear el symlink correspondiente. `./ai.sh update` hace el pull y la sincronizacion en un solo paso.

## Comandos incluidos

| Command | Cuando se usa |
|---|---|
| `/analyze-feature` | Ticket nuevo, requerimiento, refactor mediano/grande. Analiza contexto, opciones, challenge, riesgos y estimacion. |
| `/create-plan` | Despues de elegir una solucion. Produce plan tecnico ejecutable para `/dev-pipeline`. |
| `/dev-pipeline` | Despues de analisis + plan aprobado. Implementa, verifica y deja listo para review. |
| `/review-work` | Review de diff, PR o arquitectura. Unifica code review y architecture review. |
| `/debug-root-cause` | Bugs. Investiga causa raiz antes del fix. |
| `/create-pr` | Antes de abrir PR. Genera contexto, solucion, testing, riesgos y rollback. |

Para tareas muy chicas no hace falta comando: hablale por chat. Si el cambio es claro, acotado y sin decision de arquitectura, Claude debe resolverlo directo con minimo ceremony.

## Skills incluidos

| Skill | Cuando se activa |
|---|---|
| `dev-pipeline` | Implementacion post-plan con scope aprobado |
| `engineering-standards` | Codigo/review TS/JS: estilo, boundaries, errores y performance |
| `code-investigator` | "Como funciona X?", "explicame este flujo" |
| `react-19` | Componentes React, hooks, JSX |
| `nextjs` | Routing de Next.js, RSC, Server Actions, data fetching |
| `typescript` | Tipos, interfaces, generics |
| `tailwind-4` | Clases de Tailwind |
| `nestjs` | Modulos, controllers, services, guards, DTOs de NestJS |
| `vitest` | Tests unitarios |
| `architecture-patterns` | Refactors Clean/Hexagonal/DDD (backend) |
| `feature-slice` | Feature-Slice Design para frontend a escala (opcional) |
| `design-init` | Genera `.claude/DESIGN.md` a partir de tokens existentes |
| `ui-design` | UI/UX, responsive, layout, color, motion y performance visual |

## Cursor — nota sobre Global Rules

Las Global Rules de Cursor son el único paso manual que el CLI no puede automatizar. Si las modificás en el repo, hay que copiar el contenido de `cursor/global-rules.md` y pegarlo en Cursor → Settings → General → Rules for AI.

## Requisitos

- Claude Code CLI
- `jq` (usado por `statusline.sh`)
- Opcional: `bat`, `rg` (ripgrep), `fd`, `sd`, `eza` — Claude esta configurado para preferir estas sobre las herramientas Unix estandar
