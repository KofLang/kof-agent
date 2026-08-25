# RETRIEVAL ENGINE (M6) — implementado (lexical-first; embeddings reais chegam com Runtime AI)

Fluxo: Query → tokenize+expansão (symbol/recipe/diagnostic) → scoring multi-sinal
(overlap lexical +5 id/title, +3 symbol-boost, +4 diagnostic-boost, +2 recipe,
+2 recent-files, +2 workspace-keywords) → Top-K com dedup e orçamento de
caracteres → contexto JSON para o Brain. Cache versionado RETC por hash da
query (eventos cache.hit/miss). Embeddings placeholder = conjuntos de tokens;
interface pronta p/ vetores do Runtime AI (M10).
