# KofLM classifier v5 — pesos TREINADOS em Kof puro (nativo, sem Python)

- Origem: `kof-agent train` (engine/164_koflearn.kf) sobre `datasets/jsonl/koflm-v4.jsonl`
  (511 exemplos) + `datasets/jsonl/koflm-errors.jsonl` (4 colhidos), 15 epochs = 7665 passos.
- Labels: EXECUTE / ASK / REFUSE (bag-of-features token+trigramas, hash 8192, SGD int64-micro).
- `koflm-classifier-v5.w`  — pesos completos KFLR (int64 micro), 67KB.
- `koflm-classifier-v5.kflq` — quantizado KFLQ int8 por classe (scale i64 + bias i64 + CRC),
  24.6KB. Gerado por `kof-agent quant --file build/koflearn.w --out <dst>` (engine/164_koflearn.kf).
- **Mensuracao honesta da suite adversarial `eval/ptbr-suite-v4.jsonl` (620 exemplos):**
  - modelo int64: acc=30% do total (69% abstem por margem < threshold 0.45) — igual ao baseline E7 (31%)
  - modelo int8 (KFLQ): **concordancia de previsao = 1000/1000 com o int64** na suite inteira
- Roundtrip + CRC testados em `tests/learn/kfl_learner_aprende.kf` (suite `scripts/test_learn.sh`).
- Nao e um LM: e o classificador de intencao do agente (E7/E8a). O LM de referencia
  (TinyLlama-1.1B-Q4_K_M) roda em Kof nativo mas NAO pode ser redistribuido aqui (667MB/licenca).
