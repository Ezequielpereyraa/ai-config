---
description: Review senior de diff, PR o arquitectura. Unifica code review y architecture review.
argument-hint: [diff actual, archivo, carpeta, PR o decision tecnica]
---

Target de review: `$ARGUMENTS`.
Si no se especifica, revisar el diff actual.

## Objetivo

Revisar como Staff Engineer: bugs, seguridad, arquitectura, mantenibilidad, testabilidad y alineacion con el plan.

## Proceso

1. Leer el codigo/diff completo del alcance.
2. Entender la intencion del cambio.
3. Validar contra plan o criterios si existen.
4. Priorizar hallazgos por impacto.
5. No reescribir todo. Sugerir cambios concretos.

## Output

Findings first. No intro larga.

Usar el menor formato que preserve correctness.

### Compacto (`brief`/`standard`)

Usar para diffs chicos o medianos:

### Findings
- [Severidad] `path:line` — problema — fix sugerido

Si no hay findings: "No findings." y mencionar gaps de testing si existen.

### Decision
Mergea / necesita ajustes / necesita rework.

### Completo (`deep`)

Usar solo para PRs grandes, arquitectura, seguridad o cambios riesgosos.

### Veredicto
Mergea / necesita ajustes / necesita rework.

### Alcance revisado
- `path` — que se reviso

### Hallazgos bloqueantes

| Severidad | Archivo:linea | Problema | Fix sugerido |
|---|---|---|---|
| Alta | `path:line` | ... | ... |

Si no hay bloqueantes: "Ninguno".

### Arquitectura
- Acoplamiento:
- Cohesion:
- Boundaries:
- Escalabilidad:
- Testabilidad:

### Bugs y edge cases
- ...

### Complejidad / mantenibilidad
- ...

### Tests faltantes
- ...

### Decision final
[Que hacer antes de mergear]
