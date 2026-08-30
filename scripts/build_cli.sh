#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
"$ROOT/scripts/build.sh" apps/cli/main.kf build/cli.kf --native-clock
rm -rf "$ROOT/build/out"
"$KOF" build "$ROOT/build/cli.kf" --target native --output "$ROOT/build/out"
echo "CLI ready: scripts/kof-agent (binary: build/out/Default/Main)"
