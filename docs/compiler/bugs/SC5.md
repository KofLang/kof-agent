# SC5

- **Estado:** Open
- **Compilador:** 0.0.14-alpha (fix/compiler-bugs-0.0.14 ate 4954622)
- **Commit do Agent:** cc46da5..HEAD
- **Categoria:** Semantica
- **Severidade:** media
- **Target afetado:** Semantics

## Sintoma
redeclaracao de local compila

## Repro minimo
```kof
var x=1; var x=2
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
compiler-regression/SC5/ (input.kf + expected.*)
