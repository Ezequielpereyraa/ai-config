---
name: dev-pipeline
description: Pipeline de desarrollo multi-agente de 4 fases. Usar cuando el usuario pida implementar una feature, componente, refactor o cualquier tarea de programación no trivial. Orquesta subagentes de planificación, validación técnica, implementación y QA en ese orden.
---

# Dev Pipeline — Orquestador multi-agente

Pipeline de 4 fases para implementar tareas con calidad y coherencia. El agente principal **solo orquesta** — no implementa directamente.

## Cuándo aplicar

Aplicar ante cualquier tarea que implique:
- Crear o modificar componentes, páginas, hooks, servicios, utils
- Refactors o reestructuraciones
- Nuevas features con múltiples archivos afectados

Para tareas triviales de 1 archivo y 1 responsabilidad, implementar directamente sin pipeline.

---

## Principio rector — antes de cualquier fase

> **Nunca des nada por sabido. Si algo de la lógica de negocio no queda claro a partir del código, preguntá al usuario antes de continuar.**

Ante cualquier ambigüedad sobre:
- Para qué sirve un flujo o funcionalidad
- Cómo debe comportarse en un caso edge
- Qué datos o contexto maneja una entidad

**Detené el pipeline y preguntá.** Es mejor una pregunta al inicio que una implementación incorrecta al final.

---

## Herramientas de Claude Code usadas por el orquestador

| Propósito | Herramienta |
|-----------|-------------|
| Agente exploración (read-only, rápido) | `Agent` con `subagent_type: "Explore"`, `model: "haiku"` |
| Agente propósito general (análisis) | `Agent` con `subagent_type: "general-purpose"`, `model: "haiku"` |
| Agente implementación (escritura) | `Agent` con `subagent_type: "general-purpose"` (modelo default) |
| Registrar fases del pipeline | `TaskCreate` al inicio, `TaskUpdate` a `in_progress`/`completed` |
| Linting en QA | `Bash(npx eslint --format=compact <archivos>)` y `Bash(npx tsc --noEmit)` |

---

## Flujo general

```
Tarea del usuario
    │
    ▼
Fase 0: Detección de stack y carga de skills (orquestador · directo)
    │  Output: lista de skills activas para el proyecto
    ▼ (si hay ambigüedades de negocio → preguntar antes de continuar)
    │
Fase 1: Planificación (Explore · haiku)
    │  Output: mapa de archivos + lógica de negocio + reutilizables + plan
    ▼
Fase 2: Validación técnica (general-purpose · haiku)
    │  Output: plan ajustado + riesgos + oportunidades de reutilización
    ▼
Fase 3: Implementación (general-purpose · modelo default)
    │  Output: código implementado con componentes reutilizables
    ▼
Fase 4: QA (general-purpose · haiku)
       Output: reporte pass/fail + issues pendientes
```

---

## Fase 0 — Detección de stack y carga de skills

**Ejecutado por el orquestador directamente** (no es un subagente). Hacelo antes de lanzar cualquier fase.

### Paso 1 — Registrar las fases con TaskCreate

Creá una tarea por cada fase antes de empezar:
```
TaskCreate: "Fase 1 — Planificación y análisis"
TaskCreate: "Fase 2 — Validación técnica"
TaskCreate: "Fase 3 — Implementación"
TaskCreate: "Fase 4 — QA y verificación"
```

### Paso 2 — Leer el package.json del proyecto

Leé `package.json` (y `package-lock.json` o `pnpm-lock.yaml` si existe) para detectar las dependencias reales.

### Paso 3 — Mapear dependencias a skills

Consultá [SKILLS-CATALOG.md](SKILLS-CATALOG.md) para el mapeo completo de dependencias → skills.

**Stack más común (Next.js + TypeScript + Tailwind):** sumá estas como mínimo:
- `~/.claude/skills/nextjs-15/SKILL.md`
- `~/.claude/skills/next-best-practices/SKILL.md`
- `~/.claude/skills/react-19/SKILL.md`
- `~/.claude/skills/vercel-react-best-practices/SKILL.md`
- `~/.claude/skills/typescript/SKILL.md`
- `~/.claude/skills/tailwind-4/SKILL.md`

Luego sumá las adicionales según lo que detectes. Ver [SKILLS-CATALOG.md](SKILLS-CATALOG.md) para el listado completo.

### Paso 4 — Leer las skills detectadas

Leé cada SKILL.md identificado antes de continuar. Su contenido se convierte en **contexto activo** para todas las fases siguientes.

### Paso 5 — Informar al usuario

Antes de avanzar a Fase 1, mostrá un resumen breve:

```
Stack detectado: Next.js 15 · React 19 · TypeScript · Tailwind CSS 4 · Zod
Skills cargadas: nextjs-15, react-19, typescript, tailwind-4, zod-4, next-best-practices, vercel-react-best-practices
```

---

## Fase 1 — Planificación y análisis de negocio

**Agente:** `Explore` · `model: "haiku"`

Marcá la tarea de Fase 1 como `in_progress` antes de lanzar el agente.

**Prompt al agente:**
```
Explorá el proyecto en profundidad para planificar la siguiente tarea: [TAREA DEL USUARIO]

IMPORTANTE: No des nada por sabido. Leé el código real, no asumas comportamientos.

Devolvé EXACTAMENTE esto:

### 1. Lógica de negocio relevante
- ¿Qué flujo de negocio toca esta tarea?
- ¿Qué datos maneja? ¿De dónde vienen y adónde van?
- ¿Hay reglas de negocio implícitas en el código existente que esta tarea debe respetar?
- ¿Qué casos edge o estados especiales existen en el flujo actual?

### 2. Inventario de reutilizables
Buscá EXHAUSTIVAMENTE en todo el proyecto:
- Componentes que hacen algo similar o idéntico a lo que se necesita
- Hooks con lógica reutilizable
- Utils y funciones de transformación de datos
- Tipos e interfaces existentes que apliquen
- Constantes y configuraciones relevantes
Para cada uno: path completo + qué hace + si se puede usar directamente o adaptar

### 3. Archivos afectados
- Archivos a modificar (path + por qué)
- Archivos a crear (path + responsabilidad)

### 4. Plan de acción paso a paso
En qué orden y qué hace cada paso, priorizando reutilizar sobre crear.

### 5. Ambigüedades de negocio
Si encontrás algo que no podés determinar leyendo el código (comportamiento esperado, casos edge, reglas de negocio no documentadas), listalo claramente.
```

**Output esperado:** análisis de negocio + inventario de reutilizables + plan.

**Acción del orquestador:**
- Marcá Fase 1 como `completed`
- Si hay ambigüedades de negocio → **pausar el pipeline y preguntar al usuario** antes de continuar
- Si no hay ambigüedades → pasar el output completo a Fase 2

---

## Fase 2 — Validación técnica

**Agente:** `general-purpose` · `model: "haiku"`

Marcá la tarea de Fase 2 como `in_progress` antes de lanzar el agente.

**Prompt al agente:**
```
Validá este plan contra el proyecto y profundizá en las oportunidades de reutilización.

[OUTPUT COMPLETO DE FASE 1]

Revisá cada punto sin asumir nada — leé los archivos mencionados si necesitás confirmar:

1. REUTILIZACIÓN (prioridad máxima):
   - ¿El plan aprovecha TODO lo que se identificó en el inventario de reutilizables?
   - ¿Hay algo que el plan propone crear que ya existe de otra forma en el proyecto?
   - ¿Los nuevos componentes a crear pueden diseñarse para ser reutilizables en el futuro?
   - ¿Las interfaces/tipos propuestos ya existen o se pueden extender?

2. LÓGICA DE NEGOCIO:
   - ¿El plan respeta todas las reglas de negocio identificadas en Fase 1?
   - ¿Hay alguna regla implícita en el código existente que el plan podría romper?

3. ARQUITECTURA:
   - ¿Los archivos van en el lugar correcto según la estructura del proyecto?
   - ¿Se está separando correctamente lógica de negocio, UI y datos?

4. PERFORMANCE Y BUNDLE:
   - ¿Se agregan dependencias innecesarias?
   - ¿Los componentes nuevos necesitan dynamic import?
   - ¿Hay oportunidades de memoización o cache que el plan no contempla?

5. REGLAS Y BEST PRACTICES: Leé [RULES.md](RULES.md) y verificá que el plan las respete.
   Además aplicá las siguientes skills del stack del proyecto: [LISTA DE SKILLS CARGADAS EN FASE 0]

Devolvé:
- Plan final ajustado (explicitá qué cambió respecto al plan original y por qué)
- Decisiones de diseño que el implementador debe respetar
- Riesgos técnicos con impacto (Alto/Medio/Bajo)
```

**Output esperado:** plan final validado con decisiones de diseño explícitas.

**Acción del orquestador:** marcá Fase 2 como `completed` y extraé el plan validado para Fase 3.

---

## Fase 3 — Implementación

**Agente:** `general-purpose` · modelo default (sin `model` override)

Marcá la tarea de Fase 3 como `in_progress` antes de lanzar el agente.

