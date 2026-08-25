#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KOF="${KOF:-${KOF_BIN:-/home/luna/kof/Kof4j/bin/kof}}"
[ -x "$KOF" ] || KOF="$(command -v kof)"

PARTS=(
  agent/runtime/00_core.kf
  agent/runtime/05_log.kf
  agent/runtime/10_config.kf
  agent/runtime/20_scheduler.kf
  agent/runtime/25_event.kf
  agent/runtime/30_lifecycle.kf
  agent/runtime/40_workspace.kf
  agent/runtime/50_metrics.kf
  agent/runtime/90_runtime.kf
)

# usage: build.sh <entry.kf> <out.kf> [--with-gateway]
ENTRY="$1"
OUT="$2"
mkdir -p "$(dirname "$ROOT/$OUT")"
: > "$ROOT/$OUT"
SELECTED=("${PARTS[@]}")
if [ "${3:-}" = "--with-gateway" ]; then
  SELECTED+=("agent/runtime/95_gateway.kf")
fi
for p in "${SELECTED[@]}"; do
  cat "$ROOT/$p" >> "$ROOT/$OUT"
  printf '\n' >> "$ROOT/$OUT"
done
cat "$ROOT/$ENTRY" >> "$ROOT/$OUT"
echo "built $OUT (parts+entry)" >&2
