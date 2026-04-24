---
name: ui-design
description: >
  UI/UX completo — principios base (siempre activos al tocar UI) + secciones especializadas por trigger.
  Triggers específicos dentro del skill: responsive/mobile, animation/motion, copy/microcopy, color/palette, layout/spacing, editorial/minimalist, performance/slow.
license: Apache-2.0
metadata:
  author: Eze
  version: "2.0"
---

# UI Design — Principios y Patrones

## Regla 0 — Verificar DESIGN.md primero

Antes de escribir cualquier clase:

1. Buscar `.claude/DESIGN.md` en el proyecto.
2. Si existe → leerlo COMPLETO. Esos son los tokens. No inventar colores, fuentes, ni spacing.
3. Si NO existe → sugerir `/design-init` antes de seguir.

---

# BASE — Estética siempre activa

Referencias: Vercel, Notion, Linear. Minimalismo funcional, jerarquía clara, precisión tipográfica.

**Principios:**
- La tipografía hace el trabajo pesado, no el color.
- El espacio en blanco es intencional, no relleno.
- El color de marca aparece con criterio, no decorativamente.
- Cada elemento tiene una razón de existir.

## Tipografía

### Pairing
| Rol | Tipo | Ejemplos |
|---|---|---|
| Display / H1-H2 | Serif editorial o display | Fraunces, Playfair Display, DM Serif Display, Instrument Serif |
| Headings / H3-H4 | Sans-serif medium-bold | Inter, Plus Jakarta Sans, Geist Sans |
| Body / UI | Sans-serif regular | Inter, Geist Sans |
| Mono / Code | Monospace | Geist Mono, JetBrains Mono |

### Escala
```tsx
<h1 className="text-4xl md:text-6xl font-bold tracking-tight" />
<h2 className="text-3xl md:text-4xl font-semibold tracking-tight" />
<h3 className="text-xl font-semibold" />
<p  className="text-base leading-relaxed text-foreground/80" />
<span className="text-sm font-medium text-muted-foreground" />            {/* Label */}
<span className="text-xs font-semibold uppercase tracking-widest text-muted-foreground" /> {/* Overline */}
```

### Anti-patrones
- Todo el mismo peso/tamaño → jerarquía muerta.
- `tracking-wide` en body → el tracking va solo en headings y labels.
- `leading-tight` en body → solo para headings grandes.
- `font-black` (900) en texto normal → reservar para display muy grande.

## Color

### Principios
- **Sin gradientes.** Ni en fondos, textos, ni botones. (Excepción puntual: ambient background en landings — `opacity < 0.05`).
- **Color de marca como ancla** — acciones primarias, links, estados activos.
- **Escala neutral** (slate, zinc, neutral) — no gray puro. Tints cálidos o fríos, no pure gray/black.
- **Semántica explícita** — verde=éxito, rojo=error, ámbar=advertencia. Consistente siempre.
- **WCAG AA mínimo** — 4.5:1 texto normal, 3:1 texto grande.

### Tokens (siempre CSS variables o Tailwind semantic)
```css
:root {
  --color-brand: /* primario */;
  --color-brand-muted: /* suave, para backgrounds */;
  --color-foreground: /* texto principal */;
  --color-muted-foreground: /* secundario */;
  --color-background: /* fondo base */;
  --color-surface: /* cards, modales */;
  --color-border: /* bordes */;
  --color-success: /* verde */;
  --color-error: /* rojo */;
  --color-warning: /* ámbar */;
}
.dark { /* mismos tokens, valores dark */ }
```

**Nunca** `dark:bg-gray-900` hardcodeado en componentes — usar tokens semánticos.

### Anti-patrones de color
- Gradientes `from-blue-500 to-purple-600` (AI slop).
- Colores hardcodeados en componentes: `bg-blue-600` → usar `bg-brand`.
- Bajo contraste: `text-slate-400` sobre fondo blanco.
- Pure black `#000` o pure white `#fff` en áreas grandes.
- Mezclar escalas (slate + gray + zinc en el mismo componente).

## Espacio y densidad

