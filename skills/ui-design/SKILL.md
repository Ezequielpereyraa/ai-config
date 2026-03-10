---
name: ui-design
description: >
  UI/UX design principles and visual standards. Editorial + utilitarian aesthetic.
  Trigger: Any UI component, layout, styling task, or visual improvement request.
license: Apache-2.0
metadata:
  author: Eze
  version: "1.0"
---

# UI Design — Principios y Estandares Visuales

## Regla 0 — Siempre verificar primero

Antes de escribir cualquier clase de estilo:

1. Buscar `.claude/DESIGN.md` en el proyecto actual
2. Si existe → leerlo COMPLETO. Esos son los tokens del proyecto. No inventar colores ni fuentes.
3. Si no existe → sugerir `/design-init` antes de continuar

---

## Estetica base — Editorial + Utilitarian

Referencias: Vercel, Notion, Linear.
Caracteristica: minimalismo funcional, jerarquia clara, precision tipografica.

**Lo que define este estilo:**
- La tipografia hace el trabajo pesado, no el color
- El espacio en blanco es intencional, no relleno
- El color de marca aparece con criterio, no decorativamente
- Cada elemento tiene una razon de existir

---

## Tipografia

### Pairing obligatorio

| Rol | Tipo | Ejemplos |
|---|---|---|
| Display / H1-H2 | Serif editorial o display | Fraunces, Playfair Display, DM Serif Display, Lora |
| Headings / H3-H4 | Sans-serif medium-bold | Inter, Plus Jakarta Sans, Geist Sans |
| Body / UI | Sans-serif regular | Inter, Plus Jakarta Sans, Geist Sans |
| Mono / Code | Monospace | Geist Mono, JetBrains Mono, Fira Code |

### Escala y pesos

```typescript
// H1 — display, impacto visual
<h1 className="text-4xl md:text-6xl font-bold tracking-tight" />

// H2 — serif, editorial
<h2 className="text-3xl md:text-4xl font-semibold tracking-tight" />

// H3 — sans, seccion
<h3 className="text-xl font-semibold" />

// Body — legible, no comprimido
<p className="text-base leading-relaxed text-foreground/80" />

// Caption / Label
<span className="text-sm font-medium text-muted-foreground" />

// Overline
<span className="text-xs font-semibold uppercase tracking-widest text-muted-foreground" />
```

### Anti-patrones tipograficos

```typescript
// NO — todo el mismo peso
<h1 className="text-2xl font-medium" />
<p className="text-2xl font-medium" />

// NO — tracking en body text
<p className="tracking-wide" />   // tracking solo en headings y labels

// NO — lineHeight muy ajustado en body
<p className="leading-tight" />   // solo para headings grandes
```

---

## Color

### Principios

- **Sin gradientes** — nunca. Ni en fondos, ni en textos, ni en botones.
- **Color de marca como ancla** — aparece en acciones primarias, links, highlights, estados activos
- **Escala neutral** como base (slate, zinc, neutral) — no gray puro
- **Semantica explícita** — verde=exito, rojo=error, ambar=advertencia. Consistente siempre.
- **Alto contraste fondo/texto** — minimo WCAG AA (4.5:1 para texto normal, 3:1 para grande)

### Sistema de tokens (usar siempre CSS variables o Tailwind semantic)

```css
/* En globals.css — definir siempre estos */
:root {
  --color-brand: /* color primario del producto */;
  --color-brand-muted: /* version suave del brand, para backgrounds */;
  --color-foreground: /* texto principal */;
  --color-muted-foreground: /* texto secundario */;
  --color-background: /* fondo base */;
  --color-surface: /* cards, modales, paneles */;
  --color-border: /* bordes */;
  --color-success: /* verde */;
  --color-error: /* rojo */;
  --color-warning: /* ambar */;
}
```

### Dark mode

Siempre declarar ambos:

```css
:root { /* light */ }
.dark { /* dark — mismos tokens, diferentes valores */ }
```

No usar `dark:bg-gray-900` directamente en componentes. Usar tokens semanticos que cambian con el modo.

### Anti-patrones de color

```typescript
// NO — gradientes
<div className="bg-gradient-to-r from-blue-500 to-purple-600" />

// NO — colores hardcodeados en componentes
<div className="bg-blue-600 text-white" />   // usar bg-brand text-brand-foreground

// NO — bajo contraste
<p className="text-slate-400" />   // sobre fondo blanco = falla WCAG
```

