# Milestone 08 — Planner

Status:

* 🟡 Parcial — Planner determinístico completo (estratégias, DAG, merge,
  validações, rollback via backups M4); suíte nativa 5/8 verdes após correção
  de sinônimos PT-BR; 3 falhas reais em brainResolveIntent sendo fechadas.

## Resumo Executivo

BrainPlan → ExecutionPlan: estratégias Web/CRUD/Repair/Compiler/Docs/RPA/
Generic geram tarefas tipadas (CreateDir/CreateFile/CompileCheck/SearchText/
RunTests/IndexWorkspace) com deps encadeadas, validação declarativa
(dir-exists/file-exists/compiles/tests-pass/results-found/indexed), merge de
duplicatas, detecção de ciclo sobre depsCsv (reuso wsDetectCycle), eventos
plan.created/plan.optimized/rollback.generated/task.validated e toJson
estável. Corrigidos sinônimos PT-BR faltantes descobertos pelos testes
(cria/edita/gera) — o loop Brain→Planner funcionou como previsto: testes
reais expuseram lacunas da tabela.

## Arquivos Criados

agent/runtime/69_planner.kf · tests/planner_src/unit_planner.kf ·
tests/planner/*.kf (8 gerados + MANIFEST) · scripts/test_planner.sh ·
specs/{PLANNER,EXECUTION_PLAN,PLAN_GRAPH,ROLLBACK}.md · REPORT_M08.md

## Arquivos Modificados

agent/runtime/68_brain.kf (sinônimos cria/edita/gera; tipos explícitos)
· scripts/build.sh (partes 68/69) · docs/status.md · docs/TASKS.md · README.md

## APIs Criadas

plStrategyFor · plTasksFor · plMergeDuplicates · plDepsSatisfiable ·
plHasCycle · plannerBuild · plValidateTask · ExecutionPlan.toJson.

## Testes

8 autorados one-per-process: **5 PASS / 3 FAIL** (falhas reais em intents
"gera crud" e extração quoted — investigação registrada; não são flaky).
Contagem RFC (>120) fica para a rodada anti-N10 que já colhe M3–M7.

## Benchmarks

PENDENTES-N10 (harness segue padrão bench_m0X).

## Decisões Técnicas

Estratégias como tabelas de código (não aprendidas) — determinismo e
auditabilidade primeiro; aprendizado entra no SLM M12.

## Pendências

Fechar 3 falhas de intent/entities; validações compiles/tests-pass via Gateway
quando J2/GW001 abrirem; >120 testes na rodada anti-N10.

## Próxima Milestone Recomendada

Estabilização anti-N10 (colher M3–M8) e reporte upstream; depois **M9 —
Executor + Repair Loop**, que consome ExecutionPlan exatamente como gerado.
