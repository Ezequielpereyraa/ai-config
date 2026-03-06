---
name: react-19
description: >
  React 19 patterns with React Compiler. Best practices, new hooks, and upgrade nudges.
  Trigger: When writing React components - no useMemo/useCallback needed.
---

# React 19 — Senior Patterns & Best Practices

> Assumes React 19 + React Compiler. No basics. Focus on what changed and what to stop doing.

## React Compiler — No More Manual Memoization

```typescript
// ✅ Compiler handles this automatically
const Component = ({ items }: { items: IItem[] }) => {
  const filtered = items.filter(x => x.active)
  const handleClick = (id: string) => console.log(id)
  return <List items={filtered} onClick={handleClick} />
}

// ❌ NEVER — useMemo and useCallback are dead weight with the Compiler
const filtered = useMemo(() => items.filter(x => x.active), [items])
const handleClick = useCallback((id: string) => console.log(id), [])
```

> **Nudge:** Any `useMemo` / `useCallback` in new code is wrong. In existing code, flag it for removal.

## Imports

```typescript
// ✅ Named imports only
import { useState, useEffect, useRef, use } from 'react'

// ❌ NEVER
import React from 'react'
import * as React from 'react'
```

## Server Component First

```typescript
// ✅ Default — no directive, async, fetches on the server
const Page = async () => {
  const data = await fetchData()
  return <ClientComponent data={data} />
}

// ✅ Client — only when you need interactivity
'use client'
const Counter = () => {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>
}
```

**Add `'use client'` only for: state, effects, event handlers, browser APIs.**

## use() Hook

```typescript
import { use } from 'react'

// Read a promise — suspends until resolved (replaces await in RSC for client)
const Comments = ({ promise }: { promise: Promise<IComment[]> }) => {
  const comments = use(promise)
  return comments.map(c => <div key={c.id}>{c.text}</div>)
}

// Read context conditionally — not possible with useContext
const Theme = ({ show }: { show: boolean }) => {
  if (!show) return null
  const theme = use(ThemeContext)
  return <div style={{ color: theme.primary }}>Themed</div>
}
```

> **Nudge:** `use()` with a promise + `<Suspense>` is the new pattern for async data in Client Components. Flag `useEffect` + `useState` data fetching.

## useActionState

```typescript
import { useActionState } from 'react'

// Replaces useFormState from react-dom (deprecated)
const Form = () => {
  const [state, action, isPending] = useActionState(submitAction, null)
  return (
    <form action={action}>
      {state?.error && <p>{state.error}</p>}
      <input name="name" required />
      <button disabled={isPending}>{isPending ? 'Saving...' : 'Save'}</button>
    </form>
  )
}
```

> **Nudge:** If you see `useFormState` from `react-dom`, replace with `useActionState` from `react`.

## useFormStatus

```typescript
import { useFormStatus } from 'react-dom'

// Must be inside a <form> — reads the parent form's pending state
const SubmitButton = () => {
  const { pending } = useFormStatus()
  return <button disabled={pending}>{pending ? 'Saving...' : 'Save'}</button>
}

// Usage
const Form = () => (
  <form action={serverAction}>
    <input name="name" />
    <SubmitButton />  {/* knows the form is pending without prop drilling */}
  </form>
)
```

## useOptimistic

```typescript
import { useOptimistic } from 'react'

const TodoList = ({ todos, addTodo }: ITodoListProps) => {
  const [optimisticTodos, addOptimistic] = useOptimistic(
    todos,
    (state, newTodo: ITodo) => [...state, { ...newTodo, pending: true }]
  )

  const handleSubmit = async (formData: FormData) => {
    const newTodo = { id: crypto.randomUUID(), text: formData.get('text') as string }
    addOptimistic(newTodo)  // instant UI update
    await addTodo(newTodo)  // actual server call
  }

  return (
    <form action={handleSubmit}>
      {optimisticTodos.map(t => (
        <div key={t.id} style={{ opacity: t.pending ? 0.5 : 1 }}>{t.text}</div>
      ))}
      <input name="text" /><button>Add</button>
    </form>
  )
}
```

> **Nudge:** Any "optimistic UI" implemented with manual state + rollback logic → replace with `useOptimistic`.

## ref as Prop — No More forwardRef

```typescript
// ✅ React 19: ref is a regular prop
const Input = ({ ref, ...props }: React.InputHTMLAttributes<HTMLInputElement> & { ref?: React.Ref<HTMLInputElement> }) => (
  <input ref={ref} {...props} />
)

// ❌ Old — forwardRef is unnecessary in React 19
const Input = forwardRef<HTMLInputElement, React.InputHTMLAttributes<HTMLInputElement>>(
  (props, ref) => <input ref={ref} {...props} />
)
```

> **Nudge:** Any `forwardRef` in new code is wrong. Flag existing ones for migration.

## Context as Provider

```typescript
// ✅ React 19: Context directly as provider
const ThemeContext = createContext<ITheme | null>(null)

const App = () => (
  <ThemeContext value={{ primary: '#0070f3' }}>
    <Page />
  </ThemeContext>
)

// ❌ Old
<ThemeContext.Provider value={{ primary: '#0070f3' }}>
```

## Document Metadata in Components

```typescript
// ✅ React 19: metadata tags work directly in components (hoisted to <head>)
const BlogPost = ({ post }: { post: IPost }) => (
  <>
    <title>{post.title}</title>
    <meta name="description" content={post.summary} />
    <link rel="canonical" href={`https://example.com/posts/${post.slug}`} />
    <article>{post.content}</article>
  </>
)
```

> In Next.js, prefer `generateMetadata` for SEO-critical metadata. Use this pattern for dynamic in-component cases.

## Upgrade Nudges — Patterns to Flag

| If you see this | Suggest this |
|---|---|
| `useMemo` / `useCallback` | Remove — React Compiler handles it |
| `useFormState` from `react-dom` | Replace with `useActionState` from `react` |
| `forwardRef` | Remove — ref is a prop in React 19 |
| `<Context.Provider>` | Use `<Context>` directly |
| Manual optimistic state + rollback | `useOptimistic` |
| `useEffect` + `useState` for async data | `use()` + `<Suspense>` or Server Component |
| `import React from 'react'` | Named imports only |
| Prop drilling for form pending state | `useFormStatus` in child button |
| `React.memo()` on most components | Remove — Compiler handles this |
