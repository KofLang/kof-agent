# TASKS — Milestone corrente

**Milestone atual:** M5 — Corpus Engine (não iniciada)
**Milestones:** M0 ✅ · M1 ✅ · M2 🟡 · M3 🟡 · M4 🟡 (N10)
**Última atualização:** 24 de agosto de 2026

---

## M0 — Fundação

| # | Tarefa | Status |
|---|--------|--------|
| 0.1 | Árvore completa de diretórios com README por pasta | ✅ |
| 0.2 | README.md raiz (estilo Kof) | ✅ |
| 0.3 | LICENSE GPLv3 + postura de licenciamento de outputs | ✅ |
| 0.4 | .gitignore | ✅ |
| 0.5 | docs/SPEC.md — requisitos funcionais e não funcionais | ✅ |
| 0.6 | docs/ARCHITECTURE.md — camadas, fluxos, decisões estruturais | ✅ |
| 0.7 | docs/MODULES.md — mapa de módulos e dependências | ✅ |
| 0.8 | docs/ROADMAP.md — M0–M12 com critérios de aceite | ✅ |
| 0.9 | docs/CONTRIBUTING.md — processo, Regra Zero, template de report | ✅ |
| 0.10 | docs/CODE_STYLE.md — estilo Kof obrigatório | ✅ |
| 0.11 | docs/DECISIONS.md — registro de decisões + dúvidas em aberto | ✅ |
| 0.12 | docs/RISKS.md — riscos e mitigações | ✅ |
| 0.13 | docs/BENCHMARK_PLAN.md | ✅ |
| 0.14 | docs/TEST_PLAN.md | ✅ |
| 0.15 | REPORT_M00.md no template oficial | ✅ |
| 0.16 | Repositório publicado em `main` (origin: github.com/KofLang/kof-agent) | 🟡 |

Critério de fechamento da M0: todos os itens ✅ e consistência cruzada entre
os documentos. **M0 fechada em 24/08/2026.**

## M1 — Core Runtime ✅ (24/08/2026)

| # | Tarefa | Resultado |
|---|--------|-----------|
| 1.1 | specs SCHEDULER/EVENT_BUS/LIFECYCLE/CLI | ✅ 4 specs |
| 1.2 | docs/runtime.md + docs/compiler-bugs.md | ✅ |
| 1.3 | Scheduler heap determinístico + Future/await/cancel/backpressure/shutdown | ✅ |
| 1.4 | EventBus tipado sync/async (once, wildcard, chain-consume) | ✅ |
| 1.5 | Lifecycle estados+hooks+veto+crash | ✅ |
| 1.6 | Logger TRACE..FATAL plain/json/color/quiet/request-id | ✅ |
| 1.7 | Config tipada arquivo>default, validação, reload | ✅ (env: ENV001) |
| 1.8 | Workspace scanner + WorkspaceReport | ✅ |
| 1.9 | Metrics snapshotJson + RuntimeContext DI + statusJson | ✅ |
| 1.10 | CLI version/help/status/doctor/config --json exit 0/1/2 | ✅ (argv: ARG001) |
| 1.11 | WorkerPool size=1; >1 = TP001 documentado | ✅ |
| 1.12 | Testes unit+integração+stress | ✅ 39 testes + 2 stress, 11/11 suítes |
| 1.13 | Benchmarks init/events/scheduler/logger/pool + baseline JSON | ✅ init ~120 µs |
| 1.14 | check_compat.sh (gate anti-miscompile N6–N9) | ✅ |
| 1.15 | REPORT_M01.md + status.md | ✅ |

## M2 — Compiler Gateway 🟡 (24/08/2026)

| # | Tarefa | Resultado |
|---|--------|-----------|
| 2.1 | Spike Q1: 3 arquiteturas medidas (1000+ ops, p50/p95/p99) | ✅ docs/spikes + native-M02-spike.json |
| 2.2 | ADR/arquitetura vencedora | ✅ D0016: B' híbrido batch-subprocess |
| 2.3 | specs/COMPILER_GATEWAY.md | ✅ |
| 2.4 | Estruturas tipadas + SubprocessGateway + registry + eventos | ✅ compila (95_gateway.kf) |
| 2.5 | Golden tests ≥20 programas reais | ✅ 20/20 via ponte; 5 gaps semânticos upstream catalogados |
| 2.6 | Execução in-language do gateway | ❌ bloqueado J2+GW001 (pontes: golden_compiler.sh / bench harness) |
| 2.7 | REPORT_M02 + status.md | ✅ |

## M3 — Workspace Intelligence 🟡 (24/08/2026)

| # | Tarefa | Resultado |
|---|--------|-----------|
| 3.1 | specs WORKSPACE_INDEX + SNAPSHOT_FORMAT | ✅ |
| 3.2 | Snapshot completo (git/target/config/files/symbols/deps/id/ts) | ✅ |
| 3.3 | Índice persistente versionado c/ checksum + cacheInvalid | ✅ |
| 3.4 | Incremental scan + diff estruturado + rename por hash | ✅ |
| 3.5 | Dependency graph (edges/ciclos/unused imports) | ✅ |
| 3.6 | Symbol cache lexical (D0018) + diag cache | ✅ |
| 3.7 | Eventos workspace (9 tipos) | ✅ |
| 3.8 | Testes ≥30 | 🟡 37 gerados, 16 PASS nativos; 21 bloqueados N10 |
| 3.9 | Benchmarks cold/warm/export | 🟡 harness pronto; números PENDENTES-N10 |
| 3.10 | REPORT_M03 + status | ✅ |

Backlog M4 (rascunho): spec TOOL_API; Filesystem/Search/Patch/Diff/Compiler;
Editor Protocol esqueleto; issues upstream (J2/N10-N12/SC1-5).

## Backlog M1 — Core Runtime (rascunho; será refinado ao abrir a milestone)

| # | Tarefa |
|---|--------|
| 1.1 | Spec `specs/SCHEDULER.md` (task scheduler cooperativo + thread pool) |
| 1.2 | Spec `specs/EVENT_BUS.md` (eventos tipados, assinatura, cancelamento) |
| 1.3 | Spec `specs/LIFECYCLE.md` (init → ready → running → shutdown) |
| 1.4 | Spec `specs/CLI.md` (comandos, flags, exit codes, --json) |
| 1.5 | Logger com níveis (`KOF_AGENT_LOG_LEVEL`) — espírito kof.log |
| 1.6 | Config com precedência arquivo > env > default — espírito kof.config |
| 1.7 | DI simples por construtores (sem container, sem reflexão) |
| 1.8 | Command Router + Plugin Loader (registro estático em compile-time) |
| 1.9 | Workspace esqueleto (abrir diretório, listar `.kf`, checksums) |
| 1.10 | Benchmarks: init < 100 ms; dispatch do event bus |
| 1.11 | REPORT_M01.md |

Regra: nenhuma tarefa da M1 começa antes do fechamento oficial da M0.
