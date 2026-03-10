# DESIGN.md — [Nombre del Proyecto]

> Archivo generado por `/design-init`. Mantener actualizado cuando cambien los tokens.
> Yo (Cursor) leo este archivo antes de tocar cualquier UI en este proyecto.

---

## Fuentes

| Rol | Familia | Peso(s) | Origen |
|---|---|---|---|
| Display / H1-H2 | TODO | TODO | TODO |
| Headings / H3+ | TODO | TODO | TODO |
| Body / UI | TODO | TODO | TODO |
| Mono / Codigo | TODO | TODO | TODO |

### Como estan cargadas

```typescript
// TODO: copiar el import de next/font del layout
```

### Variables CSS de fuentes

```css
/* TODO: listar las variables --font-* disponibles */
```

---

## Colores

### Color de marca

```css
--color-brand: TODO;          /* accion primaria, links, highlights */
--color-brand-muted: TODO;    /* backgrounds suaves, badges */
--color-brand-foreground: TODO; /* texto sobre color de marca */
```

### Escala neutral

```css
/* Indicar cual de estas escalas se usa: slate / zinc / neutral / gray */
Escala base: TODO
```

### Tokens semanticos

```css
/* Light mode */
:root {
  --color-background: TODO;
  --color-foreground: TODO;
  --color-surface: TODO;          /* cards, paneles, inputs */
  --color-muted: TODO;            /* backgrounds secundarios */
  --color-muted-foreground: TODO; /* texto secundario */
  --color-border: TODO;
  --color-ring: TODO;             /* focus rings */

  --color-success: TODO;
  --color-error: TODO;
  --color-warning: TODO;
  --color-info: TODO;
}

/* Dark mode */
.dark {
  /* TODO: completar con valores dark */
}
```

### Colores de Tailwind config

```typescript
// TODO: pegar el objeto extend.colors del tailwind.config
```

---

## Tipografia — Escala

```typescript
// Display (H1)
text-4xl md:text-6xl font-bold tracking-tight   // TODO: ajustar a la escala del proyecto

// H2
text-3xl md:text-4xl font-semibold tracking-tight

// H3
text-xl font-semibold

// H4
text-lg font-medium

// Body
text-base leading-relaxed

// Small / Caption
text-sm text-muted-foreground

// Overline / Label
text-xs font-semibold uppercase tracking-widest text-muted-foreground
```

---

## Espaciado

### Densidades por tipo de vista

| Tipo | Padding | Gap | Border Radius |
|---|---|---|---|
| Landing / Marketing | p-8 a p-16 | gap-8+ | rounded-2xl |
| Dashboard / App | p-4 a p-6 | gap-4 a gap-6 | rounded-lg |
| Tablas / Data | p-2 a p-3 | gap-2 a gap-3 | rounded-md |

### Tokens custom de spacing (si existen)

```typescript
// TODO: listar extend.spacing del tailwind.config si tiene valores custom
```

---

## Animaciones

### Libreria(s) en uso

```
TODO: framer-motion / css transitions / ambas
```

### Duraciones estandar del proyecto

```typescript
const DURATION = {
  micro: 150,   // hover, color change
  base: 200,    // fade, slide
  modal: 300,   // drawers, modals
}
```

### Variantes Framer Motion reutilizables (si hay)

```typescript
// TODO: documentar las variantes que se repiten en el proyecto
```

---

## Componentes Base

### Stack UI

```
TODO: shadcn/ui / radix-ui / headlessui / custom / otro
```

### Componentes custom del proyecto

```
TODO: listar componentes genericos en components/ui/ o similar
```

---

## Reglas especificas del proyecto

> Decisiones de diseno particulares que no estan en el SKILL.md global.

```
TODO: agregar cualquier decision de diseno especifica de este producto
Ejemplos:
- "Los modales siempre tienen backdrop-blur"
- "Las tablas usan densidad compacta siempre"
- "Los iconos son siempre de lucide-react, tamano default size-4"
```

---

## Mejoras pendientes

> Detectadas por /design-init. Resolver progresivamente.

```
TODO: se completa automaticamente al correr /design-init
```

---

## Historial de cambios

| Fecha | Cambio |
|---|---|
| TODO | Generado por /design-init |
