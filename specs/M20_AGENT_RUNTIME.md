# M20_AGENT_RUNTIME

Unified Agent Runtime — pipeline único User→Brain→Planner→Retriever→Orchestrator→Memory→Tools→Executor→RepairLoop→Response. ExecutionState completo serializável: intent/entities/context/plan/tasks/states/metrics/events/journal. Ponto de entrada único kof-agent.run().

## Definition of Done

- Spec revisada.
- Implementação em Kof compilando para Native.
- Testes one-per-process.
- Benchmark baseline.
- Compatibility sweep.
