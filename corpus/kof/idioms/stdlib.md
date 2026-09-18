---
id: kof-idioms-stdlib-en
title: Idioms — STDLIB (math / strings / encoding / uuid)
module: kof
category: kof-idioms
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,idioms,stdlib
status: stable
tags: kof,idioms,en
---
[English](kof/idioms/stdlib.md) | [Português](kof/idioms/stdlib.pt_BR.md)

# Idioms — STDLIB (math / strings / encoding / uuid)

**Status:** available · **Introduced:** 0.3.0-beta (STDLIB track, 08/09/2026) · **Updated:** 08/09/2026

## What it is

Four namespaces of pure utilities, called **without the `kof.` prefix**
(style `math.clamp(...)`, `strings.slugify(...)`, `encoding.hexEncode(...)`,
`uuid.v4()`). Same API on the targets JVM / interpreter (Script) / Native
(x86_64) / JS; cross-arch gaps are **compile-time diagnostics**, never a
silent stub (R6).

## math — Int-only (S1)

```kof
math.clamp(v, lo, hi)      // hi < lo => swap behavior NOT guaranteed: validate beforehand
math.abs(x)  math.sign(x)
math.min(a, b)  math.max(a, b)     // arithmetic; ≠ validation.min/max (size predicate)
math.isEven(x) math.isOdd(x) math.isPositive(x) math.isNegative(x) math.isZero(x)
math.sqrt(2.0)                          // Double; -1.0 => NaN (IEEE); riscv/aarch = MATH001
math.lerp(0.0, 10.0, 0.5)               // a + (b - a) * t — linear interpolation (S1b.1)
math.percentage(3.0, 4.0)               // 75.0; total == 0 => NaN (never throws) (S1b.1)
math.isInteger(4.0)                     // true; 4.5/NaN/Inf => false (S1b.1)
math.isDecimal(4.5)                     // !isInteger (S1b.1)
math.roundTo(3.14159, 2)                // 3.14 — half-away-from-zero to N decimals (S1b.3)
math.roundTo(1234.0, -2)                // 1200.0 — negative decimals: tens/hundreds (S1b.3)
```

Double: `math.sqrt(x)` (S1b) + `lerp`/`percentage`/`isInteger`/`isDecimal`
(S1b.1, 10/09 — **pure** Double scalars, without libm) + `roundTo(value, decimals)`
(S1b.3, 14/09 — half-away-from-zero by deterministic decimal scaling, no libm;
`decimals` is an `Int`, may be negative; arithmetic contract: `roundTo(2.675,2)==2.68`)
exist on JVM/Script/JS/x86; NaN at <0 = IEEE; riscv64/aarch64 = `MATH001` for
`pow` only (the rest run under qemu). The args are **explicit Doubles** —
`math.lerp(0, 10, 0.5)` (Int) **does not** compile (SEM025; no silent widening).
`pow` is implemented on x86 (libm) but `MATH001` on the cross (no libm link).

## strings — predicates and converters (S2)

```kof
strings.isAlpha("Hello")           // letters only, non-empty; "abc123" => false
strings.isNumeric("123")  strings.isAlphaNumeric("abc123")
strings.isAscii("ola")             // bytes >=128 => false (café => false on the 4 targets)
strings.isUpperCase("HELLO")       // >=1 letter and no lowercase; "123" => false
strings.isLowerCase("abc-123")     // other chars ignored
strings.count("aabaabaa", "ab")    // 2 — NON-overlapping; empty sub => 0
strings.capitalize("hello")        // "Hello" (ASCII; 1st byte a-z)
strings.uncapitalize("Hello")      // "hello" — exact mirror of capitalize (S11)
strings.reverse("abc")             // "cba" (byte-reverse on Native — see NAT-STR01)
strings.repeat("ab", 3)            // "ababab"; n<=0 => ""
strings.truncate("hello", 3)       // "hel"; n>=len => original; n<=0 => ""
strings.padLeft("7", 3, "0")       // "007" — pad is a STRING, uses the 1st char
strings.toCamelCase("hello_world") // "helloWorld"
strings.toPascalCase("hello world")// "HelloWorld"
strings.toSnakeCase("HTTPServer")  // "http_server" — boundary at uppercase+lowercase!
strings.toKebabCase("XMLParser")   // "xml-parser"
strings.slugify("Hello, World!!")  // "hello-world" (non-ASCII becomes a separator)
```

