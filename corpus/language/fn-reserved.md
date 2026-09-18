---
id: lang-fn-reserved
title: fn e fun sao palavras reservadas
module: language
category: language
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: fn,fun,declaracao,top-level
symbols: fn
status: stable
tags: sintaxe
---
# `fn`/`fun` reservadas (PARSE085)

Kof nao tem palavra-chave de funcao. Uma funcao declara-se pelo tipo de
retorno:

```
soma(a: Int, b: Int): Int { return a + b }
```

ou prefixo de tipo (uso no repo). `fn foo()` e `fun foo()` dao
`error: 'fn' is a reserved word [PARSE085]`. Funcoes top-level sem
`return type` invalido tambem caem aqui. `val` e reservada (VAR104):
nao e nome de variavel, e sim binding imutavel.

Verificado ao portar 12 arquivos para 0.4.0-beta (commit ad8cdca) — o erro
aparecia em cada `fn` remanescente.
