# ROADMAP — Milestones do Kof Agent

**Status:** aceita (Milestone 0)

Regras globais:

1. Uma milestone por vez. Nunca pular. Nunca iniciar a próxima sem fechar a atual.
2. Cada milestone gera: documentação, testes, benchmark e `REPORT_MXX.md`
   (template oficial em `CONTRIBUTING.md` §7).
3. Definition of Done (DoD) vale para toda feature dentro da milestone.

## DoD universal (espelhado de docs/performance.md do Kof)

- [ ] Compila no target Native **ou** gap com diagnóstico explícito.
- [ ] Testes E2E reais por área afetada + caso de regressão.
- [ ] Benchmark quando impacto de performance for plausível; baseline atualizado.
- [ ] Docs sincronizadas no mesmo PR (`docs/` + READMEs de pasta).
- [ ] Sem comentários no código; sem warnings.

---

## M0 — Fundação ✅

Documentação de engenharia completa + árvore de diretórios + repo.

**Aceite:** todos os documentos listados existem, são consistentes entre si
e o repositório está publicado. Nenhuma implementação grande.

## M1 — Core Runtime ⬜

Infraestrutura do agente: CLI, Logger, Config, Workspace (esqueleto),
Event Bus, Command Router, DI simples, Lifecycle, Plugin Loader, Task
Scheduler, Thread Pool.

**Aceite:** agente inicializa < 100 ms, carrega um projeto vazio, executa
comandos `version`/`status`/`help`, eventos observáveis, exit codes
determinísticos. Benchmarks: init, throughput do event bus.

## M2 — Compiler Gateway ⬜

Interfaces tipadas sobre o compilador Kof: lexer, parser, AST, análise
semântica, IR, diagnostics, symbols, references, type checker, definitions,
hover, completion.

**Aceite:** nenhum parsing manual de Kof no repositório; diagnostics chegam
como estruturas; golden tests compilando programas reais via gateway.
Benchmarks: latência de compile-check por arquivo.

## M3 — Workspace Intelligence ⬜

Scanner completo de projetos; índice de arquivos/imports/classes/records/
interfaces/functions/modules/dependencies/targets; índice persistente
incremental por checksum.

**Aceite:** indexação incremental (reindex só mudou); consultas por símbolo.
Benchmarks: indexação inicial e incremental (arquivos/s).

## M4 — Tool API ⬜

Ferramentas oficiais desacopladas, cada uma com schema/permissões/testes/
benchmark: Filesystem, Editor, Compiler, AST, Testing, Formatting, Search,
Web Preview, JSON, HTTP, Patch, Diff, Git.

**Aceite:** registro de tools consultável em runtime; permissões aplicadas;
cada tool com teste próprio. Benchmark: dispatch overhead.

## M5 — Corpus Engine ⬜

Estrutura `corpus/{language,learn,docs,stdlib,patterns,anti-patterns,
diagnostics,architecture,future,tooling,targets}`; loader markdown com
metadata (id/module/target/version/keywords/symbols/checksum), cache e
indexador incremental.

**Aceite:** corpus do Kof importado e versionado; atualização incremental
por checksum; consulta por código de diagnostic.

## M6 — Retrieval Engine ⬜

RAG local sem banco externo: embedding index, vector index binário, top-K,
MMR, ranking, cache, incremental index, filtros por target/versão/módulo.

**Aceite:** offline total; recall@10 medido sobre conjunto de perguntas
canônicas. Benchmarks: tempo de retrieval, qualidade de ranking.

## M7 — Kof Brain ⬜

Parser de intenção PT-BR → Intents tipadas com slots, entidades, contexto e
histórico. Intents oficiais da SPEC RF-7.2.

**Aceite:** dataset canônico de frases → intents com acurácia medida e
baseline registrada; ambiguidade vira pergunta, nunca chute silencioso.

## M8 — Planner ⬜

Plan tipado completo (objetivo, tasks, tools, arquivos afetados,
dependências, riscos, etapas, rollback, prioridade, status, tempo estimado).

**Aceite:** todo plano é serializável/desserializável; planos inválidos são
rejeitados antes de executar; nunca gera código direto.

## M9 — Executor + Repair Loop ⬜

Execução de planos, edição de arquivos via Patch/Diff, compilação, recebimento
de diagnostics, correção assistida por corpus, testes, diff final, rollback.

**Aceite:** E2E "frase → projeto verde" em casos canônicos (site, CRUD,
repair de diagnostic); rollback 100% dos caminhos.

## M10 — Runtime AI ⬜

Runtime de inferência em Kof: tokenizer, GGUF loader, scheduler, sampler,
KV cache, streaming, Model API, Backend API. Sem modelo bundled.

**Aceite:** carrega GGUF real via mmap, gera tokens em streaming, primeiro
token < 200 ms em CPU SIMD se disponível. Benchmarks: tokens/s por quantização.

## M11 — GPU Universal ⬜

Compute HAL completo + backends Vulkan/Metal/DirectML/CUDA/ROCm/OpenCL/CPU
SIMD com detecção e seleção automática; quantização FP16→Q4 conforme VRAM.

**Aceite:** mesma Model API sobre qualquer backend detectado; fallback CPU
sempre disponível. Benchmarks: matmul/attention por backend.

## M12 — Dataset + Futuro SLM ⬜

Geração automática de datasets (positivos: código que compila; negativos:
erros conhecidos ligados a códigos de diagnostic), embeddings de corpus,
tokenizer dataset. Preparação para treinamento do futuro SLM do Kof.

**Aceite:** pipeline determinístico regenera datasets quando a linguagem
evoluir; export JSONL validado por schema.

---

## Ordem e paralelismo

```
M0 ─► M1 ─► M2 ─► M3 ─► M4 ─► M5 ─► M6 ─► M7 ─► M8 ─► M9 ─► M12
                                     └──────────────► M10 ─► M11
```

M10/M11 podem ser iniciadas após M6 desde que M1–M9 não sejam bloqueadas.
A trilha principal (agente útil) tem precedência sobre runtime AI.
