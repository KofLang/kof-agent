# SPEC — REPAIR_LOOP (M9)
Implementado em agent/runtime/71_executor.kf. Estados READY/RUNNING/SUCCESS/
FAILED/SKIPPED/ROLLED_BACK. Rollback via backups .katool-bak (M4) +
fs.rollbackRestore. Repair loop determinístico com teto maxRepairs
(nenhum patch aprendido ainda — GW-EXEC bloqueia compiler.check). Validações
declarativas do Planner executadas pós-tarefa. Execução nativa integral
PENDENTE-N10 (ver docs/compiler-bugs.md — N10 é progressivo com o tamanho do
translation-unit; descoberta desta milestone).
