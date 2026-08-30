#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
pass=0; fail=0
while IFS= read -r u; do
  [ -z "$u" ] && continue
  "$ROOT/scripts/build.sh" "tests/planner/$u" "build/tests_planner/$u" --native-clock >/dev/null 2>&1
  if (cd "$ROOT" && "$KOF" test "build/tests_planner/$u" --target native >/dev/null 2>&1); then
    pass=$((pass+1))
  else
    fail=$((fail+1))
  fi
done < "$ROOT/tests/planner/MANIFEST"
echo "planner-tests(native): $pass passed, $fail failed"
[ $fail -eq 0 ]
