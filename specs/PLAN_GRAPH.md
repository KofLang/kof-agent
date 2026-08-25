# PLAN_GRAPH (M8)
Goal Graph (intent) → Task Graph (estratégia) → Dependency Graph (depsCsv,
checagem plDepsSatisfiable + plHasCycle) → ExecutionPlan. Dedup por
(toolId,argA,argB). Ordenação linear por cadeia de deps (determinística).
