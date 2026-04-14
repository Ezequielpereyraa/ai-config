---
name: dev-pipeline
description: Pipeline de desarrollo con routing automático FULL/LITE. Usar cuando el usuario pida implementar una feature, componente, refactor o cualquier tarea de programación no trivial. Investiga primero, propone spec/plan/tareas según complejidad, espera aprobación, luego implementa.
---

# Dev Pipeline — Orquestador multi-agente

El agente principal **solo orquesta** — no implementa directamente.

**Principio central:** Entender antes de escribir. Siempre. Sin excepciones.

## Cuándo aplicar

**Pipeline obligatorio cuando:**

- Toca más de 1 archivo
- Tiene lógica de negocio
- Crea o modifica hooks / services / utils
- Es un refactor

**Implementar directo** (sin pipeline): corrección de 1 línea, cambio trivial de UI sin lógica, rename puntual.

---

## Flujo general

```
Tarea del usuario
    │
    ▼
Fase 0: Stack detection + routing FULL/LITE
    │
    ├─── FULL ──────────────────────────────┐
    │                                       │
    ▼                                       ▼
Fase 0.5: Spec funcional              Fase 1 LITE: Scan rápido
⏸ Pausa — aprobación spec                  │
    │                                       ▼
    ▼                               Fase 2 LITE: Plan + Tasks
Fase 1 FULL: Investigación          ⏸ Pausa — aprobación
    │                                       │
    ▼                                       │
Fase 2 FULL: Plan + Tasks                  │
⏸ Pausa — aprobación                       │
    │                                       │
    ├─── Usuario pidió tests ──┐            │
    │                          ▼            │
    │              Fase 2.5: Tests from Spec│
    │                          │            │
    └─────────┬────────────────┘            │
              │                             │
              └──────────────┬──────────────┘
                             │
                             ▼
                     Fase 3: Implementación
                             │
                             ▼
                     Fase 4: QA Mecánico
                             │
                     FULL ───┤
                             ▼
                     Fase 5: QA Negocio (solo FULL)
```

---

## Modelos por fase

| Fase                        | Modelo       | Por qué                                                                         |
| --------------------------- | ------------ | ------------------------------------------------------------------------------- |
| Fase 0 — Routing            | **`haiku`**  | Evaluación estructurada con criterios fijos — no necesita razonamiento complejo |
| Fase 0.5 — Spec (FULL)      | **`sonnet`** | Razonamiento funcional, sin necesidad de leer codebase                          |
| Fase 1 FULL — Investigación | **`sonnet`** | Scope acotado por el spec — no necesita opus                                    |
| Fase 1 LITE — Scan          | **`haiku`**  | Solo reutilizables y archivos afectados                                         |
| Fase 2 — Plan + Tasks       | **`sonnet`** | Razonamiento estructurado sobre output anterior                                 |
| Fase 2.5 — Tests (opt-in)   | **`sonnet`** | Acceptance criteria → test cases ejecutables. Solo si el usuario lo pide        |
| Fase 3 — Implementación     | **`sonnet`** | Generación de código sobre plan aprobado                                        |
| Fase 4 — QA Mecánico        | **`haiku`**  | Checks determinísticos, no requiere razonamiento                                |
| Fase 5 — QA Negocio (FULL)  | **`sonnet`** | Revisión semántica de lógica de negocio                                         |

**Nota sobre aliases:** Usá `sonnet` y `haiku` sin versión — se resuelven siempre al modelo más reciente disponible en tu cuenta. Solo hardcodeá model strings (`claude-sonnet-4-6`) si necesitás reproducibilidad exacta entre sesiones.

---

## Fase 0 — Stack detection + routing

**Routing:** `haiku` · El resto lo ejecuta el orquestador directamente.

### 1 — Registrar fases según path (después del routing)

FULL:

```
TaskCreate: "Fase 0.5 — Spec funcional"
TaskCreate: "Fase 1 — Investigación"
TaskCreate: "Fase 2 — Plan y tareas"
TaskCreate: "Fase 2.5 — Tests from Spec" (solo si el usuario lo pide — crear al momento, no por defecto)
TaskCreate: "Fase 3 — Implementación"
TaskCreate: "Fase 4 — QA Mecánico"
TaskCreate: "Fase 5 — QA Negocio"
```

LITE:

```
TaskCreate: "Fase 1 — Scan rápido"
TaskCreate: "Fase 2 — Plan y tareas"
TaskCreate: "Fase 3 — Implementación"
TaskCreate: "Fase 4 — QA Mecánico"
```

