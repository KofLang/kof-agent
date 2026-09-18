# Milestone 12 — Dataset Builder + Kof SLM Bootstrap

Status:

* ✅ Núcleo — pipeline determinístico de dataset JSONL com curadoria por
  checksum; **26 exemplos** na primeira extração (20 positive · 4 negative ·
  2 retrieval), 0 skipped. Parquet/GGUF-meta planejados.

## Resumo
Pipeline oficial de treinamento: corpus + goldens + regressões → JSONL
schema-versionado (type/id/instruction/output/intent/entities/source/
checksum/languageVersion). Curadoria: apenas conteúdo com frontmatter válido
entra; goldens carregam expected diagnostics; checksums sha256 por fonte.
Manifest.json com contagens por tipo = base do split train/val/test futuro
e das estatísticas de vocabulário (tokenizador M10 já existe).

## Arquivos Criados / Modificados
scripts/build_dataset.py · datasets/kof-dataset.jsonl · datasets/manifest.json ·
specs/DATASET.md · REPORT_M12.md · docs/status.md · README.md · docs/TASKS.md

## APIs / Testes / Benchmarks / Pendências
API: scripts/build_dataset.py [--out]. Cobertura cresce automaticamente a cada
golden/corpus novo (regeneração determinística). Stats de tokens via
tokenizer M10 pendentes de integração no emissor. >50 testes RFC desta
fase pertencem ao ciclo M5/M12-colheita anti-N10.
