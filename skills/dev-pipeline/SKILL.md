---
name: dev-pipeline
description: >
  Motor de implementacion post-plan. Usar cuando ya existe analisis, solucion elegida,
  plan aprobado, criterios de aceptacion y fuera de scope. No usar como primer paso
  para features o refactors medianos/grandes.
---

# Dev Pipeline

El asistente no es solo un generador de codigo. Tambien debe cuidar scope, arquitectura, review, QA y tradeoffs.

Esta skill existe para ejecutar. El pensamiento fuerte ocurre antes:

```
Ticket
  -> /analyze-feature
  -> /create-plan
  -> /dev-pipeline
  -> /review-work
  -> /create-pr
```

## Cuándo usar

Usar cuando el input incluye:

- Ticket o problema original.
- Solucion elegida.
- Plan aprobado.
- Criterios de aceptacion.
- Fuera de scope.
- Riesgos conocidos.
- Checks esperados.

No usar cuando:

- El ticket todavia es ambiguo.
- Hay varias soluciones posibles sin decision.
- La arquitectura no fue desafiada.
- El pedido es un cambio trivial que se puede resolver por chat.
- El usuario solo quiere analizar, estimar o revisar.

## Routing

La clasificacion de tarea se decide en `WORKFLOW.md`. Esta skill solo aplica cuando el resultado de esa clasificacion es "ejecutar con plan aprobado".

## Preflight

Antes de tocar codigo, validar lo minimo necesario. Mantenerlo breve salvo que el plan sea grande o riesgoso:

```md
## Preflight

- Plan aprobado: si/no
- Scope claro: si/no
- Criterios de aceptacion: si/no
- Fuera de scope: si/no
- Checks definidos: si/no
- Riesgos conocidos: si/no

Decision: ejecutar / frenar
Motivo:
```

Si alguna respuesta clave es "no", frenar.

## Skills activas

Leer las skills necesarias segun stack detectado:

- Base TS/JS: `engineering-standards`
- Next.js/React: `nextjs`, `react-19`
- TypeScript: `typescript`
- Tailwind: `tailwind-4`
- NestJS: `nestjs`
- Tests: use the project's configured test tools
- UI: `ui-design`

No duplicar reglas de esas skills dentro del plan. Referenciarlas y aplicarlas.

## Fases

### Fase 1 — Context scan

Leer solo lo necesario para ejecutar el plan:

- Archivos a modificar.
- Reutilizables mencionados.
- Tipos/contratos afectados.
- Tests relevantes si existen.

Output:

```md
### Context scan
- Reutilizables confirmados:
- Archivos confirmados:
- Convenciones detectadas:
- Bloqueos:
```

Si aparece una decision de arquitectura no contemplada, frenar.

### Fase 2 — Implementacion incremental

Implementar siguiendo el plan aprobado.

Reglas:

- No ampliar scope.
- No refactorizar codigo preexistente fuera del plan.
- No cambiar decisiones de arquitectura sin aprobacion.
- Cada paso debe tener verificacion concreta.
- Si el plan esta mal, reportar el problema antes de improvisar.

Orden sugerido:

1. Tipos / contratos.
2. Services / mappers / utils.
3. Hooks / Server Actions / route handlers.
4. Componentes / paginas / wiring.
5. Tests o ajustes de tests.

### Fase 3 — Deslop + QA mecanico

Primero, ejecutar `deslop` sobre el diff para limpiar ruido generado por IA (comentarios inservibles, `any` casts, defensiveness anormal).  
Luego, ejecutar checks razonables para el repo:

- Typecheck si existe.
- Tests relevantes si existen.
- Lint focalizado si esta disponible.
- Revision de convenciones contra `engineering-standards`.

No correr builds pesados salvo pedido explicito.

Output:

```md
## QA Mecanico

- Deslop:
- Typecheck:
- Tests:
- Lint:
- Convenciones:
- Resultado:
```

### Fase 4 — Review de negocio

Validar contra criterios de aceptacion:

- Cada criterio esta cubierto.
- Edge cases principales estan contemplados.
- El fuera de scope no se implemento accidentalmente.
- No se duplico logica existente.
- No se metio logica de negocio en UI.

Output:

```md
## Review de negocio

| Criterio | Estado | Evidencia |
|---|---|---|
| ... | cubierto/no cubierto | ... |

### Riesgos pendientes
- ...
```

## Cierre

Reportar lo necesario para que el usuario pueda revisar el resultado. Mantenerlo compacto si el cambio fue chico.

```md
## Resultado

### Cambios
- `path` — que cambio

### Checks ejecutados
- comando — resultado

### Riesgos pendientes
- ...

### Siguiente paso
Ejecutar `/review-work` antes de `/create-pr`.
```
