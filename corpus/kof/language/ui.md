---
id: kof-language-ui-en
title: kof.ui — Color, Palette and Theme
module: kof
category: kof-language
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,language,ui
status: stable
tags: kof,language,en
---
[English](kof/language/ui.md) | [Português](kof/language/ui.pt_BR.md)

# kof.ui — Color, Palette and Theme

Facts about Kof's UI foundation. Use it to answer questions about
colors, palettes and themes.

## Color

- `Color(r, g, b)` — channels 0-255, alpha 255.
- `Color.rgba(r, g, b, a)` — with alpha.
- `Color(packedValue)` — the raw value `0xRRGGBBAA`.
- Layout: `(r << 24) | (g << 16) | (b << 8) | a`.
- `red()`, `green()`, `blue()`, `alpha()` — channels 0-255.
- `isOpaque()` — Bool (alpha == 255).
- `withAlpha(a)` — new Color with the alpha swapped.
- `toCss()` — `rgb(r, g, b)` when opaque, `rgba(r, g, b, a)` when not.

Examples:

```kof
Color(255, 0, 0).toCss()            // rgb(255, 0, 0)
Color.rgba(10, 20, 30, 128).toCss() // rgba(10, 20, 30, 128)
Color(0xFF0000FF).red()             // 255
```

## Palette

Named constants: `Palette.red`, `green`, `blue`, `yellow`, `cyan`,
`magenta`, `black`, `white`, `gray`/`grey`, `orange`, `purple`, `pink`,
`brown`, `transparent`.

```kof
Palette.green.toCss()   // rgb(0, 255, 0)
Palette.transparent.alpha()   // 0
```

## Theme

- `Theme.light()` / `Theme.dark()` — the theme (tag 0/1).
- `isDark()` — Bool.
- Semantic colors: `background()`, `surface()`, `primary()`,
  `secondary()`, `text()`, `error()` — Color.

Dark: background `rgb(18, 18, 18)`, text `rgb(255, 255, 255)`.
Light: background `rgb(255, 255, 255)`, text `rgb(0, 0, 0)`.

```kof
var dark = Theme.dark()
dark.background().toCss()   // rgb(18, 18, 18)
```

## Semantics across targets

- Color/Theme are 32-bit Int values — the compiler manipulates the channels
  with bitwise; `toCss()` uses runtime helpers identical on JVM, Native and
  JS.
- Rendering (widgets → DOM) is **KofJS only** and is implemented:
  `Window`/`Label`/`Button`/`Input`, `Column`/`Row`, `View`+`Style`,
  events by lambda with captures, native webview (`bin/kof-webview`,
  WebKitGTK). JVM/Native: no-op handles.
- There is no JavaFX, AWT or GUI dependency in any backend.

## Router (Phase 7)

Navigation by swapping the root component: `Router` is a namespace (not a type).

- `Router.route(name, component)` — registers a route.
- `Router.go(name)` / `Router.go(name, param)` — navigates (unmounts the old + mounts the new).
- `Router.replace(name[, param])` — navigates without pushing onto the history.
- `Router.back()` / `Router.forward()` — history (stacks; `forwardStack` cleared when going forward).
- `Router.param()` — `String` of the current route's param.
- `Router.current()` — `String` of the current route.
- `Depth`: `Router.depth()` — `Int`.
- Real on the JS target (KofJS); JVM/Native: no-op handles.
- See `docs/ui/architecture.md` §2.9 and `RouterE2ETest`.

## KofScript idiom (0.4.0-beta)

```kof
var x = 5
var app = Window("Hi", Label("Olá"))
```

## Reference

- `learn/35-kof-ui.md`
- `kof-compiler/src/test/java/dev/kof/compiler/UiE2ETest.java` (29 tests)
