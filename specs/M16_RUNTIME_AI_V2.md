# M16_RUNTIME_AI_V2

Runtime AI v2 — Tensor Arena Allocator (pool por tamanho), KV Cache persistente c/ compaction, RoPE V2 (rotação complexa por posição), RMSNorm (sqrt-free escala), SwiGLU FF, MultiHead Attention (Q·K^T·softmax·V), Residual Connections, Sampler V3 (temperature/top-k/top-p/repetition-penalty/min-p/seed determinístico), Quantização Q4_0/Q5_K/Q6_K/Q8_0 interfaces (block scale+offset). Testes diferenciais native×jvm.

## Definition of Done

- Spec revisada.
- Implementação em Kof compilando para Native.
- Testes one-per-process.
- Benchmark baseline.
- Compatibility sweep.
