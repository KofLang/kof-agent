# N25 — Map nativo corrompe no resize (regressao do port 0.4.6-beta)

**Sintoma (nativo, jar 0.4.6-beta, medido 2026-09-19 nas builds isoladas `build/n25{ i,s}/`):**
1. `Map<Int,Int>`: 1500 puts de chaves unicas (`i*7`) → `size()`=**37** OU **SIGSEGV**
   (varia por corrida — rehash 512→1024 corrompe buckets).
2. `Map<String,Int>`: 1000 puts (`"chave_"+i`) → `size()`=**37** silencioso (sem crash).

**A/B no mesmo código:** jar **0.4.0-beta** → `size=1500`/`size=1000` CORRETOS.
Regressao pura do port 0.4.6 (hash nativo do runtime).

**Baseline:** no jar 0.4.0-beta original (mesmo codigo, `lib/kof.jar.old40`) os dois
cenarios passam — E7 foi commitado com `Map` no tokenizer (163/chave `"k"` + 32k tokens
era ok... na verdade E7 usava Map com <512 entradas por teste; o crash so apareceu no
vocab de 32000 chaves do TinyLlama real).

**Contorno adotado no kof-agent:** tabela de hash propria (linear probing, Int[] used)
em `engine/koflama_tokenizer.kf` (`KofLmTokIndex`/`kofLmTokIndexNew/Put/Get`) — nao usa
`Map` no caminho quente.

**Repro:** `bash scripts/test.sh` com `regressions/N25/repro_map.kf` (build + run native):
- `repro_str.kf`: 1000 puts String→Int → SIGSEGV RC=139
- `repro_int.kf`: 1500 puts Int→Int → size=1262 (esperado 1500)

**Status:** nao enviado ao tracker Kof4j (arvore esta em uso concorrente por outras
lanes; reabrir apos estabilizar).
