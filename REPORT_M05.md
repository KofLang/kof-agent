# Milestone 05 — Corpus Engine

Status:

* 🟡 Parcial — engine completa e corpus oficial semeado (22 docs); suíte
  autorada (15 testes one-per-process) aguarda a mesma rodada anti-N10 que
  trava M3/M4 (primeiro build da parte nova nasce crashando no backend
  0.0.14 — padrão já visto e resolvido em M1/M3 via bisect).

## Resumo Executivo

Corpus Engine implementada: loader de markdown com frontmatter de 16 campos,
checksum por documento (djb2), validator com 6 classes de issue (duplicate-id,
invalid-file, checksum-changed, broken-link, orphan-symbol + base), Symbol
Registry builtin com 16 símbolos da linguagem, Diagnostic Registry integrado
ao ledger de bugs (workaroundId por assinatura), Recipe Registry com
verificação de exemplo existente, cache versionado CRPIDX/CRPHSH/CRPMET v1
com checksum, consultas byId/byCategory/searchKeyword/symbolDocs e eventos no
bus. Corpus semeado com conteúdo real do Kof (language/spawn/record,
stdlib/json, diagnostics ARITH001+SEM011, recipe REST API com exemplo
compilável).

## Arquivos Criados

agent/runtime/57_corpus.kf · corpus/** (17 dirs + READMEs + 7 docs reais +
1 exemplo .kf) · tests/corpus_src/*.kf (2) · tests/corpus/*.kf gerados (15) +
MANIFEST · scripts/test_corpus.sh · specs/CORPUS_ENGINE.md ·
specs/CORPUS_SCHEMA.md · specs/CORPUS_FORMAT.md · REPORT_M05.md

## Arquivos Modificados

scripts/build.sh (parte 57) · docs/status.md · README.md · docs/TASKS.md

## Arquitetura Implementada

Loader→Index→Registries→Cache com validação em todas as fronteiras; integração
com CompatibilityRegistry via assinaturas locais (sem dependência da parte JVM-only);
mesmo envelope de persistência das demais engines.

## APIs Criadas

corpusLoad · parseCorpusDoc · corpusValidate · corpusById/byCategory/
searchKeyword/symbolDocs · corpusSaveCache/wsReadVersioned(reuso) ·
registries diag/recipe/symbol.

## Testes

15 autorados one-per-process; execução PENDENTE-N10 (padrão: parte nova nasce
crashando; playbook de bisect/isolamento já documentado e usado 3×).

## Benchmarks

PENDENTES-N10 (harness seguirá o padrão bench_m03 após desbloqueio).

## Decisões Técnicas

Registry local de workarounds dentro do corpus (evita dependência da parte
gateway JVM-only); exemplos de receitas verificáveis por existência+golden.

## Pendências / Riscos / Próxima

Rodar playbook anti-N10 na parte 57 (colher 15+ testes e benchmarks);
M6 Retrieval Engine consumirá symIndex/keywords/diagRegistry diretamente.
TOOL_CATALOG.md permanece válido (nenhuma tool nova exposta).
