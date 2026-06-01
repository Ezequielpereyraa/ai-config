---
description: Debug por causa raiz. Investiga antes de aplicar fixes.
argument-hint: [bug, stacktrace, repro o comportamiento observado]
---

Bug reportado: `$ARGUMENTS`.

## Regla critica

Causa raiz antes que fix. Fix minimo antes que refactor.

## Proceso

1. Leer el flujo real involucrado.
2. Formular hipotesis verificables.
3. Descartar hipotesis con evidencia.
4. Identificar causa raiz.
5. Proponer fix minimo.
6. Recomendar test de regresion.

## Output obligatorio

### Sintoma
[Que falla y como se reproduce]

### Flujo investigado
- `path` — por que importa

### Hipotesis

| Hipotesis | Validacion | Resultado |
|---|---|---|
| ... | ... | confirmada / descartada |

### Causa raiz
[Explicacion tecnica concreta]

### Fix minimo
- Archivos:
- Cambio:
- Por que alcanza:

### Prevencion
- Test de regresion:
- Caso borde:
- Riesgo de repeticion:
