---
name: project-conventions
description: >
  Convenciones de proyecto para Next.js App Router + TypeScript + Tailwind.
  Leer antes de crear o modificar cualquier archivo — estructura, naming, patrones.
---

# Project Conventions

> App Router. TypeScript strict. Tailwind. Sin Pages Router, sin CSS Modules, sin enums.

## Estructura de carpetas

```
src/
  app/                        ← Next.js App Router
    layout.tsx
    page.tsx
    (group)/
      page.tsx
    api/
      route.ts
    _components/              ← componentes privados de la ruta

  components/                 ← componentes genéricos reutilizables
    UserCard/
      UserCard.tsx
      index.ts                ← re-export: export { default } from './UserCard'

  hooks/                      ← lógica stateful
    useUsers.ts

  utils/                      ← funciones puras
    user.utils.ts

  services/                   ← llamadas externas (API, Firestore, Supabase)
    user.service.ts

  mappers/                    ← API response → dominio interno
    user.mapper.ts

  types/                      ← interfaces y types del dominio
    user.types.ts

  lib/                        ← config de librerías (queryClient, supabase, etc.)
    query-client.ts
```

## Naming

| Elemento | Convención | Ejemplo |
|---|---|---|
| Componentes | PascalCase | `UserCard.tsx` |
| Archivos de lógica | camelCase | `useUsers.ts`, `user.utils.ts` |
| Hooks | camelCase con `use` | `useWindowWidth.ts` |
| Constantes | SCREAMING_SNAKE_CASE | `MAX_RETRIES` |
| Interface de props | `IXxxProps` con prefijo `I` | `IUserCardProps` |
| Types de dominio | `IXxx` con prefijo `I` | `IUser`, `IOrder` |
| Directorios de componentes | PascalCase | `UserCard/` |
| Directorios de features | kebab-case | `user-profile/` |

## Componentes

```tsx
// ✅ Estructura estándar

// 1. Imports de librerías externas
import { useState } from 'react'
import Image from 'next/image'

// 2. Imports internos
import { formatDate } from '@/utils/date.utils'
import type { IUser } from '@/types/user.types'

// 3. Interface de props — fuera del componente, prefijo I
interface IUserCardProps {
  user: IUser
  onSelect?: (id: string) => void
  className?: string
}

// 4. Componente — const arrow function
const UserCard = ({ user, onSelect, className }: IUserCardProps) => {
  return (
    <div className={cn('rounded-lg p-4', className)}>
      <p>{user.name}</p>
    </div>
  )
}

// 5. Export default al final
export default UserCard
```

**Reglas:**
- Un archivo = un componente principal
- Max ~100 líneas — si se pasa, extraer
- Sin lógica de negocio — eso va en hooks/services/utils
- Siempre `export default` + `index.ts` con re-export

## TypeScript

```ts
// ✅ interface con I para objetos
interface IUser {
  id: string
  email: string
  role: UserRole
}

// ✅ type para uniones e intersecciones
type UserRole = 'admin' | 'editor' | 'user'
type WithTimestamps<T> = T & { createdAt: string; updatedAt: string }

// ✅ const object en vez de enum
const USER_ROLE = {
  ADMIN: 'admin',
  EDITOR: 'editor',
  USER: 'user',
} as const
type IUserRole = (typeof USER_ROLE)[keyof typeof USER_ROLE]

// ❌ Nunca enum
enum UserRole { ADMIN = 'admin' }

// ❌ Nunca any
const handle = (data: any) => {}  // usar unknown + type guard
```

## Tailwind

```tsx
// ✅ cn() para clases condicionales (clsx + tailwind-merge)
import { cn } from '@/lib/utils'

<div className={cn('base-class', isActive && 'active-class', className)} />

// ✅ Variantes con lookup object
const SIZE_CLASSES = {
  sm: 'text-sm px-2 py-1',
  md: 'text-base px-4 py-2',
  lg: 'text-lg px-6 py-3',
} as const

<button className={cn('rounded font-medium', SIZE_CLASSES[size])} />
```

## Data fetching

```tsx
// ✅ Server Component — async directo
const UsersPage = async () => {
  const users = await getUsers()
  return <UsersList users={users} />
}

// ✅ Paralelo — nunca waterfall
const [users, posts] = await Promise.all([getUsers(), getPosts()])

// ✅ Next.js 15 — params y searchParams son async
const Page = async ({ params }: { params: Promise<{ id: string }> }) => {
  const { id } = await params
}

// ✅ Cliente — TanStack Query
const { data: users } = useQuery({
  queryKey: ['users'],
  queryFn: getUsers,
})

// ❌ Nunca useEffect para fetch
useEffect(() => { fetchUsers().then(setUsers) }, [])
```

## Server Actions

```ts
// app/actions.ts
'use server'
import { revalidatePath } from 'next/cache'

export const createUser = async (formData: FormData) => {
  const name = formData.get('name') as string
  await db.users.create({ data: { name } })
  revalidatePath('/users')
}
```

## Imports

- Alias `@/` para todo lo interno al proyecto
- `import type` para tipos — sin runtime cost
- Imports directos en vez de barrel files para librerías pesadas

```ts
// ✅
import { format } from 'date-fns/format'
import type { IUser } from '@/types/user.types'

// ❌ barrel import de lib pesada
import { format } from 'date-fns'
```

## Git

- Conventional commits en inglés: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`
- Sin "Co-Authored-By" ni atribución de AI
- Branch naming: `feature/`, `fix/`, `refactor/`
