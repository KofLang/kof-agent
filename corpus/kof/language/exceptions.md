---
id: kof-language-exceptions-en
title: Kof Exceptions Reference
module: kof
category: kof-language
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,language,exceptions
status: stable
tags: kof,language,en
---
[English](kof/language/exceptions.md) | [Português](kof/language/exceptions.pt_BR.md)

# Kof Exceptions Reference

**Exceptions are Strings** — `throw "message"` / `catch (String e)`. There is no
exception object and no `throw 42`/`catch (Int e)` (they generate invalid
bytecode on the JVM — verified 02/09). For absence as a value, use `String?`
(not an error).

## Throw

```kof
throw "error message"
throw "user not found: " + id
```

## Try/Catch

```kof
try {
    riskyOperation()
} catch (String e) {
    println("Error: " + e)
}
```

## Try/Finally

```kof
try {
    riskyOperation()
} finally {
    println("Cleanup")
}
```

## Try/Catch/Finally

```kof
try {
    riskyOperation()
} catch (String e) {
    println("Error: " + e)
} finally {
    println("Cleanup")
}
```

## Absence vs error

- **Absence** (the data may not exist) → `String?` + `if (x != null)`.
- **Real error** (the absence is a defect) → `throw "not found: " + id`.

```kof
String? find(String key) { if (found) return value; return null }
String findOrThrow(String key) { if (found) return value; throw "not found: " + key }
```

## Runtime Errors

| Error | Trigger | Message |
|-------|---------|---------|
| Null pointer | Access null object | "Runtime error: null pointer access" |
| Array bounds | Index out of range | "Runtime error: array index out of bounds" |
| Panic | `kof_panic()` | Custom message |

## Behavior

- **JVM**: Exceptions propagate via the JVM exception table; the thrown String
  is wrapped in a `RuntimeException` and unwrapped back in the catch.
- **Native**: real unwinding via an exception frame chain (`kof_throw_string`):
  frames restore `rsp`/`rbp` and jump to the handler; `finally` runs and the
  exception is rethrown; propagation across function frames works.
- **try/catch**: works on both targets. In Native, the FIRST catch of a try
  captures (no type dispatch between multiple catches).
- **finally**: always executed (normal path, caught path, propagation).

## Limitations (0.4.0-beta)

- No stack traces in Native
- Exceptions are **Strings** — `throw 42`/`catch (Int e)` generate invalid
  bytecode on the JVM (02/09); use `String?` for absence as a value
- Native exceptions propagate via unwinding (not fatal); `finally` always runs
