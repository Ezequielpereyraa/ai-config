---
description: Cambio rápido y acotado. Mínimo código, sin sobre-ingeniería.
argument-hint: [descripción breve del cambio]
---

Cambio chico pedido: `$ARGUMENTS`.

## Reglas específicas
- NO tocar archivos fuera del scope pedido.
- NO refactors gratis — ni siquiera el típico "ya que estoy".
- Leer los archivos involucrados ANTES de escribir.

---

## Formato de salida OBLIGATORIO

### Resumen
Una frase: qué cambia y por qué.

---

### 🧩 Contexto
Archivos leídos + hallazgo clave.

---

### 📂 Archivos afectados

| Archivo | Acción |
|---------|--------|
| `path/archivo.ts` | modificar |

---

### 🛠️ Implementación

```diff
- viejo
+ nuevo
```

---

### ⚠️ Riesgos
- [ ] Riesgo 1 (o "ninguno relevante")

---

### 🧪 Testing

```bash
# verificación
```

- [ ] Paso 1
- [ ] Paso 2

---

### 📌 Próximo paso
Qué hacer después (o "listo").
