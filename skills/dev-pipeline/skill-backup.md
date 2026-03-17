---
name: dev-pipeline
description: Pipeline de desarrollo multi-agente de 5 fases. Usar cuando el usuario pida implementar una feature, componente, refactor o cualquier tarea de programación no trivial. Investiga primero, propone lista de tareas, espera aprobación, luego implementa.
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

**Implementar directo** (sin pipeline) cuando: corrección de 1 línea, cambio trivial de UI sin lógica, rename puntual.

---

## Flujo general

```
Tarea del usuario
    │
    ▼
Fase 0: Stack detection + carga de skills (orquestador · directo)
    │
    ▼
Fase 1: Investigación (Explore · opus)
    │  Entiende lógica de negocio, mapea reutilizables, detecta mejoras
    ▼
Fase 2: Plan + lista de tareas (general-purpose · sonnet)
    │  Genera checklist priorizado con decisiones de diseño
    ▼
⏸️  PAUSA — El orquestador presenta la lista al usuario y espera aprobación
    │  El usuario puede aprobar, ajustar o pedir más investigación
    ▼
Fase 3: Implementación (general-purpose · sonnet)
    │  Ejecuta exactamente lo aprobado · batching si hay +5 archivos
    ▼
Fase 4: QA Mecánico (general-purpose · haiku)
    │  Lints, tsc, convenciones, completitud
    ▼
Fase 5: QA Negocio (general-purpose · sonnet)
       Lógica de negocio, edge cases, reutilización, performance
```

---

## Modelos por fase

| Fase                    | Modelo       | Por qué                                                                                                                                                                       |
| ----------------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Fase 1 — Investigación  | **`opus`**   | La fase más crítica. Lee código real, entiende lógica de negocio implícita, detecta patrones sutiles. Si Fase 1 falla, todo lo que sigue falla. Vale el costo — es read-only. |
| Fase 2 — Plan           | **`sonnet`** | Necesita buen razonamiento para validar y estructurar. El análisis duro ya lo hizo Opus. Sonnet procesa ese output y genera el checklist.                                     |
| Fase 3 — Implementación | **`sonnet`** | Generación de código de alta calidad siguiendo un plan explícito y aprobado.                                                                                                  |
| Fase 4 — QA Mecánico    | **`haiku`**  | Verificación estructurada contra checklist, lints determinísticos, convenciones. Tarea mecánica, no requiere razonamiento complejo.                                           |
| Fase 5 — QA Negocio     | **`sonnet`** | Revisión semántica: lógica de negocio, edge cases, reutilización. Requiere razonamiento — haiku no puede hacer esto bien.                                                     |

## Herramientas del orquestador

| Propósito                  | Herramienta                                                               |
| -------------------------- | ------------------------------------------------------------------------- |
| Fase 1 — Investigación     | `Agent` con `subagent_type: "Explore"`, `model: "opus"`                   |
| Fase 2 — Plan              | `Agent` con `subagent_type: "general-purpose"`, `model: "sonnet"`         |
| Fase 3 — Implementación    | `Agent` con `subagent_type: "general-purpose"`, `model: "sonnet"`         |
| Fase 4 — QA Mecánico       | `Agent` con `subagent_type: "general-purpose"`, `model: "haiku"`          |
| Fase 5 — QA Negocio        | `Agent` con `subagent_type: "general-purpose"`, `model: "sonnet"`         |
| Registrar y trackear fases | `TaskCreate` + `TaskUpdate`                                               |
| Linting en QA              | `Bash(npx eslint --format=compact <archivos>)` y `Bash(npx tsc --noEmit)` |

---

## Fase 0 — Stack detection y carga de skills

**Ejecutado por el orquestador directamente.**

### 1 — Registrar las 5 fases con TaskCreate

```
TaskCreate: "Fase 1 — Investigación"
TaskCreate: "Fase 2 — Plan y lista de tareas"
TaskCreate: "Fase 3 — Implementación"
TaskCreate: "Fase 4 — QA Mecánico"
TaskCreate: "Fase 5 — QA Negocio"
```

### 2 — Leer package.json y detectar stack

Leé `package.json` (y lockfile si existe). Consultá [SKILLS-CATALOG.md](SKILLS-CATALOG.md) para mapear dependencias → skills.

### 3 — Leer las skills detectadas

Leé cada SKILL.md antes de continuar. Se convierten en contexto activo para todas las fases.

### 4 — Informar al usuario

```
Stack detectado: Next.js · React 19 · TypeScript · Tailwind CSS 4
Skills cargadas: nextjs, react-19, typescript, tailwind-4
```

---

