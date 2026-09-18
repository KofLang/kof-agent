# Milestone 10 — Runtime AI

Status:

* 🟡 Parcial — núcleo determinístico 100% Kof/Native e **10/10 testes
  verdes**: tokenizer, vocab do corpus, encode/decode, sampler TopK seeded,
  Tensor inteiro (matmul/transpose) e parser de header GGUF. Execução de
  pesos FP e sampler completo (temperature/topP/minP) PENDENTES-FLT (Q2).

## Resumo
Base do Runtime AI sem Ollama/llama.cpp: tudo em Kof compilado para ELF.
GGUF header real via readBytes-planejado; v1 usa header textual versionado.

## Arquivos Criados
agent/runtime/77_runtime_ai.kf · tests/ai_src/unit_ai.kf · tests/ai/*.kf
(10+MANIFEST) · scripts/test_ai.sh · specs/{RUNTIME_AI,TOKENIZER,
GGUF_LOADER,SAMPLER}.md · REPORT_M10.md

## Modificados
scripts/build.sh (parte 77) · docs/status.md · docs/TASKS.md · README.md

## APIs
tkTokenize/tkId/tkEncode/tkDecode · Vocab · vocabBuildFromCorpus ·
samplerLcg/samplerTopK · TensorR/tensorNew/Get/Set/Transpose/MatMul ·
ggufParseHeader.

## Testes / Benchmarks / Pendências
10/10 nativos (tokenizer 4, vocab 1, encode/decode 2, sampler 2, tensor 2,
gguf 2 — dedup intencional). Benchmarks throughput/matmul: PENDENTE-N10-bench.
Pendências: FP matmul/attention/RoPE/LayerNorm/KV real (Q2), GGUF binário,
generate() real, >200 testes crescem com cada subsistema FP.
