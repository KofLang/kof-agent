---
id: kof-anti-patterns-premature-optimization-en
title: Anti-pattern — Premature Optimization
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,premature-optimization
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/premature-optimization.md) | [Português](kof/anti-patterns/premature-optimization.pt_BR.md)

# Anti-pattern — Premature Optimization

## Name

Optimizing before measuring, trading simplicity for micro-performance.

## Problem

Implementing manual arrays, manual caching, complex data structures or
low-level tricks — when the program does not even work properly yet.

## Bad example

```kof
// BAD: micro-optimization without need
var buffer = new Char[1024]
var len = 0
for (var i = 0; i < input.length; i = i + 1) {
    buffer[len] = input.charAt(i)
    len = len + 1
}
var result = ...
```

## Good example

```kof
var result = ""
for (var i = 0; i < input.length; i = i + 1) {
    result += input.charAt(i)
}
```

Or, when the semantics allow it:

```kof
var result = input
```

## Why it is bad

The real cost is rarely where the programmer guesses. The simple version is
more readable, more correct and easier to evolve. The optimized version is only
justifiable with measurement.

## Rule

1. Write the idiomatic version.
2. Measure (if there is a performance requirement).
3. Optimize only the measured point, with a comment explaining why.

## Known real performance (measured 02 Sep 2026)

- Native: free-list `kof_free_head` first-fit thread-safe (futex lock) + `kof_gc_collect` conservative mark-sweep (27/08). Auto-GC off — memory is only returned in the `munmap` fallback; automatic mark-sweep GC pending. `kof_free` push without a syscall. GC is not complete yet — very long programs should avoid leaking.
- Native strings: UTF-8 bytes; concatenation allocates a new string.
- JVM: ArrayList, String, GC, virtual threads.
- JS: GraalJS ES Modules; `kof.http` via Java HttpClient interop.

## Exceptions

- Algorithms whose complexity is part of the domain (e.g.: sorting, indexed search).
