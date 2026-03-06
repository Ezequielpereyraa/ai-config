---
name: feature-slice
description: >
  Feature-Slice Design (FSD) for frontend architecture. Optional pattern for large-scale Next.js projects.
  Trigger: When the user explicitly asks about FSD, or when a frontend codebase has grown beyond ~10 features and the flat structure is causing coupling problems.
  DO NOT trigger for standard feature implementations — use only when restructuring frontend architecture.
---

# Feature-Slice Design — Frontend Architecture

> Patrón opcional. No imponer en proyectos pequeños o medianos. Leer "Cuándo usar" antes de cualquier recomendación.

## Cuándo usar FSD

**Vale la pena cuando:**
- El proyecto tiene 10+ features con lógica de UI propia
- Hay acoplamiento entre features no relacionadas
- Múltiples devs trabajan en paralelo y se pisan
- Los imports cruzados entre módulos empiezan a ser un problema real

**No usar cuando:**
- Proyecto pequeño o mediano con estructura plana que funciona
- Solo-dev en proyecto donde el overhead no aporta valor
- El usuario no lo pidió explícitamente — no sugerir como default

**Alternativa más simple que FSD:** si el problema es acoplamiento entre features, primero intentar separar por `features/[name]/` dentro de la estructura actual antes de migrar a FSD completo.

---

## Capas y dependencias

```
app/        ← providers, router, global middleware, layout raíz
pages/      ← composición de widgets por ruta (Next.js: app/ directory)
widgets/    ← bloques de UI complejos compuestos de features + entities
features/   ← acciones del usuario con lógica de negocio propia
entities/   ← objetos de dominio con su UI y lógica
shared/     ← UI genérica, utils, hooks sin dominio de negocio
```

**Regla de dependencias (no negociable):**
```
app → pages → widgets → features → entities → shared
```
Cada capa solo importa de las capas que están DEBAJO. Nunca hacia arriba.

---

## Estructura en Next.js (App Router)

```
src/
  app/                        ← Next.js App Router (capa app de FSD)
    layout.tsx
    (dashboard)/
      page.tsx                ← importa de pages/
    api/
      route.ts

  pages/                      ← composición de UI por ruta
    dashboard/
      ui/
        DashboardPage.tsx     ← orquesta widgets
      index.ts

  widgets/                    ← bloques complejos reutilizables
    sidebar/
      ui/
        Sidebar.tsx
      model/
        sidebar.store.ts      ← estado local del widget
      index.ts
    header/
      ui/
        Header.tsx
      index.ts

  features/                   ← acciones del usuario
    auth/
      login/
        ui/
          LoginForm.tsx
        model/
          login.action.ts     ← Server Action o mutation
        api/
          login.api.ts        ← llamada al endpoint
        index.ts
      logout/
        ui/
          LogoutButton.tsx
        index.ts

    subscription/
      upgrade-plan/
        ui/
          UpgradePlanModal.tsx
        model/
          upgrade.action.ts
        index.ts

  entities/                   ← objetos de dominio
    user/
      ui/
        UserAvatar.tsx
        UserCard.tsx
      model/
        user.types.ts
        user.utils.ts
      api/
        user.api.ts
      index.ts
    subscription/
      ui/
        PlanBadge.tsx
      model/
        subscription.types.ts
      index.ts

  shared/                     ← sin dominio de negocio
    ui/
      Button/
      Input/
      Modal/
    lib/
      cn.ts
      format.ts
    hooks/
      useDebounce.ts
      useMediaQuery.ts
    config/
      routes.ts
      env.ts
```

---

## Segmentos dentro de cada slice

Cada slice puede tener estos segmentos (solo los que necesita):

```
ui/      ← componentes React del slice
model/   ← estado, tipos, lógica de negocio local
api/     ← llamadas a servicios externos o Server Actions
lib/     ← utils específicos del slice
config/  ← constantes y configuración del slice
```

---

## Public API — index.ts obligatorio

Cada slice expone solo lo que otros necesitan. Nada se importa directamente desde adentro.

```ts
// features/auth/login/index.ts
export { LoginForm } from './ui/LoginForm'
export type { ILoginState } from './model/login.types'

// ✅ Importar por la public API
import { LoginForm } from '@/features/auth/login'

// ❌ Nunca importar internals directamente
import { LoginForm } from '@/features/auth/login/ui/LoginForm'
```

---

## Convivencia con Next.js App Router

Next.js `app/` es la capa **app** de FSD. Las páginas en `app/` son thin — solo componen desde `pages/`.

```tsx
// app/(dashboard)/users/page.tsx — thin, solo composición
import { UsersPage } from '@/pages/users'

export default function Page() {
  return <UsersPage />
}

// pages/users/ui/UsersPage.tsx — orquesta widgets
import { UsersList } from '@/widgets/users-list'
import { InviteUserButton } from '@/features/users/invite'

export const UsersPage = () => (
  <div>
    <InviteUserButton />
    <UsersList />
  </div>
)
```

---

## Migración incremental desde estructura plana

No es necesario migrar todo de una. Estrategia gradual:

```
1. Crear shared/ primero — mover UI genérica y utils sin dominio
2. Crear entities/ — mover tipos e UI de objetos de dominio
3. Crear features/ — agrupar por acción de usuario (una a la vez)
4. Crear widgets/ — solo cuando tengas bloques complejos reutilizables
5. Crear pages/ — último paso, cuando la composición por ruta tiene lógica propia
```

Podés tener FSD parcial: solo `shared/` + `features/` ya resuelve la mayoría del acoplamiento.

---

## Reglas de eslint para enforcea las dependencias

```json
// .eslintrc con eslint-plugin-boundaries o @feature-sliced/eslint-config
{
  "rules": {
    "boundaries/element-types": ["error", {
      "default": "disallow",
      "rules": [
        { "from": "app",      "allow": ["pages", "widgets", "features", "entities", "shared"] },
        { "from": "pages",    "allow": ["widgets", "features", "entities", "shared"] },
        { "from": "widgets",  "allow": ["features", "entities", "shared"] },
        { "from": "features", "allow": ["entities", "shared"] },
        { "from": "entities", "allow": ["shared"] },
        { "from": "shared",   "allow": [] }
      ]
    }]
  }
}
```

---

## Upgrade Nudges — Patterns to Flag

| Si ves esto | Sugerí esto |
|---|---|
| `features/` importa de `widgets/` | Viola la regla de dependencias — invertir o mover a shared |
| Componente en `shared/` con lógica de negocio | Mover a `entities/` o `features/` |
| Page importa directamente de `features/` sin pasar por `widgets/` | OK para apps medianas, en FSD estricto agregar widget |
| Imports de internals (`/ui/Component` directo) | Usar solo la public API del `index.ts` |
| Proyecto con 3-4 features usando FSD | Overhead innecesario — considerar estructura plana |
| Cross-feature import (`features/a` importa de `features/b`) | Mover lo compartido a `entities/` o `shared/` |
