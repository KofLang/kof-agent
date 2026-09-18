# Milestone 00 — Fundação

Status:

* ✅ Concluído

## Resumo Executivo

Criada a base documental e estrutural oficial do Kof Agent: especificação do
produto, arquitetura em camadas com o Compiler Gateway como única fronteira
com o compilador Kof, mapa de módulos com dependências rígidas para baixo,
roadmap M0–M12 com critérios de aceite, processo de contribuição (Regra
Zero), estilo de código Kof obrigatório, registro de 12 decisões
arquiteturais e 10 riscos, planos de benchmark e testes, árvore completa de
diretórios (27 módulos, um README cada), README raiz e licença GPLv3 no
espírito do ecossistema Kof. Repositório inicializado em `main` com remote
apontando para github.com/KofLang/kof-agent.

## Arquivos Criados

```
README.md
LICENSE                                  (GPLv3, herdada do Kof)
.gitignore
REPORT_M00.md
docs/SPEC.md
docs/ARCHITECTURE.md
docs/MODULES.md
docs/ROADMAP.md
docs/TASKS.md
docs/CONTRIBUTING.md
docs/CODE_STYLE.md
docs/DECISIONS.md
docs/RISKS.md
docs/BENCHMARK_PLAN.md
docs/TEST_PLAN.md
apps/README.md          cli/README.md         editor/README.md
agent/README.md         brain/README.md       planner/README.md
executor/README.md      runtime/README.md     compiler/README.md
workspace/README.md     tools/README.md       protocol/README.md
memory/README.md        retrieval/README.md   embeddings/README.md
tokenizer/README.md     scheduler/README.md   gpu/README.md
cpu/README.md           backends/README.md    corpus/README.md
datasets/README.md      tests/README.md       benchmarks/README.md
scripts/README.md       docs/specs/README.md
```

## Arquivos Modificados

Nenhum — milestone de fundação (repositório novo).

## Arquitetura Implementada

Arquitetura **documentada** (nenhuma implementação nesta milestone, por
definição). Decisões estruturais registradas:

1. Camadas com dependência unidirecional para baixo; violação é bug de
   arquitetura (`MODULES.md`).
2. Compiler Gateway como única porta para o compilador Kof — proibido parser
   paralelo (D0003).
3. Núcleo Brain→Planner→Executor desacoplado por Event Bus tipado e thread
   pool próprio (D0004).
4. RAG local binário sem banco externo (D0005/D0006); GGUF + Compute HAL
   isolam hardware (D0007/D0008); providers externos opcionais.
5. Editor Protocol JSON-RPC sobre stdio (D0009) — mesmo espírito LSP/DAP do Kof.
6. Segurança por design: plano visível → diff → patch atômico → rollback (D0011).

## APIs Criadas

Nenhuma implementada. Contratos definidos na SPEC para as quatro interfaces:
Tool API (RF-4), Compiler Gateway (RF-3), Model API/Backend API (RF-10/11),
Editor Protocol (RF-12).

## Ferramentas Criadas

Nenhuma — Tool API nasce na M4 (com antecipação permitida de
Filesystem/Search/Patch/Diff a partir da M2–M3).

## Testes

Quantidade: 0 (não aplicável à fundação).
Cobertura: n/a.
Resultado: n/a — plano de testes aprovado (`docs/TEST_PLAN.md`) com gates por
milestone definidos até M11.

## Benchmarks

Não executados (não há código). Plano aprovado (`docs/BENCHMARK_PLAN.md`)
com métricas por milestone, harness estilo `kof bench` (mediana + RSS +
baseline JSON + threshold 20%) e metas absolutas: init < 100 ms, primeiro
token < 200 ms.

## Decisões Técnicas

- **Docs antes de código**: Regra Zero aplicada literalmente — toda a
  fundação é documentação auditável.
- **Kof-first honesto**: D0001 fixa Native como alvo, mas R01 registra que o
  gap FLT001 (ponto flutuante no backend nativo do compilador) pode exigir
  caminho alternativo para o runtime AI — risco declarado, não escondido
  ("sem magia silenciosa" vale para o próprio plano).
- **Licenciamento alinhado ao Kof** (D0012): GPLv3 no código; outputs e
  datasets do usuário não contaminados.
- **PT-BR como língua de interface e dataset** (D0010), coerente com o
  corpus oficial e o Brain da M7.

## Pendências

- Item 0.16 🟡: publicação efetiva no GitHub depende de credenciais de push
  do ambiente (remote já configurado; histórico pronto em `main`).
- Q1: mecanismo de integração com o compilador (subprocess vs residente vs
  API embutida) — decidir na abertura da M2 com benchmark das vias.
- Q2: estratégia FP/SIMD para o runtime AI dado FLT001 — revisar antes da M10.
- Specs individuais (`specs/*.md`) começam na M1 (Scheduler, Event Bus,
  Lifecycle, CLI).

## Riscos

Novos riscos identificados nesta milestone (registrados em `RISKS.md`):

- R01 FLT001 pode bloquear performance nativa do runtime AI (mitigação: spike
  técnico cedo + HAL isolada).
- R05 corpus defasado (mitigação: checksum/versionamento desde a M5).
- R09 ambiguidade do Brain PT-BR (mitigação: intents tipadas + perguntas em
  vez de chutes).

## Próxima Milestone Recomendada

**M1 — Core Runtime**, na ordem sugerida:

1. Escrever specs `specs/SCHEDULER.md`, `specs/EVENT_BUS.md`,
   `specs/LIFECYCLE.md`, `specs/CLI.md` (Regra Zero: spec → interfaces →
   testes → código).
2. Implementar scheduler cooperativo + thread pool e event bus tipado em
   Kof compilando para Native.
3. Logger (níveis via `KOF_AGENT_LOG_LEVEL`) e Config (arquivo > env >
   default) no espírito de kof.log/kof.config.
4. CLI mínima (`version`, `help`, `status`) com exit codes determinísticos
   e `--json`.
5. Benchmarks de inicialização (< 100 ms) e dispatch do event bus; primeiro
   baseline `benchmarks/baselines/native-M01.json`.
6. Fechar com `REPORT_M01.md` no template oficial.
