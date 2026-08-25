#!/usr/bin/env python3
import json, pathlib, sys
root = pathlib.Path(__file__).resolve().parent.parent
corpus = root/"corpus"
cats, symbols, builtin = {}, {}, set()
known = {"spawn","record","constructor","Window","Palette.red","web.app","json.decode","json.encode","passwords.hash","db.connect","orm.save","log.info","config.str","crypto.sha256","secrets.get","jwt.verify"}
docs = 0
for md in corpus.rglob("*.md"):
    if md.name == "README.md": continue
    docs += 1
    cat = md.parent.name
    cats[cat] = cats.get(cat,0)+1
    txt = md.read_text()
    for line in txt.splitlines():
        if line.strip().startswith("symbols:"):
            for s in line.split(":",1)[1].split(","):
                s = s.strip()
                if s:
                    symbols.setdefault(s, 0); symbols[s] += 1
coverage = {k: (k in known) for k in symbols}
out = {"docs": docs, "by_category": cats, "symbols": symbols,
       "builtin_coverage": {k:v for k,v in coverage.items()},
       "orphan_symbols": [k for k,v in coverage.items() if not v]}
p = root/"compiler-observatory"/"coverage"/"corpus-intel.json"
p.parent.mkdir(parents=True, exist_ok=True)
p.write_text(json.dumps(out, indent=2))
print(json.dumps({"docs":docs,"categories":len(cats),"symbols":len(symbols),"orphans":out["orphan_symbols"]}))
