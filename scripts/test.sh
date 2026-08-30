#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
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

NATIVE_UNITS=(unit_core unit_logger unit_config unit_scheduler unit_eventbus unit_lifecycle unit_workspace integration_boot shutdown_safe)
WS_UNITS=(unit_ws_scan unit_ws_symbols unit_ws_deps unit_ws_persist unit_ws_diff)
# WS suites rodam em JVM: logica identica, sem depender de now()/process;
# native bloqueado pelo N10 (miscompile posicao-dependente, docs/compiler-bugs.md)
for u in "${NATIVE_UNITS[@]}"; do
  run_unit "$u" "test"
done

SAVED_TARGET="$TARGET"
TARGET="jvm"
for u in "${WS_UNITS[@]}"; do
  "$ROOT/scripts/build.sh" "tests/$u.kf" "build/tests/$u.kf" --no-native-clock >/dev/null 2>&1
  echo "== test $u (jvm)"
  if "$KOF" test "build/tests/$u.kf" --target jvm; then
    PASS=$((PASS+1))
  else
    FAIL=$((FAIL+1)); FAILED_NAMES+=("$u(jvm)")
  fi
done
TARGET="$SAVED_TARGET"

STRESS=(stress_events_10k stress_tasks_100k)
for s in "${STRESS[@]}"; do
  "$ROOT/scripts/build.sh" "tests/$s.kf" "build/tests_iso/$s/main.kf" --native-clock >/dev/null 2>&1
  echo "== test $s (run)"
  if "$KOF_TEST_BIN" run "build/tests_iso/$s/main.kf" --target "$TARGET"; then
    PASS=$((PASS+1))
  else
    FAIL=$((FAIL+1)); FAILED_NAMES+=("$s")
  fi
done

echo ""
echo "suites: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  printf 'failed: %s\n' "${FAILED_NAMES[*]}"
  exit 1
fi
