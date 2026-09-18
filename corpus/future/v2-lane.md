---
id: fut-v2-lane
title: o que falta na v2 (honesto)
module: future
category: future
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: opencl,treinamento,gate,pendencias
status: draft
tags: roadmap
---
# Pendencias reais da fila v2 (ENGINE_V2)

1. **E3(b)**: `gpu.cl.*` nao existe no compilador Kof4j — lane deles, nao
   nossa. Ate la, OpenCL e deteccao + kernels + harness (rc=77 sem ICD).
   Faltou no meu relato anterior como se E3 fosse completa.
2. **Validacao bit-exata CL == CPU == VK**: exige
   `sudo apt install mesa-opencl-icd` (Rusticl) na maquina da mantenedora.
3. **Treino E4**: adapter no v4 + rodar o gate §5.2 (precisao ≥0.95, chute
   <0.02). O card model-v2.json e especificacao; os pesos nao existem ainda.
4. **ASK por confianca**: contrato e limites YAML prontos; o gatilho
   `conf < limiar → outAsk` ainda nao esta no laco do orquestrador
   (TASKS.md marca isso como aberto, e esta mesmo).
5. **N24 (upstream)**: 5 suites ws presas no JVM.
6. Corpus: categorias novas cobrem o essencial; continue preenchendo com
   fatos verificados, nunca prosa inventada.
