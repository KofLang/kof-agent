---
id: kof-language-arrays-en
title: Kof Array Reference
module: kof
category: kof-language
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,language,arrays
status: stable
tags: kof,language,en
---
[English](kof/language/arrays.md) | [Português](kof/language/arrays.pt_BR.md)

# Kof Array Reference

**Version:** 0.4.0-beta (Sep 2026)

## Creation

```kof
var arr = new Int[10]      // array of 10 integers
var strings = new String[5] // array of 5 strings
var empty = new Int[0]      // empty array
var bigs = new Long[10]    // ✅ real Long[] (since 0.2.6-beta, 01/09)
var rows = new Long[n * k] // size by expression ok
```

## Access

```kof
var arr = new Int[5]
arr[0] = 10    // set element
println(arr[0]) // get element
```

## Length

```kof
var arr = new Int[5]
println(arr.length)  // 5
```

## Long[] (64-bit elements)

```kof
var acc = new Long[256]
acc[0] = 3000000000          // ✅ above Int.MAX — ok
var s = acc[0] + acc[0]      // ✅ 6000000000 (Long)
```

- `Long[]` is `long[]` on the JVM, `long[]` on Native, `BigInt-like`/Number on JS.
- Store into `Long[]` promotes Int to Long automatically.
- Arithmetic: `Long×Long→Long`, `Long+Int→Long`; `Int×Int→Int` (silent overflow).
- For accumulators of large products (matmul, checksum, fixed-point),
  declare `var acc: Long = 0` — not `Int`.

## Bounds Checking

Runtime checks bounds on access. Out-of-bounds access triggers `kof_bounds_error`.

## Multi-dimensional

```kof
var matrix = new Int[3]
// Each element can be an array
```

## Array as Parameter

```kof
sum(Int[] arr): Int {
    var total = 0
    for (var i = 0; i < arr.length; i++) {
        total = total + arr[i]
    }
    return total
}
```

## Array as Return

```kof
createArray(): Int[] {
    var a = new Int[3]
    a[0] = 10
    a[1] = 20
    a[2] = 30
    return a
}
```

## Empty Array

```kof
var empty = new Int[0]
println(empty.length)  // 0
```
