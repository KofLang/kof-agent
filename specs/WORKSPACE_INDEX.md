# SPEC — WORKSPACE INDEX (M3)

**Status:** implementado · parcialmente verificado (bloqueio nativo N10 — docs/compiler-bugs.md)

## 1. Modelo

`WorkspaceIndex(root, bus[, clock])` mantém `WsSnap` corrente:

- files: List<WsFileRec> (path, hash djb2, tamanho)
- symbols: List<WsSymRec> (name, kind, file) — **aproximação lexical** (D0018)
- imports: List<WsImpRec> · deps: List<WsEdgeRec> (DAG de arquivos)
- diagCache: List<WsDiagRec> (file+hash → contagem/códigos do Gateway)
- metadados: workspaceId (hash estável de root+git), gitBranch/Commit
  (lidos de .git sem processo), target (kof.config), timestamp (TimeSource)

## 2. Operações

| API | Semântica |
|-----|-----------|
| fullRescan() | varre, parseia lexical, monta deps, publica eventos |
| incremental() | diff vs corrente; reusa estado; publica workspace.changed + file.* |
| save()/load() | persistência versionada (ver SNAPSHOT_FORMAT) |
| findSymbol/symbolsOf/importsOf/depsFrom | consultas O(n) |
| cycles() | DFS com pilha — retorna caminho do ciclo |
| unusedImports() | import cujo nome ocorre ≤1× no arquivo (a própria linha) |
| diffVsCurrent() | WsDiffRec added/modified/deleted/renamed(+sym placeholders) |
| putDiag/cachedDiag | cache de diagnostics por hash (evita recheck de arquivo intacto) |

## 3. Aproximação lexical (WORKAROUND — D0018)

Sem GW-AST-DUMP o índice usa detecção por linha (`record/class/interface/
entity/abstract class` + heurística de função por `(`, exclusão de keywords,
marcadores `): `/`) = `/`{`). Consequências honestas:

1. métodos dentro de classes aparecem como `function` (sem escopo);
2. não há tipos, overloads, generics ou visibilidade;
3. NUNCA usar como verdade semântica — apenas navegação/heurística de
   planner. Substituir pelo canal do compilador quando GW-AST-DUMP abrir;
   os consumidores não mudam.

## 4. Eventos

workspace.indexing · snapshot.created · workspace.indexed ·
workspace.changed · file.added/modified/removed/renamed · diff.computed ·
workspace.cacheInvalid.

## 5. Estado de verificação

37 testes gerados (por-processo). 16 verdes no Native; os demais bloqueados
pela família N10 (miscompile posição/estado-dependente do backend nativo
0.0.14 — cada unidade lógica foi validada verde isoladamente; técnica de
isolamento e bisect documentadas em compiler-bugs.md).
