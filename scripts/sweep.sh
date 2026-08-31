#!/usr/bin/env bash
# Sweep de regressões do ledger contra o HEAD do compilador.
# Gera docs/compiler/reports/sweep-<head>.md com exit codes reais.
# Uso: scripts/sweep.sh [out.md]
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
OUT="${1:-$ROOT/docs/compiler/reports/sweep-$(cd "$KOF4J_ROOT" && git rev-parse --short HEAD).md}"
mkdir -p "$(dirname "$OUT")"

HEAD=$(cd "$KOF4J_ROOT" && git rev-parse --short HEAD 2>/dev/null || echo unknown)
VER=$("$KOF" version 2>/dev/null | head -1)

run_case() {
  local id="$1" file="$2" target="${3:-native}" mode="${4:-run}" expect="$5" to="${6:-60}"
  local out rc
  if [ "$mode" = "test" ]; then
    out=$(timeout "$to" "$KOF" test "$ROOT/$file" --target "$target" 2>&1); rc=$?
  else
    out=$(timeout "$to" "$KOF" run "$ROOT/$file" --target "$target" 2>&1); rc=$?
  fi
  local tail
  tail=$(printf '%s' "$out" | tail -2 | tr '\n' ' ' | tr -s ' ')
  if [ "$rc" -eq 0 ]; then
    printf '| %s | %s | exit 0 | %s | %s |\n' "$id" "$file" "$expect" "$tail"
  else
    printf '| %s | %s | exit %s | %s | %s |\n' "$id" "$file" "$rc" "$expect" "$tail"
  fi
}

{
  echo "# SWEEP $HEAD ($VER)"
  echo
  echo "Gerado: $(date -u +%Y-%m-%dT%H:%M:%SZ) · kof=$KOF"
  echo
  echo "| ID | Arquivo | Resultado | Esperado | Evidência (stdout/stderr) |"
  echo "|----|---------|-----------|----------|---------------------------|"
  run_case N16  regressions/N16/n16_fwd.kf          native run "fix (N16-OK)"
  run_case N17  regressions/N17/repro.kf            native run "fix (lt0=true)"
  run_case N13  regressions/N13/repro.kf            native run "fix (1)"
  run_case N12  regressions/N12/repro.kf            native run "fix (6)"
  run_case N18  regressions/N18-SUSPECT/repro.kf    native test "aberto (crash/erro)"
  run_case J4   regressions/J4/repro_full.kf        native run "fix (exit 0)"
  run_case N19  regressions/N19-SUSPECT/repro_full.kf native run "aberto (crash/erro)"
  run_case N11  regressions/N11/repro.kf            native run "fix (1 — String_lastIndexOf runtime asm)"
  run_case N3   regressions/N3/repro.kf             native run "fix (imprime 0)"
  run_case N4   regressions/N4/repro.kf             native run "fix (a|b|c; repro evita List.size — família N20)"
  run_case N6   regressions/N6/repro.kf             native run "fix (ok)"
  run_case N7   regressions/N7/repro.kf             native run "fix (termina, 3)" 10
  run_case N9   regressions/N9/repro.kf             native run "residual (esperado aabbcc; 0.2.3 devolve abbcc)"
  run_case N8   regressions/N8/repro.kf             native run "fix (r=true, sem crash)"
  run_case N1   regressions/N1/repro.kf             native run "fix (42)"
  "$ROOT/scripts/build.sh" "tests/f3_src/unit_f3.kf" "build/tests_f3/unit_f3.kf" --only=00_core.kf,05_log.kf,10_config.kf,50_metrics.kf,20_scheduler.kf,25_event.kf,30_lifecycle.kf,40_workspace.kf,45_windex.kf,47_tools.kf,03_tool_exec.kf,57_corpus.kf,67_retrieval.kf,87_memory.kf,88_conversation.kf,89_orchestrator.kf --native-clock >/dev/null 2>&1 || true
  run_case N10  build/tests_f3/unit_f3.kf native test "aberto (N10-progressivo; TU grande)" 120
} >> "$OUT"

echo "sweep: $OUT"
