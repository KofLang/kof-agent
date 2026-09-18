# REPORT_M02.md

# Milestone 02 — Compiler Gateway

Status:

* 🟡 Parcial — API estabilizada, spike/benchmark/goldens completos; execução
  in-language do gateway bloqueada por 2 bugs upstream (J2/GW001),
  contornados por ponte tooling documentada.

## Resumo Executivo

Fechada a questão arquitetural Q1 com dados: benchmark das três arquiteturas
(250 ops single-shot + 60 batches + incremental + projeto de 50 arquivos)
elegeu o **B' híbrido batch-subprocess** como implementação default da
interface única `CompilerGateway` (~21.8 ms/arquivo vs ~201 ms/op do
single-shot; embedded bloqueado sem FFI). A superfície tipada completa foi
definida e compila (records Diagnostic/Location/Range/Symbol/Snapshot/
CheckResult), com CompatibilityRegistry que anota automaticamente
diagnostics com o bug upstream correspondente e eventos publicados no
EventBus. Golden suite com **20 programas reais** criada e verde via ponte
tooling — e o bless revelou **5 lacunas semânticas reais do compilador**
(GW-SEM-COVERAGE), agora catalogadas para upstream. Descoberto mais um bug
crítico (J2: `process.run` quebra o gerador JVM), elevando o ledger para 11
itens + 5 gaps de cobertura.

## Arquivos Criados

```
specs/COMPILER_GATEWAY.md            contrato completo + gaps
agent/runtime/95_gateway.kf          records + registry + parser + SubprocessGateway
apps/gateway/main.kf                 entrada do artefato-gateway (check/build/selftest/golden)
scripts/build_gateway.sh             builder (--with-gateway → translation unit JVM-only)
scripts/spike_gateway_q1.sh          harness do benchmark Q1
scripts/golden_compiler.sh           golden runner (+ --bless)
tests/golden/compiler/*.kf           20 programas reais
tests/golden/compiler/MANIFEST       expectativas observadas (file|exit|code)
tests/golden/compiler/*.expected.json (20) — com gaps GW-AST-DUMP/GW-SEM-COVERAGE explícitos
docs/spikes/compiler-gateway-q1.md   relatório do spike
benchmarks/native-M02-spike.json     métricas p50/p95/p99 exportadas
REPORT_M02.md
```

## Arquivos Modificados

```
scripts/build.sh            flag --with-gateway
docs/DECISIONS.md           D0016 (ADR-001 gateway B'-híbrido), D0017 (goldens = verdade observada); Q1 resolvida
docs/compiler-bugs.md       +J2 (process.run quebra JVM) · +SC1..SC5 (gaps semânticos)
docs/status.md              snapshot M2
README.md                   M2 🟡 na tabela
.gitignore                  build/spike-q1 coberto por build/
```

## Arquitetura Implementada

- **Interface única, três estratégias**: `SubprocessGateway` (single-shot,
  funcional via ponte), batch-amortizado como política default do repair
  loop futuro (snapshot→dirty→check-dir), Resident/Embedded assinadas na
  interface e desbloqueáveis sem mudar chamadores.
- **CompatibilityRegistry**: mensagens de erro casadas contra assinaturas dos
  bugs do ledger (`N2`, `N4`, `CONC001`, `FLT001`...) → `workaroundId` no
  diagnostic estruturado.
- **Parser-ponte versionado** do formato oficial `:l:c: severity: msg [CODE]`
  (gap GW-DIAG-JSON documentado; posições hoje são sempre 0:0 — limitação do
  `kof check`).
- **Eventos**: compiler.started/finished, build.succeeded/failed,
  compiler.diagnostics (codes JSON) — consumíveis pelo Editor Protocol M4.

## APIs Criadas

