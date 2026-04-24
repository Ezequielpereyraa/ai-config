---
name: my-error-handling
description: >
  Personal error-handling pattern for TypeScript/JavaScript. Stack-agnostic.
  Trigger: When writing code that crosses a boundary (Server Action, route handler, controller, external API, Firestore/Supabase query, event handler, custom hook).
---

# My Error Handling

> **Scope rule:** Apply to NEW code. When editing existing code you didn't write, match the file's error-handling style — don't refactor unless it's in scope.

> **Default logger:** `console.error`. (Frontend-heavy work. If the project has its own logger, use that — but don't assume one exists.)

---

## 1. The core pattern — `try/catch + logger + rethrow`

At a **boundary**, you wrap the risky call. Log context. Rethrow.

```ts
const createOrder = async (input: IOrderInput) => {
  try {
    const order = await db.orders.insert(input)
    return order
  } catch (error) {
    console.error("[createOrder] failed", { input, error })
    throw error
  }
}
```

**Three non-negotiable parts:**
1. **Log with context.** Tag (`[functionName]`), human message, structured payload.
2. **Rethrow.** Never swallow silently.
3. **Don't transform into a generic error** unless you have a real reason (e.g., hiding internal detail at a public API boundary).

### Anti-patterns

```ts
// ❌ silent swallow
try { await risky() } catch (e) {}

// ❌ generic rethrow — loses the cause
try { await risky() } catch (e) { throw new Error("something went wrong") }

// ❌ log without context
try { await risky() } catch (e) { console.error(e); throw e }

// ❌ catching only to log and continue (broken state downstream)
try { user = await getUser(id) } catch (e) { console.error(e) }
return user.name // 💥
```

---

## 2. Where to catch — boundaries checklist

Catch **only at boundaries**. Pure utils let errors propagate — the boundary above handles them.

| Boundary                                     | Catch here? | Notes                                           |
|----------------------------------------------|-------------|-------------------------------------------------|
| Server Actions (`"use server"`)              | ✅          | User-facing response requires a typed result    |
| Route handlers (`app/api/*/route.ts`)        | ✅          | Return proper HTTP status                       |
| NestJS controllers                           | ✅          | Or rely on global exception filter — not both   |
| External API calls (`fetch`, `axios`, SDKs)  | ✅          | Log payload + status                            |
| Firestore / Supabase queries                 | ✅          | Multi-tenant: include `tenantId` in log context |
| Client event handlers (`onClick`, `onSubmit`)| ✅          | Show UI feedback + log                          |
| Custom hooks (`useXxx`)                      | ✅          | Surface error to caller via return value        |
| `services/`                                  | ✅          | Log + rethrow                                   |
| `utils/` (pure functions)                    | ❌          | Let it propagate                                |
| `mappers/`                                   | ❌          | Let it propagate                                |
| `components/` (pure rendering)               | ❌          | ErrorBoundary handles render errors             |

> **Rule of thumb:** if the function talks to the outside world (network, DB, user input, storage) → boundary. If it transforms data in memory → not a boundary.

---

## 3. Logging — what goes in the context

A useful log reconstructs the failure without reading the code.

```ts
console.error("[tag] what failed", {
  // input that caused the failure (redact secrets)
  input,
  // ids that locate the entity
  userId, tenantId, orderId,
  // the error itself (last — easier to scan)
  error,
})
```

**Always include:**
- A **tag**: `[functionName]` or `[module:operation]`. Makes grep trivial.
- The **input** (or the relevant fields). Redact passwords/tokens.
- Relevant **ids** (user, tenant, request).
- The **error** object (don't stringify — loses stack).

**Never log:**
- Passwords, tokens, API keys, full auth headers.
- Entire request objects (can contain secrets).
- PII beyond what the incident needs.

---

## 4. Error handling by boundary type

### 4.1 Server Actions

```ts
"use server"

interface ICreateOrderResult {
  ok: boolean
  error?: string
}

export const createOrderAction = async (
  input: IOrderInput,
): Promise<ICreateOrderResult> => {
  try {
    await db.orders.insert(input)
    return { ok: true }
  } catch (error) {
    console.error("[createOrderAction] failed", { input, error })
    return { ok: false, error: "Could not create order" }
  }
}
```

> Server Actions **don't rethrow** to the client — they return a typed result. This is the one exception to the rethrow rule.

### 4.2 Route handlers

```ts
export const POST = async (req: Request) => {
  try {
    const body = await req.json()
    const order = await createOrder(body)
    return Response.json(order, { status: 201 })
  } catch (error) {
    console.error("[POST /api/orders] failed", { error })
    return Response.json({ error: "Internal error" }, { status: 500 })
  }
}
```

### 4.3 Client event handlers

```tsx
const handleSubmit = async (data: IFormData) => {
  try {
    await submitForm(data)
    toast.success("Saved")
  } catch (error) {
    console.error("[Form:handleSubmit] failed", { data, error })
    toast.error("Could not save. Try again.")
  }
}
```

> On the client, don't rethrow after showing UI feedback — the user already got the signal.

### 4.4 Custom hooks

```ts
interface IUseUserResult {
  user: IUser | null
  error: Error | null
  loading: boolean
}

const useUser = (id: string): IUseUserResult => {
  const { data, error, isLoading } = useQuery({
    queryKey: ["user", id],
    queryFn: () => getUser(id),
  })

  return { user: data ?? null, error: error ?? null, loading: isLoading }
}
```

> With TanStack Query the catch is handled for you. Surface `error` to the caller — don't swallow.

### 4.5 External API calls

```ts
const fetchUserFromApi = async (id: string) => {
  try {
    const res = await fetch(`${API}/users/${id}`)
    if (!res.ok) {
      throw new Error(`API ${res.status}: ${res.statusText}`)
    }
    return await res.json()
  } catch (error) {
    console.error("[fetchUserFromApi] failed", { id, error })
    throw error
  }
}
```

> Check `res.ok` explicitly — `fetch` only rejects on network failure, not on HTTP errors.

### 4.6 Firestore / Supabase queries

```ts
const getOrders = async (tenantId: string, userId: string) => {
  try {
    const snap = await db
      .collection("orders")
      .where("tenantId", "==", tenantId)
      .where("userId", "==", userId)
      .get()
    return snap.docs.map(d => ({ id: d.id, ...d.data() }))
  } catch (error) {
    console.error("[getOrders] failed", { tenantId, userId, error })
    throw error
  }
}
```

> Multi-tenant: `tenantId` **always** in the log context.

---

## 5. Typing errors

`catch` gives you `unknown`. Narrow before using.

```ts
try {
  await risky()
} catch (error) {
  if (error instanceof ZodError) {
    console.error("[validation]", { issues: error.issues })
    throw error
  }
  if (error instanceof Error) {
    console.error("[unexpected]", { message: error.message, error })
    throw error
  }
  console.error("[non-error thrown]", { error })
  throw new Error("Unknown error")
}
```

Don't cast blindly (`error as Error`). Narrow with `instanceof`.

---

## 6. What NOT to do (quick checklist)

- ❌ Empty `catch {}`
- ❌ `catch (e) { console.log(e) }` (use `console.error` + context)
- ❌ `throw new Error("something went wrong")` (vague, no cause)
- ❌ Catch inside pure utils / mappers
- ❌ Catching only to return `null` and continuing with broken state
- ❌ Logging passwords, tokens, or full auth headers
- ❌ `error as Error` casts without `instanceof` narrowing
- ❌ Double-handling: catch in controller **and** global filter — pick one
