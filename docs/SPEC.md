# SPEC — Especificação do Kof Agent

**Status:** Milestone 0 (fundação)
**Última atualização:** 24 de agosto de 2026

---

## 1. Visão

O Kof Agent é um agente de programação oficial do ecossistema Kof. Ele
recebe objetivos em linguagem natural (português), produz planos tipados,
executa os planos através da Tool API, compila pelo compilador Kof, recebe
diagnostics estruturados e corrige o código até o estado verde.

> O agente nunca inventa regras da linguagem. O compilador é a fonte da
> verdade.

## 2. Personas

| Persona | Uso |
|---------|-----|
| Desenvolvedor Kof | "faz um site", "gera CRUD", "arruma erro" via CLI/editor |
| Editor | consome o Editor Protocol (plano, diff, progresso, cancelamento) |
| CI | roda o agente em modo não-interativo com exit codes determinísticos |
| Treinamento | consome datasets autogerados para o futuro SLM do Kof |

## 3. Requisitos funcionais

### RF-1 CLI (`cli/`)
- RF-1.1 Comandos: `run`, `plan`, `ask`, `index`, `corpus`, `bench`, `version`.
- RF-1.2 Saída legível por padrão; `--json` produz saída estruturada.
- RF-1.3 Exit codes determinísticos: 0 ok, ≠0 falha documentada.

### RF-2 Workspace Intelligence (`workspace/`)
- RF-2.1 Scanner completo de projetos `.kf`: arquivos, imports, classes,
  records, interfaces, funções, módulos, dependências, targets.
- RF-2.2 Índice interno persistente, atualização incremental por checksum.

### RF-3 Compiler Gateway (`compiler/`)
- RF-3.1 Única fronteira com o compilador Kof. Expõe: lexer/parser via
  compilador, AST, árvore semântica, symbol table, diagnostics tipados,
  IR, referências, definições, hover e completion.
- RF-3.2 Nunca retornar texto quando puder retornar estrutura tipada.
- RF-3.3 Proibido parser Kof paralelo em qualquer módulo do agente.

### RF-4 Tool API (`tools/`)
- RF-4.1 Toda ferramenta declara: `id`, `description`, input schema,
  output schema, permissions, diagnostics, tests e benchmark.
- RF-4.2 Ferramentas obrigatórias: Filesystem, Workspace, Compiler, AST,
  Semantic, Type System, IR, Diagnostics, Formatter, Testing, Git, Web,
  Preview, JSON, HTTP, Patch, Diff, Search.

### RF-5 Corpus Engine (`corpus/`)
- RF-5.1 Banco de conhecimento oficial em markdown versionado com metadata:
  id, title, module, target, version, keywords, symbols, embedding, checksum.
- RF-5.2 Loader incremental com cache e indexação por símbolo/diagnóstico.

### RF-6 Retrieval Engine (`retrieval/`)
- RF-6.1 RAG local sem banco externo: índice vetorial binário próprio,
  top-K, MMR, ranking, filtros (target, versão, módulo) e cache.

### RF-7 Kof Brain (`brain/`)
- RF-7.1 Parser de intenção em português → Intents tipadas com slots,
  entidades, contexto de sessão e histórico.
- RF-7.2 Intents oficiais: CreateWebsite, EditWebsite, CreateAPI,
  CreateCRUD, AddTheme, Refactor, RepairDiagnostic, CompilerFeature,
  ExplainDiagnostic, RunTests, GenerateDocs, SearchSymbol, EditUI,
  Automation, RPA.

### RF-8 Planner (`planner/`)
- RF-8.1 Plano tipado: objetivo, tasks, tool de cada task, arquivos
  afetados, dependências, riscos, etapas, rollback, prioridade, status,
  tempo estimado. O planner NUNCA gera código direto.

### RF-9 Executor + Repair Loop (`executor/`)
- RF-9.1 Executa planos gerando eventos, logs, diff e patch; rollback
  disponível para toda mutação.
- RF-9.2 Repair loop configurável: compilar → diagnostics → consultar
  corpus → patch → compilar → testes → fim.

### RF-10 Runtime AI (`runtime/`, `tokenizer/`, `embeddings/`)
- RF-10.1 Runtime de inferência em Kof: tokenizer próprio (UTF-8,
  português, cases, keywords Kof), loader GGUF, scheduler, sampler,
  KV cache, streaming, Model API (`generate/embed/stream/loadModel/
  unloadModel/deviceInfo`).
- RF-10.2 Motor de embeddings próprio: embedDocument, embedQuery,
  embedWorkspace, embedDiagnostic; persistência binária incremental.
- RF-10.3 Providers externos opcionais atrás de interface única.

### RF-11 Compute HAL (`gpu/`, `cpu/`, `backends/`)
- RF-11.1 Interface universal (allocate/upload/download/matmul/attention/
  rope/layernorm/softmax/kvCache/free). Nenhum código acima conhece CUDA.
- RF-11.2 Backends: Vulkan, Metal, DirectML, CUDA, ROCm, OpenCL, CPU SIMD.
  Detecção e escolha automática conforme dispositivo e VRAM.
- RF-11.3 Quantização: FP16, BF16, INT8, INT4, Q8/Q6/Q5/Q4, GGUF.

### RF-12 Editor Protocol (`protocol/`)
- RF-12.1 JSON-RPC sobre stdio. Mensagens: plan, patch, tool, progress,
  stream, diagnostics, result, cancel. Heartbeat e version obrigatórios.

### RF-13 Segurança
- RF-13.1 Ação destrutiva jamais silenciosa: sempre plano visível, diff
  visível, rollback disponível, sandbox opcional.

## 4. Requisitos não funcionais

| ID | Requisito |
|----|-----------|
| RNF-1 | Linguagem Kof; target principal Native; todo código compila no Native |
| RNF-2 | Sem dependência obrigatória de JVM/Node/serviços externos |
| RNF-3 | Inicialização < 100 ms; primeiro token < 200 ms |
| RNF-4 | Streaming contínuo; baixo consumo RAM/VRAM |
| RNF-5 | mmap e lazy loading; zero cópias desnecessárias |
| RNF-6 | Modularidade rígida: dependências só para baixo (docs/MODULES.md) |
| RNF-7 | Cada milestone entrega docs + testes + benchmark + report |

## 5. Interfaces contratuais

1. **Tool API** (RF-4) — contrato único entre agente e capacidades.
2. **Compiler Gateway** (RF-3) — contrato único entre agente e compilador.
3. **Model API / Backend API** (RF-10/RF-11) — contrato único entre runtime
   AI e implementações locais ou providers remotos.
4. **Editor Protocol** (RF-12) — contrato único entre agente e editores.

Toda interface contratual recebe spec própria em `specs/` antes da
implementação (Regra Zero).

## 6. Fora de escopo

- Treinar modelos na M0–M11 (treinamento é M12+).
- Substituir o compilador Kof ou reimplementar qualquer fase dele.
- UI gráfica própria (o editor host é integração via protocolo).

## 7. Critérios globais de aceite

Uma release do agente é aceita quando:

1. compila no target Native sem gaps silenciosos;
2. toda limitação tem diagnóstico explícito;
3. suíte de testes verde (unit + integration + golden);
4. benchmarks registrados contra baseline sem regressão > 20%;
5. documentação sincronizada no mesmo commit.
