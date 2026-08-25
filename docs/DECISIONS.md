# DECISIONS — Registro de Decisões Arquiteturais

**Formato:** ID · data · status · contexto · decisão · consequências.
Decisão nova só entra aqui com justificativa escrita. Dúvida sem resposta
vai para "Questões em aberto" — nunca vira comportamento assumido.

---

## D0001 — Linguagem e target principal
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** o agente é componente oficial do ecossistema Kof.
- **Decisão:** todo código em **Kof**; target principal **Native**
  (ELF x86-64); JVM/JS como paridade secundária quando a stdlib permitir.
  Sem dependência obrigatória de JVM.
- **Consequências:** módulos precisam respeitar gaps do Native com
  diagnósticos explícitos (ex.: CONC001, FLT001); CI precisa de toolchain
  `as`/`ld`.

## D0002 — Zero dependência externa obrigatória
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** distribuição do Kof é autocontida; o agente segue a mesma filosofia.
- **Decisão:** sem Node/Python/servidor de banco/serviço externo obrigatório.
  RAG, embeddings, tokenizer e índices são implementações próprias em Kof
  com persistência binária local.
- **Consequências:** mais código próprio; controle total de performance e
  formato; providers externos ficam opcionais atrás da Model API.

## D0003 — Compiler Gateway é a única fronteira com o compilador
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** regra Kof: "nunca duplicar o parser" (editor consome o
  frontend real).
- **Decisão:** nenhum módulo do agente parseia/inventa regras de Kof. AST,
  símbolos, diagnostics, IR chegam apenas via Compiler Gateway, como
  estruturas tipadas.
- **Consequências:** mecanismo de integração com o binário/jar do compilador
  precisa ser definido na M2 (ver Q1); latência de compile-check é métrica
  crítica.

## D0004 — Event Bus e thread pool próprios
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** concorrência previsível sem expor threads na linguagem.
- **Decisão:** scheduler cooperativo + thread pool internos; comunicação por
  eventos tipados. Quando `spawn`/filas evoluírem na stdlib Kof, o runtime
  interno migra sem mudar API pública.
- **Consequências:** cancelamento é cooperativo; prioridades explícitas nas tasks.

## D0005 — Corpus markdown versionado + índice binário próprio
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** corpus oficial (`training/`, `learn/`, `docs/` do Kof) evolui
  junto com a linguagem.
- **Decisão:** documentos em markdown com metadata fixa (id, module, target,
  version, keywords, symbols, checksum); cache e índice incremental binários,
  sem banco externo.
- **Consequências:** regeneração automática quando o Kof atualiza; checksums
  detectam defasagem.

## D0006 — RAG local, vetores quantizados em formato próprio
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** privacidade + offline + performance.
- **Decisão:** embedding index + vector index binários locais; top-K + MMR +
  ranking; filtros por target/versão/módulo.
- **Consequências:** recall medido contra conjunto canônico de perguntas;
  formato versionado desde o primeiro dia.

## D0007 — GGUF como formato de modelo; providers externos opcionais
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** runtime AI oficial não pode depender de Ollama nem de nuvem.
- **Decisão:** loader GGUF próprio (mmap/lazy) no runtime Kof; Ollama/
  OpenAI/Gemini/Claude são providers opcionais atrás da Model API única.
- **Consequências:** M10 define GGUF parser antes de sampler; rede fica
  isolada na camada backends.

## D0008 — Compute HAL como único contrato de hardware
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** portabilidade universal (Intel/AMD/NVIDIA/Apple).
- **Decisão:** interface única (allocate/upload/download/matmul/attention/
  rope/layernorm/softmax/kvCache/free). Nenhum código acima conhece CUDA,
  Vulkan ou Metal.
- **Consequências:** custo de abstração medido por benchmark por backend;
  fallback CPU SIMD sempre presente.

## D0009 — Editor Protocol JSON-RPC sobre stdio
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** mesmo espírito dos servidores LSP/DAP oficiais do Kof.
- **Decisão:** mensagens plan/patch/tool/progress/stream/diagnostics/result/
  cancel + heartbeat + version sobre stdin/stdout. Sem portas de rede.
- **Consequências:** editores integram sem config; tracing via logs locais.

## D0010 — Dataset JSONL PT-BR autogerado e ligado aos diagnostics
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** futuro SLM do Kof precisa de dados rastreáveis.
- **Decisão:** campos fixos (Instruction, Intent, Entities, Plan, Expected
  Tools, Expected Output, Expected Diagnostics). Código que compila →
  exemplo positivo; erro conhecido → negativo associado ao código do
  diagnostic. Regeneração automática quando a linguagem evolui.
- **Consequências:** pipeline depende do Compiler Gateway e do executor.

## D0011 — Segurança: plano + diff sempre visíveis; rollback sempre disponível
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** agente executa mutações em código real.
- **Decisão:** nenhuma ação destrutiva silenciosa; patches atômicos com
  rollback point; sandbox opcional; permissões declaradas por tool.
- **Consequências:** executor mantém journal completo por sessão.