| Tipo de vista | Densidad | Padding | Gap |
|---|---|---|---|
| Landing / Marketing | Amplia | p-8 a p-16 | gap-8 a gap-16 |
| Dashboard / App | Cómoda | p-4 a p-6 | gap-4 a gap-6 |
| Tablas / Data | Compacta | p-2 a p-3 | gap-2 a gap-3 |
| Mobile | Ajustada | p-4 | gap-3 |

**Ritmo vertical:**
```tsx
<section className="py-16 md:py-24">
  <div className="space-y-4">
    <span className="text-xs uppercase tracking-widest text-muted-foreground">Label</span>
    <h2 className="text-3xl font-bold tracking-tight">Título</h2>
    <p className="text-muted-foreground max-w-2xl">Descripción</p>
  </div>
</section>
```

## Bordes y profundidad
- **Bordes** sobre sombras para delimitar áreas en app (estilo Vercel/Notion).
- **Sombras suaves** para flotantes (modales, dropdowns, tooltips).
- **Sombras prominentes** solo en landing/marketing.

```tsx
<div className="rounded-lg border border-border bg-surface" />     {/* card app */}
<div className="rounded-xl shadow-lg border border-border" />       {/* modal/dropdown */}
<div className="rounded-2xl shadow-xl" />                            {/* card marketing */}
```

## Microinteracciones obligatorias (siempre)
```tsx
<button className="transition-all duration-150 hover:opacity-90 active:scale-[0.98]" />
<a      className="transition-colors duration-150 hover:text-foreground" />
<div    className="transition-all duration-200 hover:shadow-md hover:-translate-y-0.5" />  {/* card interactiva */}
<input  className="transition-colors duration-150 focus:border-brand focus:ring-2 focus:ring-brand/20" />
```

## Anti-patrones globales (nunca)
- Gradientes decorativos.
- `rounded-2xl` en cards de app — demasiado.
- Sombras en todo elemento — pierden significado.
- Iconos sin label en acciones críticas.
- Animaciones sin respetar `prefers-reduced-motion`.
- Colores hardcodeados fuera del archivo de tokens.

---

# SECCIONES POR TRIGGER

A partir de acá, activar la sección que corresponda al trigger que matchea con la request del user.

---

## 🔹 Responsive & Adapt
**Triggers:** `responsive`, `mobile`, `tablet`, `desktop`, `breakpoints`, `touch target`, `viewport`, `cross-device`.

### Principio
Adaptar no es escalar — es **repensar la experiencia** para el nuevo contexto.

### Breakpoints
- Mobile: 320-767px
- Tablet: 768-1023px
- Desktop: 1024px+
- **Preferir content-driven breakpoints** (donde el diseño se rompe) sobre valores genéricos.

### Mobile (desktop → mobile)
**Layout:** single column, stacking vertical, full-width, bottom nav.
**Interaction:** touch targets ≥44×44px, swipe en listas, bottom sheets > dropdowns, thumb-first.
**Content:** progressive disclosure, text ≥16px, primary-first (secondary en tabs/accordions).
**Nav:** hamburger o bottom nav, sticky headers para contexto.

### Tablet (híbrido)
Two-column, side panels, master-detail. Soportar touch Y pointer. Touch targets ≥44×44 pero permitir layouts más densos que phone.

### Desktop (mobile → desktop)
Multi-column, side nav visible, `max-width` para no estirar a 4K. Hover states, keyboard shortcuts, right-click menus, drag & drop.

### Técnicas
- **Flex para 1D, Grid para 2D.** No default a Grid.
- **Container queries** > media queries cuando el componente se reusa en contextos distintos.
- **`clamp()`** para sizing fluido.
- **`srcset` / `picture`** para imágenes responsive.
- **Thumb zones** — más fácil llegar al bottom que al top en mobile.

### Nunca
- Esconder funcionalidad core en mobile.
- Desktop = device potente (hay Chromebooks lentos).
- Cambiar information architecture entre contextos (confunde).
- Olvidar landscape en mobile/tablet.
- Ignorar touch en desktop (muchos tienen touch).

---

## 🔹 Animate — motion profundo
**Triggers:** `animation`, `motion`, `transition` (no básica), `hover effect`, `micro-interaction`, `delight`, `stagger`, `reveal`.

### Estrategia (antes de implementar)
- **Hero moment:** ¿cuál es LA animación signature?
- **Feedback layer:** qué interacciones necesitan acknowledgment.
- **Transition layer:** qué state changes suavizar.
- **Delight layer:** dónde sorprender.

