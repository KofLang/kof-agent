# REPORT M16.2

## Entregue
- `agent/runtime/83_m16_v2.kf`: RopeFreqs/ropeBuild/applyRope (offset+cache), KVCacheV2 (append/sliding/reset/snapshot/reuse), quantizeQ4/dequantizeQ4, SamplerConfig, samplerGreedy, LcgState/lcgNext, samplerTopKV3 determinístico.
- 14 testes nativos verdes (`tests/m162_src/unit_m162.kf`).
- `benchmarks/native-M16.2.json` com medições reais.

## Watchdog
- N17 re-testado: **aberto** — workaround ativo (kernels sem negativos; teste Q4 usa domínio não-negativo).
- N10 re-testado: **aberto** (unit_f3 segue 139).
- Colisão de símbolo `samplerTopK` com M10 resolvida renomeando para `samplerTopKV3` (limitação de namespace plano, sem bug novo).
- Palavra reservada `val` descoberta em params (PARSE023) — registrado como nota, não bloqueia.

## Pendente M16.3
- Q6_K/Q5_K packing, min-p/top-p/penalties compostos, arena checkpoint/fragmentation.
