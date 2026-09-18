# Milestone 09 — Executor + Repair Loop

Status:

* 🟡 Parcial — Executor/Validation/Rollback/Repair implementados e compilando;
  suíte própria nasce sob o bloqueio N10 (0/5 verdes no primeiro run) e,
  achado crítico desta milestone: **o N10 é progressivo** — partes verdes de
  M3/M4 regrediram quando o translation-unit cresceu (1.1MB asm).

## Resumo Executivo

Executor determinístico sobre ExecutionPlan: estados READY/RUNNING/SUCCESS/
FAILED/SKIPPED/ROLLED_BACK, deps checadas na ordem (dependência falha →
dependente SKIPPED), rollback automático por tarefa usando os backups da Tool
API, repair loop com teto maxRepairs (tentativas contadas; patch determinístico
entra quando Gateway executar), validações declarativas do Planner pós-tarefa,
eventos plan.started/finished, task.started/completed/failed/skipped,
rollback.started/finished, repair.started/finished. Integração completa do
ciclo Brain→Planner→Executor em código compilável.

## Arquivos Criados / Modificados

agent/runtime/71_executor.kf · tests/exec_src/unit_exec.kf · tests/exec/*.kf
(5 gerados + MANIFEST) · scripts/test_exec.sh · specs/{EXECUTOR,REPAIR_LOOP,
VALIDATION_ENGINE,ROLLBACK_ENGINE}.md · REPORT_M09.md · scripts/build.sh
(parte 71) · docs/status.md · docs/compiler-bugs.md (N10-progressivo)

## APIs Criadas

exExecutePlan(reg,ctx,plan,maxRepairs): ExecResult · exRollback · exValidate ·
exRepairAttempt · ExecResult(ok/executed/failed/rolledBack/repairs/lastError).

## Testes

5 autorados one-per-process (E2E cria-arquivo, rollback por falha, skip por
dep, repairs bounded, cancellation). Estado: **bloqueados pelo N10 progressivo**
— a varredura global mostrou regressão de suítes antes verdes (ws/tools)
conforme o TU cresceu. Números consolidados no status.md.

## Benchmarks / Pendências

Task/plan throughput, rollback e repair latency: PENDENTES-N10. Contagem >150
testes cresce mecanicamente após desbloqueio. Reparo real precisa J2/GW001.

## Decisões Técnicas

Skip explícito de dependentes (nunca executa com dep não-SUCCESS); repair
contado mesmo sem patch disponível (auditoria); rollback só quando a tool
declara backup; `continue` banido reestruturando com flag (N7).

## Próxima Milestone Recomendada

**Estabilização upstream-first**: reportar os 15+ achados (J2/N10–N13/SC1–5,
com repros prontos) ao compilador Kof e rodar o playbook anti-N10 por parte —
é o caminho que colhe ~140 testes acumulados de M2–M9 de uma vez. Só depois
M10 Runtime AI (que também depende de FLT/SIMD).
