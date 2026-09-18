# Milestone 06 — Retrieval Engine

Status:

* 🟡 Parcial — engine implementada e compilando; verificação nativa bloqueada
  pelo N10 (quarto nascimento de parte crashando no backend 0.0.14).

## Resumo Executivo

Retrieval Engine lexical-first implementada: tokenizador (split não-alfa +
CamelCase), embeddings placeholder por conjuntos de tokens (interface completa:
document/query/workspace/symbol/diagnostic), expansão automática de símbolos
(spawn→scheduler/task/future/runtime), receitas (crud→http/json/database/
validation/testing) e diagnósticos (code→workaround→exemplo→docs), scoring
multi-sinal (overlap + boosts id/title/symbol/diag/recipe/recent), Top-K com
dedup por (source,id) e orçamento de caracteres, cache versionado RETC por
hash da query com eventos cache.hit/miss. Integra-se ao Corpus Index (M5) e
publica contexto JSON pronto para o Brain (M7).

## Arquivos Criados

agent/runtime/67_retrieval.kf · tests/ret_src/unit_ret.kf · tests/ret/*.kf
(6 gerados + MANIFEST) · scripts/test_retrieval.sh · specs/RETRIEVAL_ENGINE.md ·
specs/EMBEDDING_SCHEMA.md · specs/RANKING.md · REPORT_M06.md

## Arquivos Modificados

scripts/build.sh (parte 67) · docs/status.md · docs/TASKS.md · README.md

## Arquitetura Implementada

Workspace/Corpus → Query Parser (tokenize) → Embedding Query → expansões →
Ranking multi-sinal determinístico → Context Builder (dedup + budget) → Brain.
Cache RETC v1 reutilizando o envelope MAGIC|VERSION|CRC das engines anteriores.

## APIs Criadas

embedDocumentTokens/embedQueryTokens/embedWorkspaceTokens/embedSymbolTokens/
embedDiagnosticTokens · retExpandSymbol/Recipe/Diagnostic · retScoreDoc ·
retBuildContext(query,topK,maxChars,recentFiles) · retCacheSave/Load ·
retTokenize/retLower/retOverlap/retCountOccurrences(reuso).

## Ferramentas Criadas

Nenhuma tool nova exposta (retrieval é consumido pelo Brain via chamada
direta; exposição na Tool API chega com o Editor Protocol M4+).

## Testes

6 testes autorados cobrindo ranking, diagnostic boost, recipe expansion,
dedup, budget e cache hit — **execução bloqueada pelo N10** (segfault no
primeiro build da parte; probes individuais de tokenize/load já validados em
artefatos menores nas milestones anteriores). Meta do RFC (>70) será colhida
na mesma rodada anti-N10 que destrava M3/M4/M5: os corpos de teste crescem
mecanicamente a partir das 9 fontes de recuperação listadas no RFC.

## Benchmarks

Harness PENDENTE-N10 (TopK latency, cache hit/miss, ranking, context build).
Padrão bench_m0X.sh já definido nas milestones anteriores.

## Decisões Técnicas

1. Lexical-first honesto: sem vetores falsos; embeddings placeholder são
   conjuntos de tokens e a interface já espelha a forma vetorial futura.
2. Expansões como tabelas de código (determinístico, auditável) antes de
   aprendidas (M12).
3. Cache por hash da query normalizada (lowercase) — hit determinístico.
4. Orçamento de contexto em caracteres (proxy de tokens até tokenizer de
   modelo existir no agente).

## Pendências

- Playbook anti-N10 na parte 67 (colher 6→70+ testes, benchmarks, baseline).
- embedding.cache vetorial + float ops (bloqueio FLT/SIMD upstream, Q2).
- Histórico de conversação como fonte (chega com sessões do Brain M7).

## Riscos

- Acúmulo de partes "nascendo crashando": cada uma exige bisect — reforça a
  prioridade máxima do reporte upstream dos 15 achados (J2/N10–N13/SC1–5).

## Próxima Milestone Recomendada

**Rodada de estabilização** (fora do roadmap numerado, meia sessão):
aplicar o playbook anti-N10 nas partes 57 e 67 (bisect por truncamento +
reordenação + conversões record→classe quando indicado), colher os testes
M5/M6 e benchmarks pendentes — depois **M7 — Kof Brain**.
