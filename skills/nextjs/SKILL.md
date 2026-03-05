---
name: nextjs
description: >
  Next.js App Router patterns, RSC boundaries, data fetching, Server Actions, caching, performance.
  Trigger: When working with Next.js — routing, components, data, optimization.
---

# Next.js — Patterns & Best Practices

## App Router File Conventions

```
app/
├── layout.tsx          # Root layout (required)
├── page.tsx            # Route UI
├── loading.tsx         # Suspense boundary
├── error.tsx           # Error boundary ('use client')
├── not-found.tsx       # 404
├── (group)/            # Route group — no URL impact
├── [slug]/page.tsx     # Dynamic segment
├── api/route.ts        # Route handler
└── _components/        # Private — not routed
```

## Server vs Client — Decision

```
Needs useState/useEffect/events? → 'use client'
Needs browser APIs?              → 'use client'
Just renders data?               → Server Component (default)
Both?                            → Server parent + Client leaf
```

**Rule:** Server Component by default. Add `'use client'` only when required. Never add it out of habit.

## Data Fetching

```typescript
// ✅ Parallel — never waterfall
const [users, posts] = await Promise.all([getUsers(), getPosts()])

// ✅ Streaming with Suspense
<Suspense fallback={<Skeleton />}>
  <SlowComponent />  {/* fetches independently */}
</Suspense>

// ✅ Caching
fetch(url)                          // static (cached)
fetch(url, { next: { revalidate: 60 } })  // ISR
fetch(url, { cache: 'no-store' })   // dynamic
```

## Server Actions

```typescript
// app/actions.ts
'use server'
import { revalidatePath } from 'next/cache'

export const createItem = async (formData: FormData) => {
  const name = formData.get('name') as string
  await db.items.create({ data: { name } })
  revalidatePath('/items')
}

// Usage — no API route needed
<form action={createItem}>
  <input name="name" />
  <button type="submit">Create</button>
</form>
```

## Async APIs (Next.js 15+)

```typescript
// params and searchParams are now async
export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  // ...
}

// cookies and headers are also async
import { cookies, headers } from 'next/headers'
const cookieStore = await cookies()
const headersList = await headers()
```

## Route Handlers

```typescript
// app/api/items/route.ts
export const GET = async (request: NextRequest) => {
  const items = await db.items.findMany()
  return NextResponse.json(items)
}

export const POST = async (request: NextRequest) => {
  const body = await request.json()
  const item = await db.items.create({ data: body })
  return NextResponse.json(item, { status: 201 })
}
```

## Performance — Critical Rules

**Eliminate waterfalls (CRITICAL)**
- `Promise.all()` for independent fetches
- Start promises early, await late
- Use Suspense to stream content — don't block entire page

**Bundle size (CRITICAL)**
- `dynamic()` for heavy client components
- Import directly — avoid barrel files (`import { fn } from 'lib'` not `import * from 'lib/index'`)
- Load analytics/third-party after hydration

**Server-side (HIGH)**
- `React.cache()` for per-request deduplication
- Minimize data passed to client components (serialize only what's needed)
- Restructure components to parallelize fetches — don't fetch sequentially in tree

## Image & Navigation

```typescript
import Image from 'next/image'
import Link from 'next/link'

// ✅ Always next/image — never <img>
<Image src="/hero.jpg" alt="..." width={800} height={600} priority />

// ✅ Always next/link for internal navigation
<Link href="/dashboard">Dashboard</Link>
```

## server-only

```typescript
import 'server-only'
// Throws at build if imported in a client component
export const getSecret = async () => db.secrets.findMany()
```

## Anti-patterns

| ❌ Don't | ✅ Do |
|----------|-------|
| `'use client'` by default | Server Component unless needed |
| Sequential awaits in components | `Promise.all()` |
| Barrel file imports | Direct imports |
| `useEffect` for data fetch | Server Components or TanStack Query |
| `<img>` tags | `next/image` |
| Hardcoded `href` strings | `next/link` |
| Global state for server data | Next.js cache + `revalidate` |
| Skip loading.tsx | Always add Suspense boundaries |
