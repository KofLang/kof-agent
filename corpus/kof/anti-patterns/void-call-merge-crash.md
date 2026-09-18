---
id: kof-anti-patterns-void-call-merge-crash-en
title: Anti-pattern — Builtin void call in a statement before merge (historical)
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,void-call-merge-crash
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/void-call-merge-crash.md) | [Português](kof/anti-patterns/void-call-merge-crash.pt_BR.md)

# Anti-pattern — Builtin void call in a statement before merge (historical)

## Name

Frame crash COMP002 with `list.add(...)` as a statement followed by `while` —
and why it is NO longer a problem.

## Problem (≤ 31/08, pre-0.3)

```kof
f(List<Box> cache, Int n): Int {
    cache.add(Box(7))     // builtin void call as a statement
    var i = 0
    var tot = 0
    while (i < n) {       // frame merge here
        var ent = cache.get(i)
        tot = tot + ent.a
        i = i + 1
    }
    return tot
}
```

It emitted bytecode with stack underflow (the `kof_list_add` already discarded the
boolean `add` returns, and the IR's `KofPop` popped it again) → the ASM broke
at the loop's frame merge with `Index -1 out of bounds for length 0`
(frame crash COMP002) **only when there was a merge (while/if) afterwards**.

## Typical symptom

- `kof check` ok in linear code (no loop/if after the call).
- Internal crash in the compiler when the builtin void call precedes a
  merge point (while/for/if).
- Message: `frame crash in Default.Main.f: Index -1 out of bounds ... [COMP002]`.

## Resolution (01/09)

The `JvmBackend.emitOperation` of `kof_list_add` no longer emits the extra `POP`:
the `ArrayList.add` pushes `boolean` and the IR's `KofPop` (generated in the
statement conversion) discards it — exactly 1 push + 1 pop.

## Preferred (today)

```kof
cache.add(item)    // ✅ write normally; the bug is fixed
```

If a COMP002 error "Index -1/-3" reappears in a new builtin void call feature,
reproduce with the call-statement + while pair and fix the emit
(balanced push/pop per operation), never work around it in the Kof code.

## Why

An emit bug (unbalanced push/pop) only blows up in the presence of a merge
because the ASM frame verifier (`COMPUTE_FRAMES`) unifies stack states at
labels; in linear code the imbalance can go unnoticed.

## Related

- `runtime-workarounds.md` §9 — fixes 01/09
- `common-mistakes.md`
