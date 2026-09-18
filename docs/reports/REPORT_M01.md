# REPORT_M01.md

# Milestone 01 — Core Runtime

Status:

* ✅ Concluído

## Resumo Executivo

Implementado o runtime nativo do Kof Agent, inteiramente em Kof compilado
para ELF x86-64: scheduler cooperativo determinístico com heap binário de
prioridades (100k tasks em ~0.7s), futures com await, cancelamento,
backpressure e shutdown gracioso; event bus tipado com envelopes-record,
sync/async, once/wildcard/consumo-de-cadeia; lifecycle com grafo legal de
estados e hooks ordenados; logger TRACE..FATAL (plain/JSON/ANSI/request-id);
config tipada arquivo>default com validação, reload e erros claros; scanner
de workspace; metrics com snapshot JSON; CLI `version/help/status/doctor/
config` com `--json` e exit codes determinísticos. Boot completo mede
**~120 µs** (meta < 100 ms). Infraestrutura descoberta necessária: padrão
part-files + concatenador (`scripts/build.sh`), wrapper de argv (`.kofargs`)
e lint de compatibilidade nativa — frutos de **10 bugs do compilador 0.0.14**
documentados com repros em `docs/compiler-bugs.md`. Suíte completa: 11
suítes / 39 testes + 2 stress, todos verdes no target Native.

## Arquivos Criados

```
specs/SCHEDULER.md · specs/EVENT_BUS.md · specs/LIFECYCLE.md · specs/CLI.md
agent/runtime/00_core.kf      utils + clocks + splitStr/parseIntStr/escapeJson/sortInts/loadArgsFile
agent/runtime/05_log.kf       Logger (níveis, json, cor, quiet, request id)
agent/runtime/10_config.kf    Config tipada + snapshotJson
agent/runtime/20_scheduler.kf TaskBody/Future/TaskNode/Scheduler(heap)/WorkerPool
agent/runtime/25_event.kf     EventEnvelope/EventHandler/Subscription/EventBus/PublishJob
agent/runtime/30_lifecycle.kf Lifecycle + NameRecorder
agent/runtime/40_workspace.kf scanWorkspace → WorkspaceReport
agent/runtime/50_metrics.kf   Metrics + snapshotJson
agent/runtime/90_runtime.kf   RuntimeContext (DI) + runtimeStatusJson
apps/cli/main.kf              CLI (version/help/status/doctor/config)
scripts/build.sh              concatenador partes+entrada → translation unit
scripts/test.sh               runner da suíte (build+test/run por artefato)
scripts/bench_m01.sh          harness de benchmarks + baseline JSON
scripts/build_cli.sh          build da CLI nativa
scripts/kof-agent             wrapper CLI (.kofargs)
scripts/check_compat.sh       gate anti-miscompile (N6/N7/N8/N9)
tests/unit_core.kf            7 testes
tests/unit_logger.kf          4
tests/unit_config.kf          5
tests/unit_scheduler.kf       6
tests/unit_eventbus.kf        6
tests/unit_lifecycle.kf       5
tests/unit_workspace.kf       4
tests/integration_boot.kf     1 E2E ponta a ponta
tests/shutdown_safe.kf        drain 500 + recusa pós-shutdown
tests/stress_events_10k.kf    10k eventos síncronos
tests/stress_tasks_100k.kf    100k tasks heap O(n log n)
benchmarks/bench_init.kf · bench_events.kf · bench_scheduler.kf ·
benchmarks/bench_logger.kf · bench_pool_scaling.kf
benchmarks/results/native-M01/*.json          runs crus (3× cada)
benchmarks/baselines/native-M01.json          baseline oficial M1
docs/runtime.md · docs/compiler-bugs.md
REPORT_M01.md
```

## Arquivos Modificados

```
docs/status.md      snapshot M1 concluída
docs/TASKS.md       checklist M1 fechado com resultados
docs/DECISIONS.md   D0013 (part-files), D0014 (.kofargs), D0015 (compat lint)
docs/CODE_STYLE.md  §13 regras de compatibilidade nativa
README.md           milestone M1 ✅ na tabela de estado
.gitignore          .kofargs
```

## Arquitetura Implementada

- **Scheduler**: heap binário manual sobre `Int[]` paralelos (prio, seq,
  taskIdx) com sift up/down — O(n log n) garantido (fila ordenada por
  inserção seria O(n²) nos 100k do stress). Estados CREATED/QUEUED/RUNNING/
  WAITING(reservado)/COMPLETED/CANCELLED/FAILED. Executor isola falhas por
  task (`try/catch String`) sem derrubar o worker. Backpressure por limite
  de fila; shutdown gracional drena tudo que foi aceito e recusa o resto.
- **Event Bus**: envelope é record (topic, payload, seq); handlers são
  objetos (`EventHandler.onEvent(e): Bool`, false = consome cadeia).
  Snapshot dos índices casados antes do dispatch permite remoção segura de
  `once`. Async = job no scheduler (ordem determinística).
- **Lifecycle**: máquina de estados explícita (tabela `allowed(from,to)`),
  hooks por alvo em ordem de registro, veto = exceção, crash path único para
  FAILED.
- **DI sem container**: `RuntimeContext` implementa `ContextView` (a view
  mínima que as tasks enxergam) e agrega cfg/logger/bus/sched/pool/life/met/
  clock. Zero estáticos mutáveis.
- **Build system**: `scripts/build.sh` concatena 9 partes + entrada num
  único translation-unit (o compilador não resolve multi-arquivo — SEM015);
  ordem das partes garante defs-before-main (bug N1).

