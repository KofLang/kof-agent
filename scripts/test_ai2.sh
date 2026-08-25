#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export KOF="${KOF:-/home/luna/kof/Kof4j/bin/kof}"
pass=0; fail=0; failed=""
while IFS= read -r u; do
  [ -z "$u" ] && continue
  "$ROOT/scripts/build.sh" "tests/ai2/$u" "build/tests_ai2/$u" >/dev/null 2>&1
  if (cd "$ROOT" && "$KOF" test "build/tests_ai2/$u" --target native >/dev/null 2>&1); then
    pass=$((pass+1))
  else
    fail=$((fail+1)); failed="$failed $u"
  fi
done < "$ROOT/tests/ai2/MANIFEST"
echo "ai2-tests(native): $pass passed, $fail failed"
if [ $fail -gt 0 ]; then echo "failed:$failed"; exit 1; fi
