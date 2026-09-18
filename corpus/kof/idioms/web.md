---
id: kof-idioms-web-en
title: Idioms — Web (kof.web)
module: kof
category: kof-idioms
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,idioms,web
status: stable
tags: kof,idioms,en
---
[English](kof/idioms/web.md) | [Português](kof/idioms/web.pt_BR.md)

# Idioms — Web (kof.web)

**Status:** available (JVM) · **Introduced:** 0.2.6-beta · **Updated:** 0.3.0-beta

## What it is

`web.app()` creates the application; each `app.get/post/put/patch/delete(path) { … }`
registers a route. The **handler's return is the response contract**:

- `return "texto"` → `200 OK` with the body (`String`).
- `return null` → `404 Not Found` (documented absence, not an error).
- `status(code)` / `headerSet(...)` before the return → headers + code.

## GOOD — handler with presence/absence

```kof
main() {
    var app = web.app()
    app.get("/tasks/:id") {
        var id = param("id").toInt()
        if (id >= 1) {
            return "task " + id
        }
        return null    // → 404
    }
    app.delete("/tasks/:id") {
        return "deleted:" + param("id")
    }
    app.listen(8080)
}
```

The idiomatic form `if (cond) { return valor } return null` works in any
order of branches (bug 53, GitHub #28 — fixed 07/09: the handler type is now
inferred from ALL the body's returns, not just the top).

## When to use

- REST/HTTP route with the `kof.web` runtime (JVM).
- Resource absence → `return null` (404), not `throw`.

## When NOT to use

- A real handler error → `throw "mensagem"` (the runtime turns it into a 500 with the
  diagnostic, R6).
- A non-200/404 response (e.g. 301, 401) → `status(code)` + return.

## Notes

- `app.listen` accepts ONLY Int (`app.listen(8080)` — #102.2 13/09: a String
  turned into a VerifyError at runtime; now it is SEM025 in `kof check`).

- `app.delete(path) { … }` is a route (HTTP verb), not `File.delete()` —
  the collided name was bug 54 (GitHub #29), fixed 07/09 (arity guard in
  `KofIo`).
- Middlewares (`app.use { … }`) follow the SAME contract: `return null`
  proceeds to the handler; `return "corpo"` responds and ends (short-circuit).
