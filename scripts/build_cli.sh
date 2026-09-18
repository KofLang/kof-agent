#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
mkdir -p "$ROOT/build/tu"
"$ROOT/scripts/build.sh" apps/cli/main.kf build/tu/cli.kf --native-clock
rm -rf "$ROOT/build/out"
"$KOF" build "$ROOT/build/tu/cli.kf" --target native --output "$ROOT/build/out"
echo "CLI ready: scripts/kof-agent (binary: build/out/Default/Main)"