**Prompt al agente:**
```
Implementá la siguiente tarea. Antes de escribir cualquier línea:
1. Leé [RULES.md](RULES.md)
2. Leé cada archivo que vas a modificar
3. Verificá que estás usando los reutilizables identificados en el plan

TAREA ORIGINAL: [TAREA DEL USUARIO]

STACK Y BEST PRACTICES ACTIVAS: [LISTA DE SKILLS CARGADAS EN FASE 0]
Aplicá las guías de esas skills en cada decisión de implementación.

PLAN VALIDADO Y DECISIONES DE DISEÑO:
[OUTPUT COMPLETO DE FASE 2]

Reglas de implementación obligatorias:
- Usá TODOS los componentes, hooks y utils existentes identificados en el plan — no recreés nada que ya existe
- Los componentes nuevos deben diseñarse para ser reutilizables: props genéricas, sin lógica de negocio hardcodeada dentro
- Separación estricta: lógica de negocio en services/utils/hooks, UI en componentes
- Si en medio de la implementación encontrás algo que el plan no contempló y que cambia la lógica de negocio → detenete y reportalo antes de continuar
- No agregues console.log, comentarios obvios ni código muerto

Al terminar, devolvé:
1. Lista de archivos creados/modificados con una línea de descripción cada uno
2. Si tomaste alguna decisión no prevista en el plan, explicala
```

**Output esperado:** código implementado + lista de archivos tocados + decisiones no previstas.

**Acción del orquestador:**
- Marcá Fase 3 como `completed`
- Si el agente reporta algo no previsto que afecta lógica de negocio → consultar al usuario
- Si todo está en orden → pasar la lista de archivos a Fase 4

---

## Fase 4 — QA y Verificación

**Agente:** `general-purpose` · `model: "haiku"`

Marcá la tarea de Fase 4 como `in_progress` antes de lanzar el agente.

**Prompt al agente:**
```
Revisá la implementación y emití un reporte de calidad. Leé los archivos reales — no asumas nada.

TAREA ORIGINAL: [TAREA DEL USUARIO]
ARCHIVOS MODIFICADOS/CREADOS: [LISTA DE FASE 3]

Verificá cada punto leyendo el código:

1. LÓGICA DE NEGOCIO:
   - ¿La implementación respeta las reglas de negocio identificadas en la planificación?
   - ¿Hay algún caso edge que no esté cubierto?
   - ¿Se introdujo lógica de negocio dentro de componentes de UI en lugar de services/hooks/utils?

2. REUTILIZACIÓN:
   - ¿Se usaron los componentes, hooks y utils existentes identificados en el plan?
   - ¿Se duplicó lógica que ya existía en otro lugar del proyecto?
   - ¿Los nuevos componentes creados son reutilizables o tienen lógica hardcodeada?

3. REGLAS Y BEST PRACTICES: Leé [RULES.md](RULES.md) y verificá:
   - const vs let, no if/else innecesarios, no useEffect para derivados
   - No any, no casteos inseguros, tipos completos
   - Separación de responsabilidades
   Además verificá que se respeten las guías de las skills activas: [LISTA DE SKILLS CARGADAS EN FASE 0]

4. LINTS: Ejecutá los siguientes comandos de verificación estática y reportá cualquier error:
   - Si el proyecto tiene ESLint: Bash `npx eslint --format=compact <archivos modificados>`
   - Si el proyecto tiene TypeScript: Bash `npx tsc --noEmit`
   Reportá los errores encontrados textualmente.

5. PERFORMANCE:
   - ¿Componentes pesados sin dynamic import?
   - ¿Imágenes sin next/image?
   - ¿Dependencias innecesarias agregadas?

6. COMPLETITUD: ¿Se implementó todo lo que pedía la tarea original?

Formato del reporte:
## Resultado: PASS ✅ / FAIL ❌ / PASS CON OBSERVACIONES ⚠️

### Issues críticos (bloquean merge)
- ...

### Observaciones (no bloquean)
- ...

### Confirmado ✅
- ...
```

**Acción del orquestador:**
- Marcá Fase 4 como `completed`
- Issues críticos → relanzar solo Fase 3 con el reporte como contexto adicional
- PASS o PASS CON OBSERVACIONES → reportar al usuario con el resumen del reporte

---

## Reglas del orquestador

- **No implementes vos** — siempre delegá a subagentes con el `Agent` tool
- **Nunca des nada por sabido** — si la lógica de negocio no es clara a partir del código, preguntá al usuario
- **Pasá contexto completo** entre fases — cada agente empieza de cero sin memoria del anterior
- **Usá `TaskCreate`** al inicio para registrar las 4 fases y `TaskUpdate` para marcar cada una al completarse
- **Pausá ante ambigüedades de negocio** — mejor preguntar que implementar algo incorrecto
- **Si Fase 4 falla**, no relances todo el pipeline — solo relanzá Fase 3 con el reporte de QA como contexto adicional
- **Fases 1, 2, 4** usan `model: "haiku"` — son análisis, no requieren el modelo más potente
- **Fase 3** usa el modelo default — la implementación requiere máxima calidad

## Recursos

- Reglas del proyecto para todos los subagentes: [RULES.md](RULES.md)
- Catálogo de skills disponibles y mapeo de dependencias: [SKILLS-CATALOG.md](SKILLS-CATALOG.md)