## APIs Criadas

| Namespace | API pública |
|-----------|-------------|
| Scheduler | launch, launchFuture, cancel, run(n), drain, await, gracefulShutdown, pending, statsJson |
| WorkerPool | launch, dynamicResize(TP001), setAffinity(TP002) |
| EventBus | subscribe, once, unsubscribe, publish, broadcast, publishAsync, statsJson |
| Lifecycle | transition, crash, state/stateName/isAlive, registerBoot/Ready/Shutdown/Crash |
| Logger | trace/debug/info/warn/error/fatal, write, isEnabled, configure, setRequestId |
| Config | loadFile, reload, has/getRaw/getStr/getInt/getBool, snapshotJson |
| Workspace | scanWorkspace(root): WorkspaceReport |
| Metrics | start, incByName, uptimeMs, snapshotJson |
| RuntimeContext | wire, finishBoot, shutdownGraceful (+ ContextView.incMetric) |
| CLI | version, help, status, doctor, config show; flags --json/--root/--file |

## Ferramentas Criadas

Tool API formal chega na M4; ferramentas de engenharia entregues agora:
`build.sh` (builder), `test.sh` (runner), `bench_m01.sh` (harness),
`build_cli.sh`, `check_compat.sh` (gate), `kof-agent` (wrapper CLI).

## Testes

Quantidade: **39 testes estruturados** em 9 suítes `test "nome" { }` +
2 programas de stress, via `kof test --target native`.
Cobertura: todos os 8 módulos do runtime + integração E2E boot→publish→
compute→shutdown + segurança de shutdown.
Resultado: **11/11 suítes verdes, 0 flaky** (nenhum assert depende de tempo;
performance é medida só em benchmarks).

## Benchmarks

| Benchmark | Valor (medianas, native) |
|-----------|--------------------------|
| init (boot→READY→shutdown) | **120 µs/boot** (best batch 11 ms/100 boots) |
| events (20k publishes + handler) | ~56.5k ops/s |
| scheduler (100k launch+drain) | ~143k tasks/s (~700 ms) |
| logger (50k formatações, sink nulo) | ~19.6k linhas/s |
| thread_pool (1 worker, 20k tasks) | ~141k tasks/s; workers>1 = TP001 documentado |

Export JSON: `benchmarks/baselines/native-M01.json` + runs crus ×3 em
`benchmarks/results/native-M01/`.

## Decisões Técnicas

1. **Heap binário manual** em vez de lista ordenada — viabiliza os 100k do
   stress dentro do DoD.
2. **Part-files + concatenador** (D0013) — única forma honesta de ter código
   modular hoje (SEM015).
3. **argv por `.kofargs`** (D0014/ARG001) — N3 segfaulta args reais no
   Native; wrapper mantém UX e um único caminho de código.
4. **DI por RuntimeContext** em vez de singletons — estáticos mutáveis são
   frágeis no backend nativo; também é o estilo Kof (sem container).
5. **Ledger de bugs do compilador** (`docs/compiler-bugs.md`) — 10 bugs J1,
   N1–N10 reproduzidos; workarounds concentrados e vigiados por
   `check_compat.sh`; meta de REMOVER cada workaround quando upstream fechar.
6. **Determinismo como contrato**: nenhuma thread real (CONC001 upstream);
   async = fila; mesma entrada ⇒ mesmo comportamento observável.

## Pendências

- ENV001: camada environment da Config desligada (bloqueios upstream J1 +
  CONF001); chaves `log.*` hoje só via arquivo/default.
- ARG001: argv real quando N3 fechar; remover wrapper/.kofargs.
- TP001/TP002: pool multi-worker/dinâmica/affinity aguardando concorrência
  na linguagem (CONC001) — API já valida e diagnostica.
- Métricas RAM/CPU/GPU indisponíveis pela stdlib atual — snapshot cobre
  tempo/contadores; ampliar quando a plataforma expor.
- `logger()` ainda não exposto na ContextView (evita choque nome-campo do
  bug de aliasing); tasks M1 não logam — reavaliar na M2.
- Specs CONFIG/LOG/WORKSPACE/METRICS incorporadas em docs/runtime.md;
  elevar a specs próprias quando ganharem superfície nova.

## Riscos

- N10 (miscompile posição-dependente) é o mais traiçoeiro: pode ressurgir ao
  crescer o translation-unit. Mitigação: check_compat + bisect por truncamento
  (técnica documentada) + manter partes pequenas.
- Baseline de benchmark sensível à máquina — comparar sempre no mesmo
  ambiente; CI futuro deve fixar runner.
- Escrita em `.kofargs` no cwd: concorrência entre duas CLIs no mesmo dir
  pode interlevar (uso interativo esperado; sandbox/lock chegam na M4+).

## Próxima Milestone Recomendada

**M2 — Compiler Gateway**, pré-requisito de tudo que é "inteligente":

1. Fechar Q1 com dados: benchmarkar as três vias de integração com o kof
   (subprocess `kof check` vs protocolo residente vs embutida) num spike de
   meia semana antes da spec final.
2. `specs/COMPILER_GATEWAY.md`: contratos tipados (DiagnosticRec, SymbolRec,
   AstNodeRef, IRSummary...) e política "nunca texto onde cabe estrutura".
3. Implementar o Gateway sobre a via vencedora; golden tests com ≥20
   programas Kof válidos/inválidos reais.
4. Benchmarks: latência p50/p95 de compile-check por arquivo; baseline M02.
5. REPORT_M02.md + status.md.