## D0012 — Licença GPLv3; outputs e datasets não contaminados
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** alinhamento com a postura de licenciamento do compilador Kof.
- **Decisão:** código do agente sob GPLv3. Projetos, patches e datasets
  produzidos pelo usuário com o agente permanecem propriedade do autor.
- **Consequências:** README/LICENSING deixam isso explícito.

## D0013 — Part-files + concatenador de build
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** o compilador 0.0.14 não resolve símbolos entre arquivos (SEM015) — multi-arquivo é planned.
- **Decisão:** código autoral em "partes" (`agent/runtime/NN_*.kf`) sem unidade compilável própria; `scripts/build.sh` concatena partes (ordem fixa) + entrada num translation-unit único por artefato.
- **Consequências:** ordem das partes é contrato; toda definição precede o main do artefato (bug N1); migração para multi-arquivo nativo quando o compilador entregar.

## D0014 — Transporte de argumentos da CLI via `.kofargs` (ARG001)
- **Data:** 2026-08-24 · **Status:** aceito (workaround)
- **Contexto:** `main(String[] args)` segfaulta no Native mesmo com zero args (N3).
- **Decisão:** entrada `main()` sem parâmetros; wrapper `scripts/kof-agent` escreve argv em `.kofargs` (cwd) e o binário lê/apaga. Caminho único nos dois alvos.
- **Consequências:** substituir por argv real assim que N3 fechar upstream; testes usam o mesmo mecanismo.

## D0015 — Regras de compatibilidade nativa obrigatórias
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** bugs N4/N6/N7/N8/N9/N10 (docs/compiler-bugs.md) produzem segfault/hang/erro errado.
- **Decisão:** proibições de estilo com força de lint via `scripts/check_compat.sh`: sem `+=` em String, sem comparação String-null, sem `continue`, sem confiar em curto-circuito, defs antes do main.
- **Consequências:** código um pouco mais verboso; cada bug fechado upstream permite remover a regra correspondente.

## D0016 — ADR-001: arquitetura do Compiler Gateway
- **Data:** 2026-08-24 · **Status:** aceito (baseado em docs/spikes/compiler-gateway-q1.md)
- **Contexto:** Q1 exigia comparar subprocess vs residente vs embedded. Medido: A=201 ms/op; B' (batch amortizado)=21.8 ms/arquivo (~9×); C bloqueado sem FFI. `process.run` é one-shot (sem pipes) e está quebrado nos DOIS alvos (J2 no JVM, GW001 no native).
- **Decisão:** interface única `CompilerGateway`; implementação default = SubprocessGateway com política batch por snapshot (B'); Resident/Embedded definidos na interface, implementações desbloqueiam quando upstream fechar GW002/GW003 — sem mudar chamadores.
- **Consequências:** repair loop da M9 usa check-dir-batched (não per-file); ponte tooling (`golden_compiler.sh`) mantém golden tests verdes hoje; parser de diagnostics é ponte versionada até GW-DIAG-JSON.

## D0017 — Golden tests refletem o compilador real, não o desejado
- **Data:** 2026-08-24 · **Status:** aceito
- **Contexto:** bless dos goldens revelou 5 lacunas semânticas (GW-SEM-COVERAGE): programas "que deveriam falhar" passam limpos no 0.0.14.
- **Decisão:** manifest registra o comportamento OBSERVADO; casos divergentes da doc são renomeados para `_gap_*` com nota e viram itens de upstream. Nada é "consertado" no agente nem mascarado nos testes.
- **Consequências:** M9 (repair) só pode reparar o que o compilador diagnostica; a lista GW-SEM-COVERAGE vai ao upstream.

## D0020 — Baseline do compilador pinado em c822ed3
- **Data:** 2026-08-24 · **Status:** aceito (temporário)
- **Contexto:** upstream fixou J1/J2 mas introduziu N14 (native HEAD sem link).
- **Decisão:** clone Kof4j em branch `kofagent-baseline` = c822ed3; sweeps do agente rodam contra esse baseline; rebase assim que N14 fechar.
- **Consequências:** ganhos J1/J2 aproveitáveis já agora (JVM target volta a ser opção p/ suites ws); N2/N10 etc seguem pendentes.

---

# Questões em aberto

## ~~Q1~~ ✅ RESOLVIDA (D0016) — benchmark das três vias executado; vencedor: B' híbrido batch-subprocess. Detalhes: docs/spikes/compiler-gateway-q1.md.

## Q2 — Ponto flutuante no target Native
O compilador hoje reporta gap FLT001 (sem SSE real no Native). Runtime AI
(M10/M11) exige matmul FP rápido. Opções: CPU backend SIMD fora do backend
Kof (C/asm linkado), antecipar suporte SSE no compilador, ou iniciar M10 no
target JVM e portar depois. **Revisar estado do compilador ao abrir a M10.**

## Q3 — Map/Set ausentes na linguagem
Estruturas do workspace/retrieval pedem dicionário. Enquanto não existe:
`List<record>` com busca linear + ordenação própria. Reavaliar quando o
plano da plataforma entregar Map/Set (P1).

## Q4 — Formato binário dos índices vetoriais
Definir layout, versão e estratégia de migração antes da M6 (spec própria).
