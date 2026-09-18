# REPORT M31-M35 — FASE 6 KofLM v1 núcleo
- `140_dataset_builder.kf`: dedup por hash, categorização por path, split determinístico train/val/test (seed), export Alpaca JSONL.
- `141_corpus_intel.kf`: exemplos supervisionados PT-BR dos bugs N10/N11/N18/J4.
- `142_training_pipeline.kf`: QLoRA TinyLlama r32/α64/ctx2048/ep3/lr2e-4/cosine/seed42 → JSON.
- `143_gguf_builder.kf`: 4 quants oficiais (Q4_K_M/Q5_K_M/Q6_K/Q8_0) + modelManifestJson c/ compiler_head.
- `144_koflm_runtime.kf`: KoflmRuntime = ModelManager + ModelRunner (register koflm-v1, load, warmup, chat, cancel).
- **9/9 testes nativos** one-per-process.
- Dataset real: `/home/luna/kof/Kof4j/training` existe (datasets/, anti-patterns/) — ingestão completa na fila M31.1.
