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

## Server → Client boundary

### Solo valores serializables como props

Los Client Components solo aceptan props que se pueden serializar a JSON. Si pasás algo no serializable, React tira error en runtime.

```ts
// ❌ — función, instancia de clase, Date, Map, Set
<ClientComponent
  onClick={handleClick}       // función no serializable
  date={new Date()}           // Date no es plain object
  user={new UserClass()}      // instancia de clase
/>

// ✅ — primitivos y plain objects únicamente
<ClientComponent
  label="Confirmar"
  timestamp={date.toISOString()}   // string
  user={{ id: user.id, name: user.name }}  // plain object
/>
```

### Formatear valores en el servidor, no en el cliente

Convertí fechas, números y cualquier valor que necesite transformación **antes** de pasarlo como prop. El Client Component recibe texto listo para mostrar.

```ts
// ❌ — el cliente recibe un timestamp y lo formatea él mismo
<PriceDisplay amount={product.priceInCents} />  // número sin formatear

// ✅ — el server formatea, el cliente solo renderiza
const formattedPrice = formatCurrency(product.priceInCents, 'ARS')
<PriceDisplay price={formattedPrice} />  // string listo
```

**Regla**: si un Client Component tiene lógica de formateo de datos → esa lógica no debería estar ahí. Moverla al server o a un `util` que el server llama.

---

## Validación de datos

### Validar en los límites del sistema, no adentro

Validar cuando los datos entran al sistema: API routes, Server Actions, formularios. No validar internamente entre capas que ya son de confianza.

```ts
// ✅ — validar en el entry point (Server Action / API route)
const schema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
})

const parsed = schema.safeParse(formData)
if (!parsed.success) return { error: parsed.error.flatten() }

// A partir de acá, `parsed.data` es de confianza — no re-validar adentro del servicio
await userService.create(parsed.data)
```

### Nunca asumir la forma de un objeto externo

Datos de APIs externas, Firestore, Supabase o `params`/`searchParams` de Next.js: siempre parsear antes de usar.

```ts
// ❌ — asume que el shape es correcto
const { id, name } = await fetchUser(userId)

// ✅ — parsear con Zod y manejar el error
const result = UserSchema.safeParse(await fetchUser(userId))
if (!result.success) throw new Error('Unexpected user shape')
const { id, name } = result.data
```

### Validaciones deben ser simples y tener sentido de negocio

- Si no sabés exactamente POR QUÉ estás validando algo → no lo validés
- No agregar validaciones defensivas para casos que nunca pueden pasar
- No validar dentro de funciones internas que solo reciben datos ya validados
- Cada validación debe tener una razón explícita de negocio o técnica

```ts
// ❌ — sobre-validación sin sentido, el tipo ya lo garantiza
const getUser = (id: string) => {
  if (!id) throw new Error('id required')       // TypeScript ya lo garantiza
  if (typeof id !== 'string') throw new Error() // idem
  ...
}

// ✅ — solo validar lo que el tipo no puede garantizar
const getUser = (id: string) => {
  if (!id.trim()) throw new Error('id cannot be empty string')
  ...
}
```

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
- ❌ Pasar funciones, instancias de clase, `Date`, `Map`, `Set` como props a Client Components
- ❌ Pasar datos sin formatear al cliente — formatear en servidor o en utils
- ❌ Asumir la forma de datos externos sin parsear (APIs, Firestore, params)
- ❌ Validaciones sin razón de negocio explícita — si no sabés por qué, no la ponés
- ❌ Re-validar datos internos que ya fueron validados en el entry point
