# SPEC KofLM (ADR-KLM-001)

kof-LM é o único modelo oficial. Base TinyLlama-1.1B-Chat-v1.0 · PT-BR · ctx 4096 · GGUF local.
Download base: scripts/download_tinyllama.sh (setup único; inferência 100%% offline).
Dataset v2: 453 exemplos dedup SHA256. Eval: 540 prompts.
Fila: treino QLoRA real → merge → KofLM.gguf → quants oficiais.
