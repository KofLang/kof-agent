# BUG LEDGER — Compilador Kof vs kof-agent

| ID | Estado | Target | Sintoma |
|----|--------|--------|---------|
| J1 | Fixed | JVM | KofRuntime gerado nao compila quando now()/secrets aparecem no fonte |
| J2 | Fixed | JVM | process.run quebra gerador JVM |
| N1 | Open | Native | fn top-level definida apos main e referenciada por ele nao linka |
| N2 | Fixed | Native | String.toInt sem simbolo nativo |
| N3 | Investigating | Native | main(String[] args) segfault |
| N4 | Open | Native | String.split segfault |
| N6 | Open | Native | comparar String com null segfault |
| N7 | Open | Native | continue em loop = hang infinito |
| N8 | Partial | Native | &&/|| sem curto-circuito |
| N9 | Partial | Native | += String perde acumulador em funcoes |
| N10 | Open | Native | miscompile progressivo posicional em TUs grandes |
| N11 | Open | Native | String.lastIndexOf ausente |
| N12 | Partial | Native | record >8 campos Long+Lists corrompe campos na construcao posicional |
| N13 | Investigating | Native | subtracao Long de calls atribuida a campo em funcao grande crasha |
| N14 | Fixed | Native | HEAD ef91b7e: .Ljf_adv undefined (hello world) |
| SC1 | Open | Semantics | atribuicao a var inexistente compila limpa |
| SC2 | Open | Semantics | Int x = "texto" sem diagnostico |
| SC3 | Open | Semantics | metodo inexistente compila |
| SC4 | Open | Semantics | aridade de construtor errada compila |
| SC5 | Open | Semantics | redeclaracao de local compila |
| N20 | Open | Native | familia getter-trivial/SEM015 espurio (contornado no agente) |
| N21 | Fixed upstream (bdebf75) | Native | aritmetica Int 64-bit vs literal 32-bit: comparacao falsa + println divergente |
| N22 | Open (SUSPECT) | Native+jvm | TU c/ PARTs core+log+sched+event: native SIGSEGV consistente (139) mesmo com main() trivial; gatilho aparente = record+class com campo record (Subscription/CheckRec); JVM standalone passa (ClassFormatError no TU so via build.sh) |
