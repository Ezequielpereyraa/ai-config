---
description: Debug estructurado. Causa raíz, fix mínimo, explicación del por qué.
argument-hint: [descripción del bug, stacktrace o repro]
---

Bug reportado: `$ARGUMENTS`.

## Reglas específicas
- Causa raíz, no síntoma. Fix mínimo, no aprovechar para refactorizar.
- Explicar el POR QUÉ del bug, no solo el qué.

## Proceso
1. Reproducir mentalmente el bug (leer el flujo real, no asumir).
2. Aislar archivo/función responsable.
3. Identificar causa raíz — no el primer síntoma visible.
4. Proponer el fix más chico que cierra el problema.
5. Implementar.
6. Explicar por qué ocurría y por qué el fix lo resuelve.

---

## Formato de salida OBLIGATORIO

### Resumen
Bug en una línea + causa raíz en una línea.

---

### 🧩 Contexto
- **Síntoma reportado:** ...
- **Flujo analizado:** archivos/funciones recorridas hasta el origen
- **Hipótesis descartadas:** qué pensé que era y por qué NO era eso

---

### 🔎 Causa raíz
Explicación técnica clara de POR QUÉ ocurre:
- Qué estado/input dispara el bug
- Qué línea/lógica exacta falla
- Por qué no se detectó antes (si aplica)

```ts
// snippet del código problemático
```

---

### 📂 Archivos afectados

| Archivo | Acción |
|---------|--------|
| `path/roto.ts` | fix |

---

### 🛠️ Fix

```diff
- código con bug
+ código corregido
```

**Por qué este fix y no otro:** justificación corta.

---

### ⚠️ Riesgos
- [ ] Regresiones posibles
- [ ] Casos no cubiertos por el fix (si los hay, declarar)

---

### 🧪 Testing
- [ ] Repro original ya no falla
- [ ] Casos borde relacionados siguen andando
- [ ] Test de regresión agregado (si aplica)

```bash
# comando para verificar
```

---

### 📌 Próximo paso
¿Sumamos test de regresión? ¿Hay otros lugares con el mismo patrón roto?
