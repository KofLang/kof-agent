---
id: java-identificacao
title: como reconhecer Java
module: java
category: java
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: java,identificar,sintaxe
status: stable
tags: java,leitura
---
# Reconhecer Java (para ler; nunca para emitir)

Marcadores de Java num pedido/arquivo:
- `public/private/protected`, `static`, `class X { ... }` com `;` por instrução
- `interface`, `implements`, `extends` multiplo por interface
- generics `List<String>`, wildcard `? extends T`, anotacoes `@Override`
- `new ArrayList<>()`, Stream API (`.stream().map().collect()`), `Optional<T>`
- `try/catch (Exception e) throws ...`, `String s = "..." + name;`
- Maven/Gradle (`pom.xml`, `build.gradle`), Spring (`@SpringBootApplication`)

Confusao proposita a evitar: Kof TAMBEM tem `class`, `interface`, `record`,
`new`, `extends` e generics `Map<String, Int>` — o que entrega Java e o
`;` por instrução, modificadores `public/private/protected`, anotacoes
`@...` e `throws`. Na duvida sobre o que e Kof valido, rode
`compiler.check` — nunca adivinhe.

Referencia autorizada Kof: [java-to-kof](kof/migration/java-to-kof.pt_BR.md).
