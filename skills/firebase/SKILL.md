---
name: firebase
description: Firebase best practices — Firestore data modeling, Auth, Storage, Security Rules, multi-tenancy, cost optimization, TypeScript integration. Use when working with Firebase, Firestore, Firebase Auth, or Cloud Storage.
---

# Firebase Best Practices

## Firestore — Data Modeling

### Flat by default, subcollections when ownership matters

```
// ✅ Multi-tenant flat collections — easy to query, cheap to read
/tenants/{tenantId}
/users/{userId}          { tenantId, email, role, ... }
/projects/{projectId}    { tenantId, ownerId, name, ... }
/tasks/{taskId}          { tenantId, projectId, title, ... }

// ✅ Subcollections — when data is always accessed through parent
/users/{userId}/sessions/{sessionId}
/projects/{projectId}/comments/{commentId}

// ❌ Deep nesting — hard to query, forces over-fetching
/tenants/{tenantId}/users/{userId}/projects/{projectId}/tasks/{taskId}
```

**Rules:**
- Design for your **query patterns** first, not relational purity
- Never nest more than 1 subcollection level deep
- If you need to query across parents, use flat collection with `tenantId` field
- Duplicate data (denormalize) when it saves reads — reads are cheap, latency isn't

### TypeScript — Typed collections with converters

```ts
// types/firestore.ts
export interface UserDoc {
  tenantId: string;
  email: string;
  name: string;
  role: UserRole;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

// converters/user.converter.ts
export const userConverter: FirestoreDataConverter<UserDoc> = {
  toFirestore(user: UserDoc): DocumentData {
    return { ...user };
  },
  fromFirestore(snapshot: QueryDocumentSnapshot): UserDoc {
    return snapshot.data() as UserDoc;
  },
};

// usage — always use converter for type safety
const userRef = doc(db, 'users', userId).withConverter(userConverter);
const userSnap = await getDoc(userRef);
const user = userSnap.data(); // UserDoc | undefined, fully typed
```

---

## Firestore — Querying

```ts
// ✅ Paginated query — always paginate, never load full collection
const getProjects = async (tenantId: string, lastDoc?: DocumentSnapshot) => {
  let q = query(
    collection(db, 'projects').withConverter(projectConverter),
    where('tenantId', '==', tenantId),
    orderBy('createdAt', 'desc'),
    limit(20),
  );

  if (lastDoc) {
    q = query(q, startAfter(lastDoc));
  }

  const snap = await getDocs(q);
  return {
    data: snap.docs.map(d => d.data()),
    lastDoc: snap.docs[snap.docs.length - 1] ?? null,
    hasMore: snap.docs.length === 20,
  };
};

// ✅ Composite queries — requires composite index in Firestore console
const getActiveTasks = (projectId: string) =>
  query(
    collection(db, 'tasks').withConverter(taskConverter),
    where('projectId', '==', projectId),
    where('status', '==', 'active'),
    orderBy('priority', 'desc'),
  );
```

**Index rules:**
- Single-field queries → automatic index
- Multi-field + orderBy → requires composite index (Firestore tells you when it fails)
- `!=` and `not-in` → expensive, can't combine with other field filters
- Array queries (`array-contains`) → can only use one per query

---

## Firestore — Writes

### Batch writes for multiple documents

```ts
// ✅ Batch — up to 500 operations, atomic commit
const createProjectWithDefaultTasks = async (project: NewProject) => {
  const batch = writeBatch(db);

  const projectRef = doc(collection(db, 'projects')).withConverter(projectConverter);
  batch.set(projectRef, { ...project, createdAt: serverTimestamp() });

  const defaultTasks = ['Setup', 'Review', 'Deploy'];
  for (const title of defaultTasks) {
    const taskRef = doc(collection(db, 'tasks')).withConverter(taskConverter);
    batch.set(taskRef, {
      projectId: projectRef.id,
      tenantId: project.tenantId,
      title,
      status: 'pending',
      createdAt: serverTimestamp(),
    });
  }

  await batch.commit();
  return projectRef.id;
};

// ✅ Transaction — for reads + writes that must be consistent
const incrementCounter = async (docId: string) => {
  await runTransaction(db, async (tx) => {
    const ref = doc(db, 'counters', docId);
    const snap = await tx.get(ref);
    const current = snap.data()?.value ?? 0;
    tx.update(ref, { value: current + 1 });
  });
};
```

### serverTimestamp — always for timestamps

```ts
// ✅
{ createdAt: serverTimestamp(), updatedAt: serverTimestamp() }

// ❌ — client clock drift, timezone issues
{ createdAt: new Date(), updatedAt: new Date() }
```

---

