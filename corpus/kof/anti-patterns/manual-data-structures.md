---
id: kof-anti-patterns-manual-data-structures-en
title: Anti-pattern — Manual Data Structures
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,manual-data-structures
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/manual-data-structures.md) | [Português](kof/anti-patterns/manual-data-structures.pt_BR.md)

# Anti-pattern — Manual Data Structures

## Name

Implementing data structures that the language already provides.

## Problem

Manual linked lists (`Node` + `next`), manual dynamic arrays, manual
hashmaps, manual string builders — when `List<T>`, `Map<K,V>`, `Set<T>` and `+`
already solve the problem (3 targets).

## Bad example

```kof
class Node {
    String value
    Node next
}
class Registry {
    Node root
    Int count
    Bool hasNext() {
        return root != null && root.next != null
    }
}
```

Historical workaround (removed 27/08): manual `List.get` with a bounds check — now `l.get(i)` already does it via `kof_list_get`.

Other manual workarounds that existed because of target gaps and are obsolete today:
a manual JSON parser in Native (JSN001/002/003 closed 31/08 — `json.encode`/`json.decode<T>` of objects/records/arrays on the 3 targets) and manual FP arithmetic/formatting in Native (FLT001 closed 31/08 — real float/double in XMM).

## Why it is bad

The manual implementation carries: allocation, chaining, counting, bounds,
iteration — everything the programmer would have to maintain and test. The domain is
"a collection", not "chained nodes".

## Preferred approach (0.4.0-beta)

```kof
class Registry {
    List<String> entries

    constructor() {
        entries = listOf()
    }
}

// Associations — Map exists (0.1.0)
var m = mapOf("kof", "kf")
m.put("json", "json")
var v = m.get("kof")

// Sets
var s = setOf(1, 2, 3)
s.add(4)

// Transformation — no manual loop
var nomes = users.map((u: User) -> u.name)
var pares = nums.filter((x: Int) -> x % 2 == 0)
```

## Common manual structures → alternative (0.4.0-beta)

| Manual | Kof alternative |
|---|---|
| Linked list (`Node.next`) | `List<T>` |
| Dynamic array + `count` | `List<T>` (size) |
| Manual hashmap | `Map<K,V>` + `mapOf` |
| Manual set | `Set<T>` + `setOf` |
| String builder | `+` concatenation |
| Collection wrapper | The collection directly |
| Registry with manual `get`/`has` | `List<T>` + `contains` / `Map.get` |
| Manual loop for map/filter | `list.map` / `filter` / `reduce` |
| Manual `Box<T>` for primitives | Native `Box<T>` (erasure fix 25/08) |

## Exceptions

- Implementing a structure to LEARN the language (didactic).
- A structure with proven performance requirements that the stdlib does not cover.
