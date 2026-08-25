# REPORT_COMPILER_HEAD_4954622

## Compiler HEAD
4954622 (fix/compiler-bugs-0.0.14 merged; baseline do agente movido ao HEAD)

## Bugs Corrigidos (verificados com repros)
| ID | Repro |
|----|-------|
| J1 | docs/compiler/reproductions/J1.md |
| J2 | docs/compiler/reproductions/J2.md |
| N2 | docs/compiler/reproductions/N2.md |
| N14 | docs/compiler/reproductions/N14.md |

## Bugs Novos (descobertos nesta fase)
N11 (lastIndexOf ausente) · N12 (record grande corrompe campos) ·
N13 (delta Long posicional) · J3 (JavaFX no runner JVM — agente)

## Bugs Ainda Reproduzíveis
N1 · N3 · N4 · N6 · N7 · N8 · N9 · **N10 (progressivo)** · SC1–SC5

## Bugs Não Reproduzidos Novamente
—

## Cobertura das Milestones
M1 ✅ estável · M3 16/37+diff7/8 · M4 9/52 · M5 pendente · M6 pendente ·
M7 pendente · M8 5/8 · M9 bloqueado · M10 10/10 · M11 5/5 · M12 núcleo ✅

## Benchmarks comparativos
M1 baselines mantidos (init ~120µs, scheduler ~143k t/s). FP: PENDENTE Q2.

## Recomendação prioritária ao time do compilador
1. N10 (progressivo por tamanho/posição do TU) — trava M3–M9.
2. N6/N7/N8/N9 (strings/controle básicos no Native).
3. SC1–SC5 (emissão de diagnósticos ausentes).
4. N11/N3/N4.
