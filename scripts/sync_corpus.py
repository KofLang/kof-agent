#!/usr/bin/env python3
"""Sync do corpus Kof a partir do training/ oficial do Kof4j (fonte da verdade).
Idempotente: re-rodar = mesma saida byte-a-byte. Uso: bash scripts/sync_corpus.sh"""
import os, re, sys, shutil

src = os.environ.get("KOF4J_ROOT", os.path.expanduser("~/Documentos/Kof4j"))
SRC = os.path.join(src, "training")
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DST = os.path.join(ROOT, "corpus", "kof")
SUBS = ["language", "idioms", "migration", "patterns", "anti-patterns",
        "reference", "tooling", "examples"]

if not os.path.isdir(SRC):
    sys.exit(f"sync_corpus: nao achei {SRC} (exporte KOF4J_ROOT)")

shutil.rmtree(DST, ignore_errors=True)
n = 0
for sub in SUBS:
    d = os.path.join(SRC, sub)
    if not os.path.isdir(d):
        continue
    out = os.path.join(DST, sub)
    os.makedirs(out, exist_ok=True)
    for fn in sorted(os.listdir(d)):
        if not fn.endswith(".md"):
            continue
        lang = "pt" if fn.endswith(".pt_BR.md") else "en"
        base = fn[:-len(".pt_BR.md")] if lang == "pt" else fn[:-len(".md")]
        text = open(os.path.join(d, fn), encoding="utf-8").read()
        # reescreve links relativos p/ caminho a partir da raiz do corpus
        def fix(m):
            path = m.group(1)
            if path.startswith("http"):
                return m.group(0)
            path = path.split("#")[0].split("/")[-1]
            return "](" + os.path.join("kof", sub, path) + ")"
        text = re.sub(r"\]\(([^)]+)\)", fix, text)
        mt = re.search(r"^# (.+)$", text, re.M)
        title = (mt.group(1) if mt else base).strip()
        fm = ("---\n"
              f"id: kof-{sub}-{base}-{lang}\n"
              f"title: {title}\n"
              "module: kof\n"
              f"category: kof-{sub}\n"
              "version: 1\n"
              "languageVersion: 0.4.0\n"
              "author: Kof4j\n"
              "createdAt: 2026-09-18\n"
              "updatedAt: 2026-09-18\n"
              f"keywords: kof,{sub},{base}\n"
              "status: stable\n"
              f"tags: kof,{sub},{lang}\n"
              "---\n")
        open(os.path.join(out, fn), "w", encoding="utf-8").write(fm + text)
        n += 1
print(f"sync_corpus: {n} docs em corpus/kof/ (fonte: {SRC})")
