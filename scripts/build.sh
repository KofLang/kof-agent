#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
[ -x "$KOF" ] || KOF="$(command -v kof)"

# Ordens de concatenacao = topologica (fix N16: uso deve seguir definicao).
# Mover/renomear arquivos exige reconcatenar e diffar contra o TU anterior.
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
  engine/81_tensors_v2.kf
  engine/82_tensor_ops.kf
  engine/79_hal.kf
  engine/83_m16_v2.kf
  engine/83_nn_interfaces.kf
  engine/84_gguf.kf
  agent/runtime/68_brain.kf
  agent/runtime/69_planner.kf
  agent/runtime/71_executor.kf
  agent/runtime/90_runtime.kf
  engine/153_graph_executor.kf
  engine/kof_f16.kf
  engine/159_shader_hal.kf
  engine/154_attention_swiglu.kf
  engine/156_lmhead_quant.kf
  engine/157_quant8_embed.kf
  training/kf/140_dataset_builder.kf
  training/kf/141_corpus_intel.kf
  training/kf/142_training_pipeline.kf
  training/kf/143_gguf_builder.kf
  training/kf/145_koflm_dataset_loader.kf
  engine/151_koflm_config.kf
  engine/155_tokenizer_engine.kf
  engine/150_koflm_backend.kf
  engine/147_koflm_tokenizer.kf
  engine/152_inference_engine.kf
  engine/144_koflm_runtime.kf
  engine/146_koflm_v2.kf
  engine/85_model_runner.kf
  agent/runtime/131_ai_engine.kf
  agent/runtime/133_model_manager.kf
  engine/160_context.kf
  engine/161_contract.kf
)

# usage: build.sh <entry.kf> <out.kf> [--with-gateway]
ENTRY="$1"
OUT="$2"
mkdir -p "$(dirname "$ROOT/$OUT")"
: > "$ROOT/$OUT"
resolve_part() {
  local name="$1" d
  for d in agent/runtime engine training/kf; do
    if [ -f "$ROOT/$d/$name" ]; then
      printf '%s/%s\n' "$d" "$name"
      return 0
    fi
  done
  echo "build.sh: part nao encontrada: $name" >&2
  return 1
}

SELECTED=("${PARTS[@]}")
for flag in "${@:3}"; do
  case "$flag" in
    --with-gateway) SELECTED+=("agent/runtime/95_gateway.kf") ;;
    --with-lm) SELECTED+=("engine/koflama_gguf.kf" "engine/koflama_forward.kf" "engine/koflama_tokenizer.kf" "engine/163_koflm_intent.kf" "engine/164_koflearn.kf" "engine/165_kofquant.kf") ;;
    --only=*) SELECTED=(); for f in $(echo "$flag" | cut -d= -f2 | tr ',' ' '); do SELECTED+=("$(resolve_part "$f")"); done ;;
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
