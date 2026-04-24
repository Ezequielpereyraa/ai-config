---
name: dev-pipeline
description: >
  Orquestador multi-agente con routing automático FULL/LITE, spec persistido y QA automatizado.
  Usar cuando: feature multi-archivo, refactor significativo, lógica de negocio nueva, hooks/services/utils.
  Para fixes de 1 línea, rename, o cambios triviales → usar commands directos (/task-small, /fix-bug, /review-code).
---

# Dev Pipeline — Orquestador multi-agente

El main agent **solo orquesta** — nunca implementa directo.
**Principio central:** entender antes de escribir. Siempre. Sin excepciones.

## Cuándo aplicar

**Pipeline obligatorio cuando:**
- Toca >1 archivo CON lógica de negocio
- Crea o modifica hooks / services / utils
- Es un refactor significativo
- Feature completa o flujo nuevo

**NO pipeline (usar commands):**
- 1-line fix → `/task-small`
- Bug con repro claro → `/fix-bug`
- Rename puntual → `/task-small`
- Review de diff/PR → `/review-code`
- Spec manual sin orquestación → `/spec-feature`

---

## Flujo

```
Tarea
  │
  ▼
Fase 0: routing FULL/LITE (haiku)
  │
  ├─ FULL ─────────────────────────────────┐
  │                                         │
  ▼                                         ▼
0.5 Spec (⏸ aprobación)            1 LITE Scan
  │                                         │
  ▼                                         ▼
1 FULL Investigación              2 LITE Plan (⏸ aprobación)
  │                                         │
  ▼                                         │
2 FULL Plan (⏸ aprobación)                 │
  │                                         │
  ├─ opt-in ─────────┐                     │
  │                  ▼                      │
  │      2.5 Tests from spec               │
  │                  │                      │
  └──────┬───────────┘                     │
         │                                  │
         └──────────┬───────────────────────┘
                    ▼
               3 Implementación
                    ▼
               4 QA Mecánico (haiku, 2 reintentos)
                    │
       FULL ────────┤
                    ▼
               5 QA Negocio (solo FULL)
```

## Modelos por fase

| Fase | Modelo | Rol |
|---|---|---|
| 0 routing | `haiku` | Evaluación con criterios fijos |
| 0.5 spec (FULL) | `sonnet` | Razonamiento funcional sin código |
| 1 FULL investigación | `sonnet` | Scope acotado por spec |
| 1 LITE scan | `haiku` | Reutilizables + archivos afectados |
| 2 plan | `sonnet` | Razonamiento estructurado |
| 2.5 tests (opt-in) | `sonnet` | Acceptance criteria → tests ejecutables |
| 3 implementación | `sonnet` | Generación sobre plan aprobado |
| 4 QA mecánico | `haiku` | Checks determinísticos |
| 5 QA negocio (FULL) | `sonnet` | Revisión semántica vs spec |

**Aliases siempre** (`sonnet`, `haiku` sin versión) para resolver al modelo más reciente.

---

## Fase 0 — Stack detection + routing

### 1. Registrar fases como tasks

FULL: `0.5, 1, 2, [2.5 opt], 3, 4, 5`
LITE: `1, 2, 3, 4`

### 2. Detectar stack

Leer `package.json` (determinístico — los sub-agentes no lo leen por su cuenta). Mapping:

| Dep | Skill |
|---|---|
| `next`, `react` | `nextjs`, `react-19` |
| `typescript`, `tsconfig` | `typescript` |
| `tailwindcss` | `tailwind-4` |
| `@nestjs/*` | `nestjs` |
| `vitest` | `vitest` |

**Registrar la lista de skills detectadas — NO leer el contenido acá.**
Los sub-agentes que las necesitan (Fase 3 implementación, Fase 4 QA) las leen en su propio prompt. Si el harness ya auto-cargó alguna por matching de description, evitamos doble carga.

Skills base SIEMPRE en la lista (se pasan a Fase 3 y Fase 4):
- `my-code-style`
- `my-perf-patterns`
- `my-error-handling`

### 3. Evaluar routing FULL vs LITE

Lanzar agente `haiku`:

