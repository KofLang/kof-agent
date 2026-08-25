#!/usr/bin/env python3
import json, hashlib, pathlib, sys
ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "datasets"; OUT.mkdir(exist_ok=True)
rows, skipped = [], 0

def chk(s): return hashlib.sha256(s.encode()).hexdigest()[:16]

for md in sorted((ROOT/"corpus").rglob("*.md")):
    if md.name == "README.md": continue
    txt = md.read_text()
    if not txt.startswith("---\n"): skipped += 1; continue
    end = txt.find("\n---\n", 4)
    if end < 0: skipped += 1; continue
    block, body = txt[4:end], txt[end+5:]
    meta = {}
    for line in block.splitlines():
        if ":" in line:
            k, v = line.split(":", 1); meta[k.strip()] = v.strip()
    if "id" not in meta: skipped += 1; continue
    rows.append({
        "type": "retrieval" if meta.get("category")=="diagnostics" else "positive",
        "id": meta["id"],
        "instruction": f"Explique {meta.get('title', meta['id'])}",
        "output": body.strip(),
        "intent": "ExplainDiagnostic" if meta.get("category")=="diagnostics" else "SearchSymbol",
        "entities": {"symbols": [s for s in meta.get("symbols","").split(",") if s]},
        "source": str(md.relative_to(ROOT)),
        "checksum": chk(txt),
        "languageVersion": meta.get("languageVersion","0.0.14"),
    })

for kf in sorted((ROOT/"tests/golden/compiler").glob("*.kf")):
    exp = kf.with_suffix(".expected.json")
    if not exp.exists(): continue
    m = json.loads(exp.read_text())
    neg = m.get("expected",{}).get("exit_code",0) != 0
    rows.append({
        "type": "negative" if neg else "positive",
        "id": kf.stem,
        "instruction": f"{'Corrija o erro' if neg else 'Valide'} o programa {kf.stem}",
        "output": kf.read_text().strip(),
        "expectedDiagnostics": m.get("expected",{}).get("first_diagnostic_code"),
        "source": str(kf.relative_to(ROOT)),
        "checksum": chk(kf.read_text()),
    })

for kf in sorted((ROOT/"tests/planner").glob("*.kf")):
    rows.append({"type":"planning","id":kf.stem,"instruction":kf.stem,"output":kf.read_text()[:400],"source":str(kf.relative_to(ROOT)),"checksum":chk(kf.read_text())})
for kf in sorted((ROOT/"tests/exec").glob("*.kf")):
    rows.append({"type":"execution","id":kf.stem,"instruction":kf.stem,"output":kf.read_text()[:400],"source":str(kf.relative_to(ROOT)),"checksum":chk(kf.read_text())})
seen=set(); uniq=[]
for r in rows:
    if r["checksum"] in seen: continue
    seen.add(r["checksum"]); uniq.append(r)
rows=uniq
manifest = {"version": 1, "count": len(rows), "skipped_invalid": skipped,
            "by_type": {}}
for r in rows: manifest["by_type"][r["type"]] = manifest["by_type"].get(r["type"],0)+1
out = OUT/"kof-dataset.jsonl"
with out.open("w") as fh:
    for r in rows: fh.write(json.dumps(r, ensure_ascii=False)+"\n")
(OUT/"manifest.json").write_text(json.dumps(manifest, indent=2))
csv = OUT/"kof-dataset.csv"
with csv.open("w") as fh:
    fh.write("type,id,instruction,checksum\n")
    for r in rows:
        fh.write(f"{r['type']},{r['id']},{r['checksum']}\n")
print(json.dumps(manifest))
