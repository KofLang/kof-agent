---
id: kof-anti-patterns-sentinel-values-en
title: Anti-pattern — Sentinel Values
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,sentinel-values
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/sentinel-values.md) | [Português](kof/anti-patterns/sentinel-values.pt_BR.md)

# Anti-pattern — Sentinel Values

## Name

Using a data value to represent absence/error.

## Problem

`""`, `-1`, `0`, `"not found"` returned to mean "does not exist".
The consumer must know the convention; legitimate values can collide
with the sentinel; the error carries no information.

## Bad example

```kof
Int findIndex(String key) {
    for (var i = 0; i < keys.size; i = i + 1) {
        if (keys.get(i) == key) {
            return i
        }
    }
    return -1
}
```

`-1` is the sentinel. The caller must remember: `if (findIndex(k) >= 0)`.

## Why it is bad

- Invisible convention (the `Int` type does not say that `-1` is special).
- Error and data are indistinguishable.
- There is no error message.

## Preferred approach (real error)

```kof
Int findIndex(String key) {
    for (var i = 0; i < keys.size; i = i + 1) {
        if (keys.get(i) == key) {
            return i
        }
    }
    throw "key not found: " + key
}
```

The consumer handles it with `try/catch` and receives the error information.

## Preferred approach (absence as data)

```kof
// ✅ String? / Int? with narrowing is the idiom
String? find(String key) {
    for (var e in entries) {
        if (e.key == key) return e.value
    }
    return null
}
var r = find("x")
if (r != null) {
    println(r.length)
}

// Alternative when error and data do not mix: exception
String findOrThrow(String key) {
    for (var e in entries) { if (e.key == key) return e.value }
    throw "not found: " + key
}
```

> **Note:** generic `Option<T>` is still `planned` — for simple cases use `String?`/`Int?`. A sentinel (`""`/`-1`) is only a `WORKAROUND` if `null` does not model the domain and must be marked explicitly.

## Exceptions

- Conventions of external APIs (e.g.: indexes return -1 in certain protocols).
