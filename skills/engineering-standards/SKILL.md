---
name: engineering-standards
description: >
  Personal engineering standards for TypeScript/JavaScript: code style, boundaries,
  error handling and pragmatic performance. Trigger when writing or reviewing TS/JS code.
---

# Engineering Standards

> Apply to NEW code. When editing existing code, match the file style unless the change explicitly includes refactor.

## Code Style

- `const` by default. Use `let` only for real reassignment. Never `var`.
- Arrow functions with `const`. Avoid `function` keyword in new code.
- React props use exported interfaces outside the component: `IButtonProps`.
- Components use `default export` plus `index.ts` re-export.
- Hooks, utils and services use named exports.
- Prefer early returns over nested branching.
- Prefer lookup objects or `Map` over long `if/else` or `switch` mapping.
- Keep responsibilities separated:

| Folder | Responsibility |
|---|---|
| `components/` | JSX and presentation. No business logic. |
| `hooks/` | Stateful UI/client logic. |
| `utils/` | Pure functions. No I/O. |
| `services/` | External calls: API, DB, SDKs. |
| `mappers/` | API/domain transformations. |
| `types/` | Interfaces, types and constants. |

## TypeScript

- No `any`. Use `unknown` and narrow.
- Avoid unsafe casts. `as const` is fine; `as SomeType` needs evidence.
- Use `interface` for object contracts, `type` for unions/computed types.
- Prefer const objects over enums unless the codebase already uses enums.

## Error Handling

Catch at boundaries, not inside pure logic.

Boundaries:

- Server Actions
- Route handlers
- NestJS controllers or exception filters
- External API calls
- Firestore/Supabase queries
- Client event handlers
- Custom hooks that surface async state
- `services/`

Default pattern:

```ts
export const createOrder = async (input: IOrderInput) => {
  try {
    return await db.orders.insert(input)
  } catch (error) {
    console.error("[createOrder] failed", { input, error })
    throw error
  }
}
```

Rules:

- Log with a searchable tag and useful context.
- Rethrow at server/service boundaries unless returning a typed user-facing result.
- Do not swallow errors silently.
- Do not replace useful errors with generic errors unless hiding internals at a public boundary.
- Never log secrets, tokens, passwords or full request objects.

## Performance

Do not micro-optimize. Do catch obvious traps.

- Lookup inside a loop -> `Map` or `Set`.
- Repeated membership checks -> `Set`.
- Static finite key mapping -> `Record`.
- Independent async calls -> `Promise.all`.
- Partial failure allowed -> `Promise.allSettled`.
- Heavy non-critical modules/components -> dynamic import.

Examples:

```ts
const rolesById = new Map(roles.map(role => [role.id, role]))

const usersWithRoles = users.map(user => ({
  ...user,
  role: rolesById.get(user.roleId),
}))
```

```ts
const [user, posts, permissions] = await Promise.all([
  getUser(userId),
  getPosts(userId),
  getPermissions(userId),
])
```

## Review Checklist

- [ ] Scope traces back to the request.
- [ ] Logic is in the correct layer.
- [ ] No unnecessary new abstraction.
- [ ] No unsafe types.
- [ ] Boundary errors are logged and surfaced correctly.
- [ ] No repeated O(n) lookup in loops.
- [ ] Independent async work is parallelized.
- [ ] Tests/checks match the risk of the change.
