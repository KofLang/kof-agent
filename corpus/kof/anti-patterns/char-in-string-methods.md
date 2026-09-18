---
id: kof-anti-patterns-char-in-string-methods-en
title: char literal in a String method with a String formal (bugs 99/100)
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,char-in-string-methods
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/char-in-string-methods.md) | [Português](kof/anti-patterns/char-in-string-methods.pt_BR.md)

# char literal in a String method with a String formal (bugs 99/100)

**Name:** char literal (or Int) as an argument of a `String` method that expects
String.

**Problem:** Kof's char literal **is** `Int` (there is no separate char
type). String methods such as `indexOf`/`contains`/`lastIndexOf`/
`startsWith`/`endsWith` expect a **String** in the 1st argument — the registry
resolves by arity, so `'c'` slipped through and each backend broke in a
different way (JVM `VerifyError`, Native SIGSEGV, JS silent `-1`, interpreter
`ClassCastException`). It is now a compilation error. The rejection was
generalized (any non-String — Int/Long/Double/collection — in a String
formal, in the methods `indexOf`/`lastIndexOf`/`contains`/`startsWith`/
`endsWith`/`split`/`concat`/`equalsIgnoreCase`/`compareTo`/
`compareToIgnoreCase`) under the dedicated code **SEM051**.

**Bad (does not compile — SEM051):**
```kof
var s = "abc"
s.indexOf('c')      // ❌ SEM051: "String.indexOf does not accept Char as argument 1"
s.contains('b')     // ❌ same
s.lastIndexOf('c')  // ❌
s.startsWith('a')   // ❌
s.endsWith('c')     // ❌
var n = 42
s.indexOf(n)        // ❌ Int too (the type matters, not the form)
```

**Preferred:**
```kof
var s = "abc"
s.indexOf("c")      // ✅ 1
s.contains("b")     // ✅ true
s.lastIndexOf("c")  // ✅ 2
s.startsWith("a")   // ✅ true
s.endsWith("c")     // ✅ true
```

**Why:** the idiom is unambiguous — the documented API (`type-system.md`) uses String;
the char overload of `java.lang.String` is not part of Kof's surface. Rejecting at
compile time (R6 — never the "compiles and breaks") instead of silently
converting Int→String: defining the semantics (byte? code unit? code point?) of a Kof
char in a String formal would be a contract change — the maintainer's decision.

**Exception (still valid):** `replace(char, char)` — the registry types the 2
formals as `CHAR` when the args are char, and the idiom `s.replace('a', 'b')`
is accepted on all backends.
