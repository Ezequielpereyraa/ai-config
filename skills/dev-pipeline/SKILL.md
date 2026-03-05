---
name: dev-pipeline
description: Pipeline de desarrollo multi-agente de 5 fases. Usar cuando el usuario pida implementar una feature, componente, refactor o cualquier tarea de programación no trivial. Investiga primero, propone lista de tareas, espera aprobación, luego implementa.
---

# Dev Pipeline — Orquestador multi-agente

El agente principal **solo orquesta** — no implementa directamente.

**Principio central:** Entender antes de escribir. Siempre. Sin excepciones.

## Cuándo aplicar

- Crear o modificar componentes, páginas, hooks, servicios, utils
- Refactors o reestructuraciones
- Nuevas features con múltiples archivos afectados

Para tareas triviales de 1 archivo y responsabilidad obvia → implementar directamente.

---

## Flujo general

```
Tarea del usuario
    │
    ▼
Fase 0: Stack detection + carga de skills (orquestador · directo)
    │
    ▼
Fase 1: Investigación (Explore · haiku)
    │  Entiende lógica de negocio, mapea reutilizables, detecta mejoras
    ▼
Fase 2: Plan + lista de tareas (general-purpose · haiku)
    │  Genera checklist priorizado con decisiones de diseño
    ▼
⏸️  PAUSA — El orquestador presenta la lista al usuario y espera aprobación
    │  El usuario puede ajustar, rechazar pasos o aclarar antes de continuar
    ▼
Fase 3: Implementación (general-purpose · modelo default)
    │  Ejecuta exactamente lo aprobado
    ▼
Fase 4: QA (general-purpose · haiku)
       Verifica calidad, lints, tests pendientes
```

---

## Herramientas del orquestador

| Propósito | Herramienta |
|-----------|-------------|
| Agente exploración (read-only, rápido) | `Agent` con `subagent_type: "Explore"`, `model: "haiku"` |
| Agente análisis/plan | `Agent` con `subagent_type: "general-purpose"`, `model: "haiku"` |
| Agente implementación | `Agent` con `subagent_type: "general-purpose"` (modelo default) |
| Registrar y trackear fases | `TaskCreate` + `TaskUpdate` |
| Linting en QA | `Bash(npx eslint --format=compact <archivos>)` y `Bash(npx tsc --noEmit)` |

---

## Fase 0 — Stack detection y carga de skills

**Ejecutado por el orquestador directamente.**

### 1 — Registrar las 4 fases con TaskCreate

```
TaskCreate: "Fase 1 — Investigación"
TaskCreate: "Fase 2 — Plan y lista de tareas"
TaskCreate: "Fase 3 — Implementación"
TaskCreate: "Fase 4 — QA"
```

### 2 — Leer package.json y detectar stack

Leé `package.json` (y lockfile si existe). Consultá [SKILLS-CATALOG.md](SKILLS-CATALOG.md) para mapear dependencias → skills.

### 3 — Leer las skills detectadas

Leé cada SKILL.md antes de continuar. Se convierten en contexto activo para todas las fases.

### 4 — Informar al usuario

```
Stack detectado: Next.js 15 · React 19 · TypeScript · Tailwind CSS 4
Skills cargadas: nextjs-15, react-19, typescript, tailwind-4, next-best-practices
```

---

## Fase 1 — Investigación

**Agente:** `Explore` · `model: "haiku"`

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

**Agente:** `general-purpose` · `model: "haiku"`

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

4. REGLAS: Leé [RULES.md](RULES.md). ¿El plan las respete?
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
- El usuario puede: aprobar, modificar pasos, pedir más investigación, o cancelar
- Solo continuar a Fase 3 cuando el usuario diga explícitamente que está de acuerdo

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

---

## Fase 3 — Implementación

**Agente:** `general-purpose` · modelo default

Marcá Fase 3 como `in_progress`. Lanzá el agente con este prompt:

