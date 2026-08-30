#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 - "$ROOT" <<'PY'
import sys, os, re, subprocess
import pathlib
root = pathlib.Path(sys.argv[1])
rep = root/"docs/compiler/reproductions"
fixed, open_, inv = [], [], []
for f in sorted(rep.glob("*.md")):
    t = f.read_text()
    st = re.search(r"\*\*Estado:\*\* (\w+)", t)
    st = st.group(1) if st else "?"
    tgt = re.search(r"\*\*Target afetado:\*\* (.+)", t)
    tgt = tgt.group(1).strip() if tgt else "?"
    sym = re.search(r"## Sintoma\n(.+)", t)
    sym = sym.group(1).strip() if sym else ""
    row = (f.stem, tgt, sym)
    {"Fixed": fixed}.get(st)
    if st == "Fixed": fixed.append(row)
    elif st in ("Open","Partial","Regression"): open_.append(row+(st,))
    else: inv.append(row)
k4j = os.environ.get("KOF4J_ROOT", "/home/luna/kof/Kof4j")
out = root/"docs/compiler/upstream-report-HEAD.md"
head = subprocess.run(["git", "-C", k4j, "rev-parse", "--short", "HEAD"], capture_output=True, text=True).stdout.strip() or "unknown"
lines = [f"# Relatório upstream — kof-agent → KofLang/compiler ({head})","",
         "Bugs descobertos pelo kof-agent durante M1–M12, com repros mínimos.",""]
def table(rows):
    r = ["| ID | Target | Sintoma |","|----|--------|---------|"]
    for i,t,s in rows: r.append(f"| {i} | {t} | {s} |")
    return r
if fixed:
    lines += ["## Corrigidos (confirmar no changelog)"] + table(fixed) + [""]
if open_:
    lines += ["## Abertos/Parciais — prioridade de correção"] + table(open_) + [""]
if inv:
    lines += ["## Em investigação"] + table(inv) + [""] 
lines += ["## Recomendação prioritária","",
          "1. N10 (miscompile progressivo por tamanho/posição do TU) — trava M3–M9.",
          "2. N6/N7/N8/N9 — semântica/strings básicas quebradas no Native.",
          "3. SC1–SC5 — cobertura semântica (validações ausentes).",
          "4. N11/N3/N4 — APIs de string/argv.",
          "",
          "Repros completos: docs/compiler/reproductions/<ID>.md"]
outp = root/"docs/compiler/upstream-report-HEAD.md"
outp.write_text("\n".join(lines)+"\n")
print("upstream report:", outp)
PY
