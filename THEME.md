# Custom Theme Implementation Plan

## Motivation

Congo v2 has become a black box — custom layouts depend on its internal partials
(`profile.html`, `icon.html`), its compiled Tailwind CSS for utility classes used
in templates, and its CSS variable system (`--color-neutral-*`, `--color-primary-*`)
referenced throughout `custom.css`. Removing it gives full ownership of every
rendered pixel.

---

## Decision: Plain CSS over Tailwind

Congo uses Tailwind CSS (compiled). Replacing it with another Tailwind setup
requires a PostCSS/Node build step, which adds tooling complexity. Plain CSS with
custom properties is simpler, more transparent, and sufficient for this site's
needs. The existing `custom.css` already does most of its work via custom
properties and custom classes — migrating it is straightforward.

---

## What Stays

- All content (`content/posts/`, `content/random/`, `content/about/`, `content/_index.md`)
- All shortcodes (`skill-group`, `experience`, `email-link`, `details`, `spotify`) — CSS variable names need updating, logic unchanged
- AsciiDoc support (Dockerfile, asciidoctor, asciidoctor-chroma)
- Hugo config structure (`config/_default/`)
- GitHub Actions workflow
- Hugo Admonitions module (separate from Congo, keep it)
- All front matter conventions

## What Goes

- Congo (`github.com/jpanther/congo/v2`) from `go.mod`, `go.sum`, `module.toml`
- `colorScheme = "avocado"` param (Congo-specific)
- `homepage.layout = "custom"` param (Congo dispatch mechanism)
- `homepage.showRecent`, `homepage.recentLimit` params
- `[entry]` and `[article]` params (Congo-specific config blocks)
- `enableCodeCopy` param (replace with own JS)
- All Tailwind utility classes in custom partials

---

## New Directory Structure

```
layouts/
  baseof.html                   # Root template: head, header, main, footer
  index.html                    # Homepage
  404.html                      # Already custom, adapt to new base
  _default/
    single.html                 # Blog post / single page
    list.html                   # Section listing (blog, tags)
    baseof.html                 # (optional: section-specific base)
  _partials/
    head.html                   # <head>: meta, OG, CSS, JS
    header.html                 # Site navigation + dark mode toggle
    footer.html                 # Footer
    profile.html                # Profile card (homepage) — replaces Congo's
    author-links.html           # Already custom, remove Tailwind classes
    icon.html                   # Own SVG icon system, same interface as Congo's
    article-meta.html           # Date, reading time, tags for posts
    pagination.html             # Prev/next or page list
    home/
      custom.html               # Already custom, remove Congo partial calls
  shortcodes/                   # No structural changes, update CSS var names
random/
  list.html                     # Already custom, remove Tailwind classes

assets/
  css/
    main.css                    # New: CSS custom properties, reset, layout, typography
    syntax.css                  # Chroma syntax highlighting (generate once)
    custom.css                  # Existing overrides — migrate into main.css or keep separate
  js/
    theme.js                    # Dark mode toggle (replaces Congo's appearance.js)
    code-copy.js                # Code copy button
  icons/                        # SVG files copied from Congo for icons we use
    circle-info.svg
    pencil.svg
    email.svg
    github.svg
    linkedin.svg
    rss.svg
    link.svg
    globe.svg
```

---

## Phase 1 — CSS Foundation

Define CSS custom properties in `assets/css/main.css` to replace Congo's
`--color-neutral-*` and `--color-primary-*` variable system. Keep the same
property names so existing `custom.css` requires no changes initially, then
consolidate in a later cleanup pass.

```css
:root {
  /* Neutral scale */
  --color-neutral-50:  249 250 251;
  --color-neutral-100: 243 244 246;
  --color-neutral-200: 229 231 235;
  --color-neutral-300: 209 213 219;
  --color-neutral-400: 156 163 175;
  --color-neutral-500: 107 114 128;
  --color-neutral-600: 75  85  99;
  --color-neutral-700: 55  65  81;
  --color-neutral-800: 31  41  55;
  --color-neutral-900: 17  24  39;
  --color-neutral-950: 3   7   18;

  /* Primary (avocado green) */
  --color-primary-50:  236 252 203;
  --color-primary-300: 190 242 100;
  --color-primary-400: 163 230 53;
  --color-primary-500: 132 204 22;
  --color-primary-600: 101 163 13;
  --color-primary-700: 77  124 15;
  --color-primary-950: 26  46  5;

  /* Semantic */
  --color-bg:       255 255 255;
  --color-text:     var(--color-neutral-800);
  --color-muted:    var(--color-neutral-500);
  --color-border:   var(--color-neutral-200);
  --max-width:      72rem;
  --prose-width:    120ch;
}

[data-theme="dark"] {
  --color-bg:     var(--color-neutral-950);
  --color-text:   var(--color-neutral-100);
  --color-muted:  var(--color-neutral-400);
  --color-border: var(--color-neutral-700);
}
```

Use `data-theme="dark"` on `<html>` (toggled by JS) rather than a `.dark` class,
so existing `custom.css` dark mode selectors (`.dark .foo`) need a one-line
update: replace `.dark` with `[data-theme="dark"]`.

Add a minimal CSS reset, base typography, and layout primitives (centered
container, prose width, nav bar).

Generate `assets/css/syntax.css` once via:
```bash
hugo gen chromastyles --style=github > assets/css/syntax-light.css
hugo gen chromastyles --style=github-dark > assets/css/syntax-dark.css
```

---

## Phase 2 — Base Template

`layouts/baseof.html` provides the outer shell:

