---
id: kof-anti-patterns-duplicate-state-en
title: Anti-pattern — Duplicate State
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,duplicate-state
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/duplicate-state.md) | [Português](kof/anti-patterns/duplicate-state.pt_BR.md)

# Anti-pattern — Duplicate State

**Updated:**  0.4.0-beta (Sep 2026) (02 Sep 2026) — `List.size` via `kof_list_get` bounds OK; `Box<T>` and `map/filter` do not duplicate.

## Name

Keeping the same data in two places and synchronizing it manually.

## Problem

A class keeps a `List` and also a `count`, or a `name` and a `displayName`
that derive from the same value. Every mutation must update both — and at
some point they diverge.

## Bad example

```kof
class Cart {
    List<Int> items
    Int count

    constructor() {
        items = listOf()
        count = 0
    }
    add(Int id) {
        items.add(id)
        count = items.size   // manual synchronization
    }
}
```

## Why it is bad

`count` is derivable from `items.size`. It is not state — it is a projection.
Every mutation point must remember to synchronize. One oversight = bug.

## Preferred approach

```kof
class Cart {
    List<Int> items

    constructor() {
        items = listOf()
    }
    add(Int id) {
        items.add(id)
    }
    Int size() {
        return items.size
    }
}
```

The size is queried, not stored.

## Another example

```kof
// BAD: duplicates
String nome
String nomeMaiusculo   // synchronize on every assignment

// GOOD: derive when needed
String nome
```

## Rule

If a value can be derived from another, derive it (method or function).
Do not store projections.

## Exceptions

- Intentional cache with explicit invalidation (rare case, documented).
