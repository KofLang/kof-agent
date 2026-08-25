# PLANNER (M8) — implementado (estratégias determinísticas)
plStrategyFor(intent) → Web/CRUD/Repair/Compiler/Docs/RPA/Generic.
plTasksFor: BrainPlan → tarefas tipadas (kind, toolId, args, deps lineares,
validation) por estratégia; fallback IndexWorkspace. Merge de duplicatas por
(toolId,argA,argB). Ciclo detectado via wsDetectCycle. Eventos plan.created/
plan.optimized/rollback.generated/task.validated.
