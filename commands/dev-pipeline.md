---
description: Ejecuta un plan aprobado. Motor de implementacion, no primer paso de analisis.
argument-hint: [plan aprobado, path a plans/*.md, o input generado por /create-plan]
---

Plan aprobado: `$ARGUMENTS`.

Si el argumento es un path a un archivo (ej. `plans/nombre.md`), leerlo antes de continuar. Si ya tiene pasos marcados `[x]`, retomar desde el primer paso sin marcar.

Se puede acotar la ejecucion en el mismo pedido: rango de pasos ("hasta el paso 3", "pasos 4 a 6") o modelo/agente puntual para un paso ("el paso 5 con \<modelo\>, porque necesita más razonamiento"). La skill `dev-pipeline` lo respeta y lo reporta en el cierre.

## Regla critica

`/dev-pipeline` **nunca deberia ser el primer paso** para features/refactors medianos o grandes.

Solo ejecutar cuando ya existe:

- Analisis o contexto suficiente.
- Solucion elegida.
- Plan aprobado.
- Criterios de aceptacion.
- Fuera de scope.
- Riesgos conocidos.

Si falta algo para un cambio `medium`, `large` o `risky`, frenar y pedir `/analyze-feature` o `/create-plan`.

Si el cambio es `trivial` o `small`, no uses pipeline pesado. Resolver por chat directo si el scope es claro.

## Objetivo

Implementar exactamente el plan aprobado usando la skill `dev-pipeline`.

## Instrucciones

1. Validar que el input contiene decision, plan, scope y checks.
2. Si el cambio es trivial, resolver por chat y no activar pipeline pesado.
3. Si el plan es suficiente, usar `dev-pipeline` como motor de ejecucion.
4. No cambiar arquitectura ni scope sin volver a pedir aprobacion.

## Output esperado

Mantenerlo breve salvo que el plan sea grande o riesgoso.

### Validacion de entrada
- Plan aprobado: si/no
- Scope claro: si/no
- Checks definidos: si/no
- Riesgos conocidos: si/no

### Ejecucion
Delegar a la skill `dev-pipeline`.

### Cierre
- Archivos modificados
- Checks ejecutados
- Progreso del plan (N/M pasos) y donde quedo si no se corrio completo
- Riesgos pendientes
- Recomendacion de review
