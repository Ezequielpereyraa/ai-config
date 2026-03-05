# Reglas del proyecto — Referencia para subagentes

Estas reglas son el estándar mínimo de calidad. Aplican a todo código escrito, revisado o refactorizado.

---

## Principios de diseño no negociables

### Reutilización antes que creación
Antes de crear cualquier componente, hook, util o tipo **buscá exhaustivamente** si ya existe algo similar en el proyecto. No asumir que no existe — buscarlo activamente.

### Componentes reutilizables por diseño
Todo componente nuevo debe diseñarse para poder reutilizarse:
- Props genéricas, no hardcodeadas para un único caso de uso
- Sin lógica de negocio específica adentro — eso va en hooks/services/utils
- Nombres que describan qué es el componente, no dónde se usa

### Lógica de negocio protegida
- La lógica de negocio vive en `services/`, `hooks/` o `utils/` — nunca dentro de un componente de UI
- Si no entendés la lógica de negocio de un flujo leyendo el código, preguntá antes de implementar
- No modificar flujos de negocio existentes sin entender por completo su impacto

---

## TypeScript

- Strict mode siempre activo
- `interface` para contratos de objetos/APIs. `type` para uniones e intersecciones
- **Nunca `any`** — usar `unknown` + type narrowing si el tipo no se conoce
- Nunca casteos inseguros (`as SomeType` sin validación previa)
- Genéricos para componentes y funciones reutilizables

---

## Clean Code

### `const` siempre, `let` nunca innecesariamente
- `const` por defecto. Solo `let` si el valor **debe** reasignarse inevitablemente
- Preferir transformaciones funcionales sobre mutación:

```ts
// ❌
let result = []
for (let i = 0; i < items.length; i++) result.push(transform(items[i]))

// ✅
const result = items.map(transform)
```

### Sin `if/else` innecesarios
- **Early return** para eliminar ramas else
- **Ternario** para asignaciones condicionales simples
- **Optional chaining** (`?.`) y **nullish coalescing** (`??`) para guardas
- **Lookup objects** en vez de if/else if o switch para múltiples condiciones:

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

### Separación de responsabilidades
- `utils/` → funciones puras de transformación/formateo
- `hooks/` → lógica stateful reutilizable
- `services/` → llamadas a APIs o integraciones externas
- Una función = una responsabilidad
- **Máximo ~150 líneas por archivo** — si lo supera, extraer
- Un componente por archivo. Un hook por archivo
- Los `index.ts` solo reexportan, no contienen lógica

---

## React / Next.js

### Server Components por defecto
- Si un componente no necesita interactividad ni hooks de browser → **Server Component**
- No agregar `"use client"` por costumbre — solo cuando es estrictamente necesario

### `useEffect` — cuándo NO usarlo
- ❌ Para fetch de datos → usar Server Components o React Query
- ❌ Para derivar estado → usar variables calculadas directamente
- ❌ Para sincronizar con props → usar useMemo o cálculo directo
- ✅ Solo para suscripciones externas, event listeners o integraciones con libs de terceros

### Componentes
- Pequeños, con una sola responsabilidad
- Custom hooks para lógica stateful reutilizable
- TanStack Query para estado del servidor en el cliente
- React Hook Form + Zod para formularios

### Assets y navegación
- Siempre `<Image>` de `next/image` en lugar de `<img>`
- Siempre `<Link>` de `next/link` para navegación interna
- `dynamic()` de Next.js para code splitting de componentes cliente pesados

---

## Performance y Bundle

- `dynamic()` para componentes pesados o que solo se usan en el cliente
- `generateStaticParams` para rutas predecibles (SSG)
- `Suspense` para streaming de partes pesadas
- Cache agresivo con `fetch` options (`force-cache`, `revalidate`, `no-store`)
- `revalidateTag` / `revalidatePath` en Server Actions para invalidar selectivamente
- No importar librerías completas si se usan solo algunas funciones (tree-shaking)
- No usar `barrel imports` de librerías pesadas

---

## Tailwind CSS

- `clsx` + `tailwind-merge` (`cn()`) para clases condicionales
- No usar `@apply` para extraer patrones — extraer a componentes
- Orden de clases: layout → spacing → sizing → typography → color → effects

---

## Anti-patrones — nunca hacer

- ❌ `let` donde `const` + transformación funcional resuelve lo mismo
- ❌ `if/else` cuando early return, ternario o lookup object es más claro
- ❌ `useEffect` para fetch, estado derivado o sync con props
- ❌ `"use client"` innecesario
- ❌ Fetch en el cliente cuando puede hacerse en el servidor
- ❌ Lógica de negocio en componentes o controladores
- ❌ Archivos de más de 150 líneas sin razón justificada
- ❌ `any` o casteos inseguros
- ❌ Strings mágicos hardcodeados — usar constantes o enums
- ❌ `console.log` en código que va a producción
- ❌ Estado global para datos del servidor — usar React Query o cache de Next.js
- ❌ Duplicar lógica que ya existe en `utils/`, `hooks/` o `services/`
