# RUNTIME AI (M10) — implementado (v1 deterministica)
Tokenizer (palavras+dígitos, ids por hash estável sobre vocabulário construído
do corpus), Vocab build/load, Sampler TopK com seed LCG e temperatura em
permille, Tensor inteiro (rows×cols, Int[]) com matMul/transpose (caminho
quantizado-int; FP aguarda FLT/SIMD upstream — Q2), GGUF header parser
(magic/version/nTensors via readBytes LE), KV cache anel por camada com
evicção contada, Model API (loadModel/unloadModel/generate/cancel/tokenize/
detokenize) com backend local retornando gap estruturado GW-WEIGHTS até o
caminho FP existir; providers externos permanecem fora (D0007).
Eventos: model.loaded/unloaded, generation.started/token/finished/cancelled.