## BAD — reimplementing what the stdlib has

```kof
// ❌ Java in disguise
Bool isAlpha(String s) {
    if (s.length == 0) { return false }
    for (var i = 0; i < s.length; i++) {
        var c = s.charAt(i)
        if (!(c >= 65 && c <= 90) && !(c >= 97 && c <= 122)) { return false }
    }
    return true
}
```

## GOOD — the abstraction exists

```kof
// ✅
var ok = strings.isAlpha(s)
```

## WHY

The iron rule is "complexity belongs to the platform". The byte loop
above exists in 4 different backends inside the compiler — written once,
tested in the conformance matrix (`stdstrings`), parity locked. Reusing is
shorter, faster and cross-target by construction.

## encoding — hex / base64 / url (S4)

```kof
encoding.hexEncode("café")            // "636166c3a9" (UTF-8 by bytes, lowercase)
encoding.hexDecode("4869")            // "Hi"; invalid digit => 0; odd => last is HIGH nibble
encoding.base64Encode("Man")          // "TWFu" (with padding)
encoding.base64Decode("TWFu")         // TOLERANT: ignores invalid ones, stops at '='
encoding.base64UrlEncode(bytes...)    // alphabet -_, WITHOUT padding (JWT-style)
encoding.base64UrlDecode(s)           // accepts both alphabets + optional padding
encoding.urlEncode("a b")             // "a%20b" — space => %20, NOT '+'
encoding.urlDecode("caf%C3%A9")       // "café"; '%' without 2 digits passes literally
```

## uuid (S3b)

```kof
var id = uuid.v4()   // e.g.: "xxxxxxxx-xxxx-4xxx-[89ab]xxx-xxxxxxxxxxxx" (RFC 4122 shape)
uuid.isUuid(id)      // true — validates the SHAPE (dashes 8/13/18/23 + rest hex); does NOT check version/variant
```

Non-deterministic: validate by **shape** (`isUuid`, or by hand: dashes at 8/13/18/23,
digit 14='4', digit 19∈{8,9,a,b}), never by equality. `uuid.v7()` (time-ordered, RFC 9562)
exists on all 5 targets (digit 14='7', digit 19∈{8,9,a,b}); ulid does not exist yet.

## random (S10a/b)

```kof
// ❌ BAD — own PRNG, internet LCG
var seed = 12345
seed = (seed * 1103515245 + 12345) % 32768
```

```kof
// ✅ GOOD — platform entropy, intent face
var roll = random.randomInt(6) + 1
var pass = random.randomString(12, "abcdefghijkmnpqrstuvwxyz23456789")
var flip = random.randomBoolean()              // coin toss
var pick = colors[random.randomInt(colors.size)]   // choice = idiom
```

**WHY:** `random.*` = draw (non-cryptographic); `security.*` = tokens
(rejection + validation). List choice **is not** a stdlib function —
`list[random.randomInt(list.size)]` is the idiom; `randomChoice` would require
an Object return in the dispatch layer (DD-STDLIB-01 — CLOSED 13/09, decision
6a: `randomBytesHex` alias of `hex` + choice=idiom; `randomBytes` reserved).

## rng — determinism you can TEST (X8 slices 1–2)

```kof
// ❌ BAD — unseeded draw inside a test (passes/fails at random, unreproducible CI)
test "sum in range" {
    var a = random.randomInt(100)
    var b = rng.int(50)
}
```

```kof
// ✅ GOOD — seeded PRNG: same seed => same sequence, any backend
test "sum commutes on random pairs" {
    rng.seed(42)
    var i = 0
    while (i < 500) {
        var a = rng.int(10000) - 5000
        var c = rng.int(10000) - 5000
        assert(a + c == c + a)
        i = i + 1
    }
}
```

**WHY:** `rng.*` = REPRODUCIBLE determinism (xorshift128 + splitmix32,
32-bit-exact — same seed, same bits on JVM and JS, `KofRngTest.jvmJsParity`);
`random.*` = OS entropy (R11). A failing property test prints its seed and the
failure reproduces. Mixing the two is the anti-pattern: seeding for security
material (R11 violation) or drawing entropy from rng (flaky tests). Slice 1 =
JVM + JS + NATIVE x86_64 (asm `RuntimeRng`, same bits by construction); cross riscv64/aarch64/ANDROID = `RNG001` honest gap at compile time.

