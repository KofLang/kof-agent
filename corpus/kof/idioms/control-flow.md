---
id: kof-idioms-control-flow-en
title: Idioms — Control Flow
module: kof
category: kof-idioms
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,idioms,control-flow
status: stable
tags: kof,idioms,en
---
[English](kof/idioms/control-flow.md) | [Português](kof/idioms/control-flow.pt_BR.md)

# Idioms — Control Flow

**Status:** available · **Introduced:** 0.0.4-alpha · **Updated:**  0.4.0-beta (Sep 2026)

## What it is

Control flow without ceremony: `if`/`else`, `while`, `do-while`, `for`,
`for-in`, `switch`, `break`/`continue` and **if as an expression**.

## if / else

```kof
if (x > 5) {
    println("maior")
} else {
    println("menor")
}
```

## if as an expression

```kof
var status = if (ativo) "online" else "offline"
```

The if-expr produces a value; both branches must produce compatible values.

## BAD — ignored if-expr

```kof
var status = ""
if (ativo) {
    status = "online"
} else {
    status = "offline"
}
```

## GOOD

```kof
var status = if (ativo) "online" else "offline"
```

## WHY

Declaring and then assigning in branches is unnecessary mutation.
The if-expression expresses the intent and eliminates the intermediate state.

## Loops

```kof
var i = 0
while (i < 5) {
    println(i)
    i = i + 1
}
```

```kof
for (var j = 0; j < 3; j = j + 1) {
    println(j)
}
```

```kof
do {
    println("pelo menos uma vez")
} while (falso())
```

## for-in (collections and arrays)

```kof
var items = listOf("a", "b", "c")
for (var item in items) {
    println(item)
}

var nums = new Int[3]
nums[0] = 5
for (var n in nums) {
    println(n)
}
```

## switch (pattern matching — since 0.2.6-beta)

```kof
switch (x) {
    case 1:
        println("um")
        break
    case 2:
        println("dois")
        break
    default:
        println("outro")
}

// pattern matching with type + record destructuring
switch (obj) {
    case String s:
        println(s)
        break
    case Point(var x, var y):
        println(x + "," + y)
        break
    default:
        println("outro")
}
```

## When not to use

- Replacing a `for-in` with a `for` with a manual index when order does not matter.
- `switch` for two cases — `if/else` is more direct.

## switch: `break` is optional (no fallthrough — verified 02/09)

Each `case` **terminates on its own**: the compiler jumps to the end of the
`switch` when it finishes the body — there is no fallthrough (nor the classic
C/Java bug of forgetting the `break`). The `break` is **accepted but not
required**; writing it is optional (some prefer it explicit for clarity).

```kof
switch (x) {
    case 1:
        println("um")      // no break — ok, does not fall into the next case
        break              // also ok (explicit)
    case 2:
        println("dois")
    default:
        println("outro")
}
```

> **Note (02/09):** previous documentation stated that `break` was
> required — verified in the compiler that it is **optional** (auto-terminates).
> `break`/`continue` remain required in loops (to exit/skip).

## switch as an expression (SYN001 — `case ... ->`; implemented, verified in the compiler)

When the `switch` **produces a value**, use the expression form (`->`), not the
statement (`:`). Each case is a single expression; there is no `break`, there is
no block scope, and `default` is required (or enum exhaustiveness —
otherwise `SEM032`). It is the same device as the `if`-expression, raised to N cases.

```kof
// ❌ BAD — switch statement + temporary + branches assigning
var label = ""
switch (op) {
    case "GET":  label = "buscar"
    case "POST": label = "criar"
    default:     label = "desconhecido"
}

// ✅ GOOD — switch expression: the value IS the switch
var label = switch (op) {
    case "GET"  -> "buscar"
    case "POST" -> "criar"
    default    -> "desconhecido"
}

// pattern matching + destructuring as an expression
var desc = switch (obj) {
    case String s            -> "str:" + s
    case Point(var x, var y) -> x + "," + y
    default                  -> "outro"
}

// nested / in return — works in any expression position
String nome(Int n) = switch (n) {
    case 0 -> "zero"
    case 1 -> "um"
    default -> "muitos"
}
```

**When to use which:** the `switch`-expression (`->`) when the result is a
value; the `switch`-statement (`:`) when each case performs side effects
(println, calls). The two coexist — the choice is by token (`->` vs `:`).

> **Verified 03/09 (SYN001):** JVM, Native (x86_64/riscv64/aarch64) and JS.
> On JS it is rendered as nested ternaries; for String/enum equality is
> by content (never reference).

## Related anti-patterns

- `premature-optimization.md` — manual loops when unnecessary
