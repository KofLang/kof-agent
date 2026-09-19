#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
mkdir -p "$ROOT/build/tests_quant"
pass=0; fail=0; failed=""
while IFS= read -r u; do
  case "$u" in *.kf) tu="$u";; *) tu="$u.kf";; esac
  [ -z "$u" ] && continue
  rm -rf "$ROOT/build/kqtest"
  "$ROOT/scripts/build.sh" "tests/quant/$u" "build/tests_quant/$u" --native-clock >/dev/null 2>&1
  if (cd "$ROOT" && "$KOF" test "build/tests_quant/$tu" --target native >/dev/null 2>&1); then
    pass=$((pass+1))
  else
    fail=$((fail+1)); failed="$failed $u"
  fi
done < "$ROOT/tests/quant/MANIFEST"
echo "quant-tests(native): $pass passed, $fail failed"
if [ $fail -gt 0 ]; then echo "failed:$failed"; exit 1; fi
