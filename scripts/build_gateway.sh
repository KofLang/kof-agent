#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
OUT="${1:-build/gateway.kf}"
"$ROOT/scripts/build.sh" apps/gateway/main.kf "$OUT" --with-gateway
echo "gateway artifact: $OUT (target jvm apenas — GW001)"
