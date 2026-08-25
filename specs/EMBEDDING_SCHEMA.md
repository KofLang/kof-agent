# EMBEDDING SCHEMA (M6)
embedDocument(title,body)/embedQuery/embedWorkspace/embedSymbol/
embedDiagnostic → List<String> tokens (split não-alfa + split CamelCase via
injeção de espaço em maiúsculas). Persistido apenas indiretamente hoje
(cache de contexto por query-hash); embedding.cache vetorial entra quando o
Runtime AI fornecer float vectors (M10/M11 — FLT/SIMD upstream).