---

## Espacio y Densidad

### Regla base

La densidad depende del tipo de vista:

| Tipo de vista | Densidad | Padding | Gap |
|---|---|---|---|
| Landing / Marketing | Amplia | p-8 a p-16 | gap-8 a gap-16 |
| Dashboard / App | Comoda | p-4 a p-6 | gap-4 a gap-6 |
| Tablas / Data | Compacta | p-2 a p-3 | gap-2 a gap-3 |
| Mobile | Ajustada | p-4 | gap-3 |

### Ritmo vertical

```typescript
// Seccion con ritmo claro
<section className="py-16 md:py-24">
  <div className="space-y-4">    // elementos relacionados
    <span className="text-xs uppercase tracking-widest text-muted-foreground">Label</span>
    <h2 className="text-3xl font-bold tracking-tight">Titulo</h2>
    <p className="text-muted-foreground max-w-2xl">Descripcion</p>
  </div>
</section>
```

---

## Bordes y Profundidad

### Preferencia

- **Bordes** sobre sombras para delimitar areas en interfaces de app (mas limpio, mas Vercel/Notion)
- **Sombras suaves** para elementos flotantes (modales, dropdowns, tooltips)
- **Sombras prominentes** solo en landing pages o elementos de marketing

```typescript
// Cards en app — borde
<div className="rounded-lg border border-border bg-surface" />

// Modal / Dropdown — sombra
<div className="rounded-xl shadow-lg border border-border" />

// Card de marketing — sombra mas presente
<div className="rounded-2xl shadow-xl" />
```

---

## Animaciones y Microinteracciones

### Principio

Toda interaccion del usuario merece feedback visual. Sin animaciones = interfaz muerta.

### Con Framer Motion — cuando aplica

```typescript
// Aparicion de elemento
const fadeIn = {
  initial: { opacity: 0, y: 8 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.2, ease: "easeOut" }
}

// Lista de items
const listItem = {
  initial: { opacity: 0, x: -8 },
  animate: { opacity: 1, x: 0 },
}

const list = {
  animate: { transition: { staggerChildren: 0.05 } }
}
```

### Con Tailwind — microinteracciones basicas obligatorias

```typescript
// Boton — siempre
<button className="transition-all duration-150 hover:opacity-90 active:scale-[0.98]" />

// Link / elemento clicable
<a className="transition-colors duration-150 hover:text-foreground" />

// Card interactiva
<div className="transition-all duration-200 hover:shadow-md hover:-translate-y-0.5" />

// Input focus
<input className="transition-colors duration-150 focus:border-brand focus:ring-2 focus:ring-brand/20" />
```

### Duraciones estandar

| Tipo | Duracion |
|---|---|
| Micro (hover, color) | 100-150ms |
| Transicion (aparicion, slide) | 200-250ms |
| Animacion compleja (modal, drawer) | 300-350ms |
| Nunca mas de | 400ms |

---

## Componentes — Patrones Visuales

### Boton primario

```typescript
<button className={cn(
  "inline-flex items-center gap-2 px-4 py-2",
  "rounded-md text-sm font-medium",
  "bg-brand text-brand-foreground",
  "transition-all duration-150",
  "hover:opacity-90 active:scale-[0.98]",
  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/50"
)} />
```

### Badge / Chip

```typescript
<span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-brand/10 text-brand border border-brand/20" />
```

### Separadores de seccion

```typescript
// Texto con lineas
<div className="flex items-center gap-4">
  <div className="h-px flex-1 bg-border" />
  <span className="text-xs text-muted-foreground">o</span>
  <div className="h-px flex-1 bg-border" />
</div>
```

---

## Anti-patrones Globales — Nunca Hacer

- Gradientes en ningun contexto (fondos, textos, botones, cards)
- Rounded en exceso — `rounded-2xl` en cards de app = demasiado
- Sombras en todos los elementos — pierden significado
- `font-black` (900) en texto normal — reservar para display muy grande
- Iconos sin label en acciones criticas (siempre + tooltip o texto)
- Animaciones sin `prefers-reduced-motion` en contextos de accesibilidad
- Colores hardcodeados fuera del archivo de tokens
- Mezclar escalas de color (slate con gray con zinc en el mismo componente)

---

## Keywords
ui, ux, design, styling, components, typography, color, animation, microinteractions, layout
