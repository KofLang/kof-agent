# M15 — CONTEXT ORCHESTRATOR
orchFuse(ix, mem, query, topK, maxChars): fusão Corpus(retrieval M6) +
MemoryLayer(semântica) com dedup por id e orçamento de caracteres.
Saída JSON {query, chunks:[{source,id}]}.
