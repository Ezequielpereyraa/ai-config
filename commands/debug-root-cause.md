---
description: Debug por causa raiz. Investiga antes de aplicar fixes.
argument-hint: [bug, stacktrace, repro o comportamiento observado]
---

Bug reportado: `$ARGUMENTS`.

## Regla critica

Causa raiz antes que fix. Fix minimo antes que refactor.

Si el bug es obvio y de bajo riesgo, podes aplicar el fix minimo despues de confirmar la causa. Si es riesgoso o ambiguo, frenar con recomendacion antes de editar.

## Proceso

1. Leer el flujo real involucrado.
2. Formular hipotesis verificables.
3. Descartar hipotesis con evidencia.
4. Identificar causa raiz.
5. Proponer fix minimo.
6. Recomendar test de regresion.

## Output

Usar el menor formato que preserve correctness.

### Compacto (`brief`/`standard`)

Usar para bugs claros o de bajo/medio riesgo:

### Causa raiz
[Explicacion tecnica concreta con evidencia]

### Fix minimo
- Cambio:
- Archivos:
- Verificacion:
- Riesgo restante:

### Completo (`deep`)

Usar solo si hay varias hipotesis, reproduccion incierta, riesgo alto o fallo complejo.

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
