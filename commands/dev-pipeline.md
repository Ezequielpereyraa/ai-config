---
description: Ejecuta un plan aprobado. Motor de implementacion, no primer paso de analisis.
argument-hint: [plan aprobado o input generado por /create-plan]
---

Plan aprobado: `$ARGUMENTS`.

## Regla critica

`/dev-pipeline` **nunca deberia ser el primer paso** para features/refactors medianos o grandes.

Solo ejecutar cuando ya existe:

- Analisis o contexto suficiente.
- Solucion elegida.
- Plan aprobado.
- Criterios de aceptacion.
- Fuera de scope.
- Riesgos conocidos.

Si falta algo, frenar y pedir `/analyze-feature` o `/create-plan`.

## Objetivo

Implementar exactamente el plan aprobado usando la skill `dev-pipeline`.

## Instrucciones

1. Validar que el input contiene decision, plan, scope y checks.
2. Si el cambio es trivial, resolver por chat y no activar pipeline pesado.
3. Si el plan es suficiente, usar `dev-pipeline` como motor de ejecucion.
4. No cambiar arquitectura ni scope sin volver a pedir aprobacion.

## Output esperado

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
- Riesgos pendientes
- Recomendacion de review