## Fase 1 — Investigación

**Agente:** `Explore` · `model: "opus"`

Esta fase siempre corre antes de cualquier implementación. Su objetivo es entender el terreno: qué existe, cómo funciona, qué se puede reutilizar, qué se puede mejorar.

Marcá Fase 1 como `in_progress`. Lanzá el agente con este prompt:

```
Investigá el proyecto en profundidad para entender el contexto de esta tarea: [TAREA DEL USUARIO]

No des nada por sabido. Leé el código real, no asumas comportamientos.

Respondé EXACTAMENTE con estas secciones:

### 1. Lógica de negocio
- ¿Qué flujo de negocio toca esta tarea?
- ¿Qué datos maneja? ¿De dónde vienen, qué transformaciones sufren, adónde van?
- ¿Qué reglas de negocio implícitas hay en el código existente que esta tarea debe respetar?
- ¿Qué casos edge o estados especiales existen en el flujo actual?

### 2. Inventario de reutilizables
Buscá EXHAUSTIVAMENTE en todo el proyecto. Para cada ítem: path completo + qué hace + si aplica directamente o necesita adaptación.

**Componentes:** ¿hay algo que haga algo similar a lo que se necesita?
**Hooks:** ¿hay lógica stateful reutilizable?
**Utils / mappers:** ¿hay funciones de transformación que apliquen?
**Services:** ¿hay servicios que ya manejen esta entidad o flujo?
**Types / interfaces:** ¿hay tipos existentes que apliquen o se puedan extender?
**Constantes / configs:** ¿hay configuraciones relevantes?

### 3. Oportunidades de mejora detectadas
Al investigar el código existente, ¿encontrás algo que conviene mejorar antes o durante esta tarea?
- Código duplicado que esta tarea podría consolidar
- Tipos incompletos o `any` que conviene corregir
- Lógica de negocio dentro de componentes que debería extraerse
- Patrones inconsistentes con el resto del proyecto
Listá solo lo que es relevante para esta tarea. No auditoría general.

### 4. Archivos afectados
- Archivos a modificar: path + motivo
- Archivos a crear: path + responsabilidad única

### 5. Ambigüedades de negocio
¿Hay algo que no podés determinar leyendo el código?
(comportamiento esperado, casos edge, reglas no documentadas)
Listá claramente — estas se resuelven con el usuario antes de continuar.
```

**Acción del orquestador:**

- Marcá Fase 1 como `completed`
- Si hay ambigüedades de negocio → **pausar y preguntar al usuario antes de continuar**
- Si no hay ambigüedades → pasar output completo a Fase 2

---

## Fase 2 — Plan y lista de tareas

**Agente:** `general-purpose` · `model: "sonnet"`

Marcá Fase 2 como `in_progress`. Lanzá el agente con este prompt:

```
Con base en la investigación, generá el plan de implementación y la lista de tareas para aprobación del usuario.

[OUTPUT COMPLETO DE FASE 1]

Revisá cada punto. Leé los archivos mencionados si necesitás confirmar algo.

1. REUTILIZACIÓN (prioridad máxima):
   - ¿El plan usa TODO lo identificado en el inventario?
   - ¿El plan propone crear algo que ya existe de otra forma?
   - ¿Los nuevos componentes se pueden diseñar para reutilización futura?
   - ¿Las interfaces propuestas ya existen o se pueden extender?

2. ARQUITECTURA Y SEPARACIÓN:
   - ¿Los archivos van en el lugar correcto según la estructura del proyecto?
   - ¿La lógica de negocio está en services/hooks/utils, no en componentes?
   - ¿Los componentes nuevos son genéricos o están acoplados a un caso específico?

3. MEJORAS: De las oportunidades detectadas en Fase 1, ¿cuáles conviene incluir en este plan?

4. REGLAS: Leé [RULES.md](RULES.md). ¿El plan las respeta?
   Stack activo: [LISTA DE SKILLS CARGADAS EN FASE 0]

Devolvé EXACTAMENTE este formato:

---
## 📋 Lista de tareas — [nombre de la feature]

### Contexto
[2-3 líneas: qué se va a hacer y por qué]

### Reutilizables que se van a usar
- `path/al/componente` — qué rol cumple en esta tarea
- `path/al/hook` — qué lógica aporta
(lista exhaustiva — si no se reutiliza nada, explicar por qué)

### Mejoras incluidas
- [mejora 1 detectada en Fase 1 que se incorpora]
(o "Ninguna" si no aplica)

### Pasos de implementación
1. [ ] Paso 1 — descripción + archivos afectados
2. [ ] Paso 2 — descripción + archivos afectados
3. [ ] Paso 3 — ...
(ordenados: primero tipos, luego servicios/hooks, luego componentes, luego tests)

### Archivos a crear
- `path/archivo.ts` — responsabilidad en una línea

### Archivos a modificar
- `path/archivo.tsx` — qué cambia y por qué

### Decisiones de diseño
- [decisión 1 que el implementador debe respetar]
- [decisión 2 ...]

### Riesgos
- [Alto/Medio/Bajo] — descripción del riesgo
---
```