### 2 — Leer package.json y detectar stack

Leé `package.json`. Consultá [SKILLS-CATALOG.md](SKILLS-CATALOG.md) para mapear dependencias → skills. Leé cada SKILL.md detectada antes de continuar.

### 3 — Evaluar routing FULL vs LITE

Lanzá un agente `haiku` con este prompt:

```
Evaluá esta tarea y determiná el path de desarrollo. Respondé SOLO con el bloque de abajo, sin explicaciones adicionales.

TAREA: [tarea del usuario]
STACK DETECTADO: [stack de paso 2]

AMBIGÜEDAD: [Alta / Baja]
→ Alta si: edge cases no especificados, reglas de negocio implícitas,
   o "lo obvio" tiene múltiples interpretaciones válidas.
→ Baja si: el comportamiento esperado está claro y no hay decisiones abiertas.

NOVEDAD: [Alta / Baja]
→ Alta si: no existe patrón similar en el codebase o toca lógica nueva.
→ Baja si: hay componente/hook/service similar que se puede replicar o extender.

SUPERFICIE: [1-2 dominios / 3+ dominios]
→ Contá dominios distintos (auth, payments, notifications...), no archivos.

PATH: [FULL / LITE]
REGLA: FULL si ambigüedad Alta OR novedad Alta OR superficie 3+
       LITE si ambigüedad Baja AND novedad Baja AND superficie 1-2
       Duda → FULL por defecto.
RAZÓN: [una línea]
```

### 4 — Informar al usuario

```
Stack: Next.js · TypeScript · Tailwind CSS 4
Skills: nextjs, react-19, typescript, tailwind-4
Ambigüedad: Baja · Novedad: Baja · Superficie: 1 dominio
→ Path LITE
```

---

## Fase 0.5 — Spec funcional (solo FULL)

**Agente:** `sonnet`

Antes de investigar el codebase, definir exactamente _qué_ se va a construir. El agente no lee código en esta fase — trabaja solo con la descripción del usuario.

Marcá Fase 0.5 como `in_progress`. Lanzá el agente con este prompt:

```
Generá el spec funcional para esta tarea. No leas código todavía.

TAREA: [tarea del usuario]

Respondé EXACTAMENTE con este formato:

---
## Spec — [nombre del feature]

### Propósito
[Una línea: qué problema resuelve y para quién]

### Casos de uso
- [Actor] puede [acción] para [resultado]
(listá todos los casos, incluidos los secundarios)

### Requisitos
- [requisito funcional 1]
- [requisito funcional 2]

### Edge cases
- ¿Qué pasa si [situación límite]?
- ¿Qué pasa si [error esperado]?

### Criterios de aceptación
- Given [contexto], When [acción], Then [resultado esperado]
- Given [contexto], When [acción], Then [resultado esperado]
(mínimo 3, uno por caso de uso principal)

### Fuera de scope
- [cosa que podría confundirse como parte del feature pero no lo es]
---

Si hay algo ambiguo que no podés resolver sin información del usuario → listalo al final como "Ambigüedades a resolver" antes de continuar.
```

**Acción del orquestador:**

- Marcá Fase 0.5 como `completed`
- **Persistir el spec:** guardar en `.claude/specs/[feature-name-kebab].md` dentro del proyecto
- Si hay ambigüedades → **pausar y resolver con el usuario antes de continuar**
- **Presentar el spec al usuario y esperar aprobación explícita**

```
Revisá el spec antes de que empiece la investigación.

[SPEC COMPLETO]

¿Aprobamos? Podés:
- ✅ Aprobar → investigo el codebase con este scope
- ✏️ Ajustar → decime qué cambiamos
- ➕ Agregar casos o edge cases que falten
```

---

## Fase 1 FULL — Investigación

**Agente:** `sonnet` · Scope acotado por el spec aprobado

Con el spec aprobado, la investigación es quirúrgica — el agente sabe exactamente qué buscar.

Marcá Fase 1 como `in_progress`. Lanzá el agente con este prompt:

```
Investigá el codebase para implementar el siguiente spec aprobado.

SPEC APROBADO:
[OUTPUT COMPLETO DE FASE 0.5]

Buscá SOLO lo relevante para este spec. No hagas auditoría general.

Respondé con estas secciones:

### 1. Inventario de reutilizables
Para cada ítem: path completo + qué hace + si aplica directo o necesita adaptación.
- Componentes similares
- Hooks con lógica aplicable
- Utils / mappers / services relevantes
- Types / interfaces existentes que apliquen
Si no hay nada reutilizable → decirlo explícitamente.

### 2. Archivos afectados
- Modificar: path + motivo
- Crear: path + responsabilidad

### 3. Decisiones de arquitectura detectadas
Patrones existentes que esta implementación debe respetar.
(naming, estructura de carpetas, convenciones de la feature más similar)

### 4. Ambigüedades técnicas
Solo las que el spec no cubre y afectan la implementación.
```

