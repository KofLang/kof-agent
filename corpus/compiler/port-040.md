---
id: comp-port-040
title: port do repo para kof 0.4.0-beta
module: compiler
category: compiler
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: port,fn,record,getOrDefault,long
symbols: fn,record
status: stable
tags: migracao
---
# Port 0.4.0 (commit ad8cdca)

Mudancas exigidas pela gramatica/semantica 0.4.0-beta:

1. **PARSE085 — `fn` e `fun` sao reservados.** Declaracao vira sintaxe tipada:
   `foo(): Int { }` ou `Int foo() { }`. (R8: Kof nao e Java.)
2. **SEM038 — record e imutavel.** Records mutados (CorpMeta em 57_corpus,
   ExecTaskState em 71_executor) viraram `class` com `constructor` explicito.
   Records permaneceram so para dados read-only (PlanNode, RunMetrics, ...).
3. **#438 — `Map.get` retorna `V?`.** Onde se queria default, usar
   `getOrDefault(k, v0)` (API real em 62bd455e). Ver `kofLmTokFind2` em
   engine/koflama_tokenizer.kf.
4. **Literal `0 - 2147483648` vira Long e derruba o ASM.** Escrever
   `0 - 2147483647 - 1` e/ou clampar `as Int` (kofLmToWh/ToWl/ToI32 em
   engine/koflama_forward.kf).
5. **`val` e reservada** — nao pode ser nome de variavel.
6. **`for-in` nao aceita chamada de funcao como colecao**: materializar em
   `var` antes (`var xs = splitStr(...); for (x in xs)`).

Regra do gate: ao mover/portar `.kf`, reconcatenar via scripts/build.sh e
provar `cmp` byte-identico contra baseline do TU.
