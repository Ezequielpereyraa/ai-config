---
name: supabase
description: Supabase best practices — Row Level Security, Auth, Realtime, Storage, Edge Functions, TypeScript integration, multi-tenancy, Next.js integration. Use when working with Supabase, PostgreSQL via Supabase, or Supabase Auth.
---

# Supabase Best Practices

## The golden rule: RLS first, always

Row Level Security is the single most important concept in Supabase. Every table that contains user data MUST have RLS enabled. If RLS is off, any authenticated user can read/write everything.

```sql
-- Always enable RLS on every table
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
```

---

## TypeScript — Typed client

### Generate types from your schema

```bash
npx supabase gen types typescript --project-id <project-id> > src/types/supabase.ts
```

### Typed client

```ts
// lib/supabase/client.ts — browser client (Client Components)
import { createBrowserClient } from '@supabase/ssr';
import type { Database } from '@/types/supabase';

export const createClient = () =>
  createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  );

// lib/supabase/server.ts — server client (Server Components, Server Actions, Route Handlers)
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import type { Database } from '@/types/supabase';

export const createServerSupabaseClient = async () => {
  const cookieStore = await cookies();
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => cookieStore.getAll(),
        setAll: (cookiesToSet) => {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options),
          );
        },
      },
    },
  );
};

// lib/supabase/admin.ts — service role client (server only, bypasses RLS)
import { createClient } from '@supabase/supabase-js';
import type { Database } from '@/types/supabase';

export const supabaseAdmin = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!, // never expose to client
);
```

---

## Row Level Security — patterns

### Basic user isolation

```sql
-- Users can only see their own data
CREATE POLICY "users_own_data" ON profiles
  FOR ALL
  USING (auth.uid() = user_id);
```

### Multi-tenant with organization membership

```sql
-- Helper function — avoids repeating joins
CREATE OR REPLACE FUNCTION auth.user_org_ids()
RETURNS uuid[] AS $$
  SELECT ARRAY(
    SELECT organization_id
    FROM organization_members
    WHERE user_id = auth.uid()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Projects visible to organization members
CREATE POLICY "org_members_see_projects" ON projects
  FOR SELECT
  USING (organization_id = ANY(auth.user_org_ids()));

CREATE POLICY "org_members_insert_projects" ON projects
  FOR INSERT
  WITH CHECK (organization_id = ANY(auth.user_org_ids()));
```

### Role-based access via custom claims

```sql
-- Set custom claims (via Edge Function or trigger)
-- Then use in policies:
CREATE POLICY "admins_can_delete" ON projects
  FOR DELETE
  USING (
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
    AND organization_id = ANY(auth.user_org_ids())
  );
```

### Separate SELECT vs INSERT/UPDATE/DELETE policies

```sql
-- More granular — always split by operation when logic differs
CREATE POLICY "read_own_tasks" ON tasks
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "create_own_tasks" ON tasks
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "update_own_tasks" ON tasks
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "delete_own_tasks" ON tasks
  FOR DELETE USING (user_id = auth.uid());
```

**Rules:**
- `USING` → filters rows for SELECT/UPDATE/DELETE
- `WITH CHECK` → validates data on INSERT/UPDATE
- Always test policies in the Supabase dashboard SQL editor
- Use `SECURITY DEFINER` functions for expensive checks that need to bypass RLS temporarily

---

## Queries — TypeScript patterns

```ts
// ✅ Typed select with filtering
const getProjects = async (orgId: string) => {
  const supabase = await createServerSupabaseClient();

  const { data, error } = await supabase
    .from('projects')
    .select('id, name, status, created_at, owner:users(id, name)')
    .eq('organization_id', orgId)
    .eq('status', 'active')
    .order('created_at', { ascending: false })
    .limit(20);

  if (error) throw new Error(error.message);
  return data; // fully typed from Database['public']['Tables']['projects']
};

// ✅ Paginated query
const getTasksPaginated = async (projectId: string, page: number, pageSize = 20) => {
  const supabase = await createServerSupabaseClient();
  const from = page * pageSize;
  const to = from + pageSize - 1;

  const { data, error, count } = await supabase
    .from('tasks')
    .select('*', { count: 'exact' })
    .eq('project_id', projectId)
    .order('created_at', { ascending: false })
    .range(from, to);

  if (error) throw new Error(error.message);
  return { data, total: count ?? 0, hasMore: (count ?? 0) > to + 1 };
};

// ✅ Upsert
const upsertProfile = async (profile: ProfileInsert) => {
  const supabase = createClient();
  const { data, error } = await supabase
    .from('profiles')
    .upsert(profile, { onConflict: 'user_id' })
    .select()
    .single();

  if (error) throw new Error(error.message);
  return data;
};
```

