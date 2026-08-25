# Status do Projeto Kof Agent

> **Fonte única de verdade sobre o estado atual.** Atualizar este arquivo ao
> final de TODA etapa/milestone (obrigação registrada em
> [CONTRIBUTING.md](CONTRIBUTING.md) §6). Em conflito entre documentos,
> vence: implementação → testes → este arquivo → demais docs.

**Última atualização:** 24 de agosto de 2026
**Milestone corrente:** M12 — Dataset Builder (M11 🟡 CPU real 5/5)
**Milestones:** M0 ✅ · M1 ✅ · M2–M10 🟡 · **M11 🟡 CPU real 5/5**

---

## Snapshot

| Item | Estado |
|------|--------|
| Compilador | HEAD 4954622 (fix/compiler-bugs-0.0.14 merged) · branch kofagent-baseline |
|------|--------|
| Repositório | `github.com/KofLang/kof-agent` · branch `main` · sincronizado |
| Código | runtime completo em Kof: 9 partes + CLI (~2.6k linhas), compila no **Native** |
| Suíte | **11/11 suítes verdes** (39 testes estruturados + 2 stress), target native |
| Benchmarks | baseline `native-M01`: init **120 µs**, scheduler ~143k tasks/s, bus ~56k ops/s, logger ~19.6k l/s, pool ~141k t/s |
| URGENTE | reportar upstream: N10-residual (segfaults em artefatos grandes), N11/N12/N13, SC1–5 |
| ✅ CORRIGIDOS upstream | J1 · J2 · N2 · N14 (baseline HEAD 4954622) |
| 🆕 J3 (investigar) | runner JVM exige JavaFX em certos artefatos de teste — bloqueia rota JVM das suítes WS |
| Workspace | índice+snapshot+diff+persistência implementados; aproximação lexical (D0018); 16/37 testes nativos (resto N10) |
| Gateway Q1 | ✅ decidido (D0016): B' híbrido batch-subprocess — A=201ms/op, B'=21.8ms/arq, C bloqueado |

## M3 — Workspace Intelligence 🟡 (24/08/2026)

Implementado: WsSnap completo (files/hashes/symbols/imports/deps/git/target),
scanner incremental com diff estruturado **incl. rename por hash**, DAG de
dependências com detecção de ciclos, unused imports, diag cache por hash,
persistência versionada WSIDX/WSSNP/WSHSH v3 com checksum, 9 eventos no bus,
consultas (findSymbol/symbolsOf/importsOf/depsFrom/cycles). Símbolos via
**aproximação lexical** (D0018) até GW-AST-DUMP.

Verificação: 37 testes um-por-processo → **16 PASS / 21 bloqueados pela
família N10** (cada unidade lógica verde isoladamente; isolamento documentado).
Novos upstream: N11 (lastIndexOf ausente), N12 (record grande corrompe campos
→ convertido p/ classe), J1-confirmado-por-presença.

## M2 — Compiler Gateway 🟡 (24/08/2026)

Entregue: spec completa (`specs/COMPILER_GATEWAY.md`); API tipada estabilizada
e compilando (`95_gateway.kf`: DiagnosticRec/Location/Symbol/Snapshot/
CheckResult + CompatibilityRegistry + eventos); spike Q1 executado e
documentado (`docs/spikes/compiler-gateway-q1.md`,
`benchmarks/native-M02-spike.json`); golden suite **20/20 verde**
(`scripts/golden_compiler.sh`, manifest = verdade observada).

Bloqueado por upstream (execução in-language): `process.run` quebra o gerador
JVM (**J2**, novo) e não existe no Native (**GW001**) → ponte tooling mantém
golden/benchmarks funcionais. Achado crítico: **GW-SEM-COVERAGE** — 5 classes
de erro documentadas que o 0.0.14 NÃO emite (var inexistente, type mismatch
em decl, método inexistente, aridade, dup decl) — catalogadas SC1..SC5 para
upstream; repair loop (M9) só poderá reparar o que o compilador diagnosticar.

