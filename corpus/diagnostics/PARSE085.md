---
id: diag-PARSE085
title: PARSE085 fn reservada
module: diagnostics
category: diagnostics
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: parse085,fn,fun,reserved
status: stable
tags: compile-time
---
# PARSE085

```
error: 'fn' is a reserved word (Kof has no function keyword); declare as
'Type name(...) { }' or 'name(...): Type { }' [PARSE085]
```

Causa: declaracao com `fn`/`fun` (sintaxe pre-0.4.0 herdada de Go/Rust).
Workaround: reescrever com tipo de retorno, ex.
`soma(a: Int, b: Int): Int { return a + b }`.
