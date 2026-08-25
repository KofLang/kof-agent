# BRAIN (M7) — implementado (determinístico; NLU aprendida chega com SLM M12)
Pipeline: texto → retTokenize (M6) → Intent Resolver (tabela de sinônimos
PT-BR: crie/faz/gere→create, arruma/corrija→repair, edite→edit, rode/teste→
runtests...) → Entity Extractor (quoted strings, códigos de diagnóstico
conhecidos, paths .kf/build) → Context Bundle (retBuildContext M6 com
recentFiles/historyPaths) → BrainPlan.
Saída: BrainPlan(intent, entitiesJson, contextJson, confidence 0-95,
ambiguitiesJson, candidateToolsCsv, candidateRecipesCsv, candidateSymbolsCsv).
Nada de código. Eventos: brain.started/intent/ambiguity/completed.
