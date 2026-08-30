#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
[ -x "$KOF" ] || KOF="$(command -v kof)"

PARTS=(
  agent/runtime/00_core.kf
  agent/runtime/05_log.kf
  agent/runtime/10_config.kf
  agent/runtime/50_metrics.kf
  agent/runtime/20_scheduler.kf
  agent/runtime/25_event.kf
  agent/runtime/30_lifecycle.kf
  agent/runtime/40_workspace.kf
  agent/runtime/45_windex.kf
  agent/runtime/47_tools.kf
  agent/runtime/03_tool_exec.kf
  agent/runtime/57_corpus.kf
  agent/runtime/67_retrieval.kf
  agent/runtime/87_memory.kf
  agent/runtime/88_conversation.kf
  agent/runtime/89_orchestrator.kf
  agent/runtime/77_runtime_ai.kf
  agent/runtime/81_tensors_v2.kf
  agent/runtime/82_tensor_ops.kf
  agent/runtime/79_hal.kf
  agent/runtime/83_m16_v2.kf
  agent/runtime/83_nn_interfaces.kf
  agent/runtime/84_gguf.kf
  agent/runtime/68_brain.kf
  agent/runtime/69_planner.kf
  agent/runtime/71_executor.kf
  agent/runtime/90_runtime.kf
  agent/runtime/153_graph_executor.kf
  agent/runtime/158_f16_decoder.kf
  agent/runtime/159_shader_hal.kf
  agent/runtime/154_attention_swiglu.kf
  agent/runtime/156_lmhead_quant.kf
  agent/runtime/157_quant8_embed.kf
  agent/runtime/151_koflm_config.kf
  agent/runtime/155_tokenizer_engine.kf
  agent/runtime/150_koflm_backend.kf
  agent/runtime/147_koflm_tokenizer.kf
  agent/runtime/152_inference_engine.kf
  agent/runtime/144_koflm_runtime.kf
  agent/runtime/146_koflm_v2.kf
  agent/runtime/85_model_runner.kf
  agent/runtime/131_ai_engine.kf
  agent/runtime/133_model_manager.kf
)

# usage: build.sh <entry.kf> <out.kf> [--with-gateway]
ENTRY="$1"
OUT="$2"
mkdir -p "$(dirname "$ROOT/$OUT")"
: > "$ROOT/$OUT"
SELECTED=("${PARTS[@]}")
for flag in "${@:3}"; do
  case "$flag" in
    --with-gateway) SELECTED+=("agent/runtime/95_gateway.kf") ;;
    --only=*) SELECTED=(); for f in $(echo "$flag" | cut -d= -f2 | tr ',' ' '); do SELECTED+=("agent/runtime/$f"); done ;;
    --native-clock) SELECTED+=("agent/runtime/98_native_clock.kf") ;;
    --no-native-clock) ;;
    *) echo "unknown flag $flag" >&2 ;;
  esac
done
for p in "${SELECTED[@]}"; do
  cat "$ROOT/$p" >> "$ROOT/$OUT"
  printf '\n' >> "$ROOT/$OUT"
done
cat "$ROOT/$ENTRY" >> "$ROOT/$OUT"
echo "built $OUT (parts+entry)" >&2
