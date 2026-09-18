---
id: kof-idioms-composition-en
title: Visual composition by objects
module: kof
category: kof-idioms
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,idioms,composition
status: stable
tags: kof,idioms,en
---
[English](kof/idioms/composition.md) | [Português](kof/idioms/composition.pt_BR.md)

# Visual composition by objects

**Updated:**  0.4.0-beta (Sep 2026) (02 Sep 2026)

> The visual is a graph of objects. No templates, XML or magic strings:
> the interface is Kof code, typed, compiled and verified like any other.

## The idea

An interface is a **tree of objects** composed in code. Each visual element
is an object; each object carries its own style; the style is made of
`Color`, `Int` and `String` — language types, never loose text.

```kof
class Style {
    Color background
    Color foreground
    Int padding
    Int radius

    constructor(Color background = Colors.surface,
                Color foreground = Colors.text,
                Int padding = 12,
                Int radius = 8) {
        this.background = background
        this.foreground = foreground
        this.padding = padding
        this.radius = radius
    }
}
```

## Composition

```kof
class View {
    Style style
    List<Node> children

    constructor(Style style, List<Node> children) {
        this.style = style
        this.children = children
    }
}

class Text {
    String content
    Style style

    constructor(String content, Style style) {
        this.content = content
        this.style = style
    }
}
```

## The palette

32-bit colors (`0xAARRGGBB`) with names, not codes:

```kof
class Colors {
    static Int primary    = 0xFF6750A4
    static Int background = 0xFF121212
    static Int text       = 0xFFE0E0E0
    static Int error      = 0xFFCF6679
}
```

## Building a screen

```kof
View homeView() {
    return View(
        Style(background: Colors.background, padding: 16),
        [
            Text("Bem-vinda", Style(color: Colors.primary, bold: true)),
            Button("Entrar", () => login())
        ]
    )
}
```

## Why objects

- **Typed**: a style with the wrong field does not compile.
- **Composable**: the screen is a value like any other — it can come from a
  function, from a list, from a condition.
- **Multi-target**: the same tree of objects becomes whatever each backend
  knows how to draw (terminal, web, native).

See also: `docs/stdlib/COLOR.md` and `learn/35-ui-and-styling.md`.
