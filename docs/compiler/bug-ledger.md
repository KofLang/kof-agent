# BUG LEDGER v2

| ID | Categoria | Descricao | HEAD achado | HEAD corrigido | Status | Impacto | Workaround | Owner |
|----|-----------|-----------|-------------|----------------|--------|---------|------------|-------|
| J1 | JVM Runtime | now() quebra gerador JVM | 4954622(prior) | — | Fixed | critico | — | Compiler |
| J2 | JVM Runtime | process.run COMP001 | 4954622(prior) | — | Fixed | critico | ponte bash | Compiler |
| N1 | Codegen Native | fn apos main nao linka | cc46da5 | — | Open | alto | defs-before-main | Compiler |
| N2 | Stdlib | toInt sem simbolo | c822ed3 | c822ed3 | Fixed | alto | parseIntStr | Compiler |
| N3 | Runtime Native | argv segfault | cc46da5 | 8df415e+65f748f | Fixed | Investigating | alto | .kofargs (ARG001) | Compiler |
| N4 | Native Runtime | split segfault | cc46da5 | 8df415e+65f748f | Partial (ainda segfault em alguns casos) | Open | alto | splitStr | Compiler |
| N6 | Native Runtime | String==null segfault | cc46da5 | 8df415e+65f748f | Fixed | Open | critico | guards exists/isFile | Compiler |
| N7 | Codegen Native | continue = hang | cc46da5 | 8df415e+65f748f | Fixed | Open | critico | flags/if aninhado | Compiler |
| N8 | Codegen Native | &&/|| sem curto-circuito | cc46da5 | — | Open | critico | aninhar ifs | Compiler |
| N9 | Codegen Native | += String perde acumulador | cc46da5 | 8df415e+65f748f | Fixed | Open | critico | x = x + e | Compiler |
| N10 | Codegen Native | miscompile progressivo por tamanho/posicao de TU | 005f47b | — | Open | CRITICA | partes pequenas+um-teste-por-processo | Compiler |
| N11 | Stdlib Native | lastIndexOf ausente | 64db910(retestado) | — | Open (ainda falha) | medio | wsLastSpace | Compiler |
| N12 | Codegen Native | record grande corrompe campos | cc46da5 | — | Partial | alto | classes p/ estruturas grandes | Compiler |
| N13 | Codegen Native | Long delta em campo crasha posicional | cc46da5 | — | Investigating | alto | parte propria 03 | Compiler |
| N14 | Native Linking | .Ljf_adv undefined (hello) | 4954622 | 4954622 | Fixed | critica | pin c822ed3 temporario | Compiler |
| SC1 | Semantic | var inexistente compila | db7320b | 8df415e (SEM020) | Fixed | medio | — | Compiler |
| SC2 | Semantic | decl tipo errado compila | db7320b | 8df415e (SEM021) | Fixed | medio | — | Compiler |
| SC3 | Semantic | metodo inexistente compila | db7320b | — | Partial (agora falha no link) | medio | — | Compiler |
| SC4 | Semantic | aridade construtor errada compila | db7320b | — | Open | medio | — | Compiler |
| SC5 | Semantic | redeclaracao local compila | db7320b | 8df415e (SEM024) | Fixed | medio | — | Compiler |
| J3 | Tooling JVM | runner JVM exige JavaFX em alguns artefatos | 634fe5f | — | Investigating | medio | suites nativas | Agent |

## Auditoria v0.1.0-beta (8df415e) — evidências

Repros dirigidos executados: N1✅ N6✅ N7✅ N8✅ N9✅ N12✅ corrigidos · N3❌N4❌ persistem · N11❌ · Security native E2E ✅ (pbkdf2/sha256/jwt).

## Auditoria v0.1.0-beta (8df415e)

Repros: N1✅ N6✅ N7✅ N8✅ N9✅ N12✅ · N3❌ N4❌ N11❌ persistem · Security native E2E ✅

## Upstream 7afdbb5

SECN002 (AES-GCM nativo) fechado — G10 completo. Não rastreado pelo agente (fora do nosso ledger), registrado como ganho do ecossistema.

## Atualização pós 65f748f (reteste dirigido)

| Bug | Status |
|-----|--------|
| N3 args | ✅ FIXED — argc=0 sem segfault |
| N9 += String | ✅ FIXED — concat acumula corretamente |
| N7 continue | ✅ FIXED — loop termina normalmente |
| N6 null-compare | ✅ FIXED — retorna false |
| N1 fwd-fn | ✅ FIXED — v=5 |
| N4 split | ❌ ainda segfault em alguns padrões |
