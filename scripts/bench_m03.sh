#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
mkdir -p "$ROOT/benchmarks/results/native-M03" "$ROOT/benchmarks/baselines"
for b in bench_ws_s bench_ws_m bench_ws_l; do
  "$ROOT/scripts/build.sh" "benchmarks/$b.kf" "build/bench/$b.kf" >/dev/null
  rm -rf "$ROOT/build/bench-out"
  "$KOF" build "$ROOT/build/bench/$b.kf" --target native --output "$ROOT/build/bench-out" >/dev/null 2>&1
  rm -rf "$ROOT/build/wsbench"
  echo "== $b"
  (cd "$ROOT" && timeout 120 "$ROOT/build/bench-out/Default/Main") | tee "$ROOT/benchmarks/results/native-M03/$b.json"
done
{
  echo "{\"target\":\"native\",\"milestone\":\"M03\",\"results\":["
  first=1
  for f in "$ROOT"/benchmarks/results/native-M03/*.json; do
    if [ $first -eq 0 ]; then echo ","; fi
    first=0
    cat "$f"
  done
  echo "]}"
} > "$ROOT/benchmarks/baselines/native-M03.json"
echo "baseline: benchmarks/baselines/native-M03.json"
