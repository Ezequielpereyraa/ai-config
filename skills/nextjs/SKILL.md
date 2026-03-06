---
name: nextjs
description: >
  Next.js App Router best practices, RSC boundaries, data fetching, Server Actions, caching, performance, and upgrade nudges.
  Trigger: When working with Next.js — routing, components, data, optimization.
---

# Next.js — Senior Patterns & Best Practices

> Assumes App Router. No Pages Router. No basics — only patterns that matter at scale.

## App Router File Conventions

```
app/
├── layout.tsx          # Root layout — persists across navigations
├── page.tsx            # Route UI — Server Component by default
├── loading.tsx         # Automatic Suspense boundary
├── error.tsx           # Error boundary — requires 'use client'
├── not-found.tsx       # 404 — triggered by notFound()
├── middleware.ts       # Edge runtime — runs before every request
├── (group)/            # Route group — no URL segment
├── [slug]/page.tsx     # Dynamic segment
├── [...slug]/page.tsx  # Catch-all segment
├── api/route.ts        # Route handler — replaces API routes
└── _components/        # Private — excluded from routing
```

## Server vs Client — Decision Rule

```
Needs useState / useReducer?              → 'use client'
Needs useEffect / lifecycle?              → 'use client'
Needs browser APIs?                       → 'use client'
Needs event handlers?                     → 'use client'
Just renders data / async?                → Server Component (default)
Both concerns?                            → Server parent + Client leaf
```

**Never add `'use client'` out of habit. Push it to the leaves.**

## Data Fetching

```typescript
// ✅ Parallel — never waterfall
const [users, posts] = await Promise.all([getUsers(), getPosts()])

// ✅ Start promises early, await late (avoids waterfall in component tree)
const usersPromise = getUsers()
const postsPromise = getPosts()
const [users, posts] = await Promise.all([usersPromise, postsPromise])

// ✅ Stream slow data — don't block the whole page
<Suspense fallback={<Skeleton />}>
  <SlowComponent />
</Suspense>

// ✅ fetch caching (Next.js 15: no longer cached by default)
fetch(url)                                    // dynamic (no cache)
fetch(url, { next: { revalidate: 60 } })      // ISR — revalidate every 60s
fetch(url, { cache: 'force-cache' })          // static — explicit opt-in

// ✅ React.cache() for per-request deduplication
import { cache } from 'react'
export const getUser = cache(async (id: string) => db.users.findUnique({ where: { id } }))
```

> **Nudge:** Sequential `await` inside a component = waterfall. Always check if fetches are independent and parallelize them.

## Server Actions

```typescript
// app/actions.ts
'use server'
import { revalidatePath, revalidateTag } from 'next/cache'

export const createItem = async (formData: FormData) => {
  const name = formData.get('name') as string
  await db.items.create({ data: { name } })
  revalidatePath('/items')
}

// With useActionState (React 19)
'use client'
import { useActionState } from 'react'

const Form = () => {
  const [state, action, isPending] = useActionState(createItem, null)
  return (
    <form action={action}>
      <input name="name" required />
      <button disabled={isPending}>{isPending ? 'Saving...' : 'Save'}</button>
    </form>
  )
}
```

> **Nudge:** If using an API route just for a mutation from the same app, replace with a Server Action.

## Next.js 15 — Breaking Changes

```typescript
// params and searchParams are now async (BREAKING)
export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
}

export default async function Page({ searchParams }: { searchParams: Promise<{ q: string }> }) {
  const { q } = await searchParams
}

// cookies, headers, draftMode are now async (BREAKING)
import { cookies, headers } from 'next/headers'
const cookieStore = await cookies()
const headersList = await headers()

// fetch() is no longer cached by default (BREAKING)
// Explicit opt-in required: cache: 'force-cache' or next: { revalidate }
```

## Middleware

```typescript
// middleware.ts — root level, runs at Edge
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export const middleware = (request: NextRequest) => {
  const token = request.cookies.get('token')
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*'],
}
```

> **Nudge:** Middleware runs on every request — keep it fast. No DB calls, no heavy computation. Use it for auth redirects, A/B flags, locale detection.

## Metadata

```typescript
// Static
export const metadata = {
  title: 'My App',
  description: 'Description',
  openGraph: { title: 'My App', images: ['/og.png'] },
}

// Dynamic — colocated with the page
export const generateMetadata = async ({ params }: { params: Promise<{ id: string }> }) => {
  const { id } = await params
  const product = await getProduct(id)
  return { title: product.name, description: product.description }
}
```

## Performance — Non-Negotiable

```typescript
// ✅ dynamic() for heavy client components
import dynamic from 'next/dynamic'
const HeavyChart = dynamic(() => import('./HeavyChart'), { ssr: false })

// ✅ next/image — never <img>
import Image from 'next/image'
<Image src="/hero.jpg" alt="..." width={800} height={600} priority />

// ✅ next/link — never <a> for internal navigation
import Link from 'next/link'
<Link href="/dashboard" prefetch>Dashboard</Link>

// ✅ server-only — guard against accidental client imports
import 'server-only'
export const getSecret = async () => db.secrets.findMany()

// ✅ Direct imports — never barrel files for heavy libs
import { format } from 'date-fns/format'  // not: import { format } from 'date-fns'
```

## Caching Strategy

| Pattern | Use case |
|---|---|
| `fetch` with `force-cache` | Static content, rarely changes |
| `fetch` with `revalidate: N` | ISR — periodically fresh |
| `fetch` default (no cache) | Dynamic — user-specific |
| `revalidatePath('/path')` | On-demand after mutation |
| `revalidateTag('tag')` | Targeted cache invalidation |
| `React.cache()` | Deduplicate within a single request |

## Upgrade Nudges — Patterns to Flag

| If you see this | Suggest this |
|---|---|
| `useEffect` for data fetch | Server Component or TanStack Query |
| `fetch` in `useEffect` | Move to Server Component |
| API route for same-app mutation | Server Action |
| `<img>` tag | `next/image` |
| `<a>` for internal link | `next/link` |
| `'use client'` on a page/layout | Push client boundary down to leaf |
| Sequential `await` on independent fetches | `Promise.all()` |
| `params.id` without awaiting (Next.js 15) | `const { id } = await params` |
| Barrel file imports from large libs | Direct subpath import |
| No `loading.tsx` on slow routes | Add Suspense / loading.tsx |
| `getServerSideProps` / `getStaticProps` | Migrate to App Router RSC |