```
Implementá exactamente lo aprobado. Antes de escribir cualquier línea:
1. Leé [RULES.md](RULES.md)
2. Leé cada archivo que vas a modificar
3. Verificá que estás usando los reutilizables del plan

TAREA ORIGINAL: [TAREA DEL USUARIO]

STACK Y BEST PRACTICES: [LISTA DE SKILLS CARGADAS EN FASE 0]
Aplicá las guías de esas skills en cada decisión.

PLAN APROBADO:
[OUTPUT COMPLETO DE FASE 2]

Reglas obligatorias:
- Usá TODOS los reutilizables identificados — no recreés nada que ya existe
- Componentes nuevos: props genéricas, sin lógica de negocio hardcodeada, IProps fuera del componente
- Funciones siempre como const arrow functions, nunca function keyword
- Separación estricta: lógica en services/utils/hooks/mappers, UI en componentes
- Si encontrás algo que el plan no contempló y cambia la lógica de negocio → STOP y reportalo
- Sin console.log, comentarios obvios ni código muerto

Al terminar, devolvé:
1. Lista de archivos creados/modificados con descripción de una línea cada uno
2. Decisiones no previstas en el plan (si las hubo) con justificación
```

**Acción del orquestador:**
- Marcá Fase 3 como `completed`
- Si hay decisiones no previstas que afectan lógica de negocio → consultar al usuario
- Si todo está en orden → pasar lista de archivos a Fase 4

---

## Fase 4 — QA

**Agente:** `general-purpose` · `model: "haiku"`

Marcá Fase 4 como `in_progress`. Lanzá el agente con este prompt:

```
Revisá la implementación. Leé los archivos reales — no asumas nada.

TAREA ORIGINAL: [TAREA DEL USUARIO]
ARCHIVOS MODIFICADOS/CREADOS: [LISTA DE FASE 3]

1. LÓGICA DE NEGOCIO:
   - ¿Respeta las reglas identificadas en la investigación?
   - ¿Hay casos edge sin cubrir?
   - ¿Hay lógica de negocio dentro de componentes UI?

2. REUTILIZACIÓN:
   - ¿Se usaron los reutilizables identificados en el plan?
   - ¿Se duplicó lógica que ya existía?
   - ¿Los componentes nuevos son reutilizables o tienen lógica hardcodeada?

3. CONVENCIONES: Leé [RULES.md](RULES.md) y verificá:
   - const arrow functions, nunca function keyword
   - Props tipadas fuera del componente con IProps
   - No if/else → early return, lookup objects
   - No let innecesario
   - No any ni casteos inseguros
   - Separación en utils/hooks/mappers/services
   Skills activas: [LISTA DE SKILLS CARGADAS EN FASE 0]

4. LINTS:
   - ESLint: Bash `npx eslint --format=compact <archivos>`
   - TypeScript: Bash `npx tsc --noEmit`

5. PERFORMANCE:
   - ¿Componentes pesados sin dynamic import?
   - ¿Imágenes sin next/image?
   - ¿Dependencias innecesarias?

6. TESTS: (testing progresivo — no bloquea merge)
   - Nueva lógica de negocio → indicar path y tipo de test unitario
   - Nuevo flujo completo → indicar caso E2E a cubrir

7. COMPLETITUD: ¿Se implementó todo lo del plan aprobado?

Formato:
## Resultado: PASS ✅ / FAIL ❌ / PASS CON OBSERVACIONES ⚠️

### Issues críticos (bloquean merge)
- ...

### Observaciones (no bloquean)
- ...

### Tests pendientes
- ...

### Confirmado ✅
- ...
```

**Acción del orquestador:**
- Marcá Fase 4 como `completed`
- FAIL con issues críticos → relanzar solo Fase 3 con el reporte como contexto
- PASS o PASS CON OBSERVACIONES → presentar reporte al usuario

---

## Reglas del orquestador

- **No implementes vos** — siempre delegá a agentes
- **Nunca des nada por sabido** — si la lógica de negocio no queda clara, preguntá
- **Pasá contexto completo entre fases** — cada agente empieza desde cero
- **Fase 1 es obligatoria siempre** — no saltearse la investigación ni en tareas "simples"
- **El checkpoint de aprobación es hard stop** — sin OK del usuario no hay Fase 3
- **Si Fase 4 falla**, relanzar solo Fase 3 — no reiniciar todo el pipeline
- **Fases 1, 2, 4** → `model: "haiku"`. **Fase 3** → modelo default

## Recursos

- Convenciones y anti-patrones: [RULES.md](RULES.md)
- Mapeo de dependencias → skills: [SKILLS-CATALOG.md](SKILLS-CATALOG.md)