```
Evaluá y determiná path. Respondé SOLO el bloque, sin explicaciones.

TAREA: [tarea]
STACK: [stack]

AMBIGÜEDAD: Alta / Baja
→ Alta si: edge cases no especificados, reglas implícitas, o "lo obvio" tiene múltiples interpretaciones.
→ Baja si: comportamiento esperado claro.

NOVEDAD: Alta / Baja
→ Alta si: no existe patrón similar en el codebase, o toca lógica nueva.
→ Baja si: hay componente/hook/service similar para replicar o extender.

SUPERFICIE: 1-2 dominios / 3+ dominios
→ Contar dominios distintos (auth, payments, notifications...), no archivos.

PATH: FULL / LITE
REGLA: FULL si Alta OR Alta OR 3+. LITE si Baja AND Baja AND 1-2. Duda → FULL.
RAZÓN: [1 línea]
```

### 4. Informar al user

```
Stack: [lista]
Skills: [lista]
Ambigüedad: [X] · Novedad: [X] · Superficie: [X]
→ Path [FULL/LITE] — [razón]
```

---

## Fase 0.5 — Spec funcional (solo FULL)

**sonnet** · No leer código — solo description del user.

Marcar `in_progress`. Lanzar agente:

```
Generá spec funcional. No leas código.

TAREA: [tarea]

Respondé EXACTAMENTE con este formato:

---
## Spec — [nombre del feature]

### Propósito
[1 línea: qué problema resuelve y para quién]

### Casos de uso
- [Actor] puede [acción] para [resultado]
(todos, incluidos secundarios)

### Requisitos
- [funcional 1]
- [funcional 2]

### Edge cases
- ¿Qué si [situación límite]?
- ¿Qué si [error esperado]?

### Criterios de aceptación
- Given [contexto], When [acción], Then [resultado]
(mínimo 3, uno por caso principal)

### Fuera de scope
- [cosa que podría confundirse]
---

Si hay ambigüedad no resoluble sin info del user → listar al final como "Ambigüedades a resolver".
```

**Orquestador:**
- Marcar `completed`.
- **Persistir:** `.claude/specs/[feature-kebab].md` (crear dir si falta).
- Si hay ambigüedades → resolver con user antes de seguir.
- **Presentar spec y esperar aprobación:**

```
Revisá el spec antes de que arranque la investigación.

[SPEC]

¿Aprobamos?
- ✅ Aprobar → investigo con este scope
- ✏️ Ajustar → qué cambiamos
- ➕ Agregar casos o edge cases
```

---

## Fase 1 — Investigación / Scan

Prompt parametrizado por path:

### FULL — `sonnet` · scope acotado por spec

```
Investigá el codebase para implementar el spec aprobado.

SPEC: [OUTPUT FASE 0.5]

Buscá SOLO lo relevante al spec. No auditoría general.

### 1. Inventario de reutilizables
(path + qué hace + directo o adapta. Si nada → decirlo)
- Componentes similares
- Hooks con lógica aplicable
- Utils / mappers / services relevantes
- Types / interfaces existentes

### 2. Archivos afectados
- Modificar: path + motivo
- Crear: path + responsabilidad

### 3. Convenciones detectadas
(patrones a respetar: naming, estructura de carpetas, convenciones de la feature más similar)

### 4. Ambigüedades técnicas
(solo las que el spec no cubre y afectan la implementación)
```

### LITE — `haiku` · scan directo sin spec

```
Scan rápido para: [TAREA]

### Reutilizables
- path + qué hace + directo o adapta (o "Ninguno relevante")

### Archivos afectados
- Modificar: path + motivo
- Crear: path + responsabilidad

### Patrón a seguir
Path del archivo más similar al que hay que crear/modificar.
```

**Orquestador:**
- Marcar `completed`.
- FULL: ambigüedades técnicas → consultar al user.
- Pasar output a Fase 2.

---

## Fase 2 — Plan + Tasks

**sonnet** para ambos paths.

