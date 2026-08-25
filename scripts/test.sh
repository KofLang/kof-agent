#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${TARGET:-native}"

mkdir -p "$ROOT/build/tests"
PASS=0
FAIL=0
FAILED_NAMES=()

run_unit() {
  local name="$1"
  local mode="$2"
  "$ROOT/scripts/build.sh" "tests/$name.kf" "build/tests/$name.kf" >/dev/null 2>&1
  echo "== test $name ($mode)"
  if [ "$mode" = "test" ]; then
    if "$KOF_TEST_BIN" test "build/tests/$name.kf" --target "$TARGET"; then
      PASS=$((PASS+1))
    else
      FAIL=$((FAIL+1)); FAILED_NAMES+=("$name")
    fi
  else
    if "$KOF_TEST_BIN" run "build/tests/$name.kf" --target "$TARGET"; then
      PASS=$((PASS+1))
    else
      FAIL=$((FAIL+1)); FAILED_NAMES+=("$name")
    fi
  fi
}

KOF_TEST_BIN="$KOF"

UNITS=(unit_core unit_logger unit_config unit_scheduler unit_eventbus unit_lifecycle unit_workspace integration_boot shutdown_safe)
for u in "${UNITS[@]}"; do
  run_unit "$u" "test"
done

STRESS=(stress_events_10k stress_tasks_100k)
for s in "${STRESS[@]}"; do
  run_unit "$s" "run"
done

echo ""
echo "suites: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  printf 'failed: %s\n' "${FAILED_NAMES[*]}"
  exit 1
fi
