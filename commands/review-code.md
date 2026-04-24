---
description: Code review senior. Detecta arquitectura, complejidad, bugs y malas prácticas. Sin reescribir todo.
argument-hint: [archivo, carpeta, PR o "diff actual"]
---

Target de review: `$ARGUMENTS`.
Si no se especifica, revisar el diff actual (`git diff`) o preguntar qué revisar.

## Reglas específicas
- Crítica constructiva, no pleasing.
- Priorizar: bugs > seguridad > arquitectura > complejidad > estilo.
- Respetar el estilo del repo. No imponer convenciones ajenas.
- Si algo está bien, decirlo — no inventar problemas.

## Proceso
1. Leer el código a revisar completo, no en slices.
2. Entender contexto: qué hace, para qué, cómo se usa.
3. Detectar issues clasificados por severidad.
4. Sugerir mejoras concretas con snippet.
5. Destacar lo bien hecho (breve).

---

## Formato de salida OBLIGATORIO

### Resumen
Veredicto en 1-2 líneas: ¿mergea, necesita ajustes, necesita rework?

---

### 🧩 Contexto
- **Alcance revisado:** archivos/líneas
- **Qué hace el código:** descripción corta
- **Arquitectura observada:** patrón/convención que sigue

---

### 🚨 Hallazgos
Clasificados por severidad. Si una categoría está vacía: "— ninguno —".

#### 🔴 Críticos (bugs, seguridad, data loss)

| # | Archivo:línea | Problema | Sugerencia |
|---|---------------|----------|------------|
| 1 | `foo.ts:42` | ... | ... |

```diff
- problemático
+ sugerido
```

#### 🟠 Arquitectura / Diseño

| # | Archivo:línea | Problema | Sugerencia |
|---|---------------|----------|------------|

#### 🟡 Complejidad / Mantenibilidad
- `path:línea` — descripción + cómo simplificar

#### 🟢 Estilo / Convenciones
- `path:línea` — nit (prioridad baja, opcional)

---

### ✅ Lo bien hecho
- Patrón/decisión correcta (2-3 ítems máximo)

---

### 📌 Decisiones discutibles

| Decisión actual | Alternativa | Cuándo conviene cambiar |
|-----------------|-------------|-------------------------|
| ... | ... | ... |

---

### ⚠️ Riesgos si se mergea tal cual
- [ ] Riesgo 1
- [ ] Riesgo 2

---

### 🧪 Testing sugerido
- [ ] Test faltante 1
- [ ] Edge case sin cubrir

---

### 📌 Próximo paso
Lista priorizada para mergear:

1. [CRÍTICO] ...
2. [ALTO] ...
3. [OPCIONAL] ...
