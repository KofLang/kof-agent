---
id: kof-idioms-functions-en
title: Idioms — Functions
module: kof
category: kof-idioms
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,idioms,functions
status: stable
tags: kof,idioms,en
---
[English](kof/idioms/functions.md) | [Português](kof/idioms/functions.pt_BR.md)

# Idioms — Functions

**Status:** available · **Introduced:** 0.0.4-alpha (without `fun`) · **Updated:**  0.4.0-beta (Sep 2026)

## What it is

Kof does not have the `fun` keyword. Functions are declared by name,
with the return type before the name **or** after the parameters.

## Valid forms (all verified in the compiler)

```kof
main() {
    println("entry point")
}
```

```kof
String saudacao() {
    return "oi"
}
```

```kof
despedida(): String {
    return "tchau"
}
```

```kof
void fazIsso() {
    println("void explícito")
}
```

```kof
Bool positivo(Int x) = x > 0      // expression body
```

```kof
int dobro(int x) {
    return x * 2
}
```

## When to use top-level functions

- Stateless logic (helpers, validation, transformation).
- Java utility classes become top-level functions.
- Handlers of `kof serve` (`handle(...)`) are top-level functions.

## When not to use

- Data + behavior → class or record.
- `main()` is the only function without an explicit type and without a return.

## Top-level function overloading (0.4.0-beta — oracle JVM)

Same-named top-level functions with **different signatures** coexist; the
call resolves the most specific applicable candidate, like the JVM.

```kof
Int g(Int x) { return x }
Int g(Int x, Int y) { return x + y }        // ✅ different arity
String twice(String s) { return s + s }
Int twice(Int n) { return n * 2 }            // ✅ different parameter type

main() {
    println(g(5))          // 5   → g/Int
    println(g(5, 6))       // 11  → g/Int,Int
    println(twice("ab"))   // abab
    println(twice(21))     // 42
}
```

- **Exact duplicate is an error** (SEM047): same name + same parameters.
- **Changing only the return type is NOT overloading** (SEM047, as on the JVM): `Int h(Int)`
  and `String h(Int)` collide.
- **Ambiguous call is an error** (SEM057): when two applicable candidates
  tie (e.g. an `Unknown` argument that would fit both), give the
  argument a type (cast or declared variable) to choose.
- Same output on the 5 targets (JVM/Script/JS/Native): the resolution is the frontend's;
  each backend references the candidate by its signature.
- **CLASS METHOD overloading ✅ exists** (0.4.0, §131 13/09): same name,
  different signatures (arity/types) in the same class coexist on the 4
  backends; the typer selects by arity+compatibility. The text above about
  duplicate/return/ambiguity applies equally to class methods.

## BAD — utility class

```kof
class StringUtils {
    static String capitalizar(String s) {
        return s.substring(0, 1).toUpperCase() + s.substring(1)
    }
}
```

## GOOD — top-level function

```kof
String capitalizar(String s) {
    return s.substring(0, 1).toUpperCase() + s.substring(1)
}
```

## WHY

Java's utility class exists because Java has no functions outside classes.
Kof has top-level functions. The extra class layer is noise.

## Lambdas (capture implemented)

```kof
var f = (x: Int) -> x * 2
println(f(21))          // 42

var g = (a: Int, b: Int) -> a + b
println(g(3, 4))        // 7

var h = () -> 99
println(h())            // 99

// Mutable capture — ✅ since 0.2.6-beta via synthetic box Box0
var offset = 10
var f2 = (x: Int) -> x + offset
println(f2(5))          // 15
offset = 20
println(f2(5))          // 25 — mutable

// Higher-order with List
var dobrados = listOf(1, 2, 3).map((x: Int) -> x * 2)
var pares = listOf(1, 2, 3, 4).filter((x: Int) -> x % 2 == 0)
```

- Lambdas compile to synthetic classes with an `invoke` method.
- Mutable capture via `BoxN` — no limitation.
- `Box<T>` erasure fix allows `Box<Int>` with primitives.

## BAD — utility class for transformation

```kof
class ListUtils {
    static List<Int> dobrar(List<Int> l) {
        var r = listOf<Int>()
        for (var x in l) { r.add(x * 2) }
        return r
    }
}
```

## GOOD — higher-order

```kof
var dobrados = nums.map((x: Int) -> x * 2)
```

## WHY (capture)

Capture was planned before 0.2.6-beta; today it is implemented — use lambdas with parameters, literals and captures freely.

## Related anti-patterns

- `java-like-code.md` — utility classes
- `unnecessary-abstraction.md` — factory/wrapper
- `fake-idioms.md` — check the status of higher-orders