## M1 — Core Runtime ✅ (concluída em 24/08/2026)

- Scheduler cooperativo determinístico: heap de prioridades (O(n log n)),
  futures/await, cancelamento, backpressure, shutdown gracioso; estados
  CREATED→QUEUED→RUNNING→(WAITING reservado)→COMPLETED/CANCELLED/FAILED.
- EventBus tipado: envelopes-record, sync/async (async = task do scheduler),
  once, wildcard `*`, consumo de cadeia.
- Lifecycle BOOTING→INITIALIZING→READY⇄BUSY→STOPPING→STOPPED / FAILED com
  hooks ordenados e veto.
- Logger TRACE..FATAL: plain/JSON/ANSI, request id, quiet-sink; níveis via
  config (`log.level`).
- Config tipada arquivo > default, validação com erros claros, reload;
  env pendente (ENV001).
- Workspace scanner (kf count recursivo, git, config, ignores).
- Metrics com snapshot JSON; uptime por TimeSource injetável.
- CLI nativa: version/help/status/doctor/config, --json, exit codes
  0/1/2; argv via wrapper `.kofargs` (ARG001 — N3 upstream).
- Infra: build.sh (part-files → translation unit único), test.sh,
  bench_m01.sh, check_compat.sh, build_cli.sh, wrapper kof-agent.

DoD da M1: todos os itens verdes — specs antes de código, testes unit/
integração/stress, benchmarks com baseline exportado, report e docs
sincronizados.

## Testes & Benchmarks

- Suítes (`scripts/test.sh`, native): unit_core 7 · unit_logger 4 ·
  unit_config 5 · unit_scheduler 6 · unit_eventbus 6 · unit_lifecycle 5 ·
  unit_workspace 4 · integration_boot 1 · shutdown_safe 1 → **39 PASS**.
- Stress: 10.000 eventos (bus+handler) ✓ · 100.000 tasks (heap) ✓.
- Zero flakiness: nenhum assert de tempo; tempo vive só nos benchmarks.
- Baseline: `benchmarks/baselines/native-M01.json` (+ runs crus ×3).

## Questões em aberto

- ~~Q1~~ ✅ resolvida (D0016). Novas questões: GW002 (pipes p/ residente),
  GW003 (FFI p/ embedded), GW-DIAG-JSON/GW-AST-DUMP (canais estruturados do
  compilador) — todas upstream, rastreadas em specs/COMPILER_GATEWAY.md §9.
- **Q2** FP/SIMD no Native para o Runtime AI (FLT001 upstream) — revisar na
  M10; spike antecipado recomendado após M6.
- **Q3** Map/Set ausentes — padrão List<record> mantido.
- **Q4** formato binário dos índices vetoriais — spec antes da M6.

## Riscos no radar (top)

1. **N10** miscompile posição-dependente do backend nativo pode ressurgir com
   o crescimento do código — mitigado por check_compat.sh + técnica de bisect
   documentada + partes pequenas.
2. **R05** corpus defasado — checksums/versionamento desde a M5.
3. **R09** ambiguidade do Brain PT-BR — intents tipadas; ambiguidade vira
   pergunta (M7).

## Ledger de bugs do compilador (upstream Kof 0.0.14)

Descobertos e contornados na M1 — detalhes/repros:
[docs/compiler-bugs.md](compiler-bugs.md).

J1 (JVM runtime gen quebra com now/secrets) · N1 (defs após main não linkam)
· N2 (String.toInt sem símbolo nativo) · N3 (argv segfault) · N4 (split
segfault) · N6 (String==null segfault) · N7 (continue = loop infinito) ·
N8 (&&/|| sem curto-circuito) · N9 (+= String perde acumulador) · N10
(miscompile posição-dependente). Gate automático: `scripts/check_compat.sh`.

## Pendências conhecidas

