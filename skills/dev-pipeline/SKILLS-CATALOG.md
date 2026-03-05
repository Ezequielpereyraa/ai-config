# Catálogo de skills disponibles

Referencia para la Fase 0 del pipeline. Mapeá las dependencias del `package.json` a las skills correspondientes y leé los archivos indicados.

Todos los paths apuntan a `~/.claude/skills/`.

---

## Next.js

**Detectar:** `"next"` en dependencies o devDependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| next-best-practices | `~/.claude/skills/next-best-practices/SKILL.md` | Siempre con Next.js |
| nextjs-best-practices | `~/.claude/skills/nextjs-best-practices/SKILL.md` | Siempre con Next.js |
| nextjs-15 | `~/.claude/skills/nextjs-15/SKILL.md` | Si la versión de Next.js es >= 15 |
| vercel-react-best-practices | `~/.claude/skills/vercel-react-best-practices/SKILL.md` | Para performance y data fetching |

---

## React

**Detectar:** `"react"` en dependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| react-19 | `~/.claude/skills/react-19/SKILL.md` | Si la versión de React es >= 19 |
| vercel-react-best-practices | `~/.claude/skills/vercel-react-best-practices/SKILL.md` | Para optimización y performance |
| react-doctor | `~/.claude/skills/react-doctor/SKILL.md` | En fases de QA o auditoría |

> Si el proyecto usa Next.js, React siempre aplica también.

---

## TypeScript

**Detectar:** `"typescript"` o cualquier `"@types/*"` en devDependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| typescript | `~/.claude/skills/typescript/SKILL.md` | Siempre que haya TypeScript |

---

## Tailwind CSS

**Detectar:** `"tailwindcss"` en dependencies o devDependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| tailwind-4 | `~/.claude/skills/tailwind-4/SKILL.md` | Si la versión es >= 4 |
| tailwind-design-system | `~/.claude/skills/tailwind-design-system/SKILL.md` | Para sistemas de diseño o componentes de UI |

---

## Validación de datos

**Detectar:** `"zod"` en dependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| zod-4 | `~/.claude/skills/zod-4/SKILL.md` | Siempre que haya Zod |

---

## Estado global

**Detectar:** `"zustand"` en dependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| zustand-5 | `~/.claude/skills/zustand-5/SKILL.md` | Cuando la tarea toque stores o estado global |

---

## Formularios

**Detectar:** `"react-hook-form"` en dependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| react-hook-form | `~/.claude/skills/react-hook-form/SKILL.md` | Siempre que haya formularios |

---

## Testing frontend

**Detectar:** `"vitest"` o `"@vitest/*"` en devDependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| vitest | `~/.claude/skills/vitest/SKILL.md` | Cuando la tarea incluya tests unitarios |

---

## E2E Testing

**Detectar:** `"@playwright/test"` o `"playwright"` en devDependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| playwright | `~/.claude/skills/playwright/SKILL.md` | Cuando la tarea incluya tests E2E |

---

## Animaciones

**Detectar:** `"framer-motion"` o `"motion"` en dependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| framer-motion | `~/.claude/skills/framer-motion/SKILL.md` | Cuando la tarea incluya animaciones o transiciones |

---

## Data fetching cliente

**Detectar:** `"@tanstack/react-query"` o `"react-query"` en dependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| tanstack-query-best-practices | `~/.claude/skills/tanstack-query-best-practices/SKILL.md` | Para hooks de data fetching, caché, mutaciones |

---

## AI / Vercel AI SDK

**Detectar:** `"ai"` o `"@ai-sdk/*"` en dependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| ai-sdk-5 | `~/.claude/skills/ai-sdk-5/SKILL.md` | Para features de IA, streaming, chat |

---

## Firebase

**Detectar:** `"firebase"` o `"firebase-admin"` en dependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| firebase | `~/.claude/skills/firebase/SKILL.md` | Siempre que haya Firebase/Firestore |

---

## Supabase

**Detectar:** `"@supabase/supabase-js"` o `"@supabase/ssr"` en dependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| supabase | `~/.claude/skills/supabase/SKILL.md` | Siempre que haya Supabase |

---

## NestJS

**Detectar:** `"@nestjs/core"` en dependencies

| Skill | Path | Cuándo priorizar |
|---|---|---|
| nestjs | `~/.claude/skills/nestjs/SKILL.md` | Siempre que haya NestJS |

---

## Backend Python / Django

**Detectar:** `django` o `djangorestframework` en requirements.txt

| Skill | Path | Cuándo priorizar |
|---|---|---|
| django-drf | `~/.claude/skills/django-drf/SKILL.md` | Para endpoints DRF, ViewSets, serializers |
| pytest | `~/.claude/skills/pytest/SKILL.md` | Para tests Python |

---

## Arquitectura

**Detectar:** proyectos con estructura de módulos compleja, monorepos, o cuando la tarea es un refactor de arquitectura

| Skill | Path | Cuándo priorizar |
|---|---|---|
| architecture-patterns | `~/.claude/skills/architecture-patterns/SKILL.md` | Refactors de arquitectura, diseño de módulos |

---

## SEO

**Detectar:** el usuario menciona SEO, meta tags, rankings

| Skill | Path | Cuándo priorizar |
|---|---|---|
| seo-audit | `~/.claude/skills/seo-audit/SKILL.md` | Auditorías o mejoras de SEO técnico |

---

## Stack típico — Next.js + TypeScript + Tailwind

Para el stack más común, las skills mínimas a cargar siempre son:

1. `~/.claude/skills/nextjs-15/SKILL.md`
2. `~/.claude/skills/next-best-practices/SKILL.md`
3. `~/.claude/skills/react-19/SKILL.md`
4. `~/.claude/skills/vercel-react-best-practices/SKILL.md`
5. `~/.claude/skills/typescript/SKILL.md`
6. `~/.claude/skills/tailwind-4/SKILL.md`

Agregar según lo que se detecte adicionalmente:
- `zod-4`, `react-hook-form` → si hay formularios
- `tanstack-query-best-practices` → si hay data fetching cliente
- `framer-motion` → si hay animaciones
- `zustand-5` → si hay estado global
- `vitest` → si hay tests unitarios
- `playwright` → si hay tests E2E
- `ai-sdk-5` → si hay integración de IA