> Una experiencia bien orquestada > 20 animaciones scattered.

### Duraciones
| Tipo | Duración |
|---|---|
| Micro (hover, color) | 100-150ms |
| State change (menu open, toggle) | 200-300ms |
| Layout change (accordion, modal) | 300-500ms |
| Page load / entrance | 500-800ms |
| **Nunca más de** | 500ms para feedback, 800ms para entrance |

**Exit animations = ~75% del enter.**

### Easing curves
```css
--ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);   /* smooth */
--ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1);  /* snappier */
--ease-out-expo:  cubic-bezier(0.16, 1, 0.3, 1);   /* confident */
```
**Evitar:** bounce, elastic (`cubic-bezier(0.34, 1.56, ...)`) — feel dated.

### Framer Motion — patrones base
```tsx
const fadeIn = {
  initial: { opacity: 0, y: 8 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.2, ease: [0.16, 1, 0.3, 1] }
}

const list = {
  animate: { transition: { staggerChildren: 0.05 } }
}

const listItem = {
  initial: { opacity: 0, x: -8 },
  animate: { opacity: 1, x: 0 },
}
```

### Categorías
- **Entrance:** page load con stagger (80-100ms delays), hero con parallax/scale, scroll-triggered con IntersectionObserver.
- **Feedback:** button hover (scale 1.02), click (scale 0.98), input focus (border transition + glow), validation (shake error, check success).
- **State transitions:** fade+slide para show/hide, height transition para expand/collapse con overflow handling, skeleton → content crossfade.
- **Navigation:** crossfade entre rutas, slide indicator en tabs.
- **Delight:** confetti en success grande, floating subtle en empty states.

### Performance
- **GPU only:** `transform` + `opacity`. Nunca `width`, `height`, `top`, `left`, `margin`.
- **`will-change`** sparingly, solo en elementos activamente animados.
- **60fps target** — 16ms/frame. Profilear en mobile real.

### Accesibilidad
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Nunca
- Bounce/elastic easing — dated.
- Animar layout properties.
- Durations >500ms para feedback — feels laggy.
- Animar sin propósito — toda animación tiene razón.
- Bloquear interacción durante animación (salvo intencional).
- Animar todo — fatiga visual.

---

## 🔹 Clarify — UX copy
**Triggers:** `error message`, `confusing label`, `microcopy`, `tooltip`, `empty state`, `button text`, `placeholder`, `loading message`, `confirmation dialog`.

### Principio
Copy clara es invisible. El user entiende sin pensar. Copy mala genera errores, tickets de soporte y frustración.

### Errores
**Mal:** `"Error 403: Forbidden"`
**Bien:** `"No tenés permiso para ver esta página. Contactá al admin para acceso."`

**Mal:** `"Invalid input"`
**Bien:** `"El email necesita un @. Ejemplo: nombre@empresa.com"`

**Reglas:** plain language · sugerir fix · no culpar al user · incluir ejemplo si ayuda · link a help si aplica.

### Labels
**Mal:** `"DOB (MM/DD/YYYY)"` · **Bien:** `"Fecha de nacimiento"` + placeholder con formato.
**Mal:** `"Enter value"` · **Bien:** `"Tu email"` / `"Nombre de la empresa"`.

**Reglas:** específico, no genérico · ejemplo de formato · instrucción ANTES del field, no después · required indicator claro.

### Buttons/CTAs
**Mal:** `"Click here"` / `"Submit"` / `"OK"`
**Bien:** `"Crear cuenta"` / `"Guardar cambios"` / `"Entendido"`

**Reglas:** verbo + noun · acción específica · match mental model del user.

### Tooltips / help text
**Mal:** `"This is the username field"` (repite label).
**Bien:** `"Elegí un username. Lo podés cambiar después en Settings."`

### Empty states
**Mal:** `"No items"`
**Bien:** `"Todavía no tenés proyectos. Creá el primero para arrancar."` + CTA.

### Success
**Mal:** `"Success"`
**Bien:** `"Cambios guardados. Se aplican ahora mismo."`

### Loading (30+ segundos)
**Mal:** `"Loading..."`
**Bien:** `"Analizando tus datos... esto suele tardar 30-60s"` + progress si es posible + escape hatch (`Cancel`).

