#!/usr/bin/env bash
# Treino overnight KofLM — log em training/logs/overnight.log
set -x
cd "$(dirname "$0")/.."
mkdir -p training/logs
{
  echo "[KofLM] $(date) instalando stack ML..."
  pip install -q -r requirements-ml.txt
  echo "[KofLM] $(date) iniciando QLoRA..."
  python3 training/scripts/train_koflm.py
  echo "[KofLM] $(date) FIM"
} >> training/logs/overnight.log 2>&1
