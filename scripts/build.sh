#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KOF="${KOF:-${KOF_BIN:-/home/luna/kof/Kof4j/bin/kof}}"
[ -x "$KOF" ] || KOF="$(command -v kof)"

PARTS=(
  agent/runtime/00_core.kf
  agent/runtime/03_tool_exec.kf
  agent/runtime/05_log.kf
  agent/runtime/10_config.kf
  agent/runtime/20_scheduler.kf
  agent/runtime/25_event.kf
  agent/runtime/30_lifecycle.kf
  agent/runtime/40_workspace.kf
  agent/runtime/45_windex.kf
  agent/runtime/47_tools.kf
  agent/runtime/50_metrics.kf
  agent/runtime/57_corpus.kf
  agent/runtime/67_retrieval.kf
  agent/runtime/68_brain.kf
  agent/runtime/90_runtime.kf
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
