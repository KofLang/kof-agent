# SC4

- **Estado:** Open
- **Compilador:** 0.0.14-alpha (fix/compiler-bugs-0.0.14 ate 4954622)
- **Commit do Agent:** cc46da5..HEAD
- **Categoria:** Semantica
- **Severidade:** media
- **Target afetado:** Semantics

## Sintoma
aridade de construtor errada compila

## Repro minimo
```kof
P() p/ record P(Int)
```

## Esperado
erro

## Observado
exit 0

## Workaround
Ver CODE_STYLE §13 e scripts/check_compat.sh (quando aplicavel).

## Milestones afetadas
M2-M9 conforme tabela em docs/compiler-bugs.md.

## Teste de regressao
compiler-regression/SC4/ (input.kf + expected.*)