**Acción del orquestador:**

- Marcá Fase 1 como `completed`
- Si hay ambigüedades técnicas → consultar al usuario
- Pasar output completo a Fase 2

---

## Fase 1 LITE — Scan rápido

**Agente:** `haiku`

Sin spec previo. Scan directo y acotado del codebase.

Marcá Fase 1 como `in_progress`. Lanzá el agente con este prompt:

```
Scan rápido del codebase para esta tarea: [TAREA DEL USUARIO]

Respondé SOLO con:

### Reutilizables
- path + qué hace + si aplica directo o necesita adaptación
(si no hay nada → "Ninguno relevante")

### Archivos afectados
- Modificar: path + motivo
- Crear: path + responsabilidad

### Patrón a seguir
Path del archivo más similar al que hay que crear/modificar.
```

**Acción del orquestador:**

- Marcá Fase 1 como `completed`
- Pasar output a Fase 2 LITE

---

## Fase 2 FULL — Plan + Tasks

**Agente:** `sonnet`

Marcá Fase 2 como `in_progress`. Lanzá el agente con este prompt:

```
Generá el plan de implementación basado en el spec y la investigación.

SPEC APROBADO:
[OUTPUT DE FASE 0.5]

INVESTIGACIÓN:
[OUTPUT DE FASE 1 FULL]

Revisá antes de planificar:
1. ¿El plan usa TODO lo del inventario de reutilizables?
2. ¿La arquitectura es coherente con los patrones detectados?
3. ¿Los archivos van en el lugar correcto según la estructura del proyecto?
4. ¿La lógica de negocio está en services/hooks/utils, no en componentes?
Leé [RULES.md](RULES.md) y verificá que el plan las respeta.
Stack activo: [LISTA DE SKILLS DE FASE 0]

Devolvé EXACTAMENTE este formato:

---
## Plan — [nombre del feature]

### Reutilizables a usar
- `path` — rol en esta implementación
(exhaustivo — si no se reutiliza nada, explicar por qué)

### Pasos de implementación
1. [ ] Paso — descripción + archivos afectados → verify: [check concreto]
(orden: tipos → services/hooks → componentes → wiring)
(cada paso incluye su verificación: tsc, test, import, render)

### Archivos a crear
- `path` — responsabilidad

### Archivos a modificar
- `path` — qué cambia y por qué

### Decisiones de diseño
- [decisión que el implementador debe respetar]

### Riesgos
- [Alto/Medio/Bajo] — descripción
---
```

**Acción del orquestador:**

- Marcá Fase 2 como `completed`
- **Persistir el plan:** guardar en `.claude/specs/[feature-name-kebab]-plan.md` dentro del proyecto
- **Presentar plan al usuario y esperar aprobación**

```
Plan listo. Revisalo antes de que arranque la implementación.

[PLAN COMPLETO]

¿Procedemos? Podés:
- ✅ Aprobar → arrancamos
- ✏️ Ajustar → decime qué cambiamos
- 🧪 Con tests → escribo tests desde el spec antes de implementar
- ❓ Consultar → aclaramos lo que necesites
```

---

## Fase 2 LITE — Plan + Tasks

**Agente:** `sonnet`

Marcá Fase 2 como `in_progress`. Lanzá el agente con este prompt:

```
Generá el plan de implementación.

TAREA: [TAREA DEL USUARIO]
SCAN: [OUTPUT DE FASE 1 LITE]

Leé [RULES.md](RULES.md). Stack activo: [LISTA DE SKILLS DE FASE 0]

Devolvé EXACTAMENTE este formato:

---
## Plan — [nombre]

### Reutilizables a usar
- `path` — rol (o "Ninguno")

### Pasos de implementación
1. [ ] Paso — descripción + archivos → verify: [check concreto]
(orden: tipos → services/hooks → componentes)

### Archivos a crear
- `path` — responsabilidad

### Archivos a modificar
- `path` — qué cambia

### Decisiones de diseño
- [decisión clave]
---
```

**Acción del orquestador:**

