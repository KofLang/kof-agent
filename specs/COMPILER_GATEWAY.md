# SPEC — COMPILER GATEWAY (M2)

**Status:** API estabilizada · implementação de referência bloqueada por
upstream (J2/GW001) — ponte tooling operacional
**Módulo:** `agent/runtime/95_gateway.kf` (contrato) · `scripts/golden_compiler.sh` (ponte)

---

## 1. Filosofia

1. O compilador é a única fonte da verdade. O Gateway nunca inventa
   informação.
2. Nunca interpretar mensagens de erro "no dedo": o parse existente é uma
   **ponte versionada** do formato oficial (`:l:c: severity: msg [CODE]`)
   até existir canal JSON/LSP nativo (gap GW-DIAG-JSON).
3. Nada retorna String quando pode retornar estrutura.
4. Nenhum módulo acima do Gateway conhece processos, CLI ou texto.

## 2. Arquitetura vencedora (ADR-001 — docs/spikes/compiler-gateway-q1.md)

| Gateway | Veredito |
|---------|----------|
| A — Subprocess single-shot | ✅ suportado; ~201 ms/op (startup JVM domina) |
| B — Residente/batch | ✅ como **B' híbrido**: agrupa checagens por snapshot/diretório (~21.8 ms/arquivo, ~9× A). Residente com pipes aguarda GW002 |
| C — Embedded | ❌ GW003: linguagem sem FFI/Java-interop |

**Decisão:** interface única `CompilerGateway`; implementação default
`SubprocessGateway` com política batch (snapshot → dirty → 1 check/dir).
Resident/Embedded entram atrás da mesma interface quando upstream entregar
GW002/GW003.

## 3. Estruturas tipadas (`95_gateway.kf`)

```
RangeRec(startLine, startCol, endLine, endCol)
LocationRec(file, range)
DiagnosticRec(code, severity, message, location, workaroundId)
SymbolRec(name, kind, visibility, gapNote)
ModuleInfoRec(path, checked, diagCount, ok)
FileHashRec(path, hash)          SnapshotRec(root, files)
CheckResult(ok, exitCode, durationMs, target, diagnostics[])
```

`DiagnosticRec.workaroundId` é preenchido automaticamente pela
**CompatibilityRegistry** quando a mensagem casa com um bug upstream
conhecido (`docs/compiler-bugs.md`: N2, N4, CONC001, FLT001...).

## 4. API pública

| Método | Estado M2 | Notas |
|--------|-----------|-------|
| check(path) | ✅ funcional* | *via ponte tooling hoje; in-language bloqueado por J2 |
| build(target) | ✅ idem | |
| run() | ✅ idem | |
| parse/ast/semantic/ir/symbols/references/hover/completion/definition | 🔒 gap `GW-AST-DUMP` / `GW-LSP` | assinaturas estabilizadas retornam estrutura vazia + gapNote — nunca texto solto |

\* Execução: `scripts/golden_compiler.sh` (mesma semântica/schema); a classe
Kof compila e emite as classes, mas `process.run` não roda em nenhum target
hoje (J2 no JVM, GW001 no native).

## 5. Workaround Registry

`CompatibilityRegistry.lookup(message) → bugId` — alimenta
`DiagnosticRec.workaroundId` e aparece no JSON (`"workaround":"N2"`). Novos
bugs entram primeiro em `compiler-bugs.md`, depois na registry.

## 6. Incremental compilation (interface pronta)

```
snapshotDir(dir): SnapshotRec            // hash djb2 por arquivo
diffSnapshots(before, after): List<String>  // dirty files
```

O compilador ainda não tem recheck incremental — o Gateway já isola os
consumidores disso: quando upstream suportar, `checkDirty(snapshot)` passa a
usar o canal nativo sem mudar chamadores.

## 7. Eventos publicados

`compiler.started` · `compiler.finished` · `build.succeeded` ·
`build.failed` · `compiler.diagnostics` (payload = codesJson).

## 8. Golden tests

20 programas reais + `MANIFEST` (file|exit|first-code) +
`.expected.json` por programa. Runner: `scripts/golden_compiler.sh`
(`--bless` para atualizar contra o compilador atual).

**Achado estrutural (GW-SEM-COVERAGE):** 5 programas que DEVERIAM falhar
segundo `docs/language-state.md` passam limpos no 0.0.14 — atribuição a
variável inexistente, type mismatch em declaração (`Int x = "s"`), método
inexistente, aridade de construtor errada e declaração duplicada. Casos
renomeados para `g*_gap_*` com nota no `.expected.json`. Isto calibra o
repair loop da M9: não se pode "consertar" diagnóstico que o compilador
ainda não emite.

## 9. Gaps registrados

| Gap | Bloqueio | Dono |
|-----|----------|------|
| GW001 | `process.run` ausente no Native | upstream |
| J2 | `process.run` quebra gerador JVM (COMP001) | upstream |
| GW002 | sem pipes/streams p/ residente LSP | upstream |
| GW003 | sem FFI p/ embedded | upstream |
| GW-DIAG-JSON | check sem saída JSON estruturada; posições sempre 0:0 | upstream |
| GW-AST-DUMP | sem dump de AST/symbols/IR consumível | upstream |
| GW-SEM-COVERAGE | 5 lacunas de checagem semântica (ver §8) | upstream |