### Confirmations
**Mal:** `"¿Estás seguro?"`
**Bien:** `"¿Eliminar 'Proyecto Alpha'? Esta acción no se puede deshacer."` + botones `"Eliminar proyecto"` / `"Cancelar"` (no `"Sí"` / `"No"`).

### Reglas globales
1. **Específico** > genérico.
2. **Conciso** sin sacrificar claridad.
3. **Activo:** `"Guardar"` > `"Será guardado"`.
4. **Humano:** `"Ups, algo salió mal"` > `"System error encountered"`.
5. **Útil:** decile qué hacer, no solo qué pasó.
6. **Consistente:** un término, úsalo siempre (no variar por variedad).

### Nunca
- Jargon sin explicación.
- Culpar al user: `"Hiciste un error"` → `"Este campo es requerido"`.
- Vago: `"Algo salió mal"` sin más.
- Humor en errores — empatía, no chistes.
- Placeholder como único label (desaparece al escribir).

---

## 🔹 Colorize — estrategia de color
**Triggers:** `todo gris`, `falta color`, `más vibrante`, `dull`, `warmth`, `palette`, `colorful`.

### Principio
**Más color ≠ mejor.** Color estratégico > rainbow vomit. Cada color tiene propósito.

### Regla 60/30/10
- **Dominant** (60%): brand o neutral principal.
- **Secondary** (30%): soporte para variedad.
- **Accent** (10%): high contrast para momentos clave.

### Dónde agregar color con propósito
- **Semántico:** success (emerald/mint), error (rose/coral), warning (amber), info (sky), neutral (slate).
- **Primary CTAs**, links, icons clave, section headers.
- **Hover states** — introducir color en la interacción.
- **Tinted backgrounds:** reemplazar `#f5f5f5` por warm neutral (`oklch(97% 0.01 60)`) o cool tint.
- **Borders acento:** left-border de color en cards de status.

### OKLCH > HSL
Perceptualmente uniforme — pasos iguales en lightness *se ven* iguales. Mejor para generar scales armónicas.

```css
--color-brand-50:  oklch(97% 0.03 260);
--color-brand-500: oklch(55% 0.20 260);
--color-brand-900: oklch(25% 0.10 260);
```

### Accesibilidad
- WCAG AA: 4.5:1 texto, 3:1 UI components.
- **Nunca color solo** — acompañar con icon/label/pattern.
- Testear color blindness (red/green).

### Nunca
- Todo el arcoíris (2-4 colores beyond neutrals).
- Color random sin semántica.
- Gray text sobre colored background — se ve lavado. Usar shade más oscuro del background o transparencia.
- Pure gray para neutrals — agregarle tint cálido/frío para sofisticación.
- Default purple-blue gradient (AI slop).

---

## 🔹 Layout — ritmo y jerarquía
**Triggers:** `layout feels off`, `spacing issues`, `visual hierarchy`, `crowded`, `alignment problems`, `rhythm`, `card grid monotono`.

### Diagnóstico
1. **Squint test:** ojos entrecerrados, ¿identificás el elemento primario, secundario, y agrupaciones?
2. **Spacing:** ¿es consistente o arbitrario? ¿todo el mismo padding = cero ritmo?
3. **Grid:** ¿card grid idéntico repetido (icon + heading + text × 1000)?
4. **Density:** ¿muy cramped o muy sparse para el tipo de contenido?

### Principios
- **Usar menos dimensiones necesarias.** Espacio + weight alone muchas veces es suficiente. Agregar color/size contrast solo si no alcanza.
- **Tight grouping** (8-12px) para elementos relacionados.
- **Generous separation** (48-96px) entre secciones distintas.
- **Variedad** — no todos los rows con el mismo gap.
- **Asymmetric compositions** cuando tenga sentido — centrar todo = genérico.

### Herramientas
- **Flex para 1D** (rows, nav, button groups, internals). Default a flex.
- **Grid para 2D** (dashboards, data-dense, page-level). No default a Grid.
- **`gap` > margins** — eliminá margin collapse hacks.
- **`clamp()`** para spacing fluido.
- **Container queries** cuando el componente vive en contextos distintos.
- **Named grid areas** (`grid-template-areas`) para layouts complejos.
- **`repeat(auto-fit, minmax(280px, 1fr))`** para grids responsive sin breakpoints.