**Acción del orquestador:**

- Marcá Fase 2 como `completed`
- **Presentar la lista al usuario exactamente como la generó el agente**
- **PAUSAR y esperar aprobación explícita antes de continuar**

---

## ⏸️ Checkpoint de aprobación

Después de Fase 2, el orquestador presenta al usuario:

```
Revisá la lista antes de que empiece la implementación.

[LISTA COMPLETA DE FASE 2]

¿Procedemos con esto? Podés:
- ✅ Aprobar → arrancamos
- ✏️ Ajustar → decime qué cambiamos
- ❓ Preguntar → aclaramos lo que necesites
```

**No avanzar a Fase 3 sin respuesta afirmativa del usuario.**

### Operatoria según el tipo de ajuste

| El usuario dice                                                               | Acción del orquestador                                                |
| ----------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| Cambio menor (wording, reordenar pasos, agregar un archivo)                   | Modificar el plan inline, confirmar al usuario y continuar a Fase 3   |
| Cambio de diseño (diferente arquitectura, nuevos módulos, decisión diferente) | Volver a Fase 2 con las notas del usuario como contexto adicional     |
| "Necesito entender mejor X antes de decidir"                                  | Volver a Fase 1 con la pregunta específica como foco de investigación |
| Cancelar                                                                      | Marcar todas las fases como `cancelled`, informar al usuario          |

---

## Fase 3 — Implementación

**Agente:** `general-purpose` · `model: "sonnet"`

Marcá Fase 3 como `in_progress`. Lanzá el agente con este prompt:

```
Implementá exactamente lo aprobado.

TAREA: [TAREA DEL USUARIO]

Antes de escribir cualquier línea, leé estos archivos:
- ~/.claude/skills/dev-pipeline/RULES.md
[PATHS DE SKILLS CARGADAS EN FASE 0 — uno por línea]

Luego leé cada archivo que vas a modificar antes de tocarlo.

PLAN APROBADO:
[SOLO ESTAS SECCIONES DEL OUTPUT DE FASE 2:]
- Reutilizables que se van a usar
- Pasos de implementación
- Archivos a crear
- Archivos a modificar
- Decisiones de diseño

Reglas obligatorias:
- Usá TODOS los reutilizables del plan — no recreés nada que ya existe
- Componentes nuevos: props genéricas, IProps fuera del componente, sin lógica de negocio
- Funciones siempre como const arrow functions, nunca function keyword
- Separación estricta: lógica en services/utils/hooks/mappers, UI en componentes
- Si encontrás algo que el plan no contempló y cambia la lógica de negocio → STOP y reportalo
- Sin console.log, comentarios obvios ni código muerto

Al terminar, devolvé:
1. Lista de archivos creados/modificados con descripción de una línea cada uno
2. Decisiones no previstas en el plan (si las hubo) con justificación
```

### Batching para features grandes

Si el plan tiene **más de 5 archivos** a crear/modificar, implementar en batches ordenados:

```
Batch 1: tipos + interfaces + servicios + mappers
    ↓ verificar que compila (tsc --noEmit)
Batch 2: hooks + utils + Server Actions
    ↓ verificar que compila
Batch 3: componentes + páginas + wiring final
    ↓ pasar a QA
```

El orquestador relanza Fase 3 por batch, pasando los archivos ya implementados como contexto para el siguiente.

**Acción del orquestador:**

- Marcá Fase 3 como `completed`
- Si hay decisiones no previstas que afectan lógica de negocio → consultar al usuario antes de continuar
- Si todo está en orden → pasar lista de archivos a Fase 4

---

## Fase 4 — QA Mecánico

**Agente:** `general-purpose` · `model: "haiku"`

Verificación estructurada y determinística. Sin razonamiento semántico — solo checks mecánicos.

Marcá Fase 4 como `in_progress`. Lanzá el agente con este prompt:

```
Verificá mecánicamente la implementación. Leé los archivos reales.

ARCHIVOS MODIFICADOS/CREADOS: [LISTA DE FASE 3]

1. LINTS:
   - ESLint: Bash `npx eslint --format=compact <archivos>`
   - TypeScript: Bash `npx tsc --noEmit`

2. CONVENCIONES (leé ~/.claude/skills/dev-pipeline/RULES.md):
   - ¿const arrow functions? ¿Ningún function keyword?
   - ¿Props tipadas fuera del componente con IProps?
   - ¿Early return en vez de if/else anidado?
   - ¿Sin let innecesario?
   - ¿Sin any ni casteos inseguros?
   - ¿Sin console.log ni código muerto?

3. ESTRUCTURA:
   - ¿Los archivos están en el directorio correcto (components/ hooks/ utils/ services/)?
   - ¿Hay index.ts con re-export para cada componente nuevo?

4. COMPLETITUD:
   - ¿Se crearon/modificaron todos los archivos del plan?
   - ¿Algún paso de implementación quedó sin completar?

Formato de respuesta:
## QA Mecánico: PASS ✅ / FAIL ❌

### Issues que bloquean (lint errors, tsc errors, convenciones rotas)
- ...

### Confirmado ✅
- ...
```

**Acción del orquestador:**

- Marcá Fase 4 como `completed`
- FAIL → relanzar Fase 3 con el reporte (máximo **2 reintentos**)
- Después de 2 reintentos fallidos → **escalar al usuario** con el reporte completo, no seguir looping
- PASS → continuar a Fase 5

---

## Fase 5 — QA Negocio

**Agente:** `general-purpose` · `model: "sonnet"`

Revisión semántica. Requiere entender el dominio — haiku no puede hacer esto bien.

Marcá Fase 5 como `in_progress`. Lanzá el agente con este prompt:

```
Revisá la implementación contra la lógica de negocio. Leé los archivos reales.

TAREA ORIGINAL: [TAREA DEL USUARIO]
ARCHIVOS MODIFICADOS/CREADOS: [LISTA DE FASE 3]
REGLAS DE NEGOCIO IDENTIFICADAS EN FASE 1: [SECCIÓN 1 DEL OUTPUT DE FASE 1]

1. LÓGICA DE NEGOCIO:
   - ¿La implementación respeta todas las reglas de negocio identificadas?
   - ¿Hay casos edge del flujo actual que quedaron sin cubrir?
   - ¿Hay lógica de negocio dentro de componentes UI que debería estar en services/hooks?

2. REUTILIZACIÓN:
   - ¿Se usaron todos los reutilizables del plan?
   - ¿Se duplicó lógica que ya existía en el proyecto?
   - ¿Los componentes nuevos son genéricos o tienen lógica hardcodeada?

3. PERFORMANCE:
   - ¿Componentes pesados sin dynamic import?
   - ¿Imágenes sin next/image?
   - ¿Fetches secuenciales que podrían ser paralelos?
   - ¿Client Components innecesarios (podrían ser Server Components)?

4. TESTS: (testing progresivo — no bloquea merge)
   - Nueva lógica de negocio → indicar path y tipo de test unitario recomendado
   - Nuevo flujo completo → indicar caso E2E a cubrir

Formato de respuesta:
## QA Negocio: PASS ✅ / FAIL ❌ / PASS CON OBSERVACIONES ⚠️

### Issues críticos (bloquean merge)
- ...

### Observaciones (no bloquean, mejoras sugeridas)
- ...

### Tests pendientes
- ...

### Confirmado ✅
- ...
```

**Acción del orquestador:**

- Marcá Fase 5 como `completed`
- FAIL con issues críticos → relanzar Fase 3 con el reporte (máximo **2 reintentos totales** contando los de Fase 4)
- PASS o PASS CON OBSERVACIONES → presentar reporte completo al usuario

---

## Reglas del orquestador

- **No implementes vos** — siempre delegá a agentes
- **Nunca des nada por sabido** — si la lógica de negocio no queda clara, preguntá
- **Pasá solo el contexto necesario por fase** — Fase 3 recibe el plan comprimido (secciones accionables), no el raw de Fase 1. Fase 4 recibe solo archivos. Fase 5 recibe archivos + reglas de negocio de Fase 1.
- **Fase 1 es obligatoria siempre** — no saltearse la investigación
- **El checkpoint de aprobación es hard stop** — sin OK del usuario no hay Fase 3
- **Reintentos de Fase 3: máximo 2 en total** — si falla dos veces, escalar al usuario con el reporte
- **Fase 1** → `opus` · **Fases 2, 3, 5** → `sonnet` · **Fase 4** → `haiku`

## Recursos

- Convenciones y anti-patrones: [RULES.md](RULES.md)
- Mapeo de dependencias → skills: [SKILLS-CATALOG.md](SKILLS-CATALOG.md)
