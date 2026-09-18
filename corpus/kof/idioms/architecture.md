---
id: kof-idioms-architecture-en
title: Idioms — Architecture
module: kof
category: kof-idioms
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,idioms,architecture
status: stable
tags: kof,idioms,en
---
[English](kof/idioms/architecture.md) | [Português](kof/idioms/architecture.pt_BR.md)

# Idioms — Architecture

**Status:** available · **Introduced:** 0.0.4-alpha · **Updated:**  0.4.0-beta (Sep 2026)

## What it is

The language philosophy applied to architecture decisions.

## Central principle

> Represent the domain, not the accidental implementation.

## 1. Complexity belongs to the platform

If the complexity can be absorbed by the compiler, runtime or stdlib,
it must disappear from the user's code.

## BAD — manual infrastructure

```kof
class JsonParser {
    // manual JSON parser
}
class Db {
    // manual connection
}
class Http {
    // manual server
}
```

## GOOD — platform (0.4.0-beta)

```kof
var j = json.encode(user)
var dados = readFile("config.json")
var html = http.get("https://example.com")   // kof.http JVM+JS (Java HttpClient)
var x = 5                                    // KofScript (.ks): top-level var → KofScriptGlobals
// kof serve: handle(method, path, body) + web.app() + ws/sse + cache
// kof c: native-only C subset for hot paths
```

## WHY

JSON, files and HTTP already exist in the platform. Reimplementing them by hand
adds complexity that the programmer would have to maintain.

## 2. Unnecessary layers

## BAD — ceremony layers

```kof
class UserController {
    UserService service
    constructor() {
        service = new UserService()
    }
    listar(): String {
        return service.listar()
    }
}
class UserService {
    UserRepository repo
    constructor() {
        repo = new UserRepository()
    }
    listar(): String {
        return repo.listar()
    }
}
class UserRepository {
    listar(): String {
        return "users"
    }
}
```

## GOOD — what the problem requires

```kof
String listarUsers() {
    return "users"
}
```

## WHY

Controller/Service/Repository exists in Java because of framework conventions
(Spring, injection, transactions). Kof does not have those conventions. Add a
layer only when it solves a real problem.

## 3. Data → record, behavior → class, logic → function

```kof
record Product(String id, String name, Double price)

class Cart {
    List<Product> items
    constructor() {
        items = listOf()
    }
    add(Product p) {
        items.add(p)
    }
}

Double total(Cart cart) {
    var sum = 0.0
    for (var item in cart.items) {
        sum = sum + item.price
    }
    return sum
}
```

## 4. Modules (0.4.0-beta)

`package`/`import` exist. `import a.b.C` file-specific fixed 27/08 — large projects with `a/b/C.kf` now compile correctly (CompilerDriver). `import a.b.*` for a directory. Targets: `jvm`, `native`, `native.risc`/`native.arm` (placeholder), `js`, `kofc`, `KofScript` (`.ks` with `let`).

For small programs, a single `.kf` file is enough — the `main()` at the top.

## 5. Intent constructs (0.4.0-beta)

The compiler reduces intent constructs to normal code (the same pattern as
`entity`/`test "nome" {}`): the syntax expresses *what*, the lowering decides *how*.

Typed query DSL (level 3 of `kof.orm`, 01/09):

```kof
entity User { id: Long generated; name: String; age: Int }

var adultos = User.query(db) { where age > 18 }   // → kof_orm_where_op
var todos   = User.query(db) {}                    // → kof_orm_all
```

- The field of `where` is **validated at compile-time** (nonexistent field →
  `ORM003`; unknown entity → `ORM002`; target without ORM → `ORM001`).
- It is **not** a mini-language: it is sugar over the existing `kof_orm_*`.
- `orderBy name asc|desc` and multiple `where` clauses (ANDed) work since 02/09
  (`a5b25cc3` — `KofOrmE2ETest.queryDslFiltersOrdersAndLimits`/`queryDslMultipleWhereAnds`).

Lifecycle (01/09):

```kof
application {
    onStart    { println("starting") }    // → kof_app_on_start (prologue of main)
    onShutdown { println("stopping") }    // → kof_app_on_shutdown (epilogue of main)
}
```

- Desugars to synthesized functions — **zero container, zero reflection**
  (the same pattern as `test "nome" {}`).

W3C spans with timing (01/09):

```kof
val h = observability.spanStart("op")     // handle traceId+spanId (48 hex)
val j = observability.spanEnd(h)          // JSON {traceId, spanId, durationMicros}
```


## When not to use

- Do not create generic "manager", "helper", "context", "handler" without a clear responsibility.
- Do not mirror the structure of a Java framework (beans, autowired, config).
- Do not plan microservices before having a problem.

## Related anti-patterns

- `unnecessary-abstraction.md`
- `java-like-code.md`