```html
<!DOCTYPE html>
<html lang="{{ .Site.Language.Lang }}" data-theme="">
  <head>{{ partial "head.html" . }}</head>
  <body>
    {{ partial "header.html" . }}
    <main>{{ block "main" . }}{{ end }}</main>
    {{ partial "footer.html" . }}
  </body>
</html>
```

`layouts/_partials/head.html` handles:
- `<meta>` charset, viewport, description, OG (use Hugo's `_internal/opengraph.html`)
- CSS bundle (`main.css` + `custom.css` + `syntax.css`)
- Dark mode script (inline, before paint, to prevent flash)
- Canonical URL, RSS autodiscovery link

`layouts/_partials/header.html`:
- Site title / logo link
- Navigation links from `menus.en.toml`
- Dark mode toggle button (sun/moon icon)

`layouts/_partials/footer.html`:
- Minimal — copyright or nothing

---

## Phase 3 — Core Page Templates

**`layouts/index.html`** — Homepage

Replaces Congo's layout dispatch. Renders the homepage directly:

```html
{{ define "main" }}
  {{ partial "home/custom.html" . }}
{{ end }}
```

`layouts/_partials/home/custom.html` already exists and handles the profile card,
statuses, nav cards, and now section. The only change: replace calls to
`partial "profile.html"` and `partial "icon.html"` with own implementations.

**`layouts/_default/single.html`** — Post / page

```html
{{ define "main" }}
<article class="prose">
  <header>
    <h1>{{ .Title }}</h1>
    {{ partial "article-meta.html" . }}
  </header>
  {{ .Content }}
</article>
{{ end }}
```

**`layouts/_default/list.html`** — Blog listing, tags, etc.

Render a list of pages with title, date, summary, tags.
Pagination via own `pagination.html` partial.

---

## Phase 4 — Replace Congo Partials

### `icon.html`

Copy the relevant SVG files from Congo's icon set into `assets/icons/`. The
partial interface stays identical:

```html
{{- $icon := resources.Get (print "icons/" . ".svg") -}}
{{- with $icon -}}
  <span class="icon">{{- $icon.Content | safeHTML -}}</span>
{{- end -}}
```

Icons needed: `circle-info`, `pencil`, `email`, `github`, `linkedin`, `rss`,
`link`, `globe`.

### `profile.html`

Implement from scratch. Reads from `site.Params.author`:

```html
<section class="profile">
  {{ with site.Params.Author.image }}
    {{ $img := resources.Get . }}
    {{ with $img }}
      <img class="profile-avatar" src="{{ .Permalink }}" alt="{{ site.Params.Author.name }}" />
    {{ end }}
  {{ end }}
  <h1 class="profile-name">{{ site.Params.Author.name }}</h1>
  {{ with site.Params.Author.headline }}
    <p class="profile-headline">{{ . }}</p>
  {{ end }}
  {{ partial "author-links.html" . }}
</section>
```

### `author-links.html`

Already custom. Remove Tailwind utility classes, replace with custom CSS classes
(`.author-links`, `.author-link`). Email obfuscation JS stays unchanged.

---

## Phase 5 — Dark Mode Toggle

`assets/js/theme.js`:
- On load: read `localStorage.getItem("theme")` or fall back to
  `prefers-color-scheme`. Set `data-theme` on `<html>`.
- On toggle: flip between `""` and `"dark"`, persist to `localStorage`.

Inline a minimal version before `<body>` in `head.html` to prevent flash of
wrong theme on load.

---

## Phase 6 — Code Copy Button

`assets/js/code-copy.js`: query all `pre > code` blocks, inject a copy button,
wire up `navigator.clipboard.writeText`. This replaces Congo's
`enableCodeCopy` param.

---

## Phase 7 — Remove Congo

1. Remove from `go.mod`:
   ```
   github.com/jpanther/congo/v2 v2.12.2
   ```
2. Remove from `config/_default/module.toml`:
   ```toml
   [[imports]]
   path = "github.com/jpanther/congo/v2"
   ```
3. Run `hugo mod tidy` to clean `go.sum`.
4. Remove Congo-specific params from `params.toml`:
   - `colorScheme`
   - `homepage.layout`, `homepage.showRecent`, `homepage.recentLimit`
   - `[article]`, `[entry]` blocks
   - `enableCodeCopy`
5. Verify build with `hugo --minify`.

---

## Phase 8 — CSS Consolidation

Once the site builds cleanly, merge `custom.css` into `main.css` and clean up:
- Replace `.dark` selectors with `[data-theme="dark"]`
- Replace `rgba(var(--color-*), 1)` with direct `rgb()` calls or keep as-is
- Remove any Congo-specific overrides that are no longer needed
- Organise into logical sections: reset, layout, typography, components, utilities

---

## Open Questions

- **Typography**: System font stack (`ui-sans-serif, system-ui, ...`) or a web
  font (Inter is a common choice)? Web fonts add a network request.
- **Admonitions**: The `hugo-admonitions` module adds its own CSS. Keep it as a
  module or copy the styles into the theme?
- **`random/list.html`**: Already mostly custom. Minor Tailwind class cleanup needed.
- **Prose styling**: Implement own prose/typography styles (similar to Tailwind's
  `prose` plugin) or use a minimal reset and rely on browser defaults with
  targeted overrides?

---

## Implementation Order

1. Phase 1 — CSS foundation (custom properties, syntax CSS)
2. Phase 2 — Base template, head, header, footer
3. Phase 3 — Homepage, single, list templates
4. Phase 4 — Replace icon.html, profile.html; update author-links.html
5. Phase 5 — Dark mode JS
6. Phase 6 — Code copy JS
7. Phase 7 — Remove Congo, verify build
8. Phase 8 — CSS consolidation and cleanup