`CompilerGateway` (contrato): check · build · run · parse · ast · semantic ·
ir · diagnostics · symbols · references · hover · completion · definition.
Implementações: SubprocessGateway (checkPath/checkDir/buildTarget/runProgram);
ResidentGateway e EmbeddedGateway declaradas na spec com condições de
desbloqueio (GW002/GW003). Estruturas: DiagnosticRec, LocationRec, RangeRec,
SymbolRec, ModuleInfoRec, FileHashRec, SnapshotRec, CheckResult(+toJson/
codesJson). Helpers incrementais: snapshotDir/diffSnapshots.

## Ferramentas Criadas

`spike_gateway_q1.sh` · `golden_compiler.sh [--bless]` · `build_gateway.sh` ·
extensão `build.sh --with-gateway`.

## Testes

Golden compiler: **20/20 PASS** (manifest = comportamento observado do kof
0.0.14; 5 casos `_gap_*` documentam aceitação incorreta upstream). Selftest
do gateway (registry/parser/snapshot-diff) definido em `selftest`; execução
in-language pendente J2 — lógica espelhada e verificada pela ponte.
Suíte M1 continua verde (regressão zero).

## Benchmarks

1000+ operações medidas (250 single-shot + 600 file-checks em batch +
300 incremental + large-project):

| Métrica | A subprocess | B' batch | C embedded |
|---|---|---|---|
| p50 | 201 ms | 21.8 ms/arquivo | BLOCKED |
| p95 | 206 ms | 22.3 ms/arquivo | — |
| p99 | 208 ms | 22.3 ms/arquivo | — |
| incremental (touch 1/10) | — | 219 ms/dir | — |
| projeto 50 arquivos | — | 254 ms/dir | — |

Export: `benchmarks/native-M02-spike.json` · relatório:
`docs/spikes/compiler-gateway-q1.md`. RAM por op não exposta pela stdlib
(gap metrics) — registrado.

## Decisões Técnicas

1. **ADR-001/D0016**: vencedor B' híbrido; Resident/Embedded preservadas na
   interface — troca de implementação sem custo para chamadores.
2. **D0017**: goldens registram a verdade observada; divergências viram itens
   upstream nomeados (`_gap_*`), nunca mascarados.
3. **Parser-ponte** explicitamente temporário, com substituição planejada
   quando `check --json`/LSP-diagnostics existir como canal nativo.
4. Relógio do gateway via `process.run("date +%s%N")` enquanto J1 impede
   `now()` em artefatos JVM.

## Pendências

- Execução in-language do Gateway: requer correção J2 (JVM) e GW001
  (native). Toda a lógica já está compilando (classes emitidas).
- AST/Symbol/Semantic/IR reais: aguardam dumps estruturais do compilador
  (GW-AST-DUMP) — consultas `findFunction/ast()/symbols()` retornam gap
  estruturado hoje, por design.
- Residente com pipes: GW002.
- Reportar upstream: J2, SC1–SC5 (com repros prontos em docs/compiler-bugs.md).

## Riscos

- Parser-ponte pode quebrar se o formato de output do `check` mudar — mitigar
  na M3 fixando versão do compilador por workspace (`kof info`) + teste de
  fumaça do formato no boot.
- `GW-SEM-COVERAGE`: repair loop da M9 não deve assumir que todo erro de
  domínio tem diagnostic — corpus de repair deve nascer dos diagnostics QUE
  EXISTEM.

## Próxima Milestone Recomendada

**M3 — Workspace Intelligence**, aproveitando o que o Gateway já dá:

1. Spec WORKSPACE: modelo de índice (files, imports, declarações por arquivo
   via parsing local do frontend? — não: via Gateway quando AST-DUMP abrir;
   M3 usa heurística léxica própria marcada WORKAROUND até lá... NÃO: manter
   proibição de parser paralelo → índice M3 = files/hashes/targets/config,
   símbolos só quando GW-AST-DUMP abrir. Ajustar escopo com esse realismo).
2. Índice persistente incremental por checksum (base já existe:
   SnapshotRec/diffSnapshots).
3. Consultas por arquivo/diretório; integração com eventos do Gateway.
4. Benchmarks de indexação inicial/incremental; REPORT_M03 + status.
