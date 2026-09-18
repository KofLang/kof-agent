---
id: kof-language-classes-en
title: Kof Classes
module: kof
category: kof-language
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,language,classes
status: stable
tags: kof,language,en
---
[English](kof/language/classes.md) | [Português](kof/language/classes.pt_BR.md)

# Kof Classes

**Version:** 0.4.0-beta (Sep 2026)

## Basic Class — two models (verified 02/09)

> `class User(String name, Int age)` is an **alias for `record`** (immutable,
> `extends java.lang.Record` on the JVM; accessors `u.name()`; writing `u.name =
> "x"` does NOT work). For **mutable state**, use fields + `constructor(...)`
> (public fields, direct write).

```kof
// Immutable (record-style): class X(...) == record X(...)
class User(String name, Int age) { }
var u = User("Mel", 30)
println(u.name)      // read ok (accessor)
// u.age = 31         // COMPILE error SEM038: record is immutable

// Mutable — real class form
class User2 {
    String name
    Int age
    public constructor(String name, Int age) {
        this.name = name
        this.age = age
    }
}
var u2 = User2("Mel", 30)
u2.age = 31           // ok — mutable public field
```

## Records (Immutable Data)

```kof
record Point(Int x, Int y)
// Auto-generates: constructor, accessors x(), y(), toString()
switch (p) {
    case Point(var x, var y): println(x + "," + y) // destructuring
}
```

## Inheritance

```kof
class Animal {
    String name
    public constructor(String name) {
        this.name = name
    }
}
class Dog extends Animal {
    public constructor(String name) {
        super(name)
    }
}
```

## Interfaces

```kof
interface Speaker {
    speak(): String
}
class Dog implements Speaker {
    public speak(): String {
        return "woof"
    }
}
```

## Virtual Dispatch

```kof
class Animal {
    public speak(): String { return "animal" }
}
class Dog extends Animal {
    public speak(): String { return "dog" }
}
main() {
    Animal a = new Dog()
    println(a.speak())  // prints "dog" (virtual dispatch)
}
```

## Field Initialization

```kof
class Config {
    String host = "localhost"
    Int port = 8080
    public constructor() {
    }
}
```

## Access Modifiers

- `public` — accessible everywhere
- `private` — accessible within class
- `protected` — accessible in subclass
- `static` — class-level
- `final` — immutable
