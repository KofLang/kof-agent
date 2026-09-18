# FASE 3 — M13/M14/M15 + Specs M18–M20

Status:

* 🟡 PENDENTE-N10 — código completo escrito e commitado; verificação nativa
  bloqueada pela progressão do N10 no translation unit consolidado (1.2MB+ asm).

## Resumo

MemoryLayer (episodic/semantic/session + TTL + snapshot/restore versionado),
ConversationEngine (turns tipados + janela deslizante + summarize + cite),
ContextOrchestrator (fusão corpus+memory com dedup+budget), PromptBuilder,
memSearch, EmbeddingsProvider interface, specs M18 Reasoning Engine /
M19 Multi-Agent / M20 SLM Runtime. 9 testes one-per-process autorados.

## Bloqueio

N10-progressivo: o TU cresceu para ~1.3MB asm e TODAS as suítes novas
nascem crashando (segfault 139). Suítes M1 core continuam estáveis.
Playbook de bisect documentado em compiler-bugs.md é o caminho de colheita.
