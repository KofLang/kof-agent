---
id: kof-anti-patterns-common-mistakes-en
title: Kof Common Mistakes
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,common-mistakes
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/common-mistakes.md) | [Português](kof/anti-patterns/common-mistakes.pt_BR.md)

# Kof Common Mistakes

## 1. Using Java-style getters/setters

```kof
// WRONG
class User {
    private String name
    public getName(): String { return name }
}

// RIGHT
class User {
    String name  // accessible directly
}
```

## 2. String.valueOf(Int) thinking it gives the character

```kof
// WRONG — returns DIGITS: "104"
var s = String.valueOf(104)

// RIGHT — the character: "h"
var c = String.valueOf(104 as Char)
```

## 3. Manual memory management

```kof
// WRONG — Kof manages memory automatically
var ptr = alloc(100)
free(ptr)

// RIGHT
var data = new Int[100]
// memory reclaimed automatically
```

## 4. Backend-specific code

```kof
// WRONG — breaks multi-target
if (target == "native") {
    nativeCode()
}

// RIGHT — same code for all targets
var result = compute()
println(result)
```

## 5. Over-engineering

```kof
// WRONG
class ServiceFactory {
    create(): Service {
        return new Service()
    }
}

// RIGHT
var service = new Service()
```

## 6. Ignoring error handling

```kof
// WRONG — unsafe
var data = riskyOperation()

// RIGHT — safe
try {
    var data = riskyOperation()
} catch (String e) {
    println("Error: " + e)
}
```

## 7. Using Object as universal type

```kof
// WRONG
var x: Object = "hello"

// RIGHT
var x: String = "hello"
```

## 8. Unnecessary annotations

Annotations exist in Kof for **interoperability** (JVM frameworks, Android). For features of the platform itself, use the idiomatic APIs — annotation+container is leaking mechanism into intent.

```kof
// WRONG — HTTP routing is language intent, not annotation
@RestController
class UserController {
    // ...
}

// RIGHT
main() {
    var app = web.app()
    app.get("/users") { ... }
}

// RIGHT — annotation as interop metadata (the external framework requires it)
@Service
class UserService {
    // ...
}
```

## 9. Manual string building

```kof
// WRONG
var result = ""
for (var i = 0; i < items.length; i++) {
    result = result + items[i] + ", "
}

// RIGHT — use concatenation
var result = "Items: " + items.length
```

## 10. Manual List.get handling (fix 27/08 — removed)

```kof
// WRONG (historical workaround) — manual bounds check before get
if (i >= 0 && i < l.size) { var x = l.get(i) }

// RIGHT (0.4.0-beta) — kof_list_get already does the bounds check with a clear message
var x = l.get(1)   // or l[1]
var y = listOf(1,2,3).get(1) // 2
```

## 11. Manual import workarounds (fix 27/08 — removed)

```kof
// WRONG — copying file C.kf to the root folder to avoid import a.b.C failing
// RIGHT (0.4.0-beta) — CompilerImports expandKofImports file-specific
import a.b.C
import a.b.*
```

## 12. Ignoring null safety (0.4.0-beta)

```kof
// WRONG — sentinel for absence
String find(String key) { return "" }

// RIGHT — String? with narrowing
String? find(String key) { if (found) return value; return null }
var r = find("x")
if (r != null) { println(r) }
```

## 13. Manual loop when higher-order exists (0.4.0-beta)

```kof
// WRONG
var nomes = listOf()
for (var u in users) { nomes.add(u.name) }

// RIGHT
var nomes = users.map((u: User) -> u.name)
```

---

## (02 Sep 2026) koflama discoveries — real JVM emit gotchas

Discoveries validated with the 100% Kof TinyLlama forward
(kof-agent M34). All fixed in the compiler; they stay here as a
cause → effect lesson.

### 1. `new String[0]` emitted NEWARRAY T_BYTE (VerifyError)

```kof
return KofLmTokVocab(new String[0], new Long[0])   // ✅ now ANEWARRAY
```

**Cause:** `JvmLiteralEmitter.arrayTypeForType` only covered primitives and
fell through to the `T_BYTE` default for reference types. The bytecode
passed `check` but the JVM rejected it at Verify (frame `[B`
vs `[Ljava/lang/String;`). The on-screen error was misleading: the
JVM launcher reports "JavaFX runtime components not
found" when `main` fails at validate — always run
`java -Xdiag -cp . Default.Main` to see the real VerifyError.

### 2. `Map<String, Int>` param emitted `Lkof/Map;` (NoClassDefFoundError)

**Cause:** `kof.jar` embedded the old `JvmTypeMapper` class
(shade did not reprocess after the partial `mvn -pl ... -am`).
`classDescriptor` already mapped `kof.Map → java/util/HashMap`, but
the outdated jar masked the fix. **Lesson:** full rebuild
(`mvn clean package` at the root) before blaming the Kof code; the
classpath of `kof run` is only the tempDir — any referenced class
that is not there becomes a NoClassDefFoundError *in the launcher*
(detail: the stack shows `validateMainMethod`, not the call site).

### 3. `Map.get` with unboxing NPE at the assignment

```kof
var r = idx.get(sub)          // r is Int → immediate unboxing → NPE if absent
if (r != null) { ... }        // too late
```

**Correct idiom:**

```kof
if (idx.contains(sub)) {
    var r = idx.get(sub)
    if (r != null) { ... }
}
```

The compiler emits `intValue()` right at the assignment when the
variable is `Int`; the `!= null` afterwards does not save it. A guard with
`contains` is the stable form today (0.4.0-beta).

### 4. Sum of Int silently overflows in wide accumulators

SPM scores reach `-29613` (×1e6 micro = `-3e10`, outside Int).
`dp[i] + scores[vi]` in `Int[]` wrapped around and Viterbi
chose absurd paths (token "e" with a phantom positive score).

**Rule:** accumulators that add micro values (×1e6) always in
`Long[]`, with `Long` sentinels (`-2e12`, not `-2e9`).

### 5. UTF-8: `String.valueOf(byte as Char)` is latin-1, not UTF-8

The SPM vocab has `▁` (U+2581, bytes `E2 96 81`). Reading byte by byte
with `as Char` produced `â` + garbage and the vocab match failed
silently (`contains` → false). Manual UTF-8 decode (2/3/4
bytes → codepoint) before `as Char`. The same principle applies to
any byte coming from File I/O that becomes text.
