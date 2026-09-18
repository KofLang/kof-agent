---
id: kof-language-overview-en
title: Kof Overview
module: kof
category: kof-language
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,language,overview
status: stable
tags: kof,language,en
---
[English](kof/language/overview.md) | [Português](kof/language/overview.pt_BR.md)

# Kof Overview

Kof is a compiled, statically-typed, object-oriented programming language targeting JVM, Native (x86_64, riscv64, aarch64) and KofJS (ES Modules), plus Android (Phase 1, APK via JVM backend), KofScript and KofC.

**Version:** 0.4.0-beta (Sep 2026) — 2218 tests (1911 kof-compiler + 38 kof-script + 7 kof-c-compiler + 262 kof-cli, 0 failures).

## Key Characteristics

- **Compiled** — the compiler emits JVM bytecode (via ASM), a native ELF binary (x86_64/riscv64/aarch64), or ES Modules; there is no interpreter
- **Statically typed** — type errors caught at compile time; null safety `String?` + narrowing `if (x != null)` since 0.2.6-beta
- **Multi-target** — same code runs on JVM, Native, JS, Native.risc, Native.arm, plus KofScript (JIT in-memory) and KofC (C subset → native)
- **Intent-oriented** — not a formal paradigm, but object orientation taken to
  its extreme: code expresses *what* should happen; the platform (language +
  compiler + runtime + stdlib) decides *how*, per target. The chain is
  `intent → Kof → compiler → backend`. Mechanisms never leak into user code:
  `spawn f()` (not Thread), `app.get(...)` (not a servlet container),
  `Window`/`Button("+1", () -> ...)` (not WebView), `json.decode<User>(body)`
  (not a manual parser),   `Palette.red` (not hex). Gaps are reported at
  compile time with codes (`HTTP002`, `DB001`, `SCHED001`) — never silently.
  See `docs/philosophy.md`.
- **Minimal boilerplate** — intent over ceremony (records, primary constructors, top-level functions)
- **Memory managed** — free-list (thread-safe, futex) + conservative `kof_gc_collect` mark-sweep (Native, 27/08); auto-GC off — automatic mark-sweep GC pending
- **No `fun` keyword** — functions are declared by name (`main()`, `String f()`, `f(): String`)

## Compilation Pipeline

```
Source (.kf / .ks / .c)
    ↓
Lexer → Tokens
    ↓
Parser → AST (PatternExpr, NullableType)
    ↓
Semantic Analysis → Typed AST (isAssignable with Nullable, record destructuring)
    ↓
Kof IR (backend-agnostic, KofOperation)
    ↓
┌─────────┬──────────┬──────┬─────────┬────────┐
│  JVM    │ Native   │ JS   │ KofScript│ KofC  │
│  (ASM)  │ x86_64   │ ES   │ JIT      │ C→ELF │
│         │ riscv64* │      │ var/top  │       │
│         │ aarch64* │      │ level    │       │
└─────────┴──────────┴──────┴─────────┴────────┘
 * real riscv64 (02/09, pure asm, qemu); aarch64 placeholder
```

## Current Features (0.4.0-beta)

