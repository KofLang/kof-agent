#!/usr/bin/env bash
# Probe real: abre/forwarda o TinyLlama GGUF de verdade (lento; fora do suite diario)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
mkdir -p "$ROOT/build/tests_quant"
"$ROOT/scripts/build.sh" tests/quant/kofq_binprobe_tinylama.kf "build/tests_quant/heavy" --native-clock >/dev/null 2>&1 || { echo "build fail"; exit 1; }
(cd "$ROOT" && "$KOF" test "build/tests_quant/heavy.kf" --target native)
