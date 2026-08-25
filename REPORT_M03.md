# REPORT_M03.md

# Milestone 03 — Workspace Intelligence

Status:

* 🟡 Parcial — implementação completa e specs entregues; verificação nativa
  bloqueada pela família N10 do compilador (16/37 testes verdes; cada unidade
  lógica validada verde isoladamente).

## Resumo Executivo

Implementado o modelo persistente do projeto: snapshot imutável completo
(workspaceId, root, gitBranch/Commit lidos de `.git` sem processo, target,
files+hashes, symbols, imports, deps), índice com consultas
(findSymbol/symbolsOf/importsOf/depsFrom/cycles/unusedImports), scanner
incremental com diff estruturado incluindo **detecção de rename por hash de
conteúdo**, cache de diagnostics por hash (base do repair loop), persistência
versionada com checksum (workspace.idx/.snapshot/.hashes) e 9 tipos de
eventos no bus. Símbolos usam **aproximação lexical declarada** (D0018) até
o compilador expor AST (GW-AST-DUMP). Verificação: 37 testes por-processo,
**16 verdes no Native**; os 21 restantes esbarram na família N10
(miscompile posição/estado-dependente) — cada unidade lógica foi provada
verde isoladamente e as técnicas de isolamento estão documentadas. Dois
novos achados upstream: **N11** (`String.lastIndexOf` ausente no runtime
nativo) e **N12** (record >8 campos misturando Long/List corrompe campos —
contornado convertendo para classe) + confirmação de que **J1 é por presença**
de `now()` no fonte, não por chamada.

## Arquivos Criados

```
specs/WORKSPACE_INDEX.md · specs/SNAPSHOT_FORMAT.md
agent/runtime/45_windex.kf          WsSnap/WsFile/WsSym/WsImp/WsEdge + parser lexical
                                    + git info sem processo + edges/cycles/unused
                                    + diff/rename + serialização versionada + WorkspaceIndex
agent/runtime/98_native_clock.kf    RealTimeClock (parte exclusiva-native; J1 é por presença)
tests/ws/*.kf (37)                  um teste por processo (isolamento N10)
tests/ws/MANIFEST
scripts/test_ws.sh                  runner ws (limpa fixtures por processo)
scripts/bench_m03.sh                harness de benchmarks workspace
benchmarks/bench_ws_{s,m,l}.kf
benchmarks/results/native-M03/ · benchmarks/baselines/native-M03.json (parcial)
REPORT_M03.md
```

## Arquivos Modificados

```
agent/runtime/00_core.kf      mkFile/EventCounter/RecordingHandler/freshBus (utils de teste promovidos)
scripts/build.sh              flags --with-gateway/--native-clock/--no-native-clock
scripts/test.sh               suites WS separadas (jvm planejado; hoje runner dedicado nativo)
docs/compiler-bugs.md         N11, N12, J1-presença
docs/status.md · README.md · docs/runtime.md (seção M3)
```

## Arquitetura Implementada

- Snapshot como **classe** `WsSnap` (decisão anti-N12: records grandes com
  Long+Lists corrompem campos); listas mutáveis internas, instância tratada
  como valor por convenção.
- Scanner incremental: coleta paths → hash → classifica added/modified/
  deleted/unchanged → pareamento deleted×added por hash = renamed → reparse
  só do que mudou.
- Dependency graph: aresta arquivo→arquivo quando import casa com símbolo
  declarado em outro arquivo; ciclos por DFS colorida; unused imports por
  contagem de ocorrências.
- Persistência: cabeçalho `MAGIC|VERSION|CRC\n` + payload seccionado
  (\u0001/\u0002/\u0003 sanitizados); rejeita magic/version/checksum inválidos
  com evento `workspace.cacheInvalid`.
- Relógio injetável (TimeSource) — FixedClock em testes/artefatos JVM;
  RealTimeClock existe apenas na parte exclusiva-nativa.

## APIs Criadas

WorkspaceIndex (fullRescan/incremental/save/load/findSymbol/symbolsOf/
importsOf/depsFrom/cycles/unusedImports/diffVsCurrent/putDiag/cachedDiag/
statsJson) · wsFullScan/wsParseFile/wsGitInfo/wsBuildEdges/wsDetectCycle/
wsUnusedImports/wsDiff/snapshotDir/diffSnapshots (reuso M2) · formatos
WSIDX/WSSNP/WSHSH v3.

## Ferramentas Criadas

`test_ws.sh` (runner com isolamento por processo + limpeza de fixtures),
`bench_m03.sh`.

## Testes

37 gerados (um por processo): **16 PASS / 21 bloqueados por N10**
(padrão: segundo fullRescan no mesmo processo, ou artefato grande com o
mesmo caminho de código, produz `array index out of bounds` espúrio).
Evidência de correção lógica: cada unidade (scan simples, parse de kinds,
edges, ciclo, unused, roundtrip, diff/rename, diag cache) passou verde em
artifact reduzido. Zero flakiness após limpeza de fixtures por processo.
Suítes M1/M2 nativas seguem verdes (regressão zero).

## Benchmarks

Harness entregue (`bench_m03.sh`, cold s/m/l + save/load warm). Execução
bloqueada pelo mesmo N10 (o bench faz fullScan pós-geração de arquivos).
Baselines ficam registrados como PENDENTES-N10; números serão colhidos no
primeiro run após fix upstream ou após nova rodada de bisect.

## Decisões Técnicas

1. **D0018 — aproximação lexical declarada**: índice de símbolos sem parser
   paralelo; limitações explícitas; substituível sem mudar consumidores.
2. **Um-teste-por-processo** para contornar N10 mantendo cobertura real.
3. **RealTimeClock segregado** em parte exclusiva-nativa (J1 é por presença
   de `now()` no fonte — descoberta desta milestone).
4. **WsSnap como classe** (anti-N12) mantendo assinaturas estáveis.
5. Git info lido diretamente de `.git/HEAD`+refs (zero processos).

## Pendências

- Fechar os 21 testes bloqueados: requer fix upstream N10 OU nova sessão de
  bisect fina (reordenar partes/mover funções — padrões já documentados).
- Benchmarks numéricos (PENDENTES-N10).
- Símbolos semânticos reais (GW-AST-DUMP) — substituir aproximação lexical.
- CLI `ws scan/status/diff` (a API existe; exposição via CLI na M4 com a
  Tool API).

## Riscos

- N10 pode atingir módulos futuros maiores (Planner/Executor) — mitigação:
  artefatos pequenos por função, testes por-processo, bisect documentado.
- Aproximação lexical pode divergir silenciosamente do compilador ao evoluir
  a gramática — mitigação: golden tests do Gateway continuam sendo a verdade;
  índice é navegação, nunca validação.

## Próxima Milestone Recomendada

**M4 — Tool API**, com ajuste de escopo honesto:

1. specs/TOOL_API.md: registro de tools com id/schema/permissões/diagnostics;
   implementar primeiro Filesystem, Search (sobre o índice M3), Patch/Diff e
   Compiler(check) via ponte existente.
2. Editor Protocol esqueleto consumindo os eventos já publicados.
3. Benchmarks de dispatch; REPORT_M04.
4. Paralelo: abrir issues upstream com compiler-bugs.md (J2/N10–N12/SC1–5)
   — desbloqueiam M2-execução e M3-verificação integral.
