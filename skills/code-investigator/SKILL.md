---
name: code-investigator
description: Investiga cómo funciona algo en el proyecto. Usar cuando el usuario pregunta "¿cómo funciona X?", "¿por qué hace Y?", "no entiendo este flujo", "¿dónde se valida Z?", "¿qué pasa cuando...?". Responde con criterio técnico, no solo describiendo código sino explicando lógica de negocio, flujo de datos y decisiones de diseño.
---

# Code Investigator

Cuando el usuario pregunta cómo funciona algo, investigá en profundidad y respondé con criterio. No describas el código — **explicá qué hace, por qué lo hace así, y qué implicaciones tiene**.

---

## Cuándo aplicar

- "¿Cómo funciona la validación de X?"
- "No entiendo cómo fluyen los datos en Y"
- "¿Por qué se hace Z de esta manera?"
- "¿Dónde se maneja el error de W?"
- "¿Qué pasa cuando el usuario hace A?"
- "Explicame este componente / hook / servicio"
- "¿Cómo se conecta X con Y?"

---

## Proceso de investigación

### Paso 1 — Entender la pregunta antes de buscar

Antes de tocar el código, definí:
- ¿Qué exactamente no se entiende? (el flujo, la lógica, la estructura, el comportamiento)
- ¿Cuál es el punto de entrada más lógico para investigar?
- ¿Hay términos ambiguos en la pregunta? Si los hay → preguntá antes de continuar

### Paso 2 — Rastrear desde el origen

No empieces desde el medio. Buscá siempre:
1. **El punto de entrada** (el componente, endpoint, o evento que dispara el flujo)
2. **El flujo completo** hacia adelante (qué llama a qué)
3. **Las dependencias hacia atrás** (de dónde vienen los datos)
4. **Los casos edge** (qué pasa cuando falla, qué pasa con valores nulos, etc.)

### Paso 3 — Leer el código real, no asumir

- Leé los archivos involucrados — no describas lo que "probablemente" hace
- Si un tipo o interfaz es relevante, buscaló y leelo
- Si hay una constante o configuración que afecta el comportamiento, encontrala
- Si hay tests, son documentación ejecutable — léelos

### Paso 4 — Identificar las capas

Para cada flujo investigado, identificá en qué capa vive cada parte:
- **UI** → componentes, presentación
- **Lógica de negocio** → hooks, services, utils
- **Datos** → APIs, estado, cache
- **Configuración** → constantes, variables de entorno

---

## Criterios de una buena respuesta

### Explicá el flujo, no el código
❌ Mal: "El componente llama a `useState` con `false` como valor inicial y luego en el `onClick` lo cambia a `true`"
✅ Bien: "El componente controla si el modal está abierto. Arranca cerrado y se abre cuando el usuario hace click en el botón de confirmar"

### Mostrá las conexiones
Siempre respondé:
- ¿Qué dispara este flujo?
- ¿Qué datos entran?
- ¿Qué transformaciones ocurren?
- ¿Qué sale al final?
- ¿Quién consume ese resultado?

### Citá el código con contexto
Cuando mostrés código, incluí:
- El path del archivo y las líneas relevantes
- Por qué esa parte específica es importante para la pregunta

### Señalá lo que no es obvio
- Decisiones de diseño que podrían sorprender ("esto se hace así porque...")
- Side effects implícitos
- Dependencias ocultas entre módulos
- Comportamientos en casos edge
- Código que podría ser un problema potencial

### Separar descripción de opinión
Separar claramente:
- **Cómo funciona** (hechos del código)
- **Por qué está hecho así** (si se puede inferir del contexto)
- **Observaciones** (si hay algo mejorable o llamativo, marcarlo explícitamente como observación)

---

## Formato de respuesta

```
## ¿Cómo funciona [X]?

### Resumen en una oración
[Una línea que cualquier persona pueda entender]

### Flujo completo
[Descripción del flujo de principio a fin, con referencias a archivos]

### Detalle por capa
**UI:** ...
**Lógica:** ...
**Datos:** ...

### Casos edge o comportamientos especiales
- ...

### Observaciones (opcional)
- ...
```

---

## Reglas de criterio

- **Nunca describas línea por línea** — sintetizá el comportamiento
- **Si algo no está claro en el código, decilo** — no inventes comportamientos
- **Si encontrás un problema o deuda técnica** al investigar, mencionalo sin exagerar
- **Si la respuesta depende de configuración externa** (env vars, feature flags, datos de API), aclararlo
- **Si el código cambió recientemente** y encontrás inconsistencias, señalálas
- **Si hay múltiples formas de llegar al mismo resultado** en el código, mencionálas
- **Preguntá si algo no queda claro** — es mejor una pregunta que una explicación incorrecta

---

## Anti-patrones a evitar

- ❌ Parafrasear el código sin agregar comprensión
- ❌ Explicar partes que no se preguntaron
- ❌ Asumir comportamiento sin leer el código
- ❌ Dar por sentado que el usuario sabe cómo funciona una librería externa (explicar si es relevante)
- ❌ Responder solo con código sin explicación
- ❌ Omitir los casos edge o el manejo de errores
