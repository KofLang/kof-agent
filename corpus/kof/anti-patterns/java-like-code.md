---
id: kof-anti-patterns-java-like-code-en
title: Anti-pattern — Java-like Code
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,java-like-code
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/java-like-code.md) | [Português](kof/anti-patterns/java-like-code.pt_BR.md)

# Anti-pattern — Java-like Code

## Name

Java code translated literally to Kof.

## Problem

Carrying Java conventions (getters/setters, builders, factories, utility
classes, DTO ceremony, `equals`, `StringBuilder`, sentinels) to Kof without
reevaluating whether the convention has a reason to exist in the new language.

## Bad example

```kof
class User {
    private String name
    private Int age
    public getName(): String {
        return name
    }
    public setName(String name) {
        this.name = name
    }
    public getAge(): Int {
        return age
    }
    public setAge(Int age) {
        this.age = age
    }
}
```

## Why it is bad

Java requires getters/setters because of JavaBeans, serialization, reflection
frameworks and tool conventions. Kof has none of those conventions. The code
duplicates state with ceremony without semantics.

## Preferred approach

```kof
class User {
    String name
    Int age
}
```

Direct access: `u.name`, `u.age = 30`.

## Java pattern → decision in Kof

| Java pattern | Why it exists in Java | Does Kof need it? | Idiomatic alternative |
|---|---|---|---|
| Getter/setter | JavaBeans, frameworks, reflection | No | Public field |
| Builder | Constructors with many optional args | No (for now) | Constructor with args or record |
| Static factory | Constructors cannot have names | No | Call the constructor |
| Utility class with static | Java has no top-level functions | No | Top-level function |
| Service/Repository/Controller | Dependency injection, lifecycles | No | Top-level function or direct class |
| `StringBuilder` | `+` in a loop was inefficient | No | `+` concatenates |
| `.equals()` | `==` cannot be overloaded | No | `==` compares content |
| DTO + mapper | Serialization requires no-arg + setters | No | Record + json.encode |
| Optional | `null` is ubiquitous | Partial (0.4.0-beta) | `String?` + `if (x != null)` narrowing; `Option<T>` still planned |
| `instanceof` + cast | Type narrowing | Yes (0.4.0-beta) | `instanceof` + `as` and pattern `case String s:` / `case Point(x,y)` |
| Manual loop for map | Java without higher-order until streams | No | `list.map/filter/reduce` (0.4.0-beta) |
| `import java.util.*` | Java collections | No | `listOf`/`mapOf`/`setOf` + file-specific `import a.b.C` (fix 27/08) |

## Exceptions

Patterns that are legitimate exceptions:
- Interoperability with Java libraries (when the interop layer exists).
- Conventions imposed by an external API.
