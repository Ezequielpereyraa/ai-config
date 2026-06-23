---
description: Analisis tecnico de ticket/feature antes de planificar o implementar.
argument-hint: [ticket, requerimiento o refactor]
---

Ticket / requerimiento: `$ARGUMENTS`.

## Reglas criticas

**NO escribas codigo.** Este comando existe para pensar antes de ejecutar.

Primero clasificá la tarea segun `WORKFLOW.md`: `small`, `medium`, `large` o `risky`.

Si el pedido es `small`, no generes el artefacto completo. Decí que alcanza resolverlo por chat, explicá el motivo en 1-3 bullets y frená.

## Objetivo

Entender el problema, explorar opciones, desafiar la solucion obvia, estimar incertidumbre y dejar una decision lista para planificar.

## Proceso

1. Leer el contexto relevante del repo antes de opinar.
2. Identificar problema real, usuarios afectados y constraints.
3. Proponer opciones solo si hay decisiones reales.
4. Desafiar la opcion recomendada: riesgos, edge cases, acoplamiento, deuda futura.
5. Estimar por complejidad e incertidumbre, no por falsa precision.
6. Terminar con una decision requerida. No implementar.

## Output

Usar el menor formato que preserve correctness.

### Compacto (`medium` por defecto)

Usar cuando hay una opcion clara o el riesgo es moderado:

### Resumen
[Problema + recomendacion en 2-4 lineas]

### Contexto leido
- `path` — por que importa

### Recomendacion
- Opcion recomendada:
- Por que:
- Riesgos principales:
- Fuera de scope:

### Decision requerida
[Que tiene que decidir el usuario antes de pasar a `/create-plan` o implementar directo]

### Completo (`large` o `risky`)

Usar solo si hay varias opciones reales, alta incertidumbre o riesgo alto.

### Opciones

| Opcion | Descripcion | Pros | Contras | Riesgos | Cuando elegirla |
|---|---|---|---|---|---|
| A | ... | ... | ... | ... | ... |

Si solo hay una opcion razonable, decirlo y explicar por que.

### Challenge
- Riesgos principales:
- Edge cases:
- Acoplamientos:
- Que podria salir mal:
- Alternativa a descartar conscientemente:

### Estimacion

| Dimension | Nivel | Nota |
|---|---|---|
| Complejidad | Baja / Media / Alta | ... |
| Riesgo | Bajo / Medio / Alto | ... |
| Incertidumbre | Baja / Media / Alta | ... |

- Optimista:
- Probable:
- Pesimista:

### Decision requerida
[Que tiene que decidir el usuario antes de pasar a `/create-plan`]
