# SPEC M16 — Runtime AI v2

## Objetivo
Transformer inference core: Tensor Engine V2 + Attention + RoPE + KV Cache + Quantização + Sampler V3.

## Módulos

### 1. Tensor Engine V2 (`agent/runtime/91_tensor_v2.kf`)
- `TensorV2` record: data IntArray/FloatArray-like, dims IntArray, strides.
- **Arena allocator**: pool por tamanho, alignment 64B, reuse via free-list, stats (allocs/reuses/peak).
- Views/slice/reshape/broadcast sem cópia (strides).
- MatMul otimizado (loop ikj, cache-friendly).
- Softmax estável (subtract max), LayerNorm, RMSNorm, GELU, SiLU.

### 2. Attention (`agent/runtime/92_attention.kf`)
- MultiHeadAttention com causal mask.
- Flash-ready stub interface (FlashAttnHook).

### 3. RoPE V2 (`93_rope.kf`)
- Rotação complexa por posição; NTK scaling (base^scale); YaRN hook preparado.

### 4. KV Cache (`94_kv_cache.kf`)
- Ring buffer com eviction LRU aproximada.
- Sliding window configurável. Prefix reuse via hash do prompt inicial.

### 5. Quantização (`95_quant.kf`)
- Q8_0 (block 32: fp16 scale + int8), Q6_K/Q5_K superblocks, Q4_0.
- Conversores quantize/dequantize roundtrip.

### 6. Sampler V3 (`96_sampler.kf`)
- Greedy/temp/top-k/top-p/min-p/freq/presence/repetition penalties/multinomial LCG-seeded.

## Riscos
| Risco | Mitigação |
|---|---|
| N10 progressivo em TU grande | part-files ≤ 60KB asm cada |
| Float precision | testes diferenciais native×jvm |
| Arena leak | stats assertion no teardown |

## DoD
- 25 testes one-per-process verdes.
- benchmarks/native-M16.json com tokens/s baseline.
- Compatibility sweep limpo.
