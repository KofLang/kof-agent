#!/usr/bin/env bash
# Treino overnight KofLM — log em training/logs/overnight.log
# Dados grandes (venv, HF cache, checkpoints) vão pro disco separado (KOF_DATA).
set -x
cd "$(dirname "$0")/.."
mkdir -p training/logs
source scripts/gpu-env.sh 2>/dev/null || KOF_DATA="$HOME/Downloads/kof-data"
VENV="$KOF_DATA/venv-ml"
export HF_HOME="$KOF_DATA/hf"
export TOKENIZERS_PARALLELISM=false
export OMP_NUM_THREADS=4
{
  echo "[KofLM] $(date) venv=$VENV hf=$HF_HOME"
  if [ ! -x "$VENV/bin/python" ]; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install -q --upgrade pip
    "$VENV/bin/pip" install -q -r requirements-ml.txt
  fi
  echo "[KofLM] $(date) iniciando treino (CPU/LoRA, resume-safe)..."
  "$VENV/bin/python" training/scripts/train_koflm.py
  echo "[KofLM] $(date) FIM rc=$?"
} >> training/logs/overnight.log 2>&1
