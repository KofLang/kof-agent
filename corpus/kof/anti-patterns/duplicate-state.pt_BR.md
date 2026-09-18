---
id: kof-anti-patterns-duplicate-state-pt
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
tags: kof,anti-patterns,pt
---
[English](kof/anti-patterns/duplicate-state.md) | [Português](kof/anti-patterns/duplicate-state.pt_BR.md)

# Anti-pattern — Duplicate State

**Updated:**  0.4.0-beta (Sep 2026) (02 Sep 2026) — `List.size` via `kof_list_get` bounds OK; `Box<T>` e `map/filter` não duplicam.

## Name

Manter o mesmo dado em dois lugares e sincronizar manualmente.

## Problem

Uma classe guarda `List` e também um `count`, ou um `name` e um `displayName`
que derivam do mesmo valor. Cada mutação precisa atualizar os dois — e em
algum ponto eles divergem.

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
        count = items.size   // sincronização manual
    }
}
```

## Why it is bad

O `count` é derivável de `items.size`. Ele não é estado — é uma projeção.
Cada ponto de mutação precisa lembrar de sincronizar. Um esquecimento = bug.

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

O tamanho é consultado, não armazenado.

## Outro exemplo

```kof
// BAD: duplica
String nome
String nomeMaiusculo   // sincronizar em toda atribuição

// GOOD: deriva quando necessário
String nome
```

## Regra

Se um valor pode ser derivado de outro, derive-o (método ou função).
Não armazene projeções.

## Exceptions

- Cache intencional com invalidação explícita (caso raro, documentado).