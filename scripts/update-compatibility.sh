#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
HEAD=$(cd "$KOF4J_ROOT" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
python3 - "$HEAD" "$TS" <<'PY'
import sys, pathlib
head, ts = sys.argv[1], sys.argv[2]
p = pathlib.Path("docs/compiler/compatibility-matrix.md")
t = p.read_text()
import re
t = re.sub(r"^Baseline: .*$", f"Baseline: {head} · atualizado {ts}", t, flags=re.M)
p.write_text(t)
up = pathlib.Path("docs/compiler/upstream-status.md")
led = pathlib.Path("docs/compiler/ledger.md").read_text()
counts = {}
for st in ["Fixed","Partial","Open","Regression","Investigating","Deprecated"]:
    counts[st] = led.count(f"| {st} |")
up.write_text(f"""# UPSTREAM STATUS

- Compiler HEAD: {head}
- Atualizado: {ts}

| Estado | Quantidade |
|--------|-----------|
| Fixed | {counts['Fixed']} |
| Partial | {counts['Partial']} |
| Open | {counts['Open']} |
| Regression | {counts['Regression']} |
| Investigating | {counts['Investigating']} |
""")
print("compatibility atualizado:", counts)
PY
