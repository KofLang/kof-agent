# SPEC — LIFECYCLE (M1)

**Status:** implementado
**Módulo:** `agent/runtime/40_lifecycle.kf` · **Depende de:** core, log

## 1. Estados

| Const | Estado | Significado |
|-------|--------|-------------|
| 0 | BOOTING | processo no ar, nada configurado |
| 1 | INITIALIZING | módulos sendo construídos/configurados |
| 2 | READY | aceitando trabalho |
| 3 | BUSY | executando plano/tarefa de alto nível (reservado p/ M8+) |
| 4 | STOPPING | drenando e liberando recursos |
| 5 | STOPPED | terminal limpo |
| 6 | FAILED | terminal por erro |

## 2. Grafo legal de transições

```
BOOTING      → INITIALIZING, FAILED(crash)
INITIALIZING → READY, FAILED(crash)
READY        → BUSY, STOPPING, FAILED(crash)
BUSY         → READY, STOPPING, FAILED(crash)
STOPPING     → STOPPED, FAILED(crash)
STOPPED      (terminal)
FAILED       (terminal)
```

Transição fora do grafo lança `"lifecycle: illegal transition X -> Y"`.
`crash(err)` é o único caminho para FAILED e dispara os crash hooks.

## 3. Hooks

```
interface LifecycleHook { onTransition(from: Int, to: Int): Bool }
```

Quatro listas: `onBoot`, `onReady`, `onShutdown`, `onCrash`. Ao entrar no
estado alvo, os hooks correspondentes rodam **em ordem de registro**; retorno
`false` veta a transição (`"lifecycle: hook veto <name>"`). Crash hook que
lança não é reprocessado — o runtime registra e segue para FAILED.

## 4. API pública

| Chamada | Contrato |
|---------|----------|
| `state()` / `stateName()` | estado atual / nome legível |
| `transition(to)` | valida + aplica + dispara hooks |
| `crash(reason)` | qualquer estado vivo → FAILED com reason nos hooks |
| `registerBoot/onReady/onShutdown/onCrash(hook)` | ordem de chamada = ordem de registro |
| `isAlive()` | não-terminal |

## 5. Não objetivos (M1)

Estados BUSY automáticos (chegam com o Planner), recuperação pós-crash,
supervisão.
