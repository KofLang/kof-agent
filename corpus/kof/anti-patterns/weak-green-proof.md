---
id: kof-anti-patterns-weak-green-proof-en
title: A "GREEN" that proves *no-crash* is not a proof — it must assert the SEMANTICS of the issue
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,weak-green-proof
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/weak-green-proof.md) | [Português](kof/anti-patterns/weak-green-proof.pt_BR.md)

# A "GREEN" that proves *no-crash* is not a proof — it must assert the SEMANTICS of the issue

## Problem

When triaging an issue (or writing a regression test for a fix), the cheapest
"proof" is to run the reported snippet and see that it no longer throws /
exits 0. That only disproves the **crash symptom** — it says nothing about the
**contract the issue title states**. A bug whose symptom was "X crashes" can be
"fixed" into a state where "X silently returns the WRONG value" — and a
no-crash proof calls that GREEN.

Real case in this repo (14/09, issue #207, enum values): an agent commented
"GREEN — `for (var d in Dir.values()) { println(d.name()) }` prints N S E W,
ec=0". The issue was closed. It was later REOPENED by the maintainer: the
lowering still emits every `Dir.N` as `ldc "N"` (a String constant), no
`Dir.class` is generated, `Dir.N.getClass()` returns `java.lang.String`, and
`Dir.N == "N"` is `true`. The snippet only ran fine because `.name()` over the
constant is folded at compile time — the exact face named in the issue title
(*"compiled as String constants instead of getstatic enum instances"*) was
never tested. A no-crash run is blind to a wrong-value bug.

This is the same trap as a weak `assertTrue(run(...).contains("N"))`: the
String `"N"` satisfies it even though the value was never an enum.

## Bad

```text
# "proof" of #207:
$ kof run repro.kf
N
S
E
W
-> "GREEN, works"   # only proves it doesn't crash
```

## Good

```text
# assert the SEMANTICS of the title, not the absence of the crash:
$ kof run sem.kf
class java.lang.String     # <- expected: class Dir
true                       # <- Dir.N == "N" expected: false / type error
-> "STILL BROKEN"          # the no-crash run had hidden this
```

Before declaring an issue fixed (or commenting GREEN on one), translate the
issue **title's claim** into an executable assertion:
- title says *type X becomes Y* → assert `getClass()`/kind, not just output;
- title says *wrong value* → assert the exact expected value;
- title says *never compiles but should* → assert both directions (compiles +
  behaves).

```kof
main() {
    println(Dir.N.getClass())    // must be the enum class, not String
    println(Dir.N == "N")        // must be false (or a type error)
}
```

## Why

The Q5 rule of the quality gate: *a test that passes by accident is a
disguised bug*. A no-crash run is the extreme case — it passes for every
silently-wrong implementation. Finding the bug is part of the work (Q4): the
question to answer is **"what does the title assert, and does the program do
it?"** — not "did the program die?".

## Twin trap: the stale-CLASSES false RED

The same discipline bites in the opposite direction: a harness that runs the
**installed** `kof-compiler/target/classes` measures the code of the LAST
`mvn compile` — if another agent landed a fix minutes ago, the re-measure
says "still reproduces" about a bug that is already dead. Real case (14/09,
#218): comment at ~12:40 says "AINDA REPRODUZ" — but the fix `da768386`
landed at 12:32 and the `target/classes` used were from a 12:28 build.

**Rule:** `mvn -o compile -pl kof-compiler -am` IMMEDIATELY before any
triage/re-measure, and note the build time + HEAD SHA in the proof. A triage
without that header is worthless — in both directions.
