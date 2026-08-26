#!/usr/bin/env bash
# Publica KofLM GGUFs: HF Hub (primário) + GitHub Release (mirror)
set -euo pipefail
cd "$(dirname "$0")/.."
VER="${1:-v1.0.0}"
DIR=models/KofLM
mkdir -p "$DIR"
for f in "$DIR"/KofLM-*.gguf; do [ -f "$f" ] || { echo "nenhum gguf em $DIR"; exit 1; }; done

# 1) Hugging Face (requer huggingface-cli login; repo privado ou publico)
if command -v huggingface-cli >/dev/null; then
  REPO="KofLang/KofLM"
  for f in "$DIR"/KofLM-*.gguf; do
    huggingface-cli upload "$REPO" "$f" "$(basename "$f")" --repo-type model
  done
fi

# 2) GitHub Release mirror (anexos até 2GB cada)
gh release create "koflm-$VER" --title "KofLM $VER" --notes "Modelo oficial PT-BR. Ver metadata.json." --draft 2>/dev/null || true
gh release upload "koflm-$VER" "$DIR"/KofLM-*.gguf "$DIR"/checksum.sha256 --clobber
echo "publicado: HF + GH release koflm-$VER"