- Marcá Fase 2 como `completed`
- **Presentar plan al usuario y esperar aprobación**

---

## Fase 2.5 — Tests from Spec (opt-in, solo FULL)

**Agente:** `sonnet` · Solo se activa si el usuario lo pidió explícitamente

Esta fase **nunca se fuerza**. El orquestador la ofrece como opción al presentar el plan en Fase 2:

```
¿Procedemos? Podés:
- ✅ Aprobar → arrancamos
- ✏️ Ajustar → decime qué cambiamos
- 🧪 Con tests → escribo tests desde el spec antes de implementar
- ❓ Consultar → aclaramos lo que necesites
```

Si el usuario elige tests, marcá Fase 2.5 como `in_progress`. Lanzá el agente con este prompt:

```
Generá tests ejecutables desde los acceptance criteria del spec.

SPEC APROBADO:
[OUTPUT DE FASE 0.5 — sección Criterios de aceptación]

PLAN APROBADO:
[OUTPUT DE FASE 2 — sección Archivos a crear/modificar]

STACK DE TESTS: [vitest / jest / playwright — según lo detectado en package.json]

Para cada Given/When/Then del spec:
1. Creá un test case que lo cubra
2. El test DEBE FALLAR (Red) — no escribas implementación
3. Usá paths reales del plan para imports (van a fallar porque no existen aún)

Formato de output:

### Tests generados
- `path/to/test.test.ts` — cubre: [criterio 1, criterio 2]
- `path/to/test.test.ts` — cubre: [criterio 3]

### Criterios sin test
- [criterio que no se puede testear unitariamente — explicar por qué]
```

**Acción del orquestador:**

- Marcá Fase 2.5 como `completed`
- Presentar tests al usuario para confirmar cobertura
- Pasar lista de test files a Fase 3 — el agente implementador sabe que debe hacer pasar los tests

---

## ⏸ Operatoria de ajustes post-aprobación

| El usuario dice                                           | Acción                                    |
| --------------------------------------------------------- | ----------------------------------------- |
| Cambio menor (wording, reordenar, agregar archivo)        | Modificar inline, confirmar y continuar   |
| Cambio de diseño (arquitectura diferente, nuevos módulos) | Volver a Fase 2 con notas del usuario     |
| "Necesito entender X antes de decidir"                    | Volver a Fase 1 con la pregunta como foco |
| Cancelar                                                  | Marcar todo como `cancelled`              |

---

## Fase 3 — Implementación

**Agente:** `sonnet`

Marcá Fase 3 como `in_progress`. Lanzá el agente con este prompt:

```
Implementá exactamente lo aprobado.

TAREA: [TAREA DEL USUARIO]

Leé antes de escribir cualquier línea:
- ~/.claude/skills/dev-pipeline/RULES.md
[PATHS DE SKILLS DE FASE 0 — uno por línea]

Luego leé cada archivo que vas a modificar antes de tocarlo.

PLAN APROBADO:
[SOLO ESTAS SECCIONES:]
- Reutilizables a usar
- Pasos de implementación
- Archivos a crear / modificar
- Decisiones de diseño

Reglas:
- Usá TODOS los reutilizables del plan
- Componentes: props genéricas, IProps fuera del componente, sin lógica de negocio
- Funciones siempre const arrow, nunca function keyword
- Si encontrás algo que el plan no contempló y cambia lógica de negocio → STOP y reportalo
- Sin console.log, comentarios obvios ni código muerto
- Ejecutá el verify de cada paso del plan después de completarlo
[SI FASE 2.5 ACTIVA]:
- Hay tests previos que deben PASAR (Green). Correlos después de cada batch.
- TEST FILES: [lista de archivos de Fase 2.5]
- Si un test falla por diseño incorrecto del test (no por bug de implementación) → reportalo, no lo modifiques

Al terminar devolvé:
1. Lista de archivos creados/modificados con descripción de una línea
2. Decisiones no previstas en el plan (si las hubo) con justificación
```

### Batching para +5 archivos

```
Batch 1: tipos + interfaces + services + mappers
    ↓ tsc --noEmit
Batch 2: hooks + utils + Server Actions
    ↓ tsc --noEmit
Batch 3: componentes + páginas + wiring
    ↓ pasar a QA
```

**Acción del orquestador:**

- Marcá Fase 3 como `completed`
- Decisiones no previstas que afecten lógica de negocio → consultar al usuario antes de continuar

---

## Fase 4 — QA Mecánico

**Agente:** `haiku`

Marcá Fase 4 como `in_progress`. Lanzá el agente con este prompt:

