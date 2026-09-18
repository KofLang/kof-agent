---
id: java-migracao
title: Java para Kof — mapa de traduçao honesto
module: java
category: java
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: java,kof,migracao,traducao
status: stable
tags: java,migracao
---
# Java → Kof (resumo do corpus oficial)

Traducao 1:1 NAO existe — "pensar em Kof", nao transliterar Java
(fonte: [java-to-kof](kof/migration/java-to-kof.pt_BR.md)):

- getter/setter → campo publico direto (`u.age = 31`), sem `getAge()`
- dados imutaveis → `record Point(Int x, Int y)` (accessor `p.x()`)
- construtor com campos → `class` + `public constructor(...)` + `this.x = x`
- `int/long/boolean` → `Int/Long/Bool`; `String` continua `String`
- checked exceptions/`throws` → nao ha equivalente direto; ver
  [exceptions](kof/language/exceptions.pt_BR.md) antes de prometer try/catch
- Stream/Optional/Lombok → reescrever com colecoes/`for`/`while` idiomáticos
  ([idioms](kof/idioms/collections.pt_BR.md)); nada de `map(...)` lambda chain
- `fn`/`fun`/`;`/`+=` sao ERROS em Kof (PARSE085/gate) — saida migrada
  SEMPRE passa `compiler.check`.

Regra do agente: o PRODUTO de uma migracao e codigo Kof verificado; se o
pedido e "escreve em Java" → REFUSE tecnico (corpus/java/recusa.md).
