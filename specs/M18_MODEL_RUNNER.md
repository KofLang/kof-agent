# M18_MODEL_RUNNER

Local Model Runner — loadModel/unloadModel/tokenize/detokenize/generate/streamGenerate sobre o GGUF Loader M17 + Runtime AI M16. Métricas: tokens/s, RAM peak, KV hit rate, latência p50/p95, throughput streaming. Cancelamento cooperativo via flag.

## Definition of Done

- Spec revisada.
- Implementação em Kof compilando para Native.
- Testes one-per-process.
- Benchmark baseline.
- Compatibility sweep.
