#!/usr/bin/env bash
# Baixa base TinyLlama-1.1B-Chat (setup único; inferência permanece 100% local)
set -euo pipefail
DEST="${1:-models/base/TinyLlama-1.1B-Chat}"
mkdir -p "$DEST"
BASE="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main"
for f in tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf tinyllama-1.1b-chat-v1.0.Q8_0.gguf; do
  [ -f "$DEST/$f" ] && continue
  echo "baixando $f..."
  curl -L --fail -o "$DEST/$f" "$BASE/$f"
done
sha256sum "$DEST"/*.gguf > "$DEST/checksums.sha256"
echo "OK: $DEST"
