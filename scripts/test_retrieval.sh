#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
mkdir -p "$ROOT/build/tests_ret"
pass=0; fail=0; failed=""
while IFS= read -r u; do
  case "$u" in *.kf) tu="$u";; *) tu="$u.kf";; esac
  [ -z "$u" ] && continue
  rm -rf "$ROOT/build/ret_corpus" "$ROOT/build/ret_cache"
  "$ROOT/scripts/build.sh" "tests/ret/$u" "build/tests_ret/$u" >/dev/null 2>&1
  if (cd "$ROOT" && "$KOF" test "build/tests_ret/$tu" --target native >/dev/null 2>&1); then
    pass=$((pass+1))
  else
    fail=$((fail+1)); failed="$failed $u"
  fi
done < "$ROOT/tests/ret/MANIFEST"
echo "retrieval-tests(native): $pass passed, $fail failed"
if [ $fail -gt 0 ]; then echo "failed:$failed"; exit 1; fi
