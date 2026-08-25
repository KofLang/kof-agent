# TASKS

## M16 — Runtime AI v2

- [x] Tensor Engine V2 — arena+softmax+rmsnorm+gelu/silu+causal (M16.1)
- [ ] MultiHead Attention completo (RoPE, KV)
- [x] RoPE V2 (cache+offset) — M16.2
- [x] KV Cache sliding/reset/snapshot — M16.2
- [~] Quantização: Q8_0 (M10) + Q4_0 ok; Q6_K/Q5_K pendentes
- [~] Sampler V3: greedy/top-k/multinomial-seed ok; top-p/min-p/penalties pendentes
- [ ] 25 testes
- [ ] benchmark baseline

## M17 — GGUF Loader

- [x] Parser V2/V3 header+metadata+tensor directory
- [x] APIs tipadas (openGGUF/getMetadata/hasTensor/listTensors/tokenizerInfo/ropeInfo)
- [x] Fixture golden tiny.gguf
- [~] Testes 2/11 (9 a fechar em M17.1)
- [ ] Checksum SHA256, cache/unload, mmap interface
- [ ] Benchmark real

## M18 — Local Model Runner

- [x] M18.1: loadModel/unload/generate/streamGenerate/cancel/reset + KV+RoPE+Sampler integrados (8/8)
- [ ] M18.2: stop sequences, UTF-8 streaming, top-p/min-p, batching

## M19 ✅ 8/8 — orchestrator/budget/audit/trace
## M20 ✅ 6/6 — runtime unificado DAG+repair+journal
