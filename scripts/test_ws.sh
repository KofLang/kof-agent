#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
TARGET="${WS_TARGET:-native}"
mkdir -p "$ROOT/build/tests_ws"
pass=0; fail=0; failed=""
while IFS= read -r u; do
  [ -z "$u" ] && continue
  rm -rf "$ROOT"/build/ws_a "$ROOT"/build/ws_b "$ROOT"/build/ws_c "$ROOT"/build/ws_d "$ROOT"/build/ws_e "$ROOT"/build/ws_z2 "$ROOT"/build/wsfix*
  "$ROOT/scripts/build.sh" "tests/ws/$u" "build/tests_ws/$u" --native-clock >/dev/null 2>&1
  if "$KOF" test "build/tests_ws/$u" --target "$TARGET" >/dev/null 2>&1; then
    pass=$((pass+1))
  else
    fail=$((fail+1)); failed="$failed $u"
  fi
done < "$ROOT/tests/ws/MANIFEST"
echo "ws-tests($TARGET): $pass passed, $fail failed"
if [ $fail -gt 0 ]; then echo "failed:$failed"; exit 1; fi