### Z-index semántico
Nunca valores arbitrarios (999, 9999). Scale:
```
dropdown → sticky → modal-backdrop → modal → toast → tooltip
```

### Nunca
- Arbitrary spacing (fuera del scale).
- Todo el spacing igual — variedad crea jerarquía.
- Cards dentro de cards — usar spacing/dividers.
- Card grid idéntico repetido.
- Centrar todo.
- Default al layout "hero metric" (big number, small label, stats, gradient) sin datos reales.

---

## 🔹 Minimalist editorial
**Triggers:** `editorial`, `minimalist`, `warm monochrome`, `bento`, `premium utilitarian`, `Notion-style`, `document-style`.

### Banned (hard)
- Inter, Roboto, Open Sans como primary.
- Lucide, Feather, Heroicons defaults (thin-line genéricos).
- `shadow-md/lg/xl` default.
- Backgrounds primary-color grandes (hero bright blue/green/red).
- Gradientes, neón, glassmorphism 3D.
- `rounded-full` en containers grandes o botones primarios.
- Emojis en código/markup/alt text.
- Placeholders tipo "John Doe", "Acme Corp", "Lorem ipsum" — usar contenido contextual realista.
- AI clichés: "Elevate", "Seamless", "Unleash", "Next-Gen", "Delve".

### Tipografía (override del base)
- **Sans body:** `'SF Pro Display', 'Geist Sans', 'Switzer', sans-serif`.
- **Serif editorial:** `'Lyon Text', 'Newsreader', 'Instrument Serif', serif`. `letter-spacing: -0.02em a -0.04em`, `line-height: 1.1`.
- **Mono:** `'Geist Mono', 'SF Mono', 'JetBrains Mono'`.
- **Body color:** nunca `#000`. Off-black `#111111` o `#2F3437`, `line-height: 1.6`. Secondary: `#787774`.

### Paleta (warm monochrome + muted pastels)
```css
--canvas: #F7F6F3;      /* warm bone */
--surface: #FFFFFF;
--border: #EAEAEA;      /* ultra-light */
--text: #111111;
--muted: #787774;

/* Accent pastels — solo en tags, code inline, small backgrounds */
--pastel-red:    #FDEBEC; /* text: #9F2F2D */
--pastel-blue:   #E1F3FE; /* text: #1F6C9F */
--pastel-green:  #EDF3EC; /* text: #346538 */
--pastel-yellow: #FBF3DB; /* text: #956400 */
```

### Componentes
- **Bento grid:** asymmetric CSS Grid, `border: 1px solid #EAEAEA`, `border-radius: 8-12px` máx, padding `24-40px`.
- **Primary button:** bg `#111`, text `#fff`, radius `4-6px`, **sin shadow**, hover `#333` o `scale(0.98)`.
- **Tags/badges:** pill (`border-radius: 9999px`), `text-xs` uppercase, `letter-spacing: 0.05em`, bg con muted pastel.
- **Accordions:** sin containers, solo `border-bottom: 1px solid #EAEAEA`. Toggle con `+` / `-` limpios.
- **Keystrokes:** `<kbd>` con `border: 1px solid #EAEAEA`, `background: #F7F6F3`, mono font.

### Iconografía
Phosphor Icons (Bold/Fill) o Radix Icons. Stroke consistente.

### Imágenes
Desaturadas, overlay warm grain `opacity: 0.04`. Never oversaturated stock. Placeholder: `https://picsum.photos/seed/{context}/1200/800`.

### Motion (override del base)
- **Scroll entry:** `translateY(12px) → 0` + `opacity 0 → 1`, `600ms`, `cubic-bezier(0.16, 1, 0.3, 1)`. Siempre `IntersectionObserver`.
- **Hover cards:** `box-shadow` de `0 0 0` a `0 2px 8px rgba(0,0,0,0.04)` en `200ms`.
- **Staggered reveals:** `animation-delay: calc(var(--index) * 80ms)`.
- **Ambient motion:** máx 1 radial gradient blob `opacity: 0.02-0.04`, `animation-duration: 20s+`, en layer `position: fixed; pointer-events: none`.

