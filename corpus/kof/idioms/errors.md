---
id: kof-idioms-errors-en
title: Idioms — Errors
module: kof
category: kof-idioms
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,idioms,errors
status: stable
tags: kof,idioms,en
---
[English](kof/idioms/errors.md) | [Português](kof/idioms/errors.pt_BR.md)

# Idioms — Errors

**Status:** available (JVM, Native, JS) · **Introduced:** 0.0.4-alpha · **Updated:**  0.4.0-beta (Sep 2026)

## What it is

Exceptions are Strings. `throw "mensagem"`, `catch (String e)`, `finally`.
It works on JVM (exception table) and Native (own unwinding).

```kof
try {
    throw "boom"
    println("unreachable")
} catch (String e) {
    println("caught: " + e)
} finally {
    println("finally")
}
```

## When to use

- An error that interrupts the flow and needs to be handled at another point.
- `finally` for cleanup that must run on every path.

## When not to use

- Normal control flow — use `if`.
- Simple validation — `if` + return.
- Absence as a value (not an error) — use `String?` + `if (x != null)` (0.4.0-beta) instead of a sentinel. Generic `Option<T>` is still planned.

## BAD — sentinel

```kof
String find(String key) {
    for (var entry in entries) {
        if (entry.key == key) {
            return entry.value
        }
    }
    return ""
}
```

When `""` means "not found", the consumer has to check by convention.
That is a sentinel: the data and the error are indistinguishable.

## GOOD — exception

```kof
String find(String key) {
    for (var entry in entries) {
        if (entry.key == key) {
            return entry.value
        }
    }
    throw "not found: " + key
}
```

Usage:

```kof
try {
    var v = find("x")
} catch (String e) {
    println("falhou: " + e)
}
```

## WHY

The exception carries the error information in the language's own error
mechanism. The sentinel spreads the convention across all consumers.

> **Since 0.2.6-beta:** absence as a value uses `String?`/`Int?` with narrowing (`if (x != null)`).
> Generic `Option<T>`/`Result<T>` are still planned — only then is a sentinel marked `WORKAROUND` acceptable.

## Propagation

```kof
void inner() {
    throw "from-inner"
}
String outer() {
    try {
        inner()
        return "no"
    } catch (String e) {
        return "got: " + e
    }
}
```

The exception crosses frames (called functions) on both targets.

## finally

```kof
try {
    trabalho()
} finally {
    limpar()
}
```

`finally` runs on the normal path, on the caught path and on propagation.

## Related anti-patterns

- `sentinel-values.md`
- `runtime-workarounds.md`
