---
id: kof-anti-patterns-unnecessary-abstraction-en
title: Anti-pattern — Unnecessary Abstraction
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,unnecessary-abstraction
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/unnecessary-abstraction.md) | [Português](kof/anti-patterns/unnecessary-abstraction.pt_BR.md)

# Anti-pattern — Unnecessary Abstraction

**Updated:**  0.4.0-beta (Sep 2026) (02 Sep 2026)

## Name

Abstractions created without a real problem.

## Problem

"Manager", "Helper", "Context", "Handler", "Wrapper", "Factory" classes that
only forward calls. Each layer adds indirection without semantics.

## Bad example

```kof
class UserManager {
    UserRepository repo
    constructor() {
        repo = new UserRepository()
    }
    find(Int id): User {
        return repo.find(id)
    }
}
class UserRepository {
    find(Int id): User {
        // real logic
    }
}
```

## Why it is bad

The consumer must know two classes to do what one function does.
The indirection solves no problem (transaction? cache? swappability?).

## Preferred approach

```kof
User findUser(Int id) {
    // real logic
}
```

## Rule

Add a layer only when it solves a concrete problem:
- tested swappability (interface + multiple implementations);
- cross-cutting transaction/cleanup;
- real shared state.

If the layer only forwards, remove it.

## Exceptions

- Interop with legacy code that requires the structure.
