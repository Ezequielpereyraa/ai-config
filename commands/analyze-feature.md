---
description: Analisis tecnico de ticket/feature antes de planificar o implementar.
argument-hint: [ticket, requerimiento o refactor]
---

Ticket / requerimiento: `$ARGUMENTS`.

## Regla critica

**NO escribas codigo.** Este comando existe para pensar antes de ejecutar.

Si el pedido parece chico, igual analizalo liviano y recomendá si alcanza resolverlo por chat.

## Objetivo

Entender el problema, explorar opciones, desafiar la solucion obvia, estimar incertidumbre y dejar una decision lista para planificar.

## Proceso

1. Leer el contexto relevante del repo antes de opinar.
2. Identificar problema real, usuarios afectados y constraints.
3. Proponer opciones solo si hay decisiones reales.
4. Desafiar la opcion recomendada: riesgos, edge cases, acoplamiento, deuda futura.
5. Estimar por complejidad e incertidumbre, no por falsa precision.
6. Terminar con una decision requerida. No implementar.

## Output obligatorio

### Resumen
[Problema en 2-3 lineas + recomendacion corta]

### Contexto leido
- `path` — por que importa

### Problema
- Usuario / actor:
- Resultado esperado:
- Restricciones:
- Fuera de scope:

### Opciones

| Opcion | Descripcion | Pros | Contras | Riesgos | Cuando elegirla |
|---|---|---|---|---|---|
| A | ... | ... | ... | ... | ... |

Si solo hay una opcion razonable, decirlo y explicar por que.

### Recomendacion
[Opcion recomendada + razon tecnica/producto]

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
