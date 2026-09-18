---
id: arch-layers
title: camadas e direcao de dependencia
module: architecture
category: architecture
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: camadas,engine,runtime,gateway
status: stable
tags: visao-geral
---
# Camadas (reorg U3, 6cb6e68)

```
apps/          cli (status/doctor/config) e gateway (check/build/selftest golden)
agent/runtime/ nucleo M1–M31: 00_core..90_runtime, corpus/retrieval,
               memory/conversation, brain/intents, executor, tools
engine/        motor de inferencia 100% Kof: 150 backend select,
               151 config, 159 shader-HAL, koflama gguf/tok/forward,
               160 context-YAML, 161 output-contract
training/kf/   141 corpus-intel, 142 pipeline, 143 gguf-builder, 148 trainer
gpu/           kernels .comp (Vulkan) + .cl (OpenCL) + tests_ocl.c
```

Dependencia so desce: apps → agent/runtime → engine; engine NUNCA importa
apps. `scripts/build.sh` e a unica fonte de ordem topologica (concatena tudo
numa TU por programa — nomes top-level compartilham espaco, por isso
`expApproxSc` no softmax do .cl). Mapa completo: docs/MODULES.md; plano v2:
specs/ENGINE_V2.md.
