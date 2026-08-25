# SPEC M21 — Language Server Protocol para Kof

## Objetivo
Servidor LSP 100% em Kof compilado nativo, reusando WorkspaceIndex (M3) e Compiler Gateway (M2).

## Arquitetura

### Transporte
- stdio (Content-Length framing JSON-RPC 2.0) — único suportado na FASE 4.1
- Process bridge via scripts/lsp_bridge.sh (kof agent roda como subprocess do editor)

### Núcleo incremental
- `LspDocument`: texto versão+uri, parse sob demanda via gateway AST dump
- `SemanticModel`: símbolos por documento alimentados pelo windex (45_windex.kf)
- Diagnostics publish-on-change (debounce 300ms)

### Features (prioridade)
1. documentSymbol/outline — via windex symbol table (existe)
2. diagnostics — via golden_compiler.sh check
3. hover — docs de ToolSpec/CorpusEntry mais próximos
4. goto-definition/references/rename — sobre índice incremental
5. completion — palavras-chave + símbolos do workspace
6. semantic tokens — classificação lexer-level

### Riscos
| Risco | Mitigação |
|---|---|
| N10 em TU grande | --only= lsp parts isolados |
| JSON escape (N-family strings) | escapeJson já existe em 00_core |
| Gateway sem AST estruturado (GW-AST-DUMP) | fase 1 usa regex-symbols, não AST |

## Definition of Done
- 30 testes one-per-process (framing, initialize, didOpen/didChange, symbols, diagnostics)
- Benchmark: autocomplete/symbol lookup/rename latency → benchmarks/native-M21.json
- Compatibility sweep registrado
