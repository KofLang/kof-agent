# M19 — MULTI AGENT RUNTIME (spec)
Scheduler de agentes sobre o EventBus existente: PlannerAgent, RetrievalAgent,
WorkspaceAgent, RepairAgent, MemoryAgent, ToolAgent. Comunicação exclusivamente
por eventos tipados; rollback distribuído via journal por agente. Sem threads
novas (usa o scheduler cooperativo M1).
