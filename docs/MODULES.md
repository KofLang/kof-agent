# MODULES — Mapa de Módulos

**Status:** aceita (Milestone 0)

Cada módulo declara: responsabilidade, API pública prevista, dependências
permitidas (somente para baixo) e milestone de nascimento. Módulos não
listados como dependência são **proibidos**.

Legenda de estado: ⬜ planejado · 🟡 parcial · ✅ completo

---

## Camada 0 — Aplicação e borda

### `apps/` ⬜ (M1)
- **Responsabilidade:** hosts executáveis compostos apenas por módulos oficiais.
- **API:** binários (`kof-agent`, host do editor).
- **Depende de:** tudo (é a folha permitida).

### `cli/` ⬜ (M1)
- **Responsabilidade:** parser de argumentos, comandos, exit codes, `--json`.
- **API:** `run/plan/ask/index/corpus/bench/version`.
- **Depende de:** agent, protocol.

### `editor/` ⬜ (M4+)
- **Responsabilidade:** adapters do Editor Protocol para editores reais.
- **Depende de:** protocol.

### `protocol/` ⬜ (M1 esqueleto, M4 completo)
- **Responsabilidade:** mensagens JSON-RPC (plan, patch, tool, progress,
  stream, diagnostics, result, cancel), heartbeat, version.
- **Depende de:** scheduler.

## Camada 1 — Núcleo do agente

### `agent/` ⬜ (M1)
- **Responsabilidade:** sessões, lifecycle, orquestração Brain→Planner→Executor,
  política de segurança e permissões.
- **Depende de:** brain, planner, executor, tools, memory, scheduler, protocol.

### `brain/` ⬜ (M7)
- **Responsabilidade:** texto PT-BR → Intent tipada + slots + entidades +
  contexto/histórico. Intents oficiais listadas em SPEC §RF-7.2.
- **Depende de:** tokenizer, memory, retrieval (para desambiguação).

### `planner/` ⬜ (M8)
- **Responsabilidade:** Intent → Plan tipado (tasks, tools, arquivos,
  dependências, riscos, rollback). Nunca gera código direto.
- **Depende de:** tools (schemas), workspace, retrieval.

### `executor/` ⬜ (M9)
- **Responsabilidade:** execução de planos, patches atômicos, diffs,
  eventos, rollback, repair loop.
- **Depende de:** tools, compiler, memory, corpus/retrieval (no repair).

### `scheduler/` ✅ contrato (M1)
- **Responsabilidade:** task scheduler cooperativo + thread pool com
  prioridades e cancelamento.
- **Depende de:** nada (camada base).

### `memory/` ⬜ (M1 básica, evolui até M12)
- **Responsabilidade:** conversation/workspace/compiler memory, recent
  files/symbols/diagnostics, plan history, patch history, corpus cache.
- **Depende de:** scheduler.

## Camada 2 — Plataforma

### `tools/` ⬜ (M4; Filesystem/Search/Patch/Diff antecipáveis na M2–M3)
- **Responsabilidade:** Tool API oficial. Cada tool: id, description,
  input/output schema, permissions, diagnostics, tests, benchmark.
- **Depende de:** compiler (tools de código), workspace, scheduler.

### `workspace/` ⬜ (M3)
- **Responsabilidade:** scanner de projeto `.kf` e índice persistente
  incremental (arquivos, imports, classes, records, interfaces, funções,
  módulos, targets).
- **Depende de:** compiler (símbolos), memory.

### `compiler/` ⬜ (M2) — Compiler Gateway
- **Responsabilidade:** ÚNICA fronteira com o compilador Kof: AST, árvore
  semântica, symbol table, diagnostics tipados, IR, referências,
  definições, hover, completion. Retorna estruturas, nunca texto solto.
- **Depende de:** scheduler.
- **Proibições:** nenhum outro módulo pode parsear/invoke o compilador.

## Camada 3 — Conhecimento

### `corpus/` ⬜ (M5)
- **Responsabilidade:** loader/parser markdown com metadata (id, title,
  module, target, version, keywords, symbols, embedding, checksum),
  versionamento, cache, indexador incremental.
- **Depende de:** tokenizer, embeddings, scheduler.

### `retrieval/` ⬜ (M6)
- **Responsabilidade:** índice vetorial binário local, top-K, MMR, ranking,
  filtros (target/versão/módulo), cache, indexação incremental.
- **Depende de:** embeddings, corpus, memory.

### `tokenizer/` ⬜ (M10; versão lexical da M6+)
- **Responsabilidade:** tokenizer próprio UTF-8/português/cases/keywords
  Kof/strings/números/comentários.
- **Depende de:** nada.

### `embeddings/` ⬜ (M6)
- **Responsabilidade:** motor próprio embedDocument/embedQuery/
  embedWorkspace/embedDiagnostic; persistência binária incremental.
- **Depende de:** runtime (Model API), tokenizer.

## Camada 4 — Runtime AI

### `runtime/` ⬜ (M10)
- **Responsabilidade:** GGUF loader (mmap/lazy), scheduler de inferência,
  sampler, KV cache, streaming, Model API (`generate/embed/stream/
  loadModel/unloadModel/deviceInfo`).
- **Depende de:** tokenizer, gpu/cpu/backends (HAL), scheduler.

### `gpu/` ⬜ (M11)
- **Responsabilidade:** Compute HAL universal + backends Vulkan/Metal/
  DirectML/CUDA/ROCm/OpenCL com seleção automática.
- **Contrato HAL:** allocate/upload/download/matmul/attention/rope/
  layernorm/softmax/kvCache/free.
- **Depende de:** scheduler.

### `cpu/` ⬜ (M11, pode antecipar M10 se FLT/SIMD nativo permitir)
- **Responsabilidade:** fallback SIMD AVX2/AVX-512/SSE4/NEON sobre thread pool.
- **Depende de:** scheduler.

### `backends/` ⬜ (M10 providers; M11 compute selection)
- **Responsabilidade:** providers opcionais (Ollama/OpenAI/Gemini/Claude/GGUF
  local) atrás de interface única; seleção automática de backend compute.
- **Depende de:** runtime (contratos), gpu.

## Camada 5 — Conteúdo e qualidade

### `corpus/datasets/ → datasets/` ⬜ (M12)
- **Responsabilidade:** datasets JSONL PT-BR (Instruction, Intent, Entities,
  Plan, Expected Tools, Expected Output, Expected Diagnostics); autogeração:
  código que compila → positivo; erro conhecido → negativo associado ao
  código de diagnostic.
- **Depende de:** compiler, executor, corpus.

### `tests/` · `benchmarks/` · `docs/` · `specs/` · `scripts/`
- Infraestrutura transversal. Regras em TEST_PLAN.md e BENCHMARK_PLAN.md.

---

## Matriz resumida de dependências (quem chama quem)

```
apps cli editor
        ↓
      agent ──► brain planner executor
                    ↓      ↓       ↓
                  tools ◄─ workspace
                    ↓
                compiler   (única porta para o kof)
                    ↑
      corpus retrieval memory
         ↓       ↓        ↓
     embeddings tokenizer
         ↓
      runtime ──► gpu cpu backends
                    ↓
               scheduler (base comum)
```

Nenhuma seta pode ser invertida. Violação é bug de arquitetura.
