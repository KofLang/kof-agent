---
id: kof-idioms-classes-en
title: Idioms — Classes
module: kof
category: kof-idioms
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,idioms,classes
status: stable
tags: kof,idioms,en
---
[English](kof/idioms/classes.md) | [Português](kof/idioms/classes.pt_BR.md)

# Idioms — Classes

**Status:** available · **Introduced:** 0.0.4-alpha · **Updated:**  0.4.0-beta (Sep 2026)

## What it is

A class with fields, methods, constructor, inheritance and interfaces.
Fields are declared **without** `var`/`val` and without a mandatory `;`.

```kof
class User {
    String name
    Int age
}
```

## Constructors

### `class X(...)` is a RECORD — immutable data (verified 02/09)

```kof
class User(String name, Int age) {
    greeting(): String {
        return "Hello " + name
    }
}
```

> **Careful (02/09):** `class X(...)` is an **alias of `record X(...)`** — the parser
> treats it as a record body (immutable, `extends java.lang.Record` on the JVM). The
> "parameters" become components with accessors: reading `user.name` works
> (it becomes `name()`), but **writing `user.name = "x"` does NOT** (final field →
> `IllegalAccessError`). For immutable data use `record` (the canonical form);
> for **mutable state** use explicit fields + `constructor(...)`.

```kof
var user = User("Mel", 26)   // record — reading ok, writing not
```

### Explicit constructor — mutable state (the real class form)

```kof
class User {
    String name
    Int age

    public constructor(String name, Int age) {
        this.name = name
        this.age = age
    }
}
```

Here the fields are **public and mutable**: `user.name = "Mel"` / `user.age = 30`.

`new User("Mel", 30)` remains valid, but `User("Mel", 30)` is the
recommended form — the compiler treats both as instance construction.

## When to use

- Entities with behavior (methods that operate on the state).
- Mutable state.
- Inheritance and polymorphism.

## When not to use

- Immutable data without behavior → **record** (see `records.md`).
- Just grouping values → record.

## BAD — getter ceremony

```kof
class User {
    private String name
    public getName(): String {
        return name
    }
    public setName(String name) {
        this.name = name
    }
}
```

## GOOD — direct field

```kof
class User {
    String name
}
```

Usage: `u.name = "Mel"` and `println(u.name)`.

## WHY

Java's getter/setter exists because of encapsulation conventions (JavaBeans, frameworks).
Kof does not have those conventions. A public field is the idiomatic form until there is
a real reason for encapsulation. Do not reproduce ceremony without semantics.

## BAD — trivial factory

```kof
createUser(String name): User {
    return User(name)
}
```

## GOOD

```kof
User(name)
```

## WHY

A factory that only delegates to the constructor adds no information. Call the constructor.

## Inheritance

```kof
class Animal {
    String name
    public constructor(String name) {
        this.name = name
    }
    speak(): String = "animal"
}
class Dog extends Animal {
    public constructor(String name) {
        super(name)
    }
    speak(): String = "dog"
}
```

- `super(args)` is the first statement of the subclass constructor.
- Override is implicit (same method name).
- Dispatch is virtual on both targets.

## Generics Box<T> (0.4.0-beta)

```kof
class Box<T>(T value) {
    get(): T { return value }
}
var b: Box<Int> = Box(42)
println(b.get())   // erasure + substituteTypeVariable — Native OK
```

## Method Overloading (0.4.0-beta, §131)

```kof
class Calc {
    Int add(Int a, Int b) { return a + b }
    Int add(Int a, Int b, Int c) { return a + b + c }
    String add(String a, String b) { return a + b }
}
var c = Calc()
c.add(1, 2)          // 3
c.add(1, 2, 3)       // 6
c.add("ko", "f")     // "kof"
```

Same-name methods with different signatures (arity or parameter types) coexist
in the class, resolved by the typer on all 4 backends. Exact duplicate → SEM047;
ambiguity → SEM057; return type alone does NOT distinguish — full rules in
`functions.md` (they apply equally to methods).

## Related anti-patterns

- Utility class of static methods → top-level functions (`functions.md`)
- Stateless service layer → top-level functions
- Trivial factory → call the constructor
- Manual `Box<T>` → use native generics
