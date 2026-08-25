#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KOF="${KOF:-/home/luna/kof/Kof4j/bin/kof}"
WORK="$ROOT/build/spike-q1"
N_A="${N_A:-250}"
rm -rf "$WORK"; mkdir -p "$WORK/single" "$WORK/medium" "$WORK/large"

printf 'record P(Int a)\nmain() {\n    var p = P(1)\n    println(p.a())\n}\n' > "$WORK/single/one.kf"
for i in $(seq 1 10); do
  printf 'record M%d(Int v)\nmain() {\n    var m = M%d(%d)\n    println(m.v())\n}\n' "$i" "$i" "$i" > "$WORK/medium/f$i.kf"
done
for i in $(seq 1 50); do
  printf 'record L%d(Int v)\nmainX%d() {\n    var l = L%d(1)\n}\n' "$i" "$i" "$i" > "$WORK/large/g$i.kf"
done

RAW="$WORK/raw"; mkdir -p "$RAW"

# Gateway A — subprocess por operação
for i in $(seq 1 "$N_A"); do
  t0=$(date +%s%N)
  "$KOF" check "$WORK/single/one.kf" >/dev/null 2>&1 || true
  t1=$(date +%s%N)
  echo $(( (t1 - t0) / 1000000 )) >> "$RAW/A.txt"
done

# Gateway B — residente-amortizado: 1 JVM valida o diretório inteiro (10 arquivos)
for r in $(seq 1 60); do
  t0=$(date +%s%N)
  "$KOF" check "$WORK/medium" >/dev/null 2>&1 || true
  t1=$(date +%s%N)
  echo $(( (t1 - t0) )) >> "$RAW/B_batch_ns.txt"
done

# Incremental simulado: toca 1 arquivo e revalida o diretório
for r in $(seq 1 30); do
  printf '// touch %s\n' "$r" >> "$WORK/medium/f1.kf"
  t0=$(date +%s%N)
  "$KOF" check "$WORK/medium" >/dev/null 2>&1 || true
  t1=$(date +%s%N)
  echo $(( (t1 - t0) / 1000000 )) >> "$RAW/B_incr.txt"
done

# Projeto grande (50 arquivos) — custo de validação completa
for r in $(seq 1 15); do
  t0=$(date +%s%N)
  "$KOF" check "$WORK/large" >/dev/null 2>&1 || true
  t1=$(date +%s%N)
  echo $(( (t1 - t0) / 1000000 )) >> "$RAW/Large.txt"
done

echo "GW-C: BLOCKED (no FFI/Java-interop in Kof 0.0.14)" > "$RAW/C.txt"
echo "raw data em $RAW"
