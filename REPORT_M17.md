# REPORT M17 — GGUF Loader

## Entregue
- `agent/runtime/84_gguf.kf` (~200 linhas): GgufHeader/MetaValue/TensorEntry/GgufHandle tipados; ggufParse V2/V3 c/ validação E_MAGIC/E_VERSION; ggufParsePairs (metadata KV); ggufParseTensors (directory); openGGUF (file→handle, E_FILE_NOT_FOUND/E_FORMAT); getMetadata; hasTensor; listTensors; getTensorLazy (hex blob decode); tokenizerInfo; ropeInfo.
- Fixture golden: `fixtures/tiny.gguf` (v3, 2 tensors, metadata bos/eos/context).
- `--only=` flag no build.sh → TU-splitter anti-N10 por milestone.

## Testes
- **2/11 one-per-process verdes** (t4 metadata-missing, t5 tensor-lookup-fixture — prova o caminho file→parse→lookup end-to-end).
- 9 falhas sob investigação: mistura de N10-residual (crash sem output em builds maiores) e expectativas de teste a corrigir.

## Watchdog
- N10-progressivo: threshold empírico ~1MB asm para ESTES padrões; mitigado via --only (suítes por domínio).
- Suspeita nova (a confirmar como N18): crash nativo dentro de função c/ loops splitStr aninhados em versão anterior do corpo; contornado reescrevendo em funções separadas.

## Pendente M17.1
- Corrigir 9 testes (expectativas + isolamento), checksum SHA256, cache/unload, benchmark real native-M17.json.
