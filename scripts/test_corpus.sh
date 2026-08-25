#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export KOF="${KOF:-/home/luna/kof/Kof4j/bin/kof}"
mkdir -p "$ROOT/build/tests_corpus"
pass=0; fail=0; failed=""
while IFS= read -r u; do
  [ -z "$u" ] && continue
  rm -rf "$ROOT/build/cdup" "$ROOT/build/cinv" "$ROOT/build/cok" "$ROOT/build/corph" "$ROOT/build/ccache" "$ROOT/build/ccache2"
  "$ROOT/scripts/build.sh" "tests/corpus/$u" "build/tests_corpus/$u" --native-clock >/dev/null 2>&1
  if (cd "$ROOT" && "$KOF" test "build/tests_corpus/$u.kf" --target native >/dev/null 2>&1); then
    pass=$((pass+1))
  else
    fail=$((fail+1)); failed="$failed $u"
  fi
done < "$ROOT/tests/corpus/MANIFEST"
echo "corpus-tests(native): $pass passed, $fail failed"
if [ $fail -gt 0 ]; then echo "failed:$failed"; exit 1; fi
