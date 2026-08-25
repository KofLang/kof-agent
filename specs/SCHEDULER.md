# SPEC — SCHEDULER (M1)

**Status:** implementado (cooperativo, worker único)
**Módulo:** `agent/runtime/30_scheduler.kf` · **Depende de:** core, log, config, event (tipos)

## 1. Propósito

Execução determinística de unidades de trabalho do agente. É o fundo sobre o
qual todo o resto roda: eventos assíncronos, hooks e futuros são tarefas.

## 2. Modelo

- Unidade = objeto implementando `TaskBody { run(ContextView v) }`.
- Fila = **heap binário** (prioridade DESC, sequência ASC — empate é FIFO).
  Sem heap, 100k tarefas com inserção ordenada seria O(n²); o heap garante
  O(n log n) e ordem total determinística.
- Worker único cooperativo: `run`/`drain` executam até esvaziar. Um corpo em
  execução bloqueia os demais (cooperativo de verdade).
- Cancelamento: cooperativo, aplicado a tarefas ainda enfileiradas (a task é
  marcada; ao chegar ao topo é descartada com estado `CANCELLED`). Corpo em
  execução não é interrompido.

## 3. Estados da task

| Const | Estado | Significado |
|-------|--------|-------------|
| 0 | CREATED | aceito pelo builder, ainda não enfileirado |
| 1 | QUEUED | no heap, aguardando worker |
| 2 | RUNNING | corpo em execução |
| 3 | WAITING | reservado: dependente de Future pendente |
| 4 | COMPLETED | corpo retornou normalmente |
| 5 | CANCELLED | descartado antes de executar |
| 6 | FAILED | corpo lançou exceção String |

## 4. API pública

| Chamada | Contrato |
|---------|----------|
| `launch(body, name, priority)` | enfileira; retorna taskId; lança `"scheduler: backpressure"` se limite atingido; lança após shutdown |
| `launchFuture(body, name, priority)` | idem + retorna `Future` |
| `cancel(taskId)` | `true` se estava QUEUED |
| `run(maxTasks)` | executa até N tarefas ou fila vazia |
| `drain()` | executa até fila vazia |
| `await(future)` | drena até future resolvido; `"scheduler: deadlock"` se fila vazia sem resolver |
| `gracefulShutdown()` | drena, recusa novos, encerra |
| `pending()/statsSnapshot()` | contadores e JSON para status |

## 5. Backpressure e ciclo de vida

- `maxPending` (0 = ilimitado, default via config `scheduler.max_pending`).
- `gracefulShutdown` é determinístico: drena tudo que foi aceito; nada é
  perdido silenciosamente.
- Falha isolada: exceção num corpo vira `FAILED` + contador; **nunca** derruba
  o worker nem as demais tarefas.

## 6. Worker Pool (gaps honestos)

`WorkerPool(size)` com size > 1 lança **TP001** (upstream: `spawn` ausente no
Native — CONC001; sem primitivas de sincronização). Size 1 é o caminho
suportado e determinístico. Pool dinâmica/affinity lançam TP001/TP002 quando
acionadas. Quando a linguagem entregar concorrência, o pool ganha workers reais
sem mudar esta API.

## 7. Não objetivos (M1)

Preempção, timers, prioridades dinâmicas, tarefas interrompíveis.
