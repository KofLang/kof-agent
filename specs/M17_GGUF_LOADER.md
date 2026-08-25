# M17_GGUF_LOADER

GGUF Loader completo — magic/version parse binário via readBytes, metadata KV pairs, tensor directory (nome/dims/type/offset), lazy loading por tensor, mmap quando stdlib expor, tokenizer metadata (vocab/bpe/special), rope metadata (dims/freq), quant metadata por tensor, compatibilidade v2/v3.

## Definition of Done

- Spec revisada.
- Implementação em Kof compilando para Native.
- Testes one-per-process.
- Benchmark baseline.
- Compatibility sweep.
