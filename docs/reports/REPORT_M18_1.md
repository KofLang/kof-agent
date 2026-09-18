# REPORT M18.1 — Local Model Runner

## Entregue
- `agent/runtime/85_model_runner.kf`: ModelRunner (loadModel/unloadModel/cancelGeneration/resetContext/generate/streamGenerate/generateStep/kvDepth), RunnerConfig/GenMetrics/StreamEvent, mrEmbed (hash-embedding sobre tensor tok_embd do GGUF), mrLogits (projeção via out_proj).
- Pipeline completo por token: embed → RoPE(offset=KV) → KV append → logits → sampler greedy seedado.
- **8/8 testes nativos one-per-process** (load/unload/determinismo/bounds/KV-grow/cancel/stream).
- Benchmark real: 256 tokens em 28ms (~9.1k tok/s pipeline sintético).

## APIs
loadModel(GgufHandle) · unloadModel() · generate(prompt,cfg):List<Int> · streamGenerate(...):List<StreamEvent> · cancelGeneration() · resetContext() · kvDepth()

## Watchdog
Nenhum bug novo — N18 workaround (acessores/campos planos) aplicado preventivamente.

## Pendente M18.2
stop sequences, UTF-8 safe streaming, top-p/min-p no runner, batching.
