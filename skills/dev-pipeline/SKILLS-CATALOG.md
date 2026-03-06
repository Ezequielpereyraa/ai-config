# Catalogo de skills disponibles

Referencia para la Fase 0 del pipeline. Mapea las dependencias del `package.json` a las skills correspondientes y lee los archivos indicados.

Todos los paths apuntan a `~/.claude/skills/`.

---

## Next.js

**Detectar:** `"next"` en dependencies o devDependencies

| Skill | Path | Cuando priorizar |
|---|---|---|
| nextjs | `~/.claude/skills/nextjs/SKILL.md` | Siempre con Next.js — incluye patrones de Next 15 |

---

## React

**Detectar:** `"react"` en dependencies

| Skill | Path | Cuando priorizar |
|---|---|---|
| react-19 | `~/.claude/skills/react-19/SKILL.md` | Si la version de React es >= 19 |

> Si el proyecto usa Next.js, React siempre aplica tambien.

---

## TypeScript

**Detectar:** `"typescript"` o cualquier `"@types/*"` en devDependencies

| Skill | Path | Cuando priorizar |
|---|---|---|
| typescript | `~/.claude/skills/typescript/SKILL.md` | Siempre que haya TypeScript |

---

## Tailwind CSS

**Detectar:** `"tailwindcss"` en dependencies o devDependencies

| Skill | Path | Cuando priorizar |
|---|---|---|
| tailwind-4 | `~/.claude/skills/tailwind-4/SKILL.md` | Si la version es >= 4 |

---

## Formularios

**Detectar:** `"react-hook-form"` en dependencies

| Skill | Path | Cuando priorizar |
|---|---|---|
| react-hook-form | `~/.claude/skills/react-hook-form/SKILL.md` | Siempre que haya formularios |

---

## Testing unitario

**Detectar:** `"vitest"` o `"@vitest/*"` en devDependencies

| Skill | Path | Cuando priorizar |
|---|---|---|
| vitest | `~/.claude/skills/vitest/SKILL.md` | Cuando la tarea incluya tests unitarios |

---

## Animaciones

**Detectar:** `"framer-motion"` o `"motion"` en dependencies

| Skill | Path | Cuando priorizar |
|---|---|---|
| framer-motion | `~/.claude/skills/framer-motion/SKILL.md` | Cuando la tarea incluya animaciones o transiciones |

---

## Data fetching cliente

**Detectar:** `"@tanstack/react-query"` o `"react-query"` en dependencies

| Skill | Path | Cuando priorizar |
|---|---|---|
| tanstack-query-best-practices | `~/.claude/skills/tanstack-query-best-practices/SKILL.md` | Para hooks de data fetching, cache, mutaciones |

---

## AI / Vercel AI SDK

**Detectar:** `"ai"` o `"@ai-sdk/*"` en dependencies

| Skill | Path | Cuando priorizar |
|---|---|---|
| ai-sdk-5 | `~/.claude/skills/ai-sdk-5/SKILL.md` | Para features de IA, streaming, chat |

---

## NestJS

**Detectar:** `"@nestjs/core"` en dependencies

| Skill | Path | Cuando priorizar |
|---|---|---|
| nestjs | `~/.claude/skills/nestjs/SKILL.md` | Siempre que haya NestJS |

---

## Arquitectura

**Detectar:** proyectos con estructura de modulos compleja, monorepos, o cuando la tarea es un refactor de arquitectura

| Skill | Path | Cuando priorizar |
|---|---|---|
| architecture-patterns | `~/.claude/skills/architecture-patterns/SKILL.md` | Refactors de arquitectura, diseno de modulos |

---

## SEO

**Detectar:** el usuario menciona SEO, meta tags, rankings

| Skill | Path | Cuando priorizar |
|---|---|---|
| seo-audit | `~/.claude/skills/seo-audit/SKILL.md` | Auditorias o mejoras de SEO tecnico |

---

## Stack tipico — Next.js + TypeScript + Tailwind

Para el stack mas comun, las skills minimas a cargar siempre son:

1. `~/.claude/skills/nextjs/SKILL.md`
2. `~/.claude/skills/react-19/SKILL.md`
3. `~/.claude/skills/typescript/SKILL.md`
4. `~/.claude/skills/tailwind-4/SKILL.md`

Agregar segun lo que se detecte adicionalmente:
- `react-hook-form` → si hay formularios
- `tanstack-query-best-practices` → si hay data fetching cliente
- `framer-motion` → si hay animaciones
- `vitest` → si hay tests unitarios
- `ai-sdk-5` → si hay integracion de IA
- `nestjs` → si hay backend NestJS
