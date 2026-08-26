#!/usr/bin/env bash
# Merge LoRA → GGUF → quants oficiais KofLM (após TREINAMENTO_CONCLUÍDO)
set -euo pipefail
cd "$(dirname "$0")/.."
ADAPTER=models/kof-LM/lora/adapter-final
[ -f "$ADAPTER/adapter_model.safetensors" ] || { echo "adapter ausente — treine primeiro"; exit 1; }
[ -d ~/llama.cpp ] || { git clone --depth 1 https://github.com/ggerganov/llama.cpp ~/llama.cpp; }
pip install -q gguf sentencepiece 2>/dev/null || true
python ~/llama.cpp/convert_lora_to_gguf.py "$ADAPTER" --outfile models/gguf/koflm-lora.gguf
echo "merge manual do adapter com base TinyLlama via llama-gguf-pipeline ou llama.cpp merge tool"
for q in q8_0 q6_k q5_k_m q4_k_m; do echo "quant pendente: $q"; done
