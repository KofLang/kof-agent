# SPEC — EVENT_BUS (M1)

**Status:** implementado
**Módulo:** `agent/runtime/20_event.kf` · **Depende de:** core, log, scheduler (tipos)

## 1. Propósito

Comunicação desacoplada entre módulos do runtime. Eventos são valores
tipados — **nunca strings soltas**: o payload é String opaca (convencionalmente
JSON), mas o envelope é um record com identidade.

## 2. Modelo

```
record EventEnvelope(String topic, String payload, Int seq)
interface EventHandler { onEvent(EventEnvelope e): Bool }
class Subscription { Int id; String topic; EventHandler h; Bool once }
```

- `onEvent` retorna `true` para continuar a cadeia, `false` para consumir e
  interromper os handlers seguintes daquele publish.
- Tópicos são convenção de namespace: `"task.started"`, `"plan.created"`, ...
  O tópico especial `"*"` casa com tudo (broadcast).

## 3. API pública

| Chamada | Contrato |
|---------|----------|
| `subscribe(topic, handler)` | retorna id de inscrição |
| `once(topic, handler)` | idem; inscrição removida após o primeiro disparo |
| `unsubscribe(id)` | `true` se existia |
| `publish(envelope)` | entrega síncrona em ordem determinística (ordem de inscrição); retorna nº de handlers chamados |
| `broadcast(topic, payload)` | publica também para inscritos de `"*"` |
| `publishAsync(sched, view, topic, payload)` | enfileira um job no scheduler que faz publish no drain — entrega assíncrona determinística |

## 4. Semântica

1. Entrega é **síncrona por padrão** — publish só retorna depois de chamar os
   handlers da cadeia.
2. Assíncrono = tarefa do scheduler: ordem de entrega segue a fila
   (prioridade/sequência), não threads.
3. Handler que lança exceção: a publicação propaga para quem publicou
   (falha explícita > engolir). O contador `eventsFailed` registra.
4. Thread-safety: o bus é confinado à thread do runtime (worker único).
   Confinamento documentado no lugar de locks — sem primitivas de
   sincronização na linguagem hoje.

## 5. Não objetivos (M1)

Tópicos curinga por sufixo (`task.*`), persistência, replay, backpressure por
assinante.
