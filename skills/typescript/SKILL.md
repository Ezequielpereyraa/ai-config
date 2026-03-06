---
name: typescript
description: >
  TypeScript strict patterns and best practices for senior developers.
  Trigger: When writing TypeScript code - types, interfaces, generics, advanced patterns.
---

# TypeScript — Senior Patterns & Best Practices

> Strict mode always. No `any`. No unsafe casts. Every pattern here has a reason.

## Interfaces vs Types

```typescript
// interface → contracts, objects, extendable shapes
interface IUser {
  id: string
  name: string
}

interface IAdmin extends IUser {
  permissions: string[]
}

// type → unions, intersections, computed types, aliases
type Status = 'active' | 'inactive' | 'pending'
type AdminOrUser = IAdmin | IUser
type WithTimestamps<T> = T & { createdAt: string; updatedAt: string }
```

**Rule:** `interface` with `I` prefix for object shapes. `type` for everything else.

## Const Objects over Enums

```typescript
// ✅ Const object — runtime values, tree-shakeable, no emit overhead
const STATUS = {
  ACTIVE: 'active',
  INACTIVE: 'inactive',
  PENDING: 'pending',
} as const

type IStatus = (typeof STATUS)[keyof typeof STATUS]
// → 'active' | 'inactive' | 'pending'

// ❌ Enum — generates runtime code, not tree-shakeable, surprising behavior
enum Status { ACTIVE = 'active', INACTIVE = 'inactive' }
```

## Discriminated Unions

```typescript
// ✅ Tag each variant — exhaustive handling, no null checks
type IApiResult<T> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: string; code: number }
  | { status: 'loading' }

const handle = (result: IApiResult<IUser>) => {
  if (result.status === 'loading') return <Spinner />
  if (result.status === 'error') return <Error message={result.error} />
  return <UserCard user={result.data} />  // TypeScript knows data exists here
}

// ✅ Exhaustive check — fails at compile time if a case is missing
const assertNever = (x: never): never => {
  throw new Error(`Unhandled case: ${JSON.stringify(x)}`)
}
```

## Branded / Opaque Types

```typescript
// Prevent mixing semantically different strings/numbers
declare const __brand: unique symbol

type IBrand<T, B> = T & { [__brand]: B }

type IUserId = IBrand<string, 'UserId'>
type ITenantId = IBrand<string, 'TenantId'>
type ICents = IBrand<number, 'Cents'>

// Constructor functions
const toUserId = (id: string): IUserId => id as IUserId
const toCents = (amount: number): ICents => amount as ICents

// Now this is a compile error — can't pass TenantId where UserId is expected
const getUser = (id: IUserId) => db.users.findUnique({ where: { id } })
getUser(tenantId)  // ❌ Type error
getUser(userId)    // ✅
```

## Template Literal Types

```typescript
type IRoute = '/users' | '/posts' | '/settings'
type IApiRoute = `/api${IRoute}`
// → '/api/users' | '/api/posts' | '/api/settings'

type IEventName<T extends string> = `on${Capitalize<T>}`
type IClickHandler = IEventName<'click'>  // → 'onClick'

// Extract path params
type IExtractParams<T extends string> =
  T extends `${string}:${infer Param}/${infer Rest}`
    ? Param | IExtractParams<`/${Rest}`>
    : T extends `${string}:${infer Param}`
    ? Param
    : never

type IParams = IExtractParams<'/users/:id/posts/:postId'>
// → 'id' | 'postId'
```

## `satisfies` Operator

```typescript
// ✅ satisfies — validates shape without widening the type
const config = {
  port: 3000,
  host: 'localhost',
  db: { url: 'postgres://...' },
} satisfies Record<string, unknown>

// config.port is still `number`, not `unknown`
// If shape doesn't match Record<string, unknown>, compile error

// Real use case — validate palette without losing literal types
const palette = {
  red: [255, 0, 0],
  green: '#00ff00',
} satisfies Record<string, string | number[]>

palette.red    // number[]  (not string | number[])
palette.green  // string    (not string | number[])
```

## Conditional Types + `infer`

```typescript
// Extract the resolved type of a Promise
type IUnwrap<T> = T extends Promise<infer U> ? U : T
type IResult = IUnwrap<Promise<IUser>>  // → IUser

// Extract array element type
type IElement<T> = T extends (infer U)[] ? U : never
type IItem = IElement<IUser[]>  // → IUser

// Extract function return type (manual ReturnType)
type IReturn<T> = T extends (...args: never[]) => infer R ? R : never

// Deep partial
type IDeepPartial<T> = {
  [K in keyof T]?: T[K] extends object ? IDeepPartial<T[K]> : T[K]
}
```

## Mapped Types

```typescript
// Make specific keys required, rest optional
type IRequireFields<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>

type IUserUpdate = IRequireFields<IUser, 'id'>
// id is required, everything else optional

// Remap keys
type IGetters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K]
}

type IUserGetters = IGetters<IUser>
// → { getId: () => string; getName: () => string }

// Filter keys by value type
type IPickByValue<T, V> = {
  [K in keyof T as T[K] extends V ? K : never]: T[K]
}

type IStringFields = IPickByValue<IUser, string>
```

## Type Guards

```typescript
// User-defined type guard
const isUser = (value: unknown): value is IUser =>
  typeof value === 'object' &&
  value !== null &&
  'id' in value &&
  typeof (value as IUser).id === 'string'

// Narrowing with discriminated union
const isSuccess = <T>(result: IApiResult<T>): result is Extract<IApiResult<T>, { status: 'success' }> =>
  result.status === 'success'

// Assertion function — throws if condition fails
const assertDefined = <T>(value: T | null | undefined, msg: string): asserts value is T => {
  if (value == null) throw new Error(msg)
}
```

## Generic Constraints

```typescript
// ✅ Constrain generics — be specific about what you need
const getProperty = <T, K extends keyof T>(obj: T, key: K): T[K] => obj[key]

// ✅ Generic with default
type IPaginated<T = unknown> = {
  data: T[]
  total: number
  page: number
  pageSize: number
}

// ✅ Constrain to objects with id
const findById = <T extends { id: string }>(items: T[], id: string): T | undefined =>
  items.find(item => item.id === id)
```

## Flat Interfaces — No Inline Nesting

```typescript
// ❌ Inline nested object
interface IOrder {
  address: { street: string; city: string; zip: string }
}

// ✅ Separate interface per concept
interface IAddress {
  street: string
  city: string
  zip: string
}

interface IOrder {
  id: string
  address: IAddress
}
```

## Import Types

```typescript
// Always use import type for type-only imports — no runtime cost
import type { IUser, IAdmin } from './types'
import { createUser, type ICreateUserDto } from './services/user.service'
```

## Upgrade Nudges — Patterns to Flag

| If you see this | Suggest this |
|---|---|
| `enum` | `const` object + derived type |
| `any` | `unknown` + type guard or generic |
| `as SomeType` without validation | Type guard before cast |
| Union of string literals directly | `const` object + `(typeof OBJ)[keyof typeof OBJ]` |
| `type` for object shape | `interface` with `I` prefix |
| Nested inline objects in interface | Separate interface per concept |
| `!` non-null assertion | `assertDefined()` or proper null check |
| Repeated `Partial<T>` patterns | `IDeepPartial<T>` or dedicated update type |
| `string` where semantics matter | Branded type |
