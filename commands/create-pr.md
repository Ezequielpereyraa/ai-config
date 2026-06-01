---
description: Genera un PR description breve, util y honesto: summary, testing, changeset y riesgos solo si importan.
argument-hint: [diff actual, rama, ticket o resumen]
---

Contexto de PR: `$ARGUMENTS`.

## Objetivo

Crear una descripcion de PR que el reviewer realmente lea.

Reglas:

- Breve > completo pero ilegible.
- No inventar testing.
- No agregar secciones vacias.
- No explicar decisiones obvias.
- Incluir riesgos/notas solo si cambian como se revisa o mergea.

## Proceso

1. Leer diff actual y commits relevantes.
2. Identificar problema, solucion y archivos/capas tocadas.
3. Validar si el repo usa changesets y si este cambio requiere uno.
4. Generar una descripcion corta, priorizando lo que ayuda a review.

## Changeset check

Primero detectar si aplica:

- `.changeset/` existe, o
- `package.json` menciona `changeset` / `@changesets/*`.

Requiere changeset solo si el cambio afecta release notes o consumidores:

- feature
- bugfix visible
- API/export/type publicos
- comportamiento observable
- package surface

No requiere changeset para cambios internos, tests, docs, tooling, refactors sin cambio observable o copy/UI sin versionado.

## Output

### Title
[Conventional commit corto]

### Summary
- [Cambio principal]
- [Segundo cambio relevante, si existe]
- [Impacto para usuario/dev/reviewer, si aplica]

### Testing
- [Comando o verificacion real]
- [QA manual real, si aplica]

### Changeset
- Required: yes/no
- Reason: [1 linea]

### Rollback
[1 linea. Si alcanza con revert, decir "Revert this PR".]

### Risks
Incluir SOLO si hay riesgo real.

- [Riesgo] -> [mitigacion]

### Reviewer notes
Incluir SOLO si hay algo no obvio.

- [Archivo/decision que conviene mirar primero]
