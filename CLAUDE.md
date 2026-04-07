# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Hugo static site (twobiers.github.io) built on the [Congo theme](https://github.com/jpanther/congo) with the [hugo-admonitions](https://github.com/KKKZOZ/hugo-admonitions) module. Content is written in Markdown or AsciiDoc. The site is deployed to GitHub Pages on every push to `main`.

## Development Commands

**Local dev server (Docker):**
```bash
docker compose up
# Site available at http://localhost:1313
```

**Local dev server (native Hugo required):**
```bash
hugo server
```

**Build for production:**
```bash
hugo --minify
```

Hugo version: `0.152.2` (extended). AsciiDoc support requires `asciidoctor` and `asciidoctor-chroma` gems (`gem install asciidoctor asciidoctor-chroma`).

## Content Structure

- `content/posts/` — long-form blog posts, each in its own directory (e.g. `2024-08-28_conditional_git_author/index.md`)
- `content/dev/` — technical/dev-focused articles
- `content/random/` — short-form notes synced automatically from [Supernotes](https://supernotes.app) via GitHub Actions daily cron
- `content/about/` — about page

**Date inference:** Hugo derives the date from the filename prefix (`YYYY-MM-DD`) when not set in frontmatter (`frontmatter.date = [":default", ":filename", ":fileModTime"]`).

## Random Posts

To create a new random post locally, run:
```bash
./random.sh
```

This opens today's file (`content/random/YYYY-MM-DD.md`) in your `$VISUAL`/`$EDITOR`.

## Configuration

- `config/_default/` — base config split across `config.toml`, `params.toml`, `menus.en.toml`, `markup.toml`, `module.toml`, `taxonomies.toml`
- `config/production/` — production overrides
- Hugo modules are used (not git submodules) for the theme; `go.mod`/`go.sum` manage them

## Theme & Customization

- Theme: Congo v2 (`github.com/jpanther/congo/v2`)
- Color scheme: `avocado`
- Custom CSS: `assets/css/custom.css`
- Custom layouts: `layouts/` (partials, shortcodes, random list template)
- AsciiDoc syntax highlighting uses Chroma via the `asciidoctor-chroma` extension; highlight classes are generated (not inline styles — `noClasses = false`)
- Goldmark unsafe mode is enabled (raw HTML in Markdown is allowed)

## CI/CD

- `.github/workflows/gh-pages.yml` — builds and deploys to GitHub Pages on push to `main`
