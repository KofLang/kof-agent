#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export KOF="${KOF:-/home/luna/kof/Kof4j/bin/kof}"
mkdir -p "$ROOT/build/tests_brain"
pass=0; fail=0; failed=""
while IFS= read -r u; do
  [ -z "$u" ] && continue
  rm -rf "$ROOT/build/brain_corpus"
  "$ROOT/scripts/build.sh" "tests/brain/$u" "build/tests_brain/$u" --native-clock >/dev/null 2>&1
  if (cd "$ROOT" && "$KOF" test "build/tests_brain/$u" --target native >/dev/null 2>&1); then
    pass=$((pass+1))
  else
    fail=$((fail+1)); failed="$failed $u"
  fi
done < "$ROOT/tests/brain/MANIFEST"
echo "brain-tests(native): $pass passed, $fail failed"
if [ $fail -gt 0 ]; then echo "failed:$failed"; exit 1; fi
