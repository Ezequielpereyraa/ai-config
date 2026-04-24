---
name: my-code-style
description: >
  Personal TypeScript/JavaScript code style. Stack-agnostic.
  Trigger: Any time you write or edit TS/JS code.
---

# My Code Style

> **Scope rule:** Apply to NEW code. When editing existing code you didn't write, **match the file's style** — don't refactor what you weren't asked to touch.

---

## 1. Variable declarations

- `const` **always**. `let` only when the value is genuinely reassigned.
- `var` is prohibited. No exceptions.

```ts
// ✅
const user = await getUser(id)
const items = rawItems.map(toDomain)

// ✅ let only when reassignment is real
let attempts = 0
while (attempts < MAX) {
  attempts++
}

// ❌ let used as "default"
let user = await getUser(id) // never reassigned
```

---

## 2. Functions

**Arrow + `const`, always.** No `function` keyword — not for components, not for handlers, not for utils.

```ts
// ✅
const getUser = async (id: string) => { /* */ }
const Button = ({ label }: IButtonProps) => <button>{label}</button>
const handleClick = () => { /* */ }

// ❌
function getUser(id: string) { /* */ }
function Button(props: IButtonProps) { /* */ }
```

---

## 3. Props

- Interface declared **outside** the component.
- Name: `IXxxProps` (I-prefix).
- **Exportable** (others may consume it).
- **Never inline.**

```ts
// ✅
export interface IButtonProps {
  label: string
  onClick: () => void
}

const Button = ({ label, onClick }: IButtonProps) => (
  <button onClick={onClick}>{label}</button>
)

// ❌ inline props
const Button = ({ label }: { label: string }) => <button>{label}</button>
```

---

## 4. Exports

### Components → `default export` + `index.ts` re-export

```
components/
  Button/
    Button.tsx      → export default Button
    index.ts        → export { default } from "./Button"
```

```ts
// Button.tsx
const Button = ({ label }: IButtonProps) => <button>{label}</button>
export default Button

// index.ts
export { default } from "./Button"
export type { IButtonProps } from "./Button"
```

### Helpers / utils / hooks → **named exports inline**

```ts
// utils/dates.ts
export const formatDate = (d: Date) => { /* */ }
export const parseDate = (s: string) => { /* */ }
export const isWeekend = (d: Date) => { /* */ }
```

No `index.ts` for util folders unless there's a clear reason to barrel.

---

## 5. Early return — against nesting

The goal is **avoid nested ifs**, not a dogmatic "check negative first" rule. You can start with the positive case if it reads cleaner — what's forbidden is deep branching.

```ts
// ✅ flat
const processOrder = (order: IOrder) => {
  if (!order.items.length) return null
  if (order.status === "cancelled") return null

  const total = calculateTotal(order)
  return { ...order, total }
}

// ❌ nested
const processOrder = (order: IOrder) => {
  if (order.items.length) {
    if (order.status !== "cancelled") {
      const total = calculateTotal(order)
      return { ...order, total }
    }
  }
  return null
}
```

---

## 6. Lookup objects over if/else chains and switch

When mapping a key to a value/behavior, use an object (or `Map`) — not `if/else if` or `switch`.

```ts
// ✅
const ROLE_LABEL: Record<Role, string> = {
  admin: "Administrator",
  editor: "Editor",
  viewer: "Viewer",
}
const label = ROLE_LABEL[role]

// ❌
let label
if (role === "admin") label = "Administrator"
else if (role === "editor") label = "Editor"
else label = "Viewer"

// ❌
switch (role) {
  case "admin": label = "Administrator"; break
  // ...
}
```

For behavior (functions), same idea:

```ts
const ACTIONS: Record<Event, (p: IPayload) => void> = {
  create: handleCreate,
  update: handleUpdate,
  delete: handleDelete,
}
ACTIONS[event](payload)
```

---

## 7. File separation — strict

Each folder has ONE responsibility. Don't mix.

| Folder        | Contains                                  |
|---------------|-------------------------------------------|
| `components/` | JSX only. No business logic.              |
| `hooks/`      | Stateful logic (`useXxx`)                 |
| `utils/`      | Pure functions. No I/O. No side effects.  |
| `services/`   | External calls (API, DB, SDK)             |
| `mappers/`    | API → domain / domain → API transforms    |
| `types/`      | Interfaces, types, enums                  |

If a file violates its folder's contract → move it.

---

## 8. File size guidelines

- Component: **~100 lines max**.
- Other files: **~150 lines max**.

Over limit → extract. Split by responsibility (sub-components, sub-hooks, util helpers).

Not a hard compile error — a code-smell trigger. If you're editing a 300-line legacy file, don't force-refactor it; just don't grow it further.

---

## 9. Naming

- **Components**: `PascalCase`. Describe WHAT, not WHERE. `Modal` not `HomeModal`.
- **Hooks**: `useCamelCase`. `useUser`, `useAuth`.
- **Utils / helpers**: `camelCase` verbs. `formatDate`, `parseToken`.
- **Constants**: `SCREAMING_SNAKE_CASE`. `MAX_RETRIES`, `DEFAULT_PAGE_SIZE`.
- **Types / interfaces**: `PascalCase`. Interfaces prefixed `I`. `IUser`, `UserRole`.
- **Event handlers**: `handleXxx`. Props that accept handlers: `onXxx`. `handleSubmit` internally, `onSubmit` in props.

---

## 10. TypeScript strict rules

- **No `any`.** If you truly don't know the shape, `unknown` + narrow.
- **No unsafe casts** (`as SomeType` without evidence). `as const` is fine. Casting through `unknown` is a red flag — fix the type.
- **Interfaces with `I` prefix.** Types without prefix.
- Prefer `interface` for object contracts, `type` for unions / intersections / computed.

---

## 11. Comments

- **Default: no comments.** Well-named identifiers explain WHAT.
- Add a comment only when the **WHY** is non-obvious: a hidden constraint, a workaround, surprising behavior.
- **No inline prose** explaining what code does.
- **No task/PR references** (`// added for ticket-123`). Dead as soon as the ticket closes.

```ts
// ✅
// Firestore rejects batch writes > 500 ops; chunk to stay under limit
const CHUNK = 450

// ❌
// this function gets the user
const getUser = (id: string) => { /* */ }
```

---

## 12. What NOT to do (quick checklist)

- ❌ `function foo()` syntax
- ❌ `var`
- ❌ Inline prop types `({ foo }: { foo: string })`
- ❌ `any` (use `unknown`)
- ❌ Business logic inside components
- ❌ `useState` for server-fetched data
- ❌ `useEffect` for data fetching
- ❌ Nested if/else when early return / lookup object works
- ❌ Comments explaining WHAT the code does
