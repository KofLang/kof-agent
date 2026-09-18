---
id: std-io-surface
title: superficie io/std verificada em uso
module: stdlib
category: stdlib
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: file,directory,map,string
symbols: File,Directory,Map.getOrDefault,splitStr
status: stable
tags: io
---
# Stdlib — APIs usadas de verdade no repo (0.4.0)

So o que aparece compilando e rodando em agent/runtime + engine + tests:

- `File(path)` → `.exists() .isFile() .isDirectory() .readText(): String?
  .writeText(String)`
- `Directory(path)` → `.exists() .isDirectory() .list(): String?
  .createDirectories()`
- `joinPath(a,b)`, `splitStr(s, sep): List<String>`, `parseIntStr`,
  `escapeJson`, `listOf<T>()`, `new Int[n]`
- String: `.length .charAt(i): Int .substring(i,j) .startsWith .indexOf
  (e indexOfFrom no laço greedy do tokenizer) .trim .contains .add concat`
- `Map.put/get` — **`get` retorna `V?` (#438)**; para default use
  `getOrDefault(k, v0)`; para existir-versus-desconhecido o narrowing
  `if (v == null)` e permitido so fora do gate (engine/).

NAO existe na stdlib: `mtime`/timestamp de arquivo — hot-reload usa hash de
conteudo (160_context.kf), e nao StringBuilder — concat com `+`.