---

## Auth — Next.js integration

```ts
// middleware.ts — protect routes, refresh session
import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => request.cookies.getAll(),
        setAll: (cookiesToSet) => {
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options),
          );
        },
      },
    },
  );

  // Refresh session — required for Server Components to see updated session
  const { data: { user } } = await supabase.auth.getUser();

  if (!user && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return supabaseResponse;
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
};
```

```ts
// Server Component — get current user
export default async function DashboardPage() {
  const supabase = await createServerSupabaseClient();
  const { data: { user }, error } = await supabase.auth.getUser();

  if (error || !user) redirect('/login');

  // Query with RLS automatically applied for this user
  const { data: projects } = await supabase
    .from('projects')
    .select('*')
    .order('created_at', { ascending: false });

  return <ProjectList projects={projects ?? []} />;
}
```

```ts
// Server Action — mutation with auth check
'use server';

export async function createProject(formData: FormData) {
  const supabase = await createServerSupabaseClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) throw new Error('Unauthorized');

  const { data, error } = await supabase
    .from('projects')
    .insert({
      name: formData.get('name') as string,
      organization_id: formData.get('orgId') as string,
    })
    .select()
    .single();

  if (error) throw new Error(error.message);

  revalidatePath('/dashboard/projects');
  return data;
}
```

---

## Realtime

```ts
// ✅ Subscribe to table changes (respects RLS)
useEffect(() => {
  const supabase = createClient();

  const channel = supabase
    .channel('tasks-changes')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'tasks', filter: `project_id=eq.${projectId}` },
      (payload) => {
        if (payload.eventType === 'INSERT') setTasks(prev => [payload.new as Task, ...prev]);
        if (payload.eventType === 'UPDATE') setTasks(prev => prev.map(t => t.id === payload.new.id ? payload.new as Task : t));
        if (payload.eventType === 'DELETE') setTasks(prev => prev.filter(t => t.id !== payload.old.id));
      },
    )
    .subscribe();

  return () => { supabase.removeChannel(channel); };
}, [projectId]);
```

**Rules:**
- Always filter with `filter:` to avoid subscribing to entire table changes
- Realtime respects RLS — users only receive events for rows they can read
- Always cleanup channel on unmount (`removeChannel`)

---

## Storage

```ts
// Upload file
const uploadAvatar = async (userId: string, file: File) => {
  const supabase = createClient();
  const ext = file.name.split('.').pop();
  const path = `avatars/${userId}.${ext}`;

  const { error } = await supabase.storage
    .from('user-assets')
    .upload(path, file, { upsert: true });

  if (error) throw new Error(error.message);

  const { data } = supabase.storage.from('user-assets').getPublicUrl(path);
  return data.publicUrl;
};
```

Storage RLS via bucket policies in Supabase dashboard — same `auth.uid()` patterns apply.

---

## Multi-tenancy pattern

```sql
-- Organizations table
CREATE TABLE organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Members table — junction
CREATE TABLE organization_members (
  organization_id uuid REFERENCES organizations(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL DEFAULT 'member', -- 'owner' | 'admin' | 'member'
  joined_at timestamptz DEFAULT now(),
  PRIMARY KEY (organization_id, user_id)
);

-- All tenant data includes organization_id
CREATE TABLE projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid REFERENCES organizations(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- RLS: members see their org's projects
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "members_see_org_projects" ON projects
  FOR ALL USING (organization_id = ANY(auth.user_org_ids()));
```

---

## Anti-patterns

```ts
// ❌ Forgetting error handling
const { data } = await supabase.from('users').select('*');
// data could be null if there's an error

// ✅ Always handle error
const { data, error } = await supabase.from('users').select('*');
if (error) throw new Error(error.message);

// ❌ Using service role client in Server Components indiscriminately
// service role bypasses RLS — only use for admin operations
const data = await supabaseAdmin.from('users').select('*'); // ← sees ALL users

// ✅ Use server client (respects RLS for logged-in user)
const supabase = await createServerSupabaseClient();
const data = await supabase.from('users').select('*'); // ← only sees own user

// ❌ No limit on queries
await supabase.from('tasks').select('*');

// ✅ Always paginate
await supabase.from('tasks').select('*').range(0, 19).limit(20);

// ❌ RLS disabled
// "I'll enable it later" — no. Enable it from the start.
```
