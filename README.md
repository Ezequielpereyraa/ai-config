# ai-config

Configuracion personal de Claude Code — comportamiento, convenciones y skills para un flujo de trabajo senior fullstack/SaaS.

## Que es esto

Un conjunto de archivos que configuran como se comporta Claude Code en todos tus proyectos:

- **`CLAUDE.md`** — Instrucciones globales: personalidad, tono, convenciones de codigo, reglas de auto-carga de skills y perfil de usuario. Claude lo lee en cada conversacion.
- **`settings.json`** — Permisos (que herramientas puede usar Claude, cuales estan bloqueadas, cuales requieren confirmacion), status line personalizado y preferencias de output.
- **`statusline.sh`** — Barra de estado personalizada dentro de Claude Code: muestra el modelo activo, directorio actual, rama de git, lineas agregadas/eliminadas y uso de la ventana de contexto como barra de progreso.
- **`skills/`** — Skills modulares. Cada skill es un `SKILL.md` que Claude lee antes de escribir codigo en ese contexto (React, Next.js, NestJS, Supabase, Tailwind, etc.). Incluye el skill `dev-pipeline` — un flujo de trabajo multi-agente de 5 fases que investiga antes de implementar, propone una lista de tareas, espera aprobacion y luego codea.

## Para quien es

Desarrolladores senior que usan Claude Code a diario y quieren que se comporte como un ingeniero senior competente, no como un bot de tutoriales. Util especificamente si trabajas con:

- Next.js (App Router, RSC, Server Actions)
- TypeScript strict
- NestJS (Controller → Service → Repository)
- Firebase / Firestore o Supabase / PostgreSQL
- Tailwind CSS v4
- TanStack Query, React Hook Form, Framer Motion, Zustand

No esta disenado para principiantes. Claude esta configurado para hacer push back en codigo-sin-contexto, aplicar convenciones y explicar tradeoffs — no para hacer lo que le pidas sin cuestionarlo.

## Que enforcea

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

## Skills incluidos

| Skill | Cuando se activa |
|---|---|
| `dev-pipeline` | Cualquier feature, componente, refactor o tarea multi-archivo |
| `code-investigator` | "Como funciona X?", "explicame este flujo" |
| `react-19` | Componentes React, hooks, JSX |
| `nextjs` | Routing de Next.js, RSC, Server Actions, data fetching |
| `typescript` | Tipos, interfaces, generics |
| `tailwind-4` | Clases de Tailwind |
| `nestjs` | Modulos, controllers, services, guards, DTOs de NestJS |
| `vitest` | Tests unitarios |
| `architecture-patterns` | Refactors Clean/Hexagonal/DDD (backend) |
| `feature-slice` | Feature-Slice Design para frontend a escala (opcional) |

## Cursor — nota sobre Global Rules

Las Global Rules de Cursor son el único paso manual que el CLI no puede automatizar. Si las modificás en el repo, hay que copiar el contenido de `cursor/global-rules.md` y pegarlo en Cursor → Settings → General → Rules for AI.

## Requisitos

- Claude Code CLI
- `jq` (usado por `statusline.sh`)
- Opcional: `bat`, `rg` (ripgrep), `fd`, `sd`, `eza` — Claude esta configurado para preferir estas sobre las herramientas Unix estandar
