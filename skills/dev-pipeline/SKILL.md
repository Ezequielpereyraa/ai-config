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
- UI: `impeccable`

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

Si el plan viene de un archivo `plans/*.md`: al terminar y verificar cada paso de la checklist, marcarlo `[x]` en ese archivo antes de pasar al siguiente — no esperar al cierre para actualizarlo. Esto deja el plan como estado real ejecutable: si la sesion se corta, retomar es leer el archivo y seguir desde el primer `[ ]` sin marcar, no releer la conversacion.

Si el pedido acota el rango ("hasta el paso N", "solo pasos X-Y") o pide un modelo/agente distinto para un paso puntual, respetarlo y decirlo en el cierre — no asumir que hay que correr el plan entero.

Orden sugerido:

1. Tipos / contratos.
2. Services / mappers / utils.
3. Hooks / Server Actions / route handlers.
4. Componentes / paginas / wiring.
5. Tests o ajustes de tests.

### Fase 3 — Deslop + QA mecanico

Primero, revisar el diff y usar `deslop` cuando el cambio de codigo sea no trivial o muestre ruido generado por IA. Para cambios chicos o documentales, hacer una revision directa sin cargar pipeline adicional.

Luego, ejecutar el conjunto minimo de checks que cubra el riesgo real:

- Typecheck solo si cambiaron contratos o codigo tipado.
- Tests dirigidos a los modulos tocados. Correr la suite completa solo para cambios transversales, de alto riesgo o cuando no haya una seleccion confiable.
- Lint focalizado sobre archivos cambiados si el proyecto lo soporta. Usar lint completo solo cuando sea la unica opcion razonable.
- Revision de convenciones contra `engineering-standards`.
- `git diff --check` antes de cerrar cambios de codigo.

#### Build local

- **No ejecutar `build` local por defecto.** El build de CI/Vercel es la validacion normal de produccion.
- No inferir que `pnpm build`, `npm run build` o equivalente es obligatorio porque aparece en docs del repositorio, un checklist generico o un plan anterior.
- Ejecutarlo unicamente si el usuario lo pide explicitamente en el pedido actual o si CI/Vercel no esta disponible y el usuario aprueba el costo antes de correrlo.
- Si no se corre, reportar `Build local: omitido; se valida en CI/Vercel`, sin tratarlo como gap bloqueante.

#### React Doctor

- Correr React Doctor solo si cambiaron componentes, hooks o comportamiento React de forma sustancial.
- Omitirlo para backend, docs, copy-only, estilos triviales o cambios ya cubiertos por typecheck/lint/tests dirigidos.
- Usar siempre el scope mas chico disponible (`changed` o `lines`), nunca un scan completo como cierre rutinario.
- No instalar ni descargar React Doctor durante el pipeline. Si no esta disponible localmente o como script del proyecto, omitirlo y reportarlo.
- Ejecutarlo una sola vez al final; no repetirlo despues de cambios de copy menores si lint y typecheck siguen pasando.

Siempre que sean independientes, correr los checks seleccionados en paralelo.

Output:

```md
## QA Mecanico

- Deslop:
- Typecheck:
- Tests:
- Lint:
- React Doctor: ejecutado/omitido (motivo)
- Build local: omitido; se valida en CI/Vercel
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

### Plan
- Archivo: `plans/<slug>.md`
- Progreso: N/M pasos completados
- Detenido en: [paso, si no se corrio completo, y por que]

### Riesgos pendientes
- ...

### Siguiente paso
Si el plan quedo incompleto: retomar con `/dev-pipeline plans/<slug>.md`. Si se completo: ejecutar `/review-work` antes de `/create-pr`.
```
