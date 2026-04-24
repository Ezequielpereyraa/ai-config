---
description: Spec de feature mediana/grande. Investiga, propone plan, ESPERA aprobación antes de codear.
argument-hint: [nombre o descripción de la feature]
---

Feature a especificar: `$ARGUMENTS`.

## Regla crítica
**NO ESCRIBAS CÓDIGO.** Tu entregable es un plan. Esperás aprobación explícita antes de implementar.

## Proceso
1. Leer código existente relacionado (components, hooks, services, schemas, rutas).
2. Inventariar reusables (hooks, utils, componentes, tipos).
3. Plan incremental con checkpoints verificables.
4. Listar archivos afectados (nuevos y modificados).
5. Enumerar riesgos y edge cases.
6. **PARAR y pedir aprobación.**

---

## Formato de salida OBLIGATORIO

### Resumen
Qué es la feature en 2-3 líneas. Inferir el "por qué" si es posible.

---

### 🧩 Contexto
- **Código existente relevante:** archivos/módulos leídos
- **Reusables detectados:** hooks, utils, componentes, tipos
- **Convenciones del codebase:** decisiones observadas a respetar

---

### 📌 Decisiones de diseño

| # | Decisión | Alternativa descartada | Razón |
|---|----------|------------------------|-------|
| 1 | ... | ... | ... |

---

### 📂 Archivos afectados

| Archivo | Acción | Motivo |
|---------|--------|--------|
| `path/nuevo.tsx` | crear | ... |
| `path/existente.ts` | modificar | ... |

---

### 🛠️ Plan de implementación (incremental)

- [ ] **Paso 1 — [nombre]**
  - Qué se hace
  - Cómo se verifica (tsc, test, flujo manual)
- [ ] **Paso 2 — [nombre]**
- [ ] **Paso 3 — [nombre]**

Cada paso deja el código en estado compilable y testeable.

---

### ⚠️ Riesgos y edge cases
- [ ] Edge case 1 + cómo lo manejamos
- [ ] Riesgo técnico 1 (perf, acople, migración) + mitigación
- [ ] Riesgo de producto 1 (UX, datos, permisos)

---

### 🧪 Testing
- **Unit:** qué se testea (vitest)
- **Integración:** flujos críticos a cubrir
- **Manual:** checklist QA propio

```bash
# comandos relevantes
```

---

### 📌 Próximo paso
**Esperando aprobación para implementar.** Decime si avanzamos con el plan tal cual, o qué ajustamos.
