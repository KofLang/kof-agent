#!/usr/bin/env bash
# Baixa KofLM oficial: tenta GH release → HF → TinyLlama base fallback
set -euo pipefail
cd "$(dirname "$0")/.."
DIR=models/KofLM; mkdir -p "$DIR"
Q="${1:-KofLM-Q4.gguf}"
GH="https://github.com/KofLang/kof-agent/releases/download/koflm-v1.0.0/$Q"
HF="https://huggingface.co/KofLang/KofLM/resolve/main/$Q"
try() { curl -L --fail -o "$DIR/$Q" "$1"; }
try "$GH" || try "$HF" || { echo "fallback: base TinyLlama Q4_K_M (sem fine-tune)"; try "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"; }
[ -f "$DIR/checksum.sha256" ] && (cd "$DIR" && sha256sum -c checksum.sha256 || echo "AVISO: checksum divergente")
echo "modelo em $DIR/$Q"
