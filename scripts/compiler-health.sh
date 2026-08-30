#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
TS=$(date -u +%Y%m%d-%H%M%S)
OUT="$ROOT/docs/compiler/health-$TS.md"
run() {
  local name="$1" script="$2"
  local line
  line=$("$ROOT/scripts/$script" 2>&1 | grep -E "(passed,|passed$)" | tail -1 || echo "$name: runner ausente")
  echo "- $line" >> "$OUT"
}
{
  echo "# Compiler Health — $TS"
  echo ""
  echo "Compiler: $($KOF version 2>/dev/null || echo '?') · HEAD: $(cd "$KOF4J_ROOT" && git rev-parse --short HEAD 2>/dev/null)"
  echo ""
  echo "| Runner | Resultado |"
  echo "|--------|-----------|"
} > "$OUT"
run core test.sh
run ws test_ws.sh
run tools test_tools.sh
run corpus test_corpus.sh
run brain test_brain.sh
run planner test_planner.sh
run exec test_exec.sh
run ai test_ai.sh
run hal test_hal.sh
echo "health report: $OUT"
tail -12 "$OUT"
