---
id: pat-tu-order
title: TU unico, colisoes e hash de conteudo
module: patterns
category: patterns
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: topological,concat,collision,hash
status: stable
tags: build
---
# Padroes de build do Kof-agent

**TU unico concatenado.** `scripts/build.sh` cola as `PARTS` numa TU.
Consequencias:
- nomes top-level compartilham um espaco — o softmax .cl renomeou
  `expApprox` → `expApproxSc` por colisao com outra part;
- mover arquivo = mudar nada no byte do TU: prova-se com `cmp` contra
  baseline antes de commitar (regra da reorg U3);
- bugs posicionais (familia N10/N24) so aparecem no TU grande — repro minimo
  que passa NAO refuta.

**Hot-reload por conteudo.** Sem mtime na stdlib: `ctxTextHash` (djb2) no
texto do YAML; `ctxChanged(hashAnterior, textoNovo)` decide re-parse.
Barato e imune a clock skew.

**Determinismo.** Fixed-point int64 em todo o motor (nada de float);
sampling greedy `temperature 0`; saida do contrato capada por linhas do YAML.
Duas rodadas, mesma saida — requisito medido (gate E4 `determinismo=1.0`).
