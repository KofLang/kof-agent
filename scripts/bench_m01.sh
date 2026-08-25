#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export KOF="${KOF:-/home/luna/kof/Kof4j/bin/kof}"
TARGET="${TARGET:-native}"
RUNS="${RUNS:-3}"

BENCHES=(bench_init bench_events bench_scheduler bench_logger bench_pool_scaling)

mkdir -p "$ROOT/benchmarks/results/$TARGET-M01" "$ROOT/benchmarks/baselines"

for b in "${BENCHES[@]}"; do
  "$ROOT/scripts/build.sh" "benchmarks/$b.kf" "build/bench/$b.kf" >/dev/null
  rm -rf "$ROOT/build/bench-out"
  "$KOF" build "$ROOT/build/bench/$b.kf" --target native --output "$ROOT/build/bench-out" >/dev/null 2>&1
  BIN_PATH="$ROOT/build/bench-out/Default/Main"
  echo "== $b"
  for r in $(seq 1 "$RUNS"); do
    OUT=$( (cd "$ROOT" && timeout 120 "$BIN_PATH") )
    echo "$OUT" | tee "$ROOT/benchmarks/results/$TARGET-M01/$b.run$r.json"
  done
done

{
  echo "{"
  echo "  \"target\": \"$TARGET\","
  echo "  \"milestone\": \"M01\","
  echo "  \"date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
  echo "  \"env\": {\"kernel\": \"$(uname -r)\", \"arch\": \"$(uname -m)\"},"
  echo "  \"results\": ["
  first=1
  for b in "${BENCHES[@]}"; do
    f="$ROOT/benchmarks/results/$TARGET-M01/$b.run$RUNS.json"
    [ -f "$f" ] || continue
    if [ $first -eq 0 ]; then echo ","; fi
    first=0
    cat "$f"
  done
  echo ""
  echo "  ]"
  echo "}"
} > "$ROOT/benchmarks/baselines/$TARGET-M01.json"

echo ""
echo "baseline: benchmarks/baselines/$TARGET-M01.json"
cat "$ROOT/benchmarks/baselines/$TARGET-M01.json"