- ENV001 (env layer), ARG001 (argv real), TP001/TP002 (multi-worker),
  métricas RAM/CPU/GPU — todos bloqueados por capacidades upstream,
  diagnosticados explicitamente (nunca silenciosos).
- Specs próprias para CONFIG/LOG/WORKSPACE/METRICS quando ganharem
  superfície nova (hoje: docs/runtime.md §3).

## Próximos passos imediatos (M2)

1. Spike Q1: medir subprocess vs residente vs embutida (meia semana).
2. `specs/COMPILER_GATEWAY.md` — contratos tipados, "nunca texto onde cabe
   estrutura".
3. Implementar Gateway pela via vencedora; golden tests ≥20 programas reais.
4. Benchmarks p50/p95 de compile-check; baseline `native-M02.json`.
5. REPORT_M02.md + atualizar este status.md.

---

## Histórico resumido

| Data | Evento |
|------|--------|
| 2026-08-24 | M0 concluída; repo publicado; status.md criado |
| 2026-08-24 | M1 concluída: runtime nativo completo, 11 suítes verdes, baselines registrados, 10 bugs do compilador documentados |
| 2026-08-24 | M2 🟡: gateway tipado + ADR-001 (B' híbrido) + goldens 20/20 via ponte; J2 e SC1–SC5 descobertos; execução in-language aguarda upstream |
| 2026-08-24 | M11 🟡: HAL v1 CPU real (copy/scale/dot) + seleção c/ override; 5/5 |
| 2026-08-24 | M10 🟡: runtime ai core (tokenizer/vocab/sampler/tensor-int/gguf-header) 10/10 nativo |
| 2026-08-24 | M9 🟡: executor/rollback/repair implementados; N10 revelado PROGRESSIVO (regressão de suítes verdes ao crescer TU) |
| 2026-08-24 | M8 🟡: planner determinístico (estratégias/DAG/validações/rollback); 5/8 nativos |
| 2026-08-24 | M7 🟡: brain PT-BR determinístico (intents/entidades/confidence/ambiguities); PENDENTE-N10 |
| 2026-08-24 | M6 🟡: retrieval lexical-first completo (expansões/ranking/budget/cache); PENDENTE-N10 |
| 2026-08-24 | M5 🟡: corpus engine + conteúdo semeado; 15 testes aguardam N10 |
| 2026-08-24 | M4 🟡: Tool API completa em código (46 tools, perms, rollback, eventos); execução aguarda N10 |
| 2026-08-24 | M3 🟡: workspace intelligence completa em código; N11/N12/J1-presença descobertos; 16/37 testes nativos, resto N10 |


---

## Pós-fixes upstream (24/08 tarde)

| Suíte | Target | Estado |
|-------|--------|--------|
| M1 core/runtime | native | 9/16 suítes ✅ (stress precisa rebuild c/ --native-clock) |
| M3 ws | native | scan 1/9 · diff **7/8** ✅ (N10 cedeu aqui) · symbols/deps/persist segfault |
| M4 tools | native | 0/52 (segfault residual N10 no caminho fs.read) |
| M5 corpus | native | 0/15 (idem) |
| M7 brain | native | 0/22 (idem) |
| M8 planner | native | **5/8** ✅ |
| M9 exec | native | 0/5 (idem N10) |
| M3 ws | jvm | bloqueado por **J3** (JavaFX no runner — investigar) |

### Ganhos da rodada
J1/J2/N2/N14 corrigidos e verificados com repros. N10-family **parcialmente
aliviada** (ws_diff 100%, planner estável). Baseline movido ao HEAD.

### Fila de trabalho sugerida
1. Investigar J3 (JavaFX no runner JVM) — pode destravar ~90 testes via rota JVM.
2. Rebuild stress/bench com `--native-clock` (refactor do clock quebrou geradores antigos).
3. Bisect N10-residual nos artefatos tools/corpus/brain (playbook já documentado).
4. Reporte upstream: N10-residual + N11/N12/N13 + SC1–5 (repros prontos).
