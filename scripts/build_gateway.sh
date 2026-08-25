#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export KOF="${KOF:-/home/luna/kof/Kof4j/bin/kof}"
OUT="${1:-build/gateway.kf}"
"$ROOT/scripts/build.sh" apps/gateway/main.kf "$OUT" --with-gateway
echo "gateway artifact: $OUT (target jvm apenas — GW001)"