### Protocolo de ejecución
1. Macro-whitespace primero: `py-24` / `py-32` entre secciones.
2. Main content width: `max-w-4xl` o `max-w-5xl`.
3. Todos los borders: `1px solid #EAEAEA`.
4. Scroll-entry animations en bloques principales.
5. Visual depth vía imagery/ambient gradients/textures sutiles — nunca fondos flat vacíos.

---

## 🔹 Optimize — performance UI
**Triggers:** `slow`, `laggy`, `janky`, `performance`, `bundle size`, `load time`, `LCP`, `CLS`, `INP`.

### Antes de optimizar: MEDIR
Premature optimization = tiempo perdido. Herramientas:
- Chrome DevTools (Lighthouse, Performance panel).
- WebPageTest para red real.
- Bundle analyzer (`@next/bundle-analyzer`).
- Real User Monitoring si lo tenés.

**Métricas a watchear:** LCP, INP, CLS (Core Web Vitals) · TTI · FCP · TBT · bundle size.

### Loading

**Imágenes:**
- WebP/AVIF. Nunca JPG/PNG en nuevo código.
- Sizing correcto — no cargar 3000px para display de 300px.
- `loading="lazy"` para below-fold.
- `srcset` + `sizes` para responsive.
- Compression 80-85% (imperceptible).

```html
<img src="hero.webp"
     srcset="hero-400.webp 400w, hero-800.webp 800w, hero-1200.webp 1200w"
     sizes="(max-width: 400px) 400px, (max-width: 800px) 800px, 1200px"
     loading="lazy" alt="..." />
```

**JS bundle:**
- Code splitting por ruta y componente pesado.
- Tree shaking (sacar deps sin uso).
- Dynamic imports para lo grande:
```tsx
const HeavyChart = lazy(() => import('./HeavyChart'))
```

**CSS:**
- Critical CSS inline, rest async.
- `@container` en regiones independientes.
- Tailwind JIT — remove unused.

**Fonts:**
- `font-display: swap` siempre.
- Subset a chars que usás.
- Preload solo críticas.
- Limitar weights cargados (2-3 max).

### Rendering

**Evitar layout thrashing:**
```js
// MAL — alterna reads/writes
elements.forEach(el => {
  const h = el.offsetHeight   // forza layout
  el.style.height = h * 2
})

// BIEN — batch reads, después batch writes
const heights = elements.map(el => el.offsetHeight)
elements.forEach((el, i) => el.style.height = heights[i] * 2)
```

**Listas largas:**
- `content-visibility: auto` para skip off-screen.
- Virtual scrolling (react-window, tanstack-virtual) si >100 items.

**Animation:**
- `transform` + `opacity` only. Nunca `width/height/top/left` animadas.
- `will-change` sparingly — consume memoria.

### Core Web Vitals

**LCP < 2.5s:**
- Hero image optimizada + preload.
- Critical CSS inline.
- SSR / SSG / ISR.

**INP < 200ms (reemplazó FID):**
- Break long tasks (chunking con `scheduler.yield()` o `setTimeout(0)`).
- Defer JS no-crítico.
- Web workers para cómputo pesado.

**CLS < 0.1:**
- `width`/`height` en imgs y videos.
- `aspect-ratio` CSS.
- No inyectar contenido sobre contenido existente.
- Reservar espacio para ads/embeds.

```css
.image-container { aspect-ratio: 16 / 9; }
```

### React-específico
- `memo()` para components caros (pero React Compiler en React 19 lo hace solo — chequear antes).
- Lazy loading de rutas.
- No inline functions en render de listas largas.
- Profiler en DevTools cuando hay jank real.

### Network
- Pagination — no cargar todo.
- HTTP caching headers.
- CDN para assets estáticos.
- `navigator.connection` para adaptive loading.

### Nunca
- Optimizar sin medir.
- Sacrificar accessibility por perf.
- `will-change` en todos lados — crea layers, consume memoria.
- Lazy load contenido above-fold.
- Optimizar micro sin atacar el bottleneck grande.
- Testear solo en MacBook + wifi rápido — probar en Android lento + 3G throttled.

---

## Keywords globales
ui, ux, design, styling, components, typography, color, animation, microinteractions, layout, responsive, mobile, accessibility, performance, editorial, minimalist, copy, microcopy, spacing, hierarchy.
