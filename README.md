# ai-config

Personal Claude Code configuration — behavior, conventions, and skills for a senior fullstack/SaaS development workflow.

## What this is

A set of files that configure how Claude Code behaves across all your projects:

- **`CLAUDE.md`** — Global instructions: personality, tone, coding conventions, skill auto-loading rules, and user profile. Claude reads this on every conversation.
- **`settings.json`** — Permissions (which tools Claude can use, which are blocked, which require confirmation), custom status line, and output preferences.
- **`statusline.sh`** — Custom status bar rendered inside Claude Code: shows active model, current directory, git branch, lines added/removed, and context window usage as a progress bar.
- **`skills/`** — Modular skill files. Each skill is a `SKILL.md` that Claude reads before writing code in that context (React, Next.js, NestJS, Supabase, Tailwind, etc.). Also includes the `dev-pipeline` skill — a multi-agent 5-phase workflow that investigates before implementing, proposes a task list, waits for approval, then codes.

## Who this is for

Senior developers who use Claude Code daily and want it to behave like a competent senior engineer, not a tutorial bot. Specifically useful if you work with:

- Next.js (App Router, RSC, Server Actions)
- TypeScript strict
- NestJS (Controller → Service → Repository)
- Firebase / Firestore or Supabase / PostgreSQL
- Tailwind CSS v4
- TanStack Query, React Hook Form, Framer Motion, Zustand

Not designed for beginners. Claude is configured to push back on code-without-context, enforce conventions, and explain tradeoffs — not to just do whatever you ask.

## What it enforces

- `const` functions everywhere — no `function` keyword
- `interface IXxxProps` pattern for React props
- Strict module separation: `components/` / `hooks/` / `utils/` / `services/` / `mappers/` / `types/`
- Max ~100 lines per component, ~150 per file
- Early return pattern, lookup objects instead of switch/if-else chains
- TypeScript strict — no `any`, no unvalidated casts
- No `useEffect` for data fetching — Server Components or TanStack Query
- No `"use client"` by default — Server Component first

## How to install

Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed.

```bash
git clone https://github.com/Ezequielpereyraa/ai-config.git ~/ai-config
cd ~/ai-config
chmod +x install.sh
./install.sh
```

The script creates symlinks from `~/.claude/` to this repo:

| Symlink | Source |
|---|---|
| `~/.claude/CLAUDE.md` | `ai-config/CLAUDE.md` |
| `~/.claude/settings.json` | `ai-config/settings.json` |
| `~/.claude/statusline.sh` | `ai-config/statusline.sh` |
| `~/.claude/skills/` | `ai-config/skills/` |

Existing files are backed up with a `.backup` suffix before being replaced.

Restart Claude Code after running install for changes to take effect.

## Updating

Since everything is symlinked, a `git pull` in this repo is enough:

```bash
cd ~/ai-config && git pull
```

No reinstall needed.

## Skills included

| Skill | Trigger |
|---|---|
| `dev-pipeline` | Any feature, component, refactor, or multi-file task |
| `code-investigator` | "How does X work?", "explain this flow" |
| `react-19` | React components, hooks, JSX |
| `nextjs` | Next.js routing, RSC, Server Actions, data fetching |
| `typescript` | Types, interfaces, generics |
| `tailwind-4` | Tailwind classes |
| `nestjs` | NestJS modules, controllers, services, guards, DTOs |
| `firebase` | Firebase, Firestore, Auth, Storage |
| `supabase` | Supabase, RLS, PostgreSQL via Supabase |
| `tanstack-query-best-practices` | TanStack Query, data fetching, mutations |
| `react-hook-form` | Forms with React Hook Form |
| `zustand-5` | Global state with Zustand |
| `framer-motion` | Animations, transitions |
| `zod-4` | Schema validation with Zod |
| `vitest` | Unit tests |
| `playwright` | E2E tests |
| `django-drf` | Django REST Framework |
| `pytest` | Python tests |
| `architecture-patterns` | Clean/Hexagonal/DDD refactors |
| `react-doctor` | React QA, audit, performance review |
| `seo-audit` | Technical SEO, meta tags |

## Requirements

- Claude Code CLI
- `jq` (used by `statusline.sh`)
- Optional: `bat`, `rg` (ripgrep), `fd`, `sd`, `eza` — Claude is configured to prefer these over standard Unix tools
