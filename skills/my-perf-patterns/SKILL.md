---
name: my-perf-patterns
description: >
  Personal performance patterns for TypeScript/JavaScript. Stack-agnostic.
  Trigger: When writing or reviewing code that handles collections, async operations, or heavy modules.
---

# My Performance Patterns

> **Scope rule:** Apply to NEW code. When editing existing code you didn't write, match the file's patterns — don't refactor perf unless it's in scope.

> **Philosophy:** Don't micro-optimize hot paths that don't exist. These rules target **real O(n²) traps** and **obvious wins**, not theoretical gains.

---

## 1. Map / Set vs Array — the core decision

**Ask ONE question:**

> *"Am I going to LOOK UP or CHECK EXISTENCE in this collection more than once?"*

- **YES** → `Map` or `Set`
- **NO** → `Array`

### Why (Big O, one glance)

```ts
array.find(x => x.id === id)   // O(n) each call
array.includes(value)           // O(n) each call
array.some(x => x === value)    // O(n) each call

map.get(id)                     // O(1)
set.has(value)                  // O(1)
```

### Hard rules — no exceptions

#### Rule 1: Lookup INSIDE a loop → Map / Set

```ts
// ❌ O(n²) — breaks at any scale
users.forEach(user => {
  const role = roles.find(r => r.id === user.roleId)
})

// ✅ O(n)
const rolesById = new Map(roles.map(r => [r.id, r]))
users.forEach(user => {
  const role = rolesById.get(user.roleId)
})
```

#### Rule 2: Static config data → Map or Record

```ts
// ✅
const ROLE_PERMISSIONS = new Map<Role, Permission[]>([
  ["admin", ["read", "write", "delete"]],
  ["user", ["read"]],
])

// ✅ if keys are a finite union — Record gives better inference
const ROLE_LABEL: Record<Role, string> = {
  admin: "Administrator",
  user: "User",
}
```

**Rule of thumb:** `Record` for finite string-union keys. `Map` when keys are dynamic, non-string, or when you need `.size` / iteration order.

#### Rule 3: Dedup of primitives → Set

```ts
// ❌
const unique = arr.filter((x, i) => arr.indexOf(x) === i)

// ✅
const unique = [...new Set(arr)]
```

#### Rule 4: Repeated membership checks → Set

```ts
// ❌ .includes runs O(n) every call
const BLOCKED_DOMAINS = ["spam.com", "bad.com", /* ...many */]
emails.filter(e => !BLOCKED_DOMAINS.includes(getDomain(e)))

// ✅
const BLOCKED_DOMAINS = new Set(["spam.com", "bad.com", /* ...many */])
emails.filter(e => !BLOCKED_DOMAINS.has(getDomain(e)))
```

### When Array stays — don't over-engineer

- **One-shot lookup** on a small array (`<~50` items) used once → `.find` is fine.
- Primary operation is `.map / .filter / .reduce` → Array is the natural shape.
- Order matters and you iterate sequentially without key-based access.

---

## 2. Async — parallel by default

Independent async calls go in parallel via `Promise.all`. Sequential `await` is only for **dependent** operations.

```ts
// ❌ sequential — 3x slower
const user = await getUser(id)
const posts = await getPosts(id)
const friends = await getFriends(id)

// ✅ parallel
const [user, posts, friends] = await Promise.all([
  getUser(id),
  getPosts(id),
  getFriends(id),
])
```

**Rule:** before writing a second `await` on the same level, ask: *"Does this depend on the previous one?"* If no → `Promise.all`.

### `Promise.allSettled` when partial failure is OK

If one failure shouldn't kill the rest:

```ts
const results = await Promise.allSettled([
  fetchA(),
  fetchB(),
  fetchC(),
])
const successes = results.filter(r => r.status === "fulfilled")
```

---

## 3. Lazy loading — heavy modules / components

If a component/module is **not critical to first paint** and weighs significantly → dynamic import.

### Next.js / React

```tsx
// ✅ heavy modal loaded only when opened
const HeavyChart = dynamic(() => import("@/components/HeavyChart"), {
  loading: () => <Skeleton />,
})
```

### Plain JS/TS module

```ts
// ✅ heavy lib loaded on demand
const parsePdf = async (file: File) => {
  const { PDFDocument } = await import("pdf-lib")
  return PDFDocument.load(await file.arrayBuffer())
}
```

**When to apply:**
- Modals / drawers that open on user action
- Chart / editor / PDF / media libraries
- Admin-only flows loaded conditionally
- Anything `>50kb` gzipped off the critical path

---

## 4. What this skill does NOT force

These are **case-by-case judgment calls** — we don't hard-enforce:

- **Spread in loops** (`acc = [...acc, x]` vs `.push`) — depends on the operation and mutation context.
- **N+1 query batching** — depends on provider, cache strategy, and whether the parent collection is bounded.
- **`structuredClone` vs `JSON.parse(JSON.stringify())`** — not used.

If one of these becomes a real bottleneck, address it then. Don't pre-optimize.

---

## 5. Anti-patterns — quick checklist

- ❌ `.find` / `.includes` / `.some` inside a `.forEach` / `for` loop
- ❌ `array.filter((x, i) => array.indexOf(x) === i)` for dedup
- ❌ Static lookup tables as `if/else` chains
- ❌ Sequential `await` on independent calls
- ❌ Importing heavy libs at top of the entry file when they're only used in rare flows