```
Generá plan de implementación.

[SI FULL] SPEC APROBADO: [FASE 0.5]
INVESTIGACIÓN/SCAN: [FASE 1]

Verificá antes de planificar:
1. ¿Usa TODO el inventario de reutilizables?
2. ¿Arquitectura coherente con convenciones detectadas?
3. ¿Archivos en lugar correcto según estructura del proyecto?
4. ¿Lógica de negocio en services/hooks/utils, NO en componentes?

Aplicá skills activas: [LISTA DE SKILLS DE FASE 0]
Skills personales siempre activas: my-code-style, my-perf-patterns, my-error-handling

Devolvé EXACTAMENTE:

---
## Plan — [nombre]

### Reutilizables a usar
- `path` — rol en esta implementación
(exhaustivo — si nada, explicar por qué)

### Pasos de implementación
1. [ ] Paso — descripción + archivos → verify: [check concreto]
(orden: tipos → services/hooks → componentes → wiring)
(cada paso con su verificación: tsc, test, import, render)

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

**Orquestador:**
- Marcar `completed`.
- **Persistir:** `.claude/specs/[feature-kebab]-plan.md`.
- **Presentar plan y esperar aprobación:**

```
Plan listo:

[PLAN]

¿Procedemos?
- ✅ Aprobar → arranco impl
- ✏️ Ajustar → qué cambiamos
- 🧪 Con tests → escribo tests desde spec antes de implementar (solo FULL)
- ❓ Consultar
```

---

## Fase 2.5 — Tests from spec (opt-in, solo FULL)

**sonnet** · Solo si el user lo pidió en Fase 2.

Marcar `in_progress`. Lanzar agente:

```
Generá tests ejecutables desde acceptance criteria.

SPEC CRITERIOS: [FASE 0.5 — Criterios de aceptación]
PLAN ARCHIVOS: [FASE 2 — Archivos crear/modificar]
STACK TESTS: [vitest/jest/playwright según package.json]

Para cada Given/When/Then:
1. Test case que lo cubra
2. El test DEBE FALLAR (Red) — no escribir impl
3. Usar paths reales del plan (van a fallar porque no existen aún)

Formato:

### Tests generados
- `path/test.test.ts` — cubre: [criterios]

### Criterios sin test unitario
- [criterio + por qué no es unitariamente testeable]
```

**Orquestador:**
- Marcar `completed`.
- Presentar tests al user para confirmar cobertura.
- Pasar lista de test files a Fase 3.

---

## Operatoria post-aprobación

| User dice | Acción |
|---|---|
| Cambio menor (wording, reordenar, agregar archivo) | Modificar inline, confirmar, continuar |
| Cambio de diseño (arquitectura distinta, nuevos módulos) | Volver a Fase 2 con notas del user |
| "Necesito entender X antes de decidir" | Volver a Fase 1 con la pregunta como foco |
| Cancelar | Marcar todo como `cancelled` |

---

## Fase 3 — Implementación

**sonnet**

Marcar `in_progress`. Lanzar agente:

```
Implementá exactamente lo aprobado.

TAREA: [TAREA]

LEÉ ANTES DE CUALQUIER LÍNEA:
- ~/.claude/skills/my-code-style/SKILL.md
- ~/.claude/skills/my-perf-patterns/SKILL.md
- ~/.claude/skills/my-error-handling/SKILL.md
[PATHS DE SKILLS DE FASE 0 — una por línea]

Luego leé cada archivo a modificar ANTES de tocarlo.

PLAN APROBADO (solo estas secciones):
- Reutilizables a usar
- Pasos de implementación
- Archivos a crear / modificar
- Decisiones de diseño

Reglas:
- Usar TODOS los reutilizables del plan.
- Si encontrás algo que el plan no contempló y cambia lógica de negocio → STOP y reportalo. No decidas por tu cuenta.
- Ejecutar el verify de cada paso después de completarlo.
[SI 2.5 ACTIVA]:
- Hay tests previos que deben PASAR (Green). Correrlos después de cada batch.
- TEST FILES: [lista]
- Si un test falla por diseño incorrecto del test (no por bug de impl) → reportalo, NO lo modifiques.

Al terminar devolvé:
1. Lista de archivos creados/modificados (descripción 1 línea c/u)
2. Decisiones no previstas en el plan (si las hubo) + justificación
```

### Batching para +5 archivos

```
Batch 1: tipos + interfaces + services + mappers
   → tsc --noEmit
Batch 2: hooks + utils + Server Actions
   → tsc --noEmit
Batch 3: componentes + páginas + wiring
   → pasar a QA
```

**Orquestador:**
- Marcar `completed`.
- Decisiones no previstas que afecten lógica de negocio → consultar al user antes de seguir.

---

## Fase 4 — QA Mecánico

**haiku**

Marcar `in_progress`. Lanzar agente:

```
Verificá mecánicamente. Leé los archivos reales.

