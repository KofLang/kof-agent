#!/usr/bin/env python3
"""Corpus sintético PT-BR: expande dataset com QA gerados por templates determinísticos."""
import json, hashlib, pathlib
OUT = pathlib.Path("datasets/synthetic/koflm-synthetic.jsonl")
OUT.parent.mkdir(parents=True, exist_ok=True)
topics = ["Scheduler", "EventBus", "Planner", "Retrieval", "MemoryLayer", "ToolOrchestrator",
          "GGUF", "Tokenizer", "KV Cache", "Sampler", "RoPE", "Quantização",
          "Workspace", "LSP", "Observatory", "Journal"]
verbs = ["Explique", "Descreva a arquitetura de", "Quais os casos de uso de", "Compare implementações de"]
diffs = ["facil", "medio", "dificil"]
seen, n = set(), 0
with open(OUT, "w") as f:
    for t in topics:
        for v in verbs:
            for d in range(3):
                instr = f"{v} {t} no contexto do Kof Agent."
                ans = (f"{t}: componente do Kof Agent escrito em Kof puro, compilado nativo. "
                       f"Nível: {diffs[d]}. Integra-se via EventBus e MetricsRegistry, sem dependências externas.")
                key = hashlib.sha256(instr.encode()).hexdigest()
                if key in seen: continue
                seen.add(key); n += 1
                f.write(json.dumps({"instruction": instr, "input": "", "output": ans,
                                    "source": "synthetic", "tags": ["sintetico", t.lower()],
                                    "difficulty": diffs[d], "checksum": key}, ensure_ascii=False) + "\n")
print(json.dumps({"synthetic_examples": n}))
