# ARCHITECTURE — Arquitetura Oficial do Kof Agent

**Status:** aceita (Milestone 0)
**Última atualização:** 24 de agosto de 2026

---

## 1. Princípio central

> O usuário escreve a intenção. O agente planeja, executa e repara usando
> apenas ferramentas oficiais. O compilador Kof é a fonte da verdade.

O agente é à plataforma Kof o que o LSP é ao compilador: um consumidor do
frontend real, nunca uma implementação paralela.

```
intenção (PT-BR)
      ↓
   Brain  →  Planner  →  Executor
                 ↓              ↓
              Tool API ←── patches/diffs
                 ↓
        Compiler Gateway (única fronteira com o compilador Kof)
                 ↓
           diagnostics tipados → Corpus/Retrieval → repair loop
```

## 2. Visão em camadas

```
┌─────────────────────────────────────────────────────────────┐
│  Kof Editor · CLI · CI                                      │
│         │  Editor Protocol: JSON-RPC sobre stdio            │
└─────────┼───────────────────────────────────────────────────┘
          ▼
┌─────────────────────────────────────────────────────────────┐
│  Agent Core (agent/)                                        │
│  sessões · lifecycle · event bus · command router · DI      │
│          ├── Brain       texto → Intent tipada              │
│          ├── Planner     Intent → Plan tipado               │
│          └── Executor    Plan → Patch/Diff + Repair Loop    │
├─────────────────────────────────────────────────────────────┤
│  Scheduler + Thread Pool (scheduler/)                       │
├─────────────────────────────────────────────────────────────┤
│  Tool API (tools/)   Workspace (workspace/)                 │
│  Memory (memory/)    Protocol (protocol/)                   │
├─────────────────────────────────────────────────────────────┤
│  Compiler Gateway (compiler/)  ← ÚNICA fronteira c/ kof     │
├─────────────────────────────────────────────────────────────┤
│  Corpus Engine (corpus/)   Retrieval Engine (retrieval/)    │
│  Tokenizer (tokenizer/)    Embeddings (embeddings/)         │
├─────────────────────────────────────────────────────────────┤
│  Runtime AI (runtime/)  →  Compute HAL (gpu/ cpu/ backends) │
│  Model API: generate/embed/stream/loadModel/deviceInfo      │
└─────────────────────────────────────────────────────────────┘
```

Regra estrutural: **dependências apontam sempre para baixo**. O mapa de
dependências permitidas por módulo vive em `MODULES.md` e é auditável.

## 3. Fluxo principal (request → resultado)

1. **Entrada** — CLI ou editor envia texto em português.
2. **Brain** — tokeniza, extrai Intent + slots + entidades; anexa contexto
   (sessão, workspace, histórico).
3. **Planner** — gera `Plan` tipado: tasks, tools, arquivos afetados,
   dependências, riscos, rollback. Nunca código.
4. **Aprovação** — plano exibido ao usuário (CLI/editor). Mutação sem plano
   visível é proibida.
5. **Executor** — roda cada task pela Tool API; produz eventos (`progress`,
   `diagnostics`, `result`) e diffs.
6. **Repair Loop** — compila via Gateway → recebe diagnostics → consulta
   Corpus/Retrieval → aplica patch → repete até verde ou limite configurável.
7. **Saída** — diff final, resultado dos testes, métricas, exit code.

## 4. Fluxo do Repair Loop

```
compilar → diagnostics?
    ├─ não → testes → passou? fim ✅
    └─ sim → classificar diagnostic (código)
             → retrieval no corpus (por código/símbolo/target)
             → gerar patch mínimo
             → aplicar com rollback point
             → voltar ao topo (máx. N iterações configurável)
```

Cada iteração registra histórico na Memory para aprendizado futuro (M12).

## 5. Decisões estruturais

| # | Decisão | Motivo |
|---|---------|--------|
| A1 | Compiler Gateway como única fronteira | zero duplicação do frontend Kof; editor e agente nunca divergem do compilador |
| A2 | Event Bus interno próprio | módulos desacoplados; progresso/cancelamento uniformes |
| A3 | Thread pool próprio + tarefas cooperativas | previsibilidade; quando a stdlib Kof evoluir (`spawn`), o scheduler passa a usá-la sem mudar API |
| A4 | RAG local com índice binário próprio | sem servidor externo; incremental por checksum; offline |
| A5 | GGUF como formato de modelo | padrão de fato, quantização madura |
| A6 | Compute HAL único contrato | nenhum módulo acima conhece CUDA/Vulkan/Metal |
| A7 | Providers externos opcionais | interface única; runtime local é o caminho oficial |
| A8 | JSON-RPC sobre stdio para editores | mesmo espírito LSP/DAP do Kof; zero portas de rede |

## 6. Modelo de eventos

Eventos são valores tipados publicados no Event Bus:

| Evento | Origem | Consumidor típico |
|--------|--------|-------------------|
| `plan.created` | Planner | editor/CLI (aprovação) |
| `task.started` / `task.finished` | Executor | progresso |
| `patch.applied` / `patch.reverted` | Executor | diff UI, memória |
| `diagnostics.received` | Gateway | repair loop, editor |
| `retrieval.hit` | Retrieval | corpus cache, telemetria local |
| `token.stream` | Runtime AI | streaming no editor |
| `heartbeat` | Protocol | liveness |

## 7. Concorrência e recursos

- Uma sessão = um workspace indexado = uma fila de planos serializáveis.
- Tasks independentes paralelizam no thread pool com cancelamento
  cooperativo.
- Recursos (arquivos abertos, processos do compilador, handles GPU) têm
  lifecycle dono→tarefa; rollback fecha tudo.
- Memória: mmap para modelos e índices; lazy loading; zero cópias nos
  caminhos quentes (streaming de tokens, diff).

## 8. Segurança

- Toda mutação passa por: plano → diff → aplicação atômica → rollback point.
- Permissões por tool (filesystem leitura/escrita, rede, git push) são
  declaradas no schema da tool e conferidas pelo executor.
- Sandbox opcional isola execução de programas gerados.

## 9. Mapeamento filosofia → arquitetura

| Filosofia Kof | Realização arquitetural |
|---------------|--------------------------|
| Intenção acima da implementação | Brain + Planner tipados |
| Compilador fonte da verdade | Compiler Gateway exclusivo (A1) |
| Menos cerimônia | APIs ≤ 10 funções por namespace |
| Backend agnostic | nenhuma camada acima da HAL conhece backend |
| Ferramentas são plataforma | Tool API com schema/permissões/testes/benchmark |
| Sem magia silenciosa | todo gap vira evento `diagnostic` com código |
