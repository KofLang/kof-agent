# Relatório upstream — kof-agent → KofLang/compiler (4954622)

Bugs descobertos pelo kof-agent durante M1–M12, com repros mínimos.

## Corrigidos
| ID | Target | Sintoma |
|----|--------|---------|
| J1 | JVM | KofRuntime gerado nao compila quando now()/secrets aparecem no fonte |
| J2 | JVM | process.run quebra gerador JVM |
| N14 | Native | HEAD ef91b7e: .Ljf_adv undefined (hello world) |
| N2 | Native | String.toInt sem simbolo nativo |

## Abertos/Parciais
| ID | Target | Sintoma |
|----|--------|---------|
| N1 | Native | fn top-level definida apos main e referenciada por ele nao linka |
| N10 | Native | miscompile progressivo posicional em TUs grandes |
| N11 | Native | String.lastIndexOf ausente |
| N12 | Native | record >8 campos Long+Lists corrompe campos na construcao posicional |
| N4 | Native | String.split segfault |
| N6 | Native | comparar String com null segfault |
| N7 | Native | continue em loop = hang infinito |
| N8 | Native | &&/|| sem curto-circuito |
| N9 | Native | += String perde acumulador em funcoes |
| SC1 | Semantics | atribuicao a var inexistente compila limpa |
| SC2 | Semantics | Int x = "texto" sem diagnostico |
| SC3 | Semantics | metodo inexistente compila |
| SC4 | Semantics | aridade de construtor errada compila |
| SC5 | Semantics | redeclaracao de local compila |

## Em investigação
| ID | Target | Sintoma |
|----|--------|---------|
| N13 | Native | subtracao Long de calls atribuida a campo em funcao grande crasha |
| N3 | Native | main(String[] args) segfault |

## Recomendação prioritária

1. N10 (miscompile progressivo por tamanho/posição do TU) — trava M3–M9.
2. N6/N7/N8/N9 — semântica/strings básicas no Native.
3. SC1–SC5 — cobertura semântica.
4. N11/N3/N4 — APIs de string/argv.
