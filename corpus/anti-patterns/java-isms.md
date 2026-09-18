---
id: anti-java-isms
title: java-isms que o gate barra
module: anti-patterns
category: anti-patterns
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: sycophancy,no-op,+=,continue,null
status: stable
tags: estilo
---
# Anti-padroes (motivos reais, nao gosto)

- **`+=` / `-=`** — o parser trata como erro historico da familia N9
  (`x += e` perdia acumulador no native). Gate `scripts/check_compat.sh` barra;
  escrever `x = x + e`.
- **`continue`/`break` fora do padrao** — `continue` em loop com acumulador foi
  implicated em codegen quebrado (N9/N10); reescrever com `if` invertido.
- **`== null`/`!= null` em agent/runtime, apps/cli, tests, benchmarks** — a
  idiom de narrowing `T?` e legitimo so em `engine/` e `training/kf/` (APIs
  FFI/get do 0.4.0 devolvem `T?`); no resto o gate barra para manter o nucleo
  rodando nas duas backends. Fora do gate, preferir `getOrDefault`.
- **Fachada de backend** — anunciar OpenCL no auto-select sem dispatch real e
  proibido (Q7 ENGINE_V2): `detectOpenCL()` existe, mas CL nao entra em
  `backendAutoSelect` ate `gpu.cl.*` existir no compilador.
- **Explicacao antes do resultado** — contrato E5: resultado primeiro,
  explicacao e extra capped (engine/161_contract.kf). Zero cortesia.