## Firestore — Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function belongsToTenant(tenantId) {
      return isAuthenticated()
        && request.auth.token.tenantId == tenantId;
    }

    function isOwner(userId) {
      return isAuthenticated()
        && request.auth.uid == userId;
    }

    function hasRole(role) {
      return isAuthenticated()
        && request.auth.token.role == role;
    }

    function isValidUser() {
      return request.resource.data.keys().hasAll(['email', 'tenantId', 'role'])
        && request.resource.data.email is string
        && request.resource.data.tenantId is string;
    }

    // Users collection
    match /users/{userId} {
      allow read: if isOwner(userId) || hasRole('admin');
      allow create: if isAuthenticated() && isValidUser();
      allow update: if isOwner(userId) || hasRole('admin');
      allow delete: if hasRole('admin');
    }

    // Projects — tenant-scoped
    match /projects/{projectId} {
      allow read, write: if belongsToTenant(resource.data.tenantId);
      allow create: if belongsToTenant(request.resource.data.tenantId);
    }
  }
}
```

**Rules:**
- Never use `allow read, write: if true` — even temporarily
- Validate data shape on create/update with `request.resource.data`
- Use custom claims (`request.auth.token.*`) for roles and tenantId
- Test rules locally with the Firebase Emulator before deploying

---

## Firebase Auth

```ts
// auth/firebase-auth.service.ts
export class FirebaseAuthService {
  // Set custom claims on user (server-side only — Admin SDK)
  async setUserClaims(uid: string, claims: CustomClaims): Promise<void> {
    await adminAuth.setCustomUserClaims(uid, claims);
  }

  // Listen to auth state changes (client)
  onAuthStateChanged(callback: (user: User | null) => void): Unsubscribe {
    return firebaseAuth.onAuthStateChanged(callback);
  }

  // Force token refresh after claim update
  async refreshToken(): Promise<void> {
    const user = firebaseAuth.currentUser;
    if (user) await user.getIdToken(true); // force=true
  }
}
```

**Rules:**
- Set `tenantId` and `role` as custom claims → available in Security Rules without extra reads
- After updating custom claims server-side, force client token refresh (`getIdToken(true)`)
- Never store sensitive data in the token — it's visible client-side
- Use `onAuthStateChanged` for auth state, not manual token management

---

## Next.js integration

```ts
// lib/firebase.ts — client SDK singleton
import { initializeApp, getApps } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';

const app = getApps().length ? getApps()[0] : initializeApp(firebaseConfig);

export const db = getFirestore(app);
export const auth = getAuth(app);

// lib/firebase-admin.ts — Admin SDK (server only)
import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';

const adminApp = getApps().length
  ? getApps()[0]
  : initializeApp({ credential: cert(serviceAccount) });

export const adminDb = getFirestore(adminApp);
export const adminAuth = getAuth(adminApp);
```

```ts
// Server Component — direct Admin SDK read (no round-trip)
export default async function ProjectsPage() {
  const user = await getCurrentUser(); // reads cookie/session
  const projects = await adminDb
    .collection('projects')
    .where('tenantId', '==', user.tenantId)
    .orderBy('createdAt', 'desc')
    .limit(20)
    .get();

  return <ProjectList projects={projects.docs.map(d => ({ id: d.id, ...d.data() }))} />;
}

// Client Component — use TanStack Query + client SDK
const useProjects = (tenantId: string) =>
  useQuery({
    queryKey: ['projects', tenantId],
    queryFn: () => getProjects(tenantId),
  });
```

**Rules:**
- Server Components → use Admin SDK directly (no auth overhead, no client SDK)
- Client Components → use client SDK + TanStack Query
- Never expose Admin SDK or service account to the client
- Keep `firebaseConfig` (public keys) in `NEXT_PUBLIC_*` env vars — they're safe to expose
- Keep service account in private env vars — never in `NEXT_PUBLIC_*`

---

## Cost optimization

| Pattern | Cost | Recommendation |
|---------|------|----------------|
| `onSnapshot` listener | Per read on each change | Use only for realtime UI; prefer `getDocs` for static data |
| `getDocs` full collection | 1 read per doc | ALWAYS paginate with `limit()` |
| Pagination with cursor | Only reads the page | Use `startAfter(lastDoc)` |
| Denormalized fields | More writes, fewer reads | Worth it for frequently read data |
| Batch writes | 1 write per op | Group related writes |
| `serverTimestamp()` | No extra read | Always use for timestamps |

**Critical:**
- Add `limit()` to every query — a collection with 10k docs without limit = 10k reads
- Unsubscribe `onSnapshot` listeners on component unmount
- Use `select()` (field masks) when you only need specific fields from large documents

---

## Anti-patterns

```ts
// ❌ No limit — reads entire collection
const snap = await getDocs(collection(db, 'users'));

// ✅
const snap = await getDocs(query(collection(db, 'users'), limit(50)));

// ❌ Client timestamp
{ createdAt: new Date() }

// ✅
{ createdAt: serverTimestamp() }

// ❌ Untyped collection access
const data = snap.data(); // any

// ✅ Use converter
const ref = doc(db, 'users', id).withConverter(userConverter);
const data = (await getDoc(ref)).data(); // UserDoc | undefined

// ❌ Orphaned listener
useEffect(() => {
  onSnapshot(query, (snap) => setData(snap.docs));
  // Missing unsubscribe!
}, []);

// ✅
useEffect(() => {
  const unsubscribe = onSnapshot(query, (snap) => setData(snap.docs));
  return unsubscribe; // cleanup
}, []);
```
