# Compiler Head Report — 416ff4b

## Regression sweep (repros executados)

| Bug | Resultado | Evidência |
|-----|-----------|-----------|
| N16 fwd-ref classe | ✅ **FIXED** — `N16-OK` jvm+native | regressions/N16/n16_fwd.kf |
| N17 cmp signed Int[] | ✅ **FIXED** — `lt0=true` nativo | regressions/N17/repro.kf |
| N13 Long delta | ✅ **FIXED** — imprime `1` | regressions/N13/repro.kf |
| N11 lastIndexOf | ❌ aberto — COMP001 símbolo ausente | docs/compiler/bug-ledger.md |
| N12 record >8 campos | ❌ aberto — campo 9º retorna `0` | regressions/N12/repro.kf |
| J4 Frame.merge purgeExpired | 🟡 parcial — fix não cobre repro_full; reabrir upstream c/ minimização pendente | regressions/J4/repro_full.kf |
| N10 progressivo TU grande | ❌ aberto — f3_test SIGSEGV 139 | build/f3_test.kf |

## Impacto no agente
- M10: **9/9 nativo** (Q8 destravado pelo fim do N17).
- M16.2: **14/14 nativo**.
- Kernels podem re-adotar negativos (softmax/causal simplificáveis em M16.3).

## Ações upstream sugeridas
1. Reabrir J4 com regressions/J4/repro_full.kf.
2. N12: 9º campo de record zera.
3. N11: lastIndexOf ausente no backend nativo.
