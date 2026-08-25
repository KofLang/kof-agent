# RUNTIME — Core Runtime do Kof Agent (M1)

**Status:** implementado · **Target:** Native (ELF x86-64) · **Kof 0.0.14-alpha**

---

## 1. Visão

O runtime M1 é a base determinística sobre a qual todas as milestones
seguintes serão construídas: scheduler cooperativo com heap de prioridades,
event bus tipado, lifecycle com hooks, logger estruturado, config tipada,
workspace scanner, metrics e CLI.

```
apps/cli/main.kf ── entrada (argv via .kofargs, ARG001)
        │ scripts/build.sh concatena partes + entrada
agent/runtime/
  00_core.kf       utils (parseIntStr, splitStr, escapeJson, clocks, sort)
  05_log.kf        Logger TRACE..FATAL (plain/json/color/quiet)
  10_config.kf     Config tipada (arquivo > default; env pendente ENV001)
  20_scheduler.kf  Scheduler heap + Future + WorkerPool (TP001)
  25_event.kf      EventBus + PublishJob (sync/async)
  30_lifecycle.kf  Lifecycle BOOTING..FAILED + hooks
  40_workspace.kf  scanWorkspace → WorkspaceReport
  50_metrics.kf    contadores + snapshotJson
  90_runtime.kf    RuntimeContext (DI por construtor) + statusJson
```

## 2. Modelo de execução

- **Worker único cooperativo e determinístico**: ordem total = prioridade
  DESC, sequência ASC (empate FIFO). Mesmas entradas ⇒ mesma ordem, sempre.
- Publicação assíncrona de eventos = tarefa do scheduler; entrega segue a
  fila, não threads.
- Falhas isolam por task (`try/catch String` no executor do scheduler);
  `lastError` guarda a última.
- Zero estado estático mutável (semântica frágil no backend nativo): tudo
  vive em `RuntimeContext` injetado por construtores.

## 3. Contratos por módulo

Specs formais: [specs/SCHEDULER.md](../specs/SCHEDULER.md),
[specs/EVENT_BUS.md](../specs/EVENT_BUS.md),
[specs/LIFECYCLE.md](../specs/LIFECYCLE.md),
[specs/CLI.md](../specs/CLI.md).

### Config — chaves reconhecidas

| Chave | Tipo | Default | Efeito |
|-------|------|---------|--------|
| `log.level` | nome | INFO | TRACE/DEBUG/INFO/WARN/ERROR/FATAL |
| `log.color` | bool | false | ANSI no formato plain |
| `log.json` | bool | false | linha JSON estruturada |
| `scheduler.max_pending` | int | 0 (∞) | backpressure |

Precedência M1: **arquivo > default**. A camada de environment existe na API
(`getEnv` reservado) mas fica desligada até o compilador resolver J1/CONF001
(ENV001). Formato do arquivo: `chave = valor`, `#` comentário.

### CLI

```bash
scripts/build_cli.sh                 # gera build/out/Default/Main
scripts/kof-agent version            # wrapper escreve .kofargs e executa
scripts/kof-agent doctor --root DIR --json
scripts/kof-agent status --root DIR --json
scripts/kof-agent config show --file PATH
```

Exit codes: 0 ok · 1 uso inválido · 2 falha funcional (doctor/status).

## 4. Desempenho (baselines nativos, máquina de dev)

| Benchmark | Resultado |
|-----------|-----------|
| init (boot→READY→shutdown) | **~120 µs/boot** (meta < 100 ms) |
| event bus publish síncrono | ~56k ops/s (handler incluso) |
| scheduler launch+drain | ~144k tasks/s (100k tasks) |
| logger format (sink nulo) | ~19.6k linhas/s |
| thread pool (1 worker) | ~141k tasks/s |

Baselines: `benchmarks/baselines/native-M01.json` · runs crus em
`benchmarks/results/native-M01/`.

## 4b. Workspace Intelligence (M3)

`WorkspaceIndex` + `WsSnap`: modelo persistente do projeto (files+hashes,
symbols lexicais aproximados — D0018 —, imports, DAG de deps, git sem
processo, target via kof.config). Persistência WSIDX/WSSNP/WSHSH v3 com CRC.
Diff estruturado com rename por hash. Diag cache por hash para o repair loop.
Eventos: workspace.indexed/changed, file.added/modified/removed/renamed,
snapshot.created/diff.computed/workspace.cacheInvalid. Specs:
WORKSPACE_INDEX.md/SNAPSHOT_FORMAT.md. Bloqueio honesto: 21/37 testes nativos
aguardam fix N10 do compilador (isolamento por-processo documentado).

## 5. Testes

11 suítes verdes (`scripts/test.sh`, target native): unit_core (7),
unit_logger (4), unit_config (5), unit_scheduler (6), unit_eventbus (6),
unit_lifecycle (5), unit_workspace (4), integration_boot (1 E2E),
shutdown_safe (500-task drain + recusa pós-shutdown), stress_events_10k,
stress_tasks_100k. Total: **39 testes** + 2 stress. Sem asserts de tempo
(zero flakiness por design); desempenho é domínio dos benchmarks.

## 6. Compatibilidade com o compilador 0.0.14 (crítico)

Durante a M1 descobrimos e contornamos bugs reais do backend. O ledger
completo com repros está em [compiler-bugs.md](compiler-bugs.md). Regras de
código impostas por `scripts/check_compat.sh` (rode antes de todo commit):

1. Proibido `+=` em acumulação de String — usar `x = x + e`.
2. Proibido comparar String com `null` (segfault no runtime nativo).
3. Proibido `continue` dentro de `for-in`/`while` (loop infinito no native).
4. Não confiar em curto-circuito de `&&`/`||` quando o lado direito pode
   falhar — aninhar ifs.
5. Um único translation-unit por artefato: `scripts/build.sh` concatena as
   partes (o compilador não resolve símbolos entre arquivos — SEM015).
6. Toda definição precede o `main` do artefato (função referenciada antes da
   definição não linka no native).
7. Sem campos estáticos mutáveis; DI por construtores.
8. `implements` exige construtor explícito (primary ctor + implements não
   parseia).
9. `now()` indisponível em artefatos JVM (bug J1); benchmarks são nativos.
