# DATASET BUILDER (M12)
Emissor JSONL determinístico (scripts/build_dataset.py) sobre fontes
verificáveis: corpus/*.md (instruction/output), tests/golden (repair),
compiler-regressions (negative), examples compiláveis. Cada linha carrega
checksum sha256 do conteúdo-fonte; docs sem frontmatter válido são pulados e
contados como skipped. Tipos: positive/negative/repair/retrieval/conversation/
planning/execution. Stats: total, por tipo, coverage de categorias.
Parquet/GGUF-meta: planejado.
