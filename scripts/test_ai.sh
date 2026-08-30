#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
pass=0; fail=0; failed=""
while IFS= read -r u; do
  [ -z "$u" ] && continue
  "$ROOT/scripts/build.sh" "tests/ai/$u" "build/tests_ai/$u" >/dev/null 2>&1
  if (cd "$ROOT" && "$KOF" test "build/tests_ai/$u" --target native >/dev/null 2>&1); then
    pass=$((pass+1))
  else
    fail=$((fail+1)); failed="$failed $u"
  fi
done < "$ROOT/tests/ai/MANIFEST"
echo "ai-tests(native): $pass passed, $fail failed"
if [ $fail -gt 0 ]; then echo "failed:$failed"; exit 1; fi
