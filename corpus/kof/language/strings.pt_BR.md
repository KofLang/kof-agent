---
id: kof-language-strings-pt
title: Kof String Reference
module: kof
category: kof-language
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,language,strings
status: stable
tags: kof,language,pt
---
[English](kof/language/strings.md) | [Português](kof/language/strings.pt_BR.md)

# Kof String Reference

**Version:** 0.4.0-beta (Sep 2026)

## Creation

```kof
var s = "Hello"           // string literal
var s = ""                // empty string
```

## Operations

### Length
```kof
var s = "Hello"
println(s.length)  // 5
```

### Character Access
```kof
var s = "Hello"
println(s.charAt(0))       // H (o caractere)
println(s.charAt(0) as Int) // 72 (o code point, explícito)
```

### Substring
```kof
var s = "Hello"
println(s.substring(1, 4))  // "ell"
```

### Concatenation
```kof
var a = "Hello"
var b = " World"
println(a + b)  // "Hello World"
```

### Contains
```kof
var s = "Hello World"
println(s.contains("World"))  // true
println(s.contains("xyz"))    // false
```

### Starts With / Ends With
```kof
var s = "Hello"
println(s.startsWith("He"))  // true
println(s.endsWith("llo"))    // true
```

### Equality
```kof
var a = "Hello"
var b = "Hello"
println(a == b)  // true (byte-level comparison)
```

## Immutability

Strings are immutable. Operations like `concat` create new strings.

## Null safety (0.4.0-beta)

```kof
String? s = mapOf("k", "x").get("k")   // null via API (sem `= null` — SEM048 desde 10/09)
if (s != null) {
    println(s.length)   // OK — narrowing
}
```

## Encoding and length — per target

- **Native**: strings are UTF-8; `length` returns the **byte count**.
- **JVM**: strings are UTF-16 (`java.lang.String`); `length` returns code units.

```kof
println("Olá".length)  // Native: 4 (UTF-8 bytes); JVM: 3 (UTF-16 units)
```

Do not assume a specific character count when the string contains non-ASCII
characters and the target matters.