```
Verificá mecánicamente la implementación. Leé los archivos reales.

ARCHIVOS: [LISTA DE FASE 3]

1. LINTS:
   - Bash: npx eslint --format=compact [archivos]
   - Bash: npx tsc --noEmit

2. CONVENCIONES (leé ~/.claude/skills/dev-pipeline/RULES.md):
   - ¿const arrow functions? ¿Ningún function keyword?
   - ¿IProps fuera del componente?
   - ¿Early return en vez de if/else anidado?
   - ¿Sin any ni casteos inseguros?
   - ¿Sin console.log ni código muerto?

3. ESTRUCTURA:
   - ¿Archivos en directorio correcto?
   - ¿index.ts con re-export para cada componente nuevo?

4. COMPLETITUD:
   - ¿Se crearon/modificaron todos los archivos del plan?

Formato:
## QA Mecánico: PASS ✅ / FAIL ❌

### Bloqueantes
- ...

### Confirmado ✅
- ...
```

**Acción del orquestador:**

- FAIL → relanzar Fase 3 con reporte (máximo **2 reintentos**)
- Después de 2 reintentos → escalar al usuario, no seguir looping
- PASS → path FULL continúa a Fase 5 · path LITE termina aquí

---

## Fase 5 — QA Negocio (solo FULL)

**Agente:** `sonnet`

Marcá Fase 5 como `in_progress`. Lanzá el agente con este prompt:

```
Revisá la implementación contra el spec y la lógica de negocio.

SPEC ORIGINAL: [OUTPUT DE FASE 0.5]
ARCHIVOS: [LISTA DE FASE 3]
REGLAS DE NEGOCIO: [SECCIÓN 1 DE FASE 1 FULL si aplica]

1. CRITERIOS DE ACEPTACIÓN:
   ¿Cada Given/When/Then del spec está cubierto por la implementación?

2. EDGE CASES:
   ¿Los edge cases del spec están manejados?

3. LÓGICA DE NEGOCIO:
   ¿Hay lógica de negocio dentro de componentes UI que debería estar en services/hooks?

4. REUTILIZACIÓN:
   ¿Se usaron todos los reutilizables del plan?
   ¿Se duplicó lógica que ya existía?

5. PERFORMANCE:
   - ¿Client Components innecesarios?
   - ¿Fetches secuenciales que podrían ser paralelos?
   - ¿Imágenes sin next/image?

6. TESTS: (progresivo — no bloquea merge)
   - Nueva lógica de negocio → path + tipo de test recomendado
   - Flujo completo nuevo → caso E2E a cubrir

Formato:
## QA Negocio: PASS ✅ / FAIL ❌ / PASS CON OBSERVACIONES ⚠️

### Criterios de aceptación
- [Given/When/Then] → ✅ cubierto / ❌ no cubierto

### Issues críticos (bloquean merge)
- ...

### Observaciones (no bloquean)
- ...

### Tests pendientes
- ...
```

**Acción del orquestador:**

- FAIL con issues críticos → relanzar Fase 3 (máximo **2 reintentos totales** contando Fase 4)
- PASS o PASS CON OBSERVACIONES → presentar reporte completo al usuario

---

## Reglas del orquestador

- **No implementes vos** — siempre delegá a agentes
- **Routing dudoso → FULL** — nunca asumir LITE si hay incertidumbre
- **Pasá solo el contexto necesario por fase** — Fase 3 recibe plan comprimido, no raw de Fase 1. Fase 4 recibe solo archivos. Fase 5 recibe archivos + spec + reglas de negocio.
- **Fase 0.5 es obligatoria en FULL** — no saltear el spec
- **Fase 2.5 es opt-in** — solo si el usuario lo pide. Nunca forzar ni sugerir insistentemente
- **Ambos checkpoints son hard stop** — sin OK del usuario no avanza
- **Persistir artefactos** — spec en `.claude/specs/`, plan en `.claude/specs/` (con sufijo `-plan`). Crear directorio si no existe
- **Reintentos de Fase 3: máximo 2 en total**
- **Modelos:** Fase 0/1 LITE/4 → `haiku` · Fase 0.5/1 FULL/2/2.5/3/5 → `sonnet`
- **Aliases siempre** — usá `sonnet` y `haiku` sin versión, se resuelven al modelo más reciente

## Recursos

- Convenciones y anti-patrones: [RULES.md](RULES.md)
- Mapeo dependencias → skills: [SKILLS-CATALOG.md](SKILLS-CATALOG.md)
