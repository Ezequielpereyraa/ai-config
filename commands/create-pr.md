---
description: Genera documentacion de PR clara: contexto, solucion, testing, riesgos y rollback.
argument-hint: [diff actual, rama, ticket o resumen]
---

Contexto de PR: `$ARGUMENTS`.

## Objetivo

Preparar una PR entendible para reviewers. No maquillar riesgos ni inventar testing.

## Proceso

1. Leer diff actual y commits relevantes.
2. Identificar problema resuelto y solucion implementada.
3. Resumir cambios por capa.
4. Declarar testing real.
5. Declarar riesgos, rollback y notas de review.

## Output obligatorio

### Title
[Conventional commit style si aplica]

### Summary
[2-4 bullets maximo]

### Context
- Ticket / problema:
- Por que se cambia:

### Solution
- Que se implemento:
- Decisiones relevantes:
- Fuera de scope:

### Changes
- Frontend:
- Backend:
- Data / contracts:
- Tests:

### Testing
- [ ] Comando / verificacion ejecutada
- [ ] QA manual

### Risks
- Riesgo:
- Mitigacion:

### Rollback
[Como volver atras o desactivar si falla]

### Reviewer notes
- Donde mirar primero:
- Decision que merece especial atencion:
