#!/usr/bin/env python3
"""KofLM v1 dataset builder — corpus real PT-BR de /home/luna/kof/Kof4j/training + specs/docs do agent."""
import json, hashlib, pathlib, sys

ROOT = pathlib.Path("/home/luna/kof-agent")
SOURCES = [
    pathlib.Path("/home/luna/kof/Kof4j/training"),
    ROOT / "specs",
    ROOT / "docs",
    ROOT / "tests",
]
OUT = ROOT / "training" / "dataset" / "jsonl"
OUT.mkdir(parents=True, exist_ok=True)

def cat_for(p: pathlib.Path) -> str:
    s = str(p).lower()
    for k, c in [("bug", "compiler"), ("spec", "compiler"), ("runtime", "runtime"),
                 ("tool", "tooling"), ("gguf", "ai"), ("tokenizer", "ai"),
                 ("test", "testing"), ("doc", "language"), ("readme", "language")]:
        if k in s:
            return c
    return "language"

def qa_from_text(p: pathlib.Path, text: str):
    """Gera pares QA simples: título/pergunta -> treino de contexto."""
    first = text.strip().splitlines()[0] if text.strip() else p.name
    yield {
        "instruction": f"Explique o conteúdo de {p.name}.",
        "input": first[:120],
        "output": " ".join(text.split())[:600],
        "source": str(p),
        "tags": [cat_for(p)],
    }

seen, rows = set(), []
files_scanned = 0
for src in SOURCES:
    if not src.exists():
        continue
    for p in sorted(src.rglob("*")):
        if p.is_file() and p.suffix.lower() in {".kf", ".md", ".txt", ".json", ".yaml", ".toml", ".csv"}:
            try:
                text = p.read_text(encoding="utf-8", errors="ignore")
            except Exception:
                continue
            if len(text.strip()) < 40:
                continue
            files_scanned += 1
            for row in qa_from_text(p, text):
                key = hashlib.sha256(row["output"].encode()).hexdigest()
                if key in seen:
                    continue
                seen.add(key)
                rows.append(row)

# split determinístico seed 42
def bucket(i: int) -> str:
    v = abs((42 * 1103515245 + i * 12345)) % 100
    return "train" if v < 90 else ("validation" if v < 95 else "test")

splits = {"train": [], "validation": [], "test": []}
for i, r in enumerate(rows):
    r["bucket"] = bucket(i)
    splits[r["bucket"]].append(r)

manifest = {"dataset_version": "koflm-ds-v1", "seed": 42, "documents": files_scanned,
            "examples": len(rows), "checksum": hashlib.sha256(
                json.dumps(rows, sort_keys=True).encode()).hexdigest()}
(OUT / "dataset.manifest.json").write_text(json.dumps(manifest, indent=2))
for name, rs in splits.items():
    with open(OUT / f"dataset_{name}.jsonl", "w") as f:
        for r in rs:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")
print(json.dumps({"examples": len(rows), "train": len(splits['train']),
                  "validation": len(splits['validation']), "test": len(splits['test']),
                  "checksum16": manifest["checksum"][:16]}))
