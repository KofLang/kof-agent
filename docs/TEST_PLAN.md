# TEST_PLAN — Plano de Testes

**Status:** aceito (Milestone 0)

---

## 1. Níveis

| Nível | O quê | Onde |
|-------|-------|------|
| Unit | função/classe isolada; erros como exceções String testadas via try/catch | `tests/<module>/unit/` |
| Integration | módulos juntos (ex.: executor + gateway + filesystem) | `tests/<module>/integration/` |
| Golden | entrada canônica → saída exata (planos, diffs, índices) | `tests/golden/` |
| Regression | um teste por bug corrigido, para sempre | `tests/regression/` |
| Corpus | exemplos do corpus compilam e ensinam o que compila | `tests/corpus/` |
| Compiler | programas Kof reais através do Compiler Gateway | `tests/compiler/` |
| Benchmark | validação de saída + métricas (ver BENCHMARK_PLAN) | `benchmarks/` |

## 2. Ferramentas da linguagem

- Suíte oficial: `test "nome" { }` + `assert(cond[, "msg"])` +
  `kof test <dir> --target native`.
- Exit code determinístico: falha = exit ≠ 0, sem stack trace.
- `process.exit(code)` para harnesses próprios.

## 3. Convenções

1. Cada módulo tem ao menos: caminho feliz + caso de erro + caso-limite.
2. Nome do arquivo descreve a área (`patch_rollback.kf`, `gateway_diagnostics.kf`).
3. Teste roda isolado; ordem não importa.
4. Bug corrigido sem regression test é bug reaberto.
5. Comportamento por target documentado quando diverge — gap vira caso de
   teste do diagnóstico (ex.: CONC001 esperado no Native).

## 4. Gates por milestone

- M0: n/a (documentação).
- M1: unit do scheduler/event bus/config; golden do `--json`; init < 100 ms.
- M2: compiler tests com ≥ 20 programas reais (válido e inválido); diagnostics
  tipados comparados campo a campo.
- M3: golden de índice de workspace em projeto exemplo versionado.
- M4: cada tool com unit + permissão negada testada.
- M5: corpus test garante que todo exemplo citado compila.
- M6: conjunto canônico de perguntas com recall@10 medido.
- M7–M9: E2E frase→verde nos casos canônicos (site, CRUD, repair);
  rollback 100% coberto.
- M10–M11: paridade numérica CPU vs GPU backend tolerância definida; fallback
  CPU sempre testado mesmo com GPU presente.

## 5. Critério final de release

```
mvn-equivalente: kof test tests/ --target native  → verde
golden diff vazio
benchmarks sem regressão > 20%
docs sincronizadas no mesmo commit
```

## 6. Proibições

- Mocks fingindo comportamento do compilador (usar o Gateway real).
- Teste dependente de rede/serviço externo (providers opcionais têm suite separada).
- Skip silencioso: teste pulado precisa de motivo documentado no PR.
