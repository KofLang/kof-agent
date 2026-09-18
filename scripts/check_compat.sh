#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VIOLATIONS=$(grep -rnE "\+=|== null|!= null|^[^/]*\bcontinue\b" \
  "$ROOT"/agent/runtime/*.kf "$ROOT"/apps/cli/*.kf "$ROOT"/tests/*.kf "$ROOT"/benchmarks/*.kf 2>/dev/null || true)
if [ -n "$VIOLATIONS" ]; then
  echo "compat violations (see docs/compiler-bugs.md):"
  echo "$VIOLATIONS"
  exit 1
fi
echo "native-compat style: OK"
