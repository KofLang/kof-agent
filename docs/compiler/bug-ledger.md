# BUG LEDGER v2

| ID | Categoria | Descricao | HEAD achado | HEAD corrigido | Status | Impacto | Workaround | Owner |
|----|-----------|-----------|-------------|----------------|--------|---------|------------|-------|
| J1 | JVM Runtime | now() quebra gerador JVM | 4954622(prior) | — | Fixed | critico | — | Compiler |
| J2 | JVM Runtime | process.run COMP001 | 4954622(prior) | — | Fixed | critico | ponte bash | Compiler |
| N1 | Codegen Native | fn apos main nao linka | cc46da5 | — | Open | alto | defs-before-main | Compiler |
| N2 | Stdlib | toInt sem simbolo | c822ed3 | c822ed3 | Fixed | alto | parseIntStr | Compiler |
| N3 | Runtime Native | argv segfault | cc46da5 | — | Investigating | alto | .kofargs (ARG001) | Compiler |
| N4 | Native Runtime | split segfault | cc46da5 | — | Open | alto | splitStr | Compiler |
| N6 | Native Runtime | String==null segfault | cc46da5 | — | Open | critico | guards exists/isFile | Compiler |
| N7 | Codegen Native | continue = hang | cc46da5 | — | Open | critico | flags/if aninhado | Compiler |
| N8 | Codegen Native | &&/|| sem curto-circuito | cc46da5 | — | Open | critico | aninhar ifs | Compiler |
| N9 | Codegen Native | += String perde acumulador | cc46da5 | — | Open | critico | x = x + e | Compiler |
| N10 | Codegen Native | miscompile progressivo por tamanho/posicao de TU | 005f47b | — | Open | CRITICA | partes pequenas+um-teste-por-processo | Compiler |
| N11 | Stdlib Native | lastIndexOf ausente | cc46da5 | — | Open | medio | wsLastSpace | Compiler |
| N12 | Codegen Native | record grande corrompe campos | cc46da5 | — | Partial | alto | classes p/ estruturas grandes | Compiler |
| N13 | Codegen Native | Long delta em campo crasha posicional | cc46da5 | — | Investigating | alto | parte propria 03 | Compiler |
| N14 | Native Linking | .Ljf_adv undefined (hello) | 4954622 | 4954622 | Fixed | critica | pin c822ed3 temporario | Compiler |
| SC1 | Semantic | var inexistente compila | db7320b | — | Open | medio | — | Compiler |
| SC2 | Semantic | decl tipo errado compila | db7320b | — | Open | medio | — | Compiler |
| SC3 | Semantic | metodo inexistente compila | db7320b | — | Open | medio | — | Compiler |
| SC4 | Semantic | aridade construtor errada compila | db7320b | — | Open | medio | — | Compiler |
| SC5 | Semantic | redeclaracao local compila | db7320b | — | Open | medio | — | Compiler |
| J3 | Tooling JVM | runner JVM exige JavaFX em alguns artefatos | 634fe5f | — | Investigating | medio | suites nativas | Agent |