| Feature | JVM | Native | JS | Notes |
|---------|-----|--------|----|-------|
| Classes, records, interfaces, inheritance, virtual dispatch | ✅ | ✅ | ✅ | super = SUP001 on Native |
| Constructors (`constructor(...)`, primary `class X(...)`) | ✅ | ✅ | ✅ | since 0.0.5 |
| Functions (all forms, no `fun`, expression body) | ✅ | ✅ | ✅ | |
| Enums (`enum Color { Red }` + values/valueOf/name + exhaustive switch SEM031) | ✅ | ✅ | ✅ | 3 targets |
| Lambdas with mutable capture (Box0) | ✅ | ✅ | ✅ | since 0.2.6-beta |
| If-expressions `var x = if (c) a else b` | ✅ | ✅ | ✅ | |
| `List<T>` + `listOf` + `map/filter/reduce` | ✅ | ✅ | ✅ | higher-order 27/08 |
| `Map<K,V>` + `mapOf` (put/get/remove/contains/size/keys/values/clear/isEmpty) | ✅ | ✅ | ✅ | since 0.1.0 |
| `Set<T>` + `setOf` (add/contains/remove/size/clear/isEmpty) | ✅ | ✅ | ✅ | since 0.1.0 |
| `Box<T>` generics with primitive `T` | ✅ | ✅ | ✅ | fix substituteTypeVariable 25/08 |
| Null safety `String?` / `Int?` + narrowing `if (x != null)` | ✅ | ✅ | ✅ | since 0.2.6-beta |
| Pattern matching `case String s` + `instanceof`/`as` | ✅ | ✅ | ✅ | since 0.2.6-beta |
| Record destructuring `case Point(x, y)` | ✅ | ✅ | ✅ | Parser fieldVars |
| Concurrency: `spawn` / `Handle<T>` / `await` | ✅ | ✅ (pthread, 31/08) | ✅ (event-loop) | CONC001 closed; JS CONC003 closed 03/09 |
| Strings (`+`, `==`, indexOf, trim, split, ...) | ✅ | ✅ | ✅ | |
| Arrays (`new Int[n]`, `arr[i]`, `.length`) | ✅ | ✅ | ✅ | |
| Exceptions `throw "msg"` / try/catch/finally | ✅ | ✅ | ✅ | Native unwinding |
| Generics (erasure) | ✅ | ✅ | ✅ | |
| JSON `json.encode` / `json.decode<T>` (objects/records/arrays, FP) | ✅ | ✅ | ✅ | JSN001/002/003 closed 31/08 |
| kof.io: `readFile`, `writeFile`, `readLine`, `File/Path/Directory` | ✅ | ✅ | ✅ | |
| kof.time: `now()` / `sleep()` | ✅ | ✅ | ✅ | |
| kof.http: `http.get/post/put/delete/patch/options/status` + `timeout/retry/circuit` | ✅ | HTTP002 | ✅ | JS via Java HttpClient 27/08; retry/circuit 30/08 |
| kof.cache: `cache.get/set/set_ttl/ttl/delete/clear` | ✅ | ✅ | ✅ | ConcurrentHashMap/Js Map |
| switch, instanceof, `as` | ✅ | ✅ | ✅ | |
| Web server (`web.app()` routes/middleware/`status`/`headerSet` + `listenSecure` TLS + `app.ws` + `app.sse`) | ✅ | base ✅ 03/09; TLS `WEB002`, ws `WEB004`, sse `WEB003` | ✅ base 16/09 | ws/sse 30/08; JS base (`web.app`/routes/context-fns) 16/09, `app.ws`/`app.sse` = WEB004/WEB003 compile-time |
| kof.validation (13 predicates) | ✅ | ✅ | ✅ | |
| kof.security (passwords/crypto/jwt/secrets/auth + rateLimit/sessions/apiKeys) | ✅ | ✅ | ✅ | |
| kof.observability (health/readiness/liveness/counter/increment/gauge/requestId) | ✅ | ✅ | ✅ | |
| kof.db + native SQLite + MySQL handshake | ✅ | ✅ (MySQL auth scramble SHA-1 done) | ✅ 16/09 | JS via GraalJS bridge (DB001 closed); typed `query<T>` = DB002 |
| KofScript top-level `var`/`val` + repl --watch --inspect | ✅ | ✅ | ✅ | KofScriptGlobals |
| KofC C subset → ELF x86_64 | — | ✅ | — | native-only |

## Planned / Unavailable (0.4.0-beta)

| Feature | Status |
|---------|--------|
| Generic `Option<T>` | Planned — use `String?` |
| `Array literals {1, 2, 3}` | Unavailable — use `new Int[n]` / `listOf` |
| Full MySQL query/prepared on Native | In progress (handshake done 27/08) |
| Real RISC-V/ARM codegen | Placeholder (target separation done, as/ld+qemu) |
| ~~Scheduler `every`/`at` on Native~~ | ✅ `SCHED001` closed 31/08 (JVM/JS/Native — 3 targets) |
| Automatic GC mark-sweep on Native | Pending (manual free-list + `kof_gc_collect`; auto-GC off) |
| HTTP/2 in `kof.http` | Planned (HTTP002 on Native) |
| Web stack tail on Native/JS (`web.app`) | base ✅ (Native 03/09, JS 16/09); residual per feature: TLS `WEB002`, ws `WEB004`, sse `WEB003` (JVM ✅) |

## What Kof Is NOT

- Java with different syntax
- A transpiler to Java
- A Spring clone
- A framework
- An interpreter
- A VM