ARCHIVOS: [LISTA DE FASE 3]

1. LINTS:
   - Bash: npx eslint --format=compact [archivos]
   - Bash: npx tsc --noEmit

2. CONVENCIONES (leé las skills activas — my-code-style, my-perf-patterns, my-error-handling + stack skills):
   - const arrow functions, NO function keyword
   - IProps fuera del componente
   - Early return en vez de if/else anidado
   - Sin any ni casteos inseguros
   - Sin console.log ni código muerto

3. ESTRUCTURA:
   - Archivos en directorio correcto
   - index.ts con re-export para cada componente nuevo

4. COMPLETITUD:
   - ¿Se crearon/modificaron TODOS los archivos del plan?

Formato:

## QA Mecánico: PASS ✅ / FAIL ❌

### Bloqueantes
- ...

### Confirmado ✅
- ...
```

**Orquestador:**
- FAIL → relanzar Fase 3 con reporte (máximo **2 reintentos totales**).
- Después de 2 reintentos → escalar al user, NO seguir looping.
- PASS: FULL continúa a Fase 5, LITE termina aquí.

---

## Fase 5 — QA Negocio (solo FULL)

**sonnet**

Marcar `in_progress`. Lanzar agente:

```
Revisá la implementación contra el spec y la lógica de negocio.

SPEC ORIGINAL: [FASE 0.5]
ARCHIVOS: [FASE 3]
REGLAS DE NEGOCIO: [FASE 1 sección 3 si aplica]

1. CRITERIOS DE ACEPTACIÓN:
   ¿Cada Given/When/Then del spec está cubierto por la impl?

2. EDGE CASES:
   ¿Los edge cases del spec están manejados?

3. LÓGICA DE NEGOCIO:
   ¿Hay lógica de negocio dentro de componentes UI que debería estar en services/hooks?

4. REUTILIZACIÓN:
   - ¿Se usaron TODOS los reutilizables del plan?
   - ¿Se duplicó lógica que ya existía?

5. PERFORMANCE (si aplica al stack):
   - ¿Client Components innecesarios?
   - ¿Fetches secuenciales que podrían ser paralelos?
   - ¿Imágenes sin next/image?

6. TESTS (progresivo — no bloquea merge):
   - Nueva lógica de negocio → path + tipo de test recomendado
   - Flujo nuevo → caso E2E a cubrir

Formato:

## QA Negocio: PASS ✅ / FAIL ❌ / PASS CON OBSERVACIONES ⚠️

### Criterios de aceptación
- [G/W/T] → ✅ cubierto / ❌ no cubierto

### Issues críticos (bloquean merge)
- ...

### Observaciones (no bloquean)
- ...

### Tests pendientes
- ...
```

**Orquestador:**
- FAIL con issues críticos → relanzar Fase 3 (máx **2 reintentos totales** contando Fase 4).
- PASS o PASS CON OBSERVACIONES → presentar reporte completo al user.

---

## Reglas del orquestador

- **Nunca implementés vos** — siempre delegar a sub-agentes con Task tool.
- **Duda en routing → FULL.** Nunca LITE por defecto si hay incertidumbre.
- **Contexto mínimo por fase** — pasar solo lo necesario:
  - Fase 3 recibe plan comprimido (secciones listadas), NO raw de Fase 1.
  - Fase 4 recibe solo lista de archivos.
  - Fase 5 recibe archivos + spec + reglas de negocio de Fase 1.
- **Fase 0.5 obligatoria en FULL** — no saltear spec.
- **Fase 2.5 estrictamente opt-in** — nunca forzar ni sugerir insistentemente.
- **Aprobaciones son hard stop** — sin OK explícito del user, no avanzar.
- **Persistir artefactos** en `.claude/specs/`:
  - spec → `[feature-kebab].md`
  - plan → `[feature-kebab]-plan.md`
  - Crear el directorio si no existe.
- **Reintentos Fase 3: máx 2 en total** (contando Fase 4 y Fase 5).
- **Convenciones de código** viven en las skills personales (`my-code-style`, `my-perf-patterns`, `my-error-handling`) y stack skills. NO duplicar acá — referenciarlas en los prompts.
