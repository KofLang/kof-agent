---
id: train-v4-format
title: formato do dataset v4 e do eval
module: training
category: training
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: dataset,v4,exec,ask,refuse
status: stable
tags: dados
---
# Dataset v4 (E2)

`datasets/jsonl/koflm-v4.jsonl` — uma linha JSON por exemplo:
`input, instruction, output, action ∈ {EXECUTE, ASK, REFUSE},
bucket (0..9, separa train/eval), checksum, source`.

Regras da transformacao (scripts/build_koflm_v4.py, deterministica):
- EXECUTE so quando existe codigo/documento real herdado do v3; saida =
  resultado (+ ate 2 linhas). Mediana de output: 400 → 140 chars.
- ambiguo/incompleto → `ASK: <pergunta de 1 linha>`.
- pedido em idioma estrangeiro (Java/Kotlin) ou que Kof nao tem →
  `REFUSE: <motivo tecnico de 1 linha>`.
- disjuncao train/eval por bucket de hash; nunca inventar saida — sem
  correspondente real no v3 vira ASK/REFUSE, nunca EXECUTE fabricado.

`eval/ptbr-suite-v4.jsonl` (620) rotula `expected_action` e mede o gate
§5.2: precisao de intencao ≥0.95, ASK correto ≥0.90, chute sem pergunta
<0.02, determinismo 1.0.
