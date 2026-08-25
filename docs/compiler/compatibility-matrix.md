# COMPATIBILITY MATRIX — Compiler x Agent milestones

| Milestone | Backend | Status | Bloqueios |
|-----------|---------|--------|-----------|
| M1 Core | Native | ✅ estavel | — |
| Semantic SC1/SC2/SC5 | ambos | ✅ FIXED upstream (SEM020/021/024) | — |
| Semantic SC3 | Native | 🟡 Partial (link error em vez de SEM) | — |
| M2 Gateway exec | JVM | 🟡 ponte tooling | J2(resolvido)/GW001 |
| M2 Gateway exec | Native | ❌ | GW001 |
| M3 Workspace verify | Native | 🟡 16/37 | N10/N11/N12 |
| M3 ws suites | JVM | ❌ | J3 (JavaFX runner) |
| M4 Tools exec | Native | 🟡 9/52 | N10-residual |
| M5 Corpus verify | Native | ❌ 0/15 | N10 |
| M7 Brain verify | Native | ❌ 0/22 | N10 |
| M8 Planner | Native | ✅ 5/8 | intents residuais |
| M9 Executor | Native | ❌ 0/5 | N10 |
| M10 Runtime AI | Native | 🟡 tokenizer ok; matmul | FLT/SIMD (Q2) |
| M11 GPU HAL | ambos | 🟡 contratos | Q2 |
| M12 Datasets | native/jvm | 🟡 emissor pronto | — |

Baseline: 4954622 · atualizado 2026-08-25T12:07:02Z
