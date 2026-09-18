---
id: kof-reference-compiler-en
title: Kof Compiler Reference
module: kof
category: kof-reference
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,reference,compiler
status: stable
tags: kof,reference,en
---
[English](kof/reference/compiler.md) | [Português](kof/reference/compiler.pt_BR.md)

# Kof Compiler Reference

**Version:** 0.4.0-beta (Sep 2026) — 2218 tests

## Compilation Pipeline

```
Source (.kf / .ks / .c)
    ↓
Lexer → Tokens
    ↓
Parser → AST (PatternExpr fieldVars, NullableType)
    ↓
Semantic Analysis → Typed AST (isAssignable with null narrowing, record destructuring)
    ↓
Kof IR (backend-agnostic) → Optimizer (constant folding, branch simplification)
    ↓
┌─────────┬──────────┬──────┬──────────┬──────┬─────────┐
│  JVM    │ Native   │ JS   │ KofScript│ KofC │ Android │
│  (ASM)  │ x86_64/  │ ES   │ JIT      │ C→ELF│ JVM→APK │
│         │ risc/arm*│      │          │      │ (Phase 1)│
└─────────┴──────────┴──────┴──────────┴──────┴─────────┘
```

* native.risc/arm placeholder

## CLI Commands

| Command | Description |
|---------|-------------|
| `kof build <dir\|file.kf> [--target jvm\|native\|native.risc\|native.arm\|js\|android] [--output <dir>] [--release] [--apk]` | Compile all .kf files |
| `kof run <file.kf\|dir> [--target jvm\|native\|native.risc\|native.arm\|js\|android] [args...]` | Compile and run (JVM/Native/JS/Android) |
| `kof serve <file.kf> [--port] [--host]` | Start HTTP server (web.app + legacy handle API) |
| `kof check <file.kf\|dir> [--target <t>]` | Type-check only (target-aware gaps) |
| `kof test <file.kf\|dir> [--target jvm\|native\|js]` | Structured tests `test "nome" { }` on the 3 targets |
| `kof script <file.ks> [--watch] [--inspect]` | KofScript top-level var/val → KofScriptGlobals + JIT |
| `kof repl` | Incremental KofScript REPL |
| `kof c <file.c> [-o outDir]` | KofC C subset → ELF x86_64 (native-only) |
| `kof fmt <file.kf\|dir>` | Formatter via the real parser (KofFormatter), idempotent |
| `kof config gen <file.kf\|dir> [--output <file>]` | Generates a `kof.config` template from the code's `config.*` keys |
| `kof bench [paths...] [--iterations N] [--quick] [--baseline <file>]` | Benchmark harness with baselines |
| `kof profile <file.kf> [--target ...]` | Execution + metrics (CPU, RSS, GC) |
| `kof inspect <file.kf> [--json]` | IR statistics (ops before/after the optimizer) |
| `kof decompile <file.class> [--output <file.kf>]` | Structural Kof skeleton from a `.class` |
| `kof translate <file.java> [--output <file.kf>]` | Java subset → Kof source |
| `kof compare <legacy.class\|jar> <file.kf> [--json]` | Differential test legacy vs Kof |
| `kof migrate <file.class\|java> [--output <file.kf>] [--json]` | Migration + traceable report |
| `kof debug <file.kf>` | DAP MVP on the JVM target |
| `kof info [--json]` | Environment report |
| `kof lsp` | Language Server (stdio, LSP 3.x) |
| `kof deps <init\|add\|remove\|list\|resolve>` | Package manager (`kofdeps`, Maven Central) |
| `kof editor <list\|detect\|status\|setup\|install\|uninstall\|update>` | Editor integration (EDI001) |
| `kof new <name>` | Project skeletons by type |
| `kof init` | Initialize a project in the current directory |
| `kof install <dir>` | Installs this build as a distribution |
| `kof version` | Show version (0.4.0-beta) |

26 commands. `kof fmt` and `kof config gen` implemented (0.4.0-beta).

Fixes 27/08:
- `CompilerImports.expandKofImports` handles `import a.b.C` (file) in addition to `a.b.*` (folder) — large projects with `a/b/C.kf` now generate both `.class` files.
- `NativeRuntime` free-list GC (`kof_free_head`, `kof_gc_collect` mark-sweep; auto-GC off) + spawn/await via pthread (31/08).

## Backend Targets

### JVM
- Uses ASM for bytecode generation
- Targets Java 21
- Uses JVM's GC and memory management
- `kof.http` via `java.net.http.HttpClient`

### Native
- Generates x86_64 Linux ELF binaries
- Uses Linux syscalls directly (no libc)
- Thread-safe free-list allocator (futex lock) + conservative `kof_gc_collect` mark-sweep; auto-GC off (automatic mark-sweep GC still pending)
- Real floating point in XMM (FLT001 closed 31/08); complete JSON for objects/arrays (JSN001/002/003 closed 31/08)
- `spawn`/`await` via pthread (CONC001 closed 31/08)
- MySQL handshake with SHA-1 scramble (WIP)
- Runtime functions: kof_alloc, kof_free, kof_gc_*, kof_print, kof_string_*, kof_array_*, kof_list_*, kof_net_*, kof_db_mysql_scramble, etc.

### Native RISC-V / ARM
- Placeholder ELF via `riscv64-linux-gnu-as/ld` + qemu, `Target.NATIVE_RISCV64/AARCH64`

### JS
- ES Modules 2022+ via GraalJS
- `kof.http` via Java HttpClient interop
- `kof.cache`, `Map/Set`, `String?`, pattern record destructuring

### KofScript
- JIT in-memory, top-level `var`/`val` → `KofScriptGlobals` (no `let`/`const` preprocess — JS sugar removed `183cb048`), evalCache 64 LRU

### KofC
- C subset (`int` globals, `void` funcs, `if`/`while`/`*(int*)`/`&`) → x86_64 via `as`/`ld`

### Android
- Phase 1: `AndroidProjectWriter` — JVM output (bytecode) + KofJS for assets → debug APK (aapt2/d8/apksigner via Maven; host Activity in Kof)
- Gaps: `AND001` spawn/await, `AND002` kof.web, `AND003` reflection, `AND004` android.jar

## IR Operations

| Operation | Description |
|-----------|-------------|
| KofLoadLiteral | Load constant value |
| KofLoadLocal | Load local variable |
| KofStoreLocal | Store local variable |
| KofLoadField | Load object field |
| KofStoreField | Store object field |
| KofBinary | Binary arithmetic |
| KofUnary | Unary operation |
| KofCall | Method/function call (incl. map/filter/reduce, http) |
| KofNewObject | Create object |
| KofNewArray | Create array |
| KofArrayLoad | Array element read |
| KofArrayStore | Array element write |
| KofArrayLength | Array length |
| KofReturn | Return value |
| KofReturnVoid | Return void |
| KofThrow | Throw exception |
| KofLabel | Label marker |
| KofJump | Unconditional jump |
| KofConditionalJump | Conditional branch (pattern + null narrowing) |
