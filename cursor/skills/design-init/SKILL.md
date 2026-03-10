---
name: design-init
description: >
  Skill invocable via /design-init. Escanea el proyecto, extrae tokens de diseño existentes
  (fuentes, colores, spacing, animaciones), detecta duplicidades y problemas de escalabilidad,
  y genera .cursor/DESIGN.md pre-poblado con mejoras propuestas.
---

# design-init — Generador de DESIGN.md

## Cuando se activa

El usuario ejecuta `/design-init` en cualquier proyecto.

---

## Proceso de ejecucion

### Paso 1 — Escanear el proyecto

Leer en paralelo (lo que exista):

```
tailwind.config.ts / tailwind.config.js
app/globals.css / src/globals.css / styles/globals.css
app/layout.tsx / src/app/layout.tsx
package.json
```

Buscar adicionalmente:

```
**/theme.ts
**/tokens.ts
**/design-tokens.*
**/constants/colors.*
**/styles/*.css
```

### Paso 2 — Extraer tokens existentes

**De tailwind.config:**
- Colores extendidos (`extend.colors`)
- Fuentes extendidas (`extend.fontFamily`)
- Spacing custom (`extend.spacing`)
- Border radius custom (`extend.borderRadius`)
- Animaciones custom (`extend.animation`, `extend.keyframes`)

**De globals.css / CSS puro:**
- Variables CSS definidas en `:root` y `.dark`
- `@font-face` declarations
- `@import` de fuentes
- Clases utilitarias custom (`@layer utilities`)
- Clases de componentes custom (`@layer components`)

**De layout.tsx:**
- Imports de `next/font` o `next/font/google`
- Variables de fuente asignadas (`.variable`)
- Font families en uso

**De package.json:**
- Paquetes de fuentes: `@fontsource/*`, `next/font`, fuentes custom
- Librerias de animacion: `framer-motion`, `motion`, `@react-spring/*`
- Librerias UI: `shadcn`, `radix-ui`, `headlessui`, etc.

### Paso 3 — Detectar problemas

**Duplicidades:**
- Mismos colores definidos en tailwind.config Y en CSS variables
- Misma fuente importada por `next/font` Y por `@import` de Google Fonts
- Clases de componentes repetidas en multiples CSS files
- Spacing o border-radius hardcodeados en componentes que deberian ser tokens

**Problemas de escalabilidad:**
- Colores hardcodeados en hex dentro de `tailwind.config.extend.colors` sin variable CSS correspondiente (no cambian con dark mode)
- `@layer components` con estilos muy especificos de un solo componente (deberia estar en el componente)
- Animaciones duplicadas con distintos nombres pero mismos keyframes
- Fuentes cargadas con `@import` de Google Fonts (deberia ser `next/font` para performance)

**Centralizacion necesaria:**
- Colores semanticos sin nombre semantico (ej: `primary: "#0f172a"` vs `foreground: "#0f172a"`)
- Escalas de color incompletas (tiene `primary-500` pero no el resto de la escala)
- Tokens sin dark mode equivalente

### Paso 4 — Generar DESIGN.md

Crear `.cursor/DESIGN.md` en la raiz del proyecto con:
- Todo lo que se encontro, organizado por seccion
- `TODO:` donde falte informacion que el usuario debe completar
- Seccion de mejoras propuestas basada en los problemas detectados

Usar el template de `~/.cursor/skills/design-init/DESIGN.template.md` como base.

### Paso 5 — Reportar al usuario

Despues de generar el archivo, mostrar:

```
DESIGN.md generado en .cursor/DESIGN.md

Tokens encontrados:
- Fuentes: [lista]
- Colores: [cantidad] tokens
- Animaciones: [si/no]

Problemas detectados:
[lista de duplicidades y problemas de escalabilidad con ubicacion exacta]

Mejoras propuestas:
[lista priorizada]

Campos que necesitan completarse manualmente (marcados con TODO en el archivo):
[lista]
```

---

## Reglas del scan

- Reportar paths exactos de donde se encontro cada token
- Si un token esta definido en multiples lugares → marcar como duplicado con ambos paths
- Si tailwind.config usa `hsl()` con variables CSS → mapear correctamente al valor real
- Si el proyecto usa CSS puro sin Tailwind → funciona igual, extraer de los CSS files
- No asumir stack — detectar lo que hay
- Si `.cursor/DESIGN.md` ya existe → preguntar al usuario si quiere sobreescribir o hacer merge

---

## Mejoras que siempre proponer (si aplican)

1. **Migrar `@import` de Google Fonts a `next/font`** — performance critica en Next.js
2. **Unificar colores duplicados** — eliminar definicion en tailwind.config si ya existe como CSS variable
3. **Agregar semantica a colores sin nombre semantico** — `#0f172a` → `--color-foreground`
4. **Completar dark mode** — si hay `:root` sin `.dark` equivalente
5. **Extraer animaciones duplicadas** — un solo `@keyframes` reutilizable
6. **Centralizar spacing frecuente** — si se repite `px-6 py-4` en muchos componentes, proponer token

---

## Keywords
design-init, design tokens, generate, setup, fonts, colors, tailwind, css variables, duplicates
