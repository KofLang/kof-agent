# EXECUTION_PLAN (M8)
ExecutionPlan{id,intent,strategy,tasks[PlanTaskRec],acyclic,version} com
toJson estável. PlanTaskRec{id=plan-<strat>-<conf>-tN, kind, toolId, argA,
argB, depsCsv, validation, rollback}. Validações: dir-exists, file-exists,
compiles(GW-EXEC), tests-pass(GW-EXEC), results-found, indexed.
Rollback: backups .katool-bak via fs.rollbackRestore (M4).
