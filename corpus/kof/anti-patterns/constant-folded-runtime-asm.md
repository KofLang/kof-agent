---
id: kof-anti-patterns-constant-folded-runtime-asm-en
title: Runtime constant: literal concatenation of `static final String` is FOLDED at the call-site
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,constant-folded-runtime-asm
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/constant-folded-runtime-asm.md) | [Português](kof/anti-patterns/constant-folded-runtime-asm.pt_BR.md)

# Runtime constant: literal concatenation of `static final String` is FOLDED at the call-site

## Problem

A `static final String` initialized with **concatenation of String
literals** (JLS 15.28 constants) is treated by javac as a **constant variable**:
the final value is embedded in the *constant pool* of **every class that
references it** at compile time. When the value changes (you edit one of the
pieces), only whoever recompiles sees the new value — the rest of the build
carries the **old value in-line**, and an incremental `mvn compile -o` does not
recompile whoever did not change.

Classic result in this repo (12/09, the day of the GC cross G-0): the GC lane edits
`NativeRiscvAsmRt0.RISCV_RUNTIME_ASM_0` (new 32B block header in
`kof_alloc`), recompiles incrementally, runs the suite →
`NativeRiscvRuntimeSliceRegistryTest` fails with
"reflexive concatenation in the derived order must be byte-identical to the
production runtime". **FALSE split-brain**: `RiscvSlices` reads the pieces by
*reflection* (fresh value) while the test's LHS reads
`NativeRiscvAsm.RISCV_RUNTIME_ASM` (getstatic on a `.class` with bytes **folded
in the previous compilation**). The test was right; the build was the lottery.

## Bad

```java
// NativoRuntime.java
static final String RUNTIME_ASM =
        Part0.RUNTIME_ASM_0 + Part1.RUNTIME_ASM_1;   // ❌ constant variable
```

Whoever uses it (`RuntimeArchEmitter`, tests, `RiscvSlices`) embeds the bytes in
its own `.class`. Editing `Part0.java` + incremental `mvn -o compile` →
new `Part0.class`, **old** emitter/test, and no error until the suite
flags divergence. (The `RISCV_RUNTIME_ASM_B` already had the same remedy in the
repo — "constant string too long" forced StringBuilder — but the 64KB
justification **hid** the structural reason, and the 3 sister constants
remained foldable.)

## Preferred

```java
// NativoRuntime.java — same bytes, resolved in <clinit> on every JVM
static final String RUNTIME_ASM = runtimeAsm();
private static String runtimeAsm() {
    return new StringBuilder()
            .append(Part0.RUNTIME_ASM_0)
            .append(Part1.RUNTIME_ASM_1)
            .toString();
}
```

`StringBuilder.append` is not a constant expression → the field **stops being**
a constant variable → the value is computed in `<clinit>` on the test JVM; every
read (`getstatic`) sees the value **of the current build**.

## Why

- The problem is **distribution of the value across .class files**, not the
  value. Literal concatenation moves bytes into N constant pools; a
  method/`<clinit>` keeps the bytes only in the pieces' `.class` files.
- A `static final String` derived from `String.format`, `+` of variables, or
  a method is **no longer** constant — the pattern applies only to pure
  concatenation of literals/constants, which is exactly the format of this
  sliced runtime.
- `RiscvSlices` (and any oracle that derives the order of the pieces **from the
  aggregator source** via regex) keeps working: it only needs the **order and
  names** `NativeRiscvAsmXxx.CONST` in the source — method calls
  (`runtimeRt()` with `.append(...)` on the following lines) preserve both.

## Checklist

- [ ] Is the constant **pure concatenated literal**? → method-`<clinit>`.
- [ ] Is there an oracle comparing by reflection/parse (fresh) vs `getstatic`
      (folded)? → **all** the aggregator's constants need the pattern,
      never only the one that hit the 64KB error.
- [ ] When reporting "production diverges from the piece": **recompile full first**
      (clean `mvn test-compile`) before blaming the author of someone else's commit.
