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
3. Validar contra plan o criterios si existen. Si no hay plan ni pipeline previo (cambio manual, hecho a mano o en otra herramienta/sesion), reconstruir la intencion desde el diff mismo antes de opinar, y marcarlo explicito en el output: "Sin plan de referencia — intencion inferida del diff". Si hay plan con "Out of scope"/"Archivos afectados" declarados, comparar el diff real contra eso — scope creep (archivos tocados que el plan no menciona, cambios fuera de lo declarado "out of scope") es un finding en si mismo, no un detalle menor.
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
- Decisiones arquitectonicas no documentadas: [alguna decision de peso que el diff toma sin dejar rastro en plan/ADR/comentario]

### Scope
- Scope creep: [cambios fuera de lo que el plan declaraba — archivos no mencionados, "out of scope" tocado]
- Cambios colaterales: [efectos en codigo que el plan no tocaba, aunque sean "mejoras" de paso]

### Bugs y edge cases
- ...

### Complejidad / mantenibilidad
- Abstracciones innecesarias:
- Duplicacion:
- Archivos demasiado grandes para su responsabilidad:

### Tests faltantes
- ...

### Decision final
[Que hacer antes de mergear]
