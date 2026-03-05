# Reglas del proyecto — Referencia para subagentes

Estas reglas son el estándar mínimo de calidad. Aplican a todo código escrito, revisado o refactorizado.

---

## Principios de diseño no negociables

### Reutilización antes que creación
Antes de crear cualquier componente, hook, util o tipo **buscá exhaustivamente** si ya existe algo similar en el proyecto. No asumir que no existe — buscarlo activamente.

### Componentes reutilizables por diseño
- Props genéricas, no hardcodeadas para un único caso de uso
- Nombre describe QUÉ es el componente, no DÓNDE se usa (`UserCard`, no `DashboardUserCard`)
- Sin lógica de negocio adentro — eso va en hooks/services/utils
- Si un componente solo funciona en un contexto específico → extraer lógica a hook, dejar componente genérico

### Lógica de negocio protegida
- La lógica de negocio vive en `services/`, `hooks/` o `utils/` — nunca dentro de un componente de UI
- Si no entendés la lógica de negocio de un flujo leyendo el código, preguntá antes de implementar
- No modificar flujos de negocio existentes sin entender por completo su impacto

---

## Declaración de funciones — siempre `const`, nunca `function`

```ts
// ❌
function processUser(user: User) { ... }
export default function MyComponent() { ... }

// ✅
const processUser = (user: User) => { ... }
const MyComponent = () => { ... }
export default MyComponent
```

Aplica a: componentes React, funciones utilitarias, handlers, callbacks. Sin excepciones.

---

## Props — tipado fuera del componente, siempre `IProps`

```ts
// ❌ — tipo inline, no reutilizable, no importable
const Card = ({ title, onClick }: { title: string; onClick: () => void }) => { ... }

// ✅ — interface separada, prefijo I, exportable
interface ICardProps {
  title: string
  onClick: () => void
  className?: string
}

const Card = ({ title, onClick, className }: ICardProps) => { ... }
export type { ICardProps }
```

---

## Separación de responsabilidades — estructura obligatoria

```
components/
  UserCard/
    UserCard.tsx          ← solo JSX, cero lógica de negocio
    UserCard.types.ts     ← IUserCardProps y tipos del componente
    index.ts              ← re-export limpio

hooks/
  useUsers.ts             ← lógica stateful, llamadas a servicios
  useUserFilters.ts       ← lógica de filtrado/búsqueda

utils/
  user.utils.ts           ← funciones puras de transformación

mappers/
  user.mapper.ts          ← API response → dominio interno

services/
  user.service.ts         ← llamadas a API / Firestore / Supabase

types/
  user.types.ts           ← interfaces y types del dominio
```

**Regla**: si un componente tiene más de 2-3 líneas de lógica que no son JSX → extraer a hook o util.
**Regla**: máx ~100 líneas por componente. Máx ~150 por cualquier otro archivo. Si se pasa, extraer.

---

## TypeScript

- Strict mode siempre activo
- `interface` (prefijo `I`) para contratos de objetos. `type` para uniones e intersecciones
- **Nunca `any`** — usar `unknown` + type narrowing si el tipo no se conoce
- Nunca casteos inseguros (`as SomeType` sin validación previa)
- Genéricos para componentes y funciones reutilizables

---

## Clean Code

### `const` siempre, `let` solo si el valor debe reasignarse inevitablemente

```ts
// ❌
let result = []
for (let i = 0; i < items.length; i++) result.push(transform(items[i]))

// ✅
const result = items.map(transform)
```

### Early return — validar el caso negativo primero

```ts
// ❌
const process = (user: User | null) => {
  if (user) {
    if (user.active) {
      return doSomething(user)
    } else {
      return null
    }
  } else {
    return null
  }
}

// ✅
const process = (user: User | null) => {
  if (!user) return null
  if (!user.active) return null
  return doSomething(user)
}
```

### Lookup objects en vez de if/else chains o switch

```ts
// ❌
if (role === 'admin') return AdminComponent
else if (role === 'editor') return EditorComponent
else return UserComponent

// ✅
const ROLE_COMPONENT = {
  admin: AdminComponent,
  editor: EditorComponent,
  user: UserComponent,
} as const
const Component = ROLE_COMPONENT[role] ?? ROLE_COMPONENT.user
```

---

## React / Next.js

### Server Components por defecto
- Si un componente no necesita interactividad ni hooks de browser → **Server Component**
- No agregar `"use client"` por costumbre — solo cuando es estrictamente necesario

### `useEffect` — cuándo NO usarlo
- ❌ Para fetch de datos → usar Server Components o React Query
- ❌ Para derivar estado → usar variables calculadas directamente
- ❌ Para sincronizar con props → usar cálculo directo
- ✅ Solo para suscripciones externas, event listeners o integraciones con libs de terceros

### Assets y navegación
- Siempre `<Image>` de `next/image`, nunca `<img>`
- Siempre `<Link>` de `next/link` para navegación interna
- `dynamic()` para code splitting de componentes cliente pesados

---

## Performance y Bundle

- `dynamic()` para componentes pesados o que solo se usan en el cliente
- `Suspense` para streaming de partes pesadas
- Cache agresivo con `fetch` options (`force-cache`, `revalidate`, `no-store`)
- `revalidateTag` / `revalidatePath` en Server Actions para invalidar selectivamente
- No importar librerías completas si se usan solo algunas funciones

---

## Tailwind CSS

- `clsx` + `tailwind-merge` (`cn()`) para clases condicionales
- No usar `@apply` para extraer patrones — extraer a componentes
- Orden de clases: layout → spacing → sizing → typography → color → effects

---

## Anti-patrones — nunca hacer

- ❌ `function` keyword para declarar funciones o componentes
- ❌ Props tipadas inline dentro del componente
- ❌ Lógica de negocio dentro de componentes UI
- ❌ `let` donde `const` + transformación funcional resuelve lo mismo
- ❌ `if/else` cuando early return, ternario o lookup object es más claro
- ❌ `useEffect` para fetch, estado derivado o sync con props
- ❌ `"use client"` innecesario
- ❌ `any` o casteos inseguros
- ❌ Strings mágicos hardcodeados — usar constantes o enums
- ❌ `console.log` en código que va a producción
- ❌ Estado global para datos del servidor — usar React Query o cache de Next.js
- ❌ Duplicar lógica que ya existe en `utils/`, `hooks/`, `mappers/` o `services/`
- ❌ Componentes de más de ~100 líneas
