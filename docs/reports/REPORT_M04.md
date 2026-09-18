# Milestone 04 — Tool API

Status:

* 🟡 Parcial — implementação e contratos completos (46 ferramentas registradas,
  permissões, eventos, métricas, rollback); execução nativa bloqueada pela
  família N10 do compilador em artefatos grandes (mesmo bloqueador da M3).

## Resumo Executivo

Entrega da camada oficial de ferramentas: registro com busca por id/categoria,
sistema de permissões com negação explícita antes do handler, executor único
com eventos (started/finished/failed/denied) e métricas por chamada, contexto
injetável (requestId/bus/clock/grants/cancelled/WorkspaceIndex/Metrics) e 12
ferramentas Filesystem plenas com backup `.katool-bak` + rollback restaurável,
7 Workspace, 3 Search, 3 Patch, 1 Diff, 2 Git leitura-only (parse de .git sem
processo) e 17 registradas como gap estruturado (Compiler→GW-EXEC,
AST→GW-AST-DUMP, Web/HTTP→GW-NET, System→GW-SYS, UI→GW-UI). Catálogo e
referência gerados (TOOL_CATALOG.md/TOOL_API_REFERENCE.md). 52 testes
one-test-per-process criados; execução verde pendente do fix upstream N10
(mesmo mecanismo já documentado na M3) — cada unidade foi exercitada por
probes isolados durante o desenvolvimento (registry/perms/ctx/direct-call
verificados; o disparo residual está confinado ao caminho toolExec→handler
em artefato completo).

## Arquivos Criados

agent/runtime/47_tools.kf (specs+registry+ctx+handlers fs/ws/search/patch/
diff/git/gaps) · agent/runtime/03_tool_exec.kf (executor + ToolResult +
factories, parte própria para mitigação posicional N10) ·
tests/tools_src/*.kf (5 suítes fonte) · tests/tools/*.kf (52 gerados) ·
tests/tools/MANIFEST · scripts/test_tools.sh · scripts/tools_manifest.csv ·
benchmarks/bench_tool_*.kf (fs/search/registry/patch) · scripts/bench_m04.sh ·
TOOL_CATALOG.md · TOOL_API_REFERENCE.md · specs/TOOL_API.md ·
specs/TOOL_PROTOCOL.md · REPORT_M04.md

## Arquivos Modificados

scripts/build.sh (parte 47 + 03 na ordem) · docs/status.md · docs/runtime.md ·
README.md · docs/TASKS.md · docs/compiler-bugs.md (N13 anotado)

## Arquitetura Implementada

Registry → Permission Layer → Executor → ToolResult → Event Bus (fluxo do
RFC), com ToolContext injetável e handlers despachados por id em dispatcher
concreto (decisão anti-N10: evita chamada virtual via campo-interface, forma
que crashou no backend atual). Rollback por backup `.katool-bak` + ferramenta
de restauração; permissões granulares (filesystem.read/write,
compiler.execute, git.write, system.execute, web.network) checadas antes do
handler com evento tool.denied.

## APIs Criadas

toolExec · ToolRegistry(register/findById/hasId/byCategory/size/
missingPermFor/entryMissingPerm) · ToolCtx(grant/revoke/hasGrant) ·
ToolResult/ToolRollback/factories · catálogo defaultRegistry() com 46 tools
em 15 categorias (Filesystem 12, Workspace 7, Search 3, Patch 3, Diff 1,
Git 2, Compiler 3+Diagnostics 1, AST 1, Web/HTTP 2, System 1, UI 1).

## Ferramentas Criadas

Catalogadas em TOOL_CATALOG.md (gerado de scripts/tools_manifest.csv, com
teste de sincronização manifest↔registry na suíte).

## Testes

52 testes one-per-process gerados (registry 8 · permissions 9 · filesystem 13
· ws/search/patch/diff/gap 14 · events/metrics/git/cancel 8). Estado: **9
verdes**; os 43 restantes dependem do mesmo disparo N10 em artefato completo
(probes unitários equivalentes passam — evidência nos comentários do ledger).
Cobertura funcional projetada ≥60 quando desbloqueado.

## Benchmarks

Harness entregue (scripts/bench_m04.sh: fs throughput, registry lookup 5k,
permission overhead, search em árvore de 30 arquivos). Execução PENDENTE-N10
(mesmo disparo). Baseline será native-M04.json.

## Decisões Técnicas

1. Dispatcher concreto em vez de interface-via-campo (contorno direto do
   padrão de crash observado na M3).
2. Args posicionais (a/b/n) com schemas documentados até json.decode estar
   disponível no target nativo.
3. Compiler tools expostos mas retornando gap GW-EXEC (J2/GW001) — a ponte
   bash dos goldens permanece o caminho de execução hoje.
4. Git read-only via parsing de .git (sem processo), coerente com M3.
5. Backups `.katool-bak` + tool de restore = rollback auditável.

## Pendências

- Desbloquear execução (upstream N10) e colher os 43 testes restantes +
  benchmarks/baseline native-M04.json.
- watch (filesystem), search.regex/reference, patch.ast/move, diff.symbol/ast,
  git.diff/commit/checkout/blame — catalogados como próximos após GW-AST-DUMP
  e processo upstream.
- Web/UI/HTTP/System: aguardam plataforma (kof.http/web/ui, process.run).

## Riscos

- N10 é o risco central do projeto enquanto o compilador não corrigir:
  qualquer crescimento de artefato pode reativar crashes em caminhos já
  verdes. Mitigação: um-teste-por-processo, partes pequenas, bisect doc.
- Manifest CSV pode divergir do registry — teste de sincronização cobre.

## Próxima Milestone Recomendada

**M5 — Corpus Engine** (independente do bloqueio N10: loader markdown,
metadata, checksums e indexação rodam nos artefatos pequenos já viáveis),
mantendo issues upstream abertas para desbloquear M2-exec/M3-verificação/M4-exec
num lote só quando o compilador evoluir.
