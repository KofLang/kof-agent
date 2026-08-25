#!/usr/bin/env bash
# Golden compiler tests — ponte GW-DIAG-JSON (mesmo schema de
# CheckResult.toJson() do CompilerGateway). Uso: golden_compiler.sh [--bless]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KOF="${KOF:-/home/luna/kof/Kof4j/bin/kof}"
DIR="$ROOT/tests/golden/compiler"
MANIFEST="$DIR/MANIFEST"
BLESS=0
if [ "${1:-}" = "--bless" ]; then BLESS=1; fi

pass=0; fail=0; tmp="$DIR/.manifest.tmp"; : > "$tmp"
while IFS='|' read -r file wantExit wantCode || [ -n "$file" ]; do
  if [ -z "$file" ]; then continue; fi
  f="$ROOT/$file"
  set +e
  out=$("$KOF" check "$f" 2>&1)
  rc=$?
  set -e
  gotCode=$(printf '%s' "$out" | { grep -oE '\[(SEM|PARS|ARITH|GW|CHK)[A-Z0-9]*\]' || true; } | head -1 | tr -d '[]')
  if [ -z "$gotCode" ]; then gotCode="*"; fi
  if [ "$BLESS" = "1" ]; then
    echo "$file|$rc|$gotCode" >> "$tmp"
    echo "BLESS $file exit=$rc code=$gotCode"
  else
    okExit=0; [ "$rc" = "$wantExit" ] && okExit=1
    okCode=0; { [ "$wantCode" = "*" ] || [ "$wantCode" = "$gotCode" ]; } && okCode=1
    if [ "$okExit" = "1" ] && [ "$okCode" = "1" ]; then
      pass=$((pass+1)); echo "PASS $file"
    else
      fail=$((fail+1)); echo "FAIL $file want=($wantExit,$wantCode) got=($rc,$gotCode)"
    fi
  fi
done < "$MANIFEST"

if [ "$BLESS" = "1" ]; then
  mv "$tmp" "$MANIFEST"
  echo "manifest blessed."
  exit 0
fi
echo "golden: $pass passed, $fail failed"
if [ "$fail" -eq 0 ]; then exit 0; fi
exit 1
