# REPORT M16 — Runtime AI v2

## Entregue
- `agent/runtime/82_tensor_ops.kf`: TensorArena (pool+reuse+stats), tensorSoftmaxRow estável (aprox racional positiva), tensorRmsNorm, gelu/silu, tensorCausalMask.
- 7 testes unitários verdes no Native (`tests/m16_src/unit_m16.kf`, build via scripts/build.sh).

## Bugs do compilador encontrados
- **N16** (SEM025): método de classe não resolve quando uso precede definição — REGRESSÃO de 3329323. Workaround: ordenação topológica dos PARTS + helpers movidos de 03_tool_exec p/ 47_tools.
- **N17** (Codegen): comparação signed quebrada p/ negativos de Int[] no native. Workaround: aritmética livre de negativos nos kernels.

## Pendente (próxima sprint M16.2)
- RoPE V2, KV Cache ring/sliding/prefix, Quantização Q4–Q8, Sampler V3 completo (~18 testes restantes).
- Benchmarks native-M16.json após kernels attention completos.

## Baseline
Compilador: Kof4j origin/main @ 65f748f · kof 0.0.14-alpha
