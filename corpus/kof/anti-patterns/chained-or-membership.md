---
id: kof-anti-patterns-chained-or-membership-en
title: Anti-pattern — Chained-OR Membership (chain of `==`/`||`)
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,chained-or-membership
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/chained-or-membership.md) | [Português](kof/anti-patterns/chained-or-membership.pt_BR.md)

# Anti-pattern — Chained-OR Membership (chain of `==`/`||`)

## Name

Testing membership in a set of values with a chain of comparisons
(`x == "A" || x == "B" || x == "C" ...`) instead of a set.

## Problem

Extensive chains of `||` to check whether a value belongs to a group. It is the
most visible anti-idiom of "Java translated to Kof": unreadable, verbose,
easy to forget/duplicate an entry, hidden intent, scales poorly.

> Kof should let the code say **what** is being done (membership in
> a set), not **how** the programmer implemented the search. If someone
> writes 50 `||` in a row in Kof, the answer is not "write better" — it is
> "why did Kof let that through?".

## Bad example (NEVER)

```kof
Bool isQueryOperation(String operation) {
    return operation == "GetSession"
        || operation == "GetAccess"
        || operation == "GetDashboard"
        || operation == "GetToday"
        || operation == "GetTodayBoard"
        || operation == "ListIntakes"
        || operation == "GetIntake"
        || operation == "ListCompanies"
        || operation == "GetCompany"
        || operation == "ListCompanyMembers"
}
```

## Preferred approach (IDIOMATIC — verified on the 3 targets)

`Set<T>` + variadic `setOf(...)` + `.contains(...)`:

```kof
Bool isQueryOperation(String operation) {
    val known = setOf(
        "GetSession",
        "GetAccess",
        "GetDashboard",
        "GetToday",
        "GetTodayBoard",
        "ListIntakes",
        "GetIntake",
        "ListCompanies",
        "GetCompany",
        "ListCompanyMembers"
    )
    return known.contains(operation)
}
```

When the set is reused, extract it into a function that returns it **or**
declare it as a class field — `Set<T>` as a declared type (field, function
return or parameter) works on the 3 targets since 0.2.6-beta (09/02, the JVM
descriptor of `kof.Set` was mapped to `java/util/HashSet`):

```kof
Set<String> knownOperations() {
    return setOf("GetSession", "GetAccess", "GetDashboard", "GetToday")
}

Bool isQueryOperation(String operation) {
    return knownOperations().contains(operation)
}
```

> **History (closed 09/02):** local `setOf(...)` always worked on the 3
> targets; but `Set<T>` as a **declared type** (class field or function
> return) failed on the **JVM** at runtime (`NoClassDefFoundError: kof/Set` —
> the `Lkof/Set;` descriptor was not materialized). Fixed in
> `JvmTypeMapper` (`kof.Set` → `java/util/HashSet` mapping) + parser
> of class members with generic return (`Set<Int> foo()`, `List<String> bar()`).

## Why it is bad

| Chain of `||` | `setOf(...).contains(...)` |
|---|---|---|
| 10 lines for 10 values | 1 line of intent + the values in a list |
| forgetting/duplicating an entry = silent bug | the set deduplicates; adding = 1 line |
| O(n) linear search, hidden intent | `Set` (hash) O(1) average, explicit intent |
| looks like generated code | looks like human-written code |

## When the short chain is acceptable

Up to **2** values, `||` is more direct than creating a `Set`:

```kof
if (status == "active" || status == "pending") { ... }   // ok — 2 cases
```

Beyond that → `setOf(...).contains(...)`.

## What STILL does NOT exist (don't hallucinate)

- There is **NO** `x in [...]` operator nor a set literal `{"a","b"}` in the
  language today — using that **does not compile** (see `fake-idioms.md`).
- The real, compilable idiom is **`setOf(...).contains(x)`** (JVM/Native/JS,
  0.2.6-beta). The `in` syntax / set literal is a future evolution of the
  compiler (expressiveness planning), not a current API.

## Related anti-patterns

- `java-like-code.md` — Java translated literally to Kof
- `fake-idioms.md` — do not teach `in`, set literal, etc. (does not exist yet)
- Corresponding idiom: `training/idioms/collections.md` (section "Membership")