## validation — formatting is NOT validating (S12/S12b)

```kof
// ❌ BAD — scoring by hand, and throwing when the CPF has too many digits
var out = ""
for (var i = 0; i < cpf.length; i++) {
    out = out + cpf.charAt(i)
    if (i == 2 || i == 5) { out = out + "." }
}

// ✅ GOOD — the two faces, each in its place
validation.isCpf("52998224725")     // STRICT: false if check digits do not match
validation.formatCpf("529.982.247-25") // "529.982.247-25" — LENIENT: only punctuates
```

**WHY:** `formatCpf`/`formatCep`/`formatCnpj` **form, they do not validate**: they remove
existing punctuation and reapply the mask; if the number of digits does not match
(or is `null`), they return the **original input** — never throw, never truncate.
Whoever decides whether the document is *valid* is the strict face (`isCpf`/`isCnpj`/
`isCep`). Separating the two is the "represent the intent" rule: formatting
presentation is one thing, checking legitimacy is another. The same applies to
`time.isWeekend(y,m,d)` (calendar only, no clock — invalid date => `false`
because `dayOfWeek` gives 0).

## Note per target (honest gates)

| function | JVM/Script | Native x86_64 | Native riscv64/aarch64 | JS |
|---|---|---|---|---|
| math.*, strings.is*/count/capitalize/uncapitalize/reverse/repeat/truncate/pad*, encoding.hex*/url*, time.isLeapYear/daysInMonth/dayOfWeek/daysBetween/isWeekend, validation.isCpf/isCnpj/isCep/isPis/isIpv4/isIpv6/isMac/isPort/isCreditCard/isDomain/formatCpf/formatCep/formatCnpj | ✅ | ✅ | ✅ | ✅ |
| strings.toCamel/Pascal/Snake/Kebab/slugify | ✅ | ✅ | ✅ (STRN001 closed 09/09 — B15, golden diff qemu) | ✅ |
| strings.escapeHtml/escapeJson (5 entities; >=128 copy) | ✅ | ✅ | ✅ (B20, golden diff qemu) | ✅ |
| strings.removeWhitespace/normalizeWhitespace | ✅ | ✅ | ✅ (B21) | ✅ |
| encoding.base64* / base64Url* | ✅ | ✅ | ✅ (ENC002 closed 09/09) | ✅ |
| net.scheme/host/port/path/query/fragment + queryEncode/Decode | ✅ | ✅ | ✅ (NET001 closed 09/09) | ✅ |
| uuid.v4 | ✅ | ✅ | ✅ (SECN000 closed 09/09) | ✅ |
| uuid.isUuid (form 8-4-4-4-12; version/variant not checked) | ✅ | ✅ | ✅ (B25, UUID001 closed in the beta→main merge 10/09) | ✅ |
| math.sqrt (S1b — first Double; NaN at <0 = IEEE) | ✅ | ✅ | ✅ (B32 `fsqrt.d`; MATH001 closed 11/09) | ✅ |
| math.lerp/percentage/isInteger/isDecimal/roundTo (S1b.1/S1b.3 — pure SSE2, without libm) | ✅ | ✅ | ✅ (B32; MATH001 closed 11/09) | ✅ |
| math.pow (S1b.2 — libm `pow@PLT` + `-lm` on x86) | ✅ | ✅ | ❌ `MATH001` (static cross without libc) | ✅ |
| random.randomInt/randomBoolean/randomString (beta face S10a/b) | ✅ | ✅ | ✅ (B27/B28, getrandom/lemire) | ✅ |
| random.double/boolean/int/hex (main face S10) | ✅ | ✅ | ✅ (B27) | ✅ |

`strings.reverse` on non-ASCII: byte-reverse on Native vs UTF-16 on JVM/JS —
gap **NAT-STR01** (parity only locked on ASCII in the matrix).

## Limitations

- `charAt(i)` returns the **code** of the char (Int), not a char literal — that is
  why `padLeft` receives pad as a String.
- `strings.*` predicates are **ASCII**: accents => false (decision locked in the
  `stdstrings` matrix, not a bug).
- `encoding.hexDecode`/`base64Decode` are **tolerant by specification**
  (same behavior on the 4 backends); if you need to reject invalid input,
  validate beforehand (`strings.isNumeric`/`isAlphaNumeric`).
