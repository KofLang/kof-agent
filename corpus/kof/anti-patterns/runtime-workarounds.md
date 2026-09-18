---
id: kof-anti-patterns-runtime-workarounds-en
title: Anti-pattern — Runtime Workarounds
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,runtime-workarounds
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/runtime-workarounds.md) | [Português](kof/anti-patterns/runtime-workarounds.pt_BR.md)

# Anti-pattern — Runtime Workarounds

## Name

Treating temporary workarounds as language rules.

## Problem

When a feature does not exist yet, the code needs a detour.
The detour is legitimate — but it is **not an idiom**. The corpus must mark it
explicitly `WORKAROUND` and `NOT IDIOMATIC`.

## Current workarounds (0.2.6-beta history; current boundary in fake-idioms.md)

### 1. Partial null safety

```kof
// ✅ String? / Int? implemented with narrowing
String? s = mapOf("k", "x").get("k")   // NOTE since 10/09: `= null` literal is SEM048 —
                                        // null reaches T? via API only
if (s != null) {
    println(s.length)   // OK — narrowing via isAssignable
}
// generic Option<T> is still planned — use String? for simple nullability
// WORKAROUND until Option<T>: exception or record Found(Bool ok, T value)
```

**Do not learn Option<T> as an idiom — use String?.**

### 2. JSON — RESOLVED (31/08)

```kof
// ✅ JSN001/JSN002/JSN003 closed 31/08: json.encode/json.decode<T> of
// objects/records and arrays (Int/Long/Bool/String/Double) works on the
// 3 targets — compile-time composition in Native, real FP in XMM.
var j = json.encode(Point(3, 4))
var d = json.decode<Point>(j)
var l = json.decode<Int[]>("[1,2,3]")
```

Do not use the JSON workaround anymore (not encoding an object in Native, swapping
Double for Int) — the feature is closed.

### 3. Constructor with arguments — RESOLVED (0.4.0-beta)

```kof
// ✅ Primary constructor is the idiomatic form since 0.0.5
class User(String name, Int age) { }
var u = User("Mel", 30)   // without new also OK
// Verbose form still valid but not idiomatic
```

Do not use `// WORKAROUND` for the constructor — it is a stable feature.

### 4. Capture in lambdas — RESOLVED (0.4.0-beta)

```kof
var offset = 10
var f = (x: Int) -> x + offset   // ✅ OK — mutable capture via synthetic box BoxN
println(f(5))   // 15
```

Do not mark capture as a workaround — it is implemented.

### 5. Imports in a large project — RESOLVED (27/08)

```kof
// ✅ CompilerImports expandKofImports now handles import a.b.C (file) + a.b (folder)
// Project largeproj with a/b/C.kf → correct Main.class + a/b/C.class
import a.b.C
import a.b.*
```

A manual import workaround is not necessary.

### 6. List.get / listOf — RESOLVED (27/08)

```kof
var l = listOf(1, 2, 3)
var x = l.get(1)   // 2 — kof_list_get with bounds, no manual handling
```

Do not implement a manual bounds check — the stdlib already does it.

### 7. Threads in Native — RESOLVED (31/08)

```kof
// ✅ CONC001 closed 31/08: native spawn/await via pthread
spawn work()
val r = spawn compute()
var v = await r
// Native FP (FLT001) also closed 31/08: real float/double in XMM
var d = 1.5 * 2.0
```

Do not mark spawn/await in Native or FP as WORKAROUND — it is implemented.

### 8. Native GC — in progress

```kof
// Native uses free-list first-fit thread-safe (futex lock) + kof_gc_collect
// (conservative mark-sweep). Auto-GC is off (27/08): memory is only
// returned in the munmap fallback — automatic mark-sweep GC still pending.
// It is not yet a complete production GC — long programs should avoid leaking
```

### 9. Fixes of 01/09 (compiler bugs closed)

```kof
// ✅ Frame crash COMP002 with List.add in statement + while — RESOLVED 01/09
// (the kof_list_add emit popped the boolean 2×; now the IR's KofPop handles it)
var c = listOf<Box>()
c.add(Box(7))
var i = 0
while (i < n) {
    var ent = c.get(i)   // ✅ compiles and runs (it was a frame crash before)
    i = i + 1
}

// ✅ Builtin-type static receiver — RESOLVED 01/09
var s = String.valueOf(42)      // "42" (invokestatic String.valueOf)
var i2 = Integer.valueOf("17")  // same for Integer/Long/Double/…

// ✅ Real primitive casts — RESOLVED 01/09
var ch = 104 as Char            // real I2C (it was checkcast "?" → VerifyError)
var trunc = longVal as Int      // real L2I (narrowing Long→Int)
```

Do not re-apply workarounds for these cases (e.g.: avoiding `List.add` before
`while`, or concatenating digits manually instead of `String.valueOf`).

## Rule

1. Every workaround in the corpus carries the `WORKAROUND` label.
2. Every workaround cites the planned feature that will replace it.
3. Never present a workaround as an example of "idiomatic code".

## When a workaround stops being a workaround

When the feature is implemented, the official example is updated and the label
removed. The conceptual history is preserved in the CHANGELOG, not in the corpus.
In 0.2.6-beta the following were removed: lambda capture, imports a.b.C, List.get, primary constructor,
native JSON (JSN001/002/003, 31/08), threads in Native (CONC001, 31/08) and native FP (FLT001, 31/08).

## Exceptions

- None: workarounds are always temporary by definition.
