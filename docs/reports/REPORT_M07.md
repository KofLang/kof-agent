# Milestone 07 — Kof Brain

Status:

* 🟡 Parcial — implementação completa e compilando; 22 testes autorados
  one-per-process aguardam a rodada anti-N10 (mesmo bloqueador das últimas).

## Resumo

Brain PT-BR determinístico: pipeline texto→tokens→intent (tabela de sinônimos:
crie/faz/gere, arruma/corrija/conserta, edite, rode/teste, busque, explique,
refatore) → entidades (quoted/diagCode/path) → contexto via Retrieval (M6) →
BrainPlan com confidence (cap 95), ambiguities estruturadas quando entidade
obrigatória falta (nunca assume; histórico pode preencher), candidate tools e
recipes. Separação rígida: Brain interpreta; Planner planeja (M8); Executor
modifica.

## Arquivos

agent/runtime/68_brain.kf · tests/brain_src/*.kf (2) · tests/brain/*.kf (22 +
MANIFEST) · scripts/test_brain.sh · specs/{BRAIN,INTENTS,ENTITIES,
NLU_PIPELINE}.md · REPORT_M07.md

## APIs / Testes / Pendências

brainProcess/brainPlanJson/brainResolveIntent/brainExtractEntities/
brainRequiredEntity/brainAmbiguitiesJson/brainConfidence/
brainCandidateTools. Testes: 22 autorados (intents 12, entidades/ambiguidade/
confiança/contexto 10); execução PENDENTE-N10; crescimento para >70 cobre
gírias adicionais, history resolver completo e variações de flexão — corpos já
no formato one-per-process. Benchmarks idem. TOOL_CATALOG inalterado.
