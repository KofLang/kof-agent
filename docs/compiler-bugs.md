# COMPILER BUGS — Ledger de bugs do Kof 0.0.14 descobertos pelo kof-agent

> Registro técnico para reporte upstream ao compilador Kof. Cada item foi
> reproduzido durante a M1 e contornado no código do agente. Este arquivo é
> a justificativa viva das regras em `CODE_STYLE.md` §12 e do gate
> `scripts/check_compat.sh`.

Ambiente: kof 0.0.14-alpha, JDK 25 (build), binutils 2.46, Linux x86_64.

| ID | Alvo | Sintoma | Repro mínimo | Workaround no agente |
|----|------|---------|--------------|----------------------|
| J1 | JVM | `COMP001`: KofRuntime gerado não compila (`unclosed string literal` em `headers.split("`) quando o programa usa `now()` ou `secrets.*` — seções time/web/security do runtime-template com escape duplo quebrado | `main(){ println(now()) }` → `kof run --target jvm` | Benchmarks/CLI são nativos; unidades de teste não chamam `now()`; env via `secrets` proibida |
| N1 | Native | Função top-level definida **depois** de `main` e referenciada por ele → `undefined reference` no `ld`, mesmo sem try/catch | `main(){ f() }  f(): Int { return 1 }` | Regra "defs antes do main"; concatenador garante partes→entrada |
| N2 | Native | `"42".toInt()` → `undefined reference to String_kof_string_to_int` (símbolo ausente do runtime asm) | `println("42".toInt())` nativo | `parseIntStr()` própria em `00_core.kf` |
| N3 | Native | `main(String[] args)` → **segfault** ao acessar `args.length` (mesmo com 0 args) | `main(String[] a){ println(a.length) }` | Entrada `main()` sem parâmetros + convenção `.kofargs` escrita pelo wrapper (ARG001) |
| N4 | Native | `String.split(sep)` → **segfault** | `"a=b".split("=")` | `splitStr()` própria em `00_core.kf` |
| N6 | Native | Comparar String com `null` (`t == null` / `!= null`) após `readText()` bem-sucedido → **segfault** (`kof_string_equals` contra ponteiro nulo) | `var t = f.readText(); if (t == null) {...}` | Guardas apenas com `exists()/isFile()`; proibido comparar String a null |
| N7 | Native | `continue` dentro de `for-in`/`while` → **loop infinito** | loop com `if (x.length == 0) { continue }` | Proibido `continue`; reestruturar com flags/if aninhados |
| N8 | Native | `||` e `&&` **sem curto-circuito**: lado direito avaliado mesmo quando o esquerdo decide | `s.length == 0 || s.substring(0,1) == "#"` com `s=""` → bounds error | Aninhar ifs sempre que o RHS puder falhar |
| N9 | Native | Acúmulo com `+=` sobre String perde o acumulador (resultado = última atribuição) dentro de funções | `out += s.substring(i, i+1)` em while → retorna último char | Sempre `out = out + expr`; gate do check_compat |
| J2 | JVM | `process.run(...)` → mesmo COMP001 do J1 (seção web do runtime-template corrompida é puxada por process) | `main(){ process.run("echo","hi") }` jvm | Gateway in-language bloqueado; ponte tooling (scripts/golden_compiler.sh) |
| SC1 | ambos | Cobertura semântica: atribuição a variável inexistente compila limpa | `main(){ y = 5 }` | registrado GW-SEM-COVERAGE (upstream feature gap) |
| SC2 | ambos | `Int x = "texto"` sem diagnóstico | declaração tipada com tipo errado | idem |
| SC3 | ambos | chamada a método inexistente compila | `s.naoExiste()` | idem |
| SC4 | ambos | construtor com aridade errada compila | `P()` para `record P(Int a)` | idem |
| SC5 | ambos | redeclaração de variável local compila | `var x=1; var x=2` | idem |
| N13 | Native | Atribuição `campoLong = a.nowMs() - t0` (subtração de calls Long → campo) dentro de função grande crasha; mesma expressão em contexto pequeno passa | toolExec durationMs | dur computada em variável local/parte própria; ainda posição-sensível |
| N10 | Native | Miscompile **dependente de posição/tamanho**: mesma construção funciona num programa pequeno e gera `array index out of bounds` espúrio (condição Int correta) em programa grande | `parseInto` com `indexOf`+`substring` crashava só no artefato completo; isolado passava | Reescrever com `splitStr`; manter funções críticas pequenas; se sintoma reaparecer, bisect por truncamento do translation-unit |

## Atualização 24/08 — reteste contra fix/compiler-bugs-0.0.14 (c822ed3..ef91b7e)

| ID | Status pós-fix |
|----|----------------|
| J1 | ✅ **CORRIGIDO** (`now()` compila e roda no JVM) |
| J2 | ✅ **CORRIGIDO** (`process.run` compila e executa no JVM) |
| N1–N13 | presentes em c822ed3 (re-sweep idêntico ao anterior) |
| **N14 (NOVO)** | **REGRESSÃO no HEAD ef91b7e**: todo build native falha no link — `undefined reference to .Ljf_adv` dentro de `kof_json_find_value` (emitJsonFindValue emite label local não gerado). Repro: qualquer `main(){println("hello")}` → `kof run --target native`. **Hello world nativo quebrado globalmente no HEAD.** |

**Decisão D0020:** baseline do kof-agent pinado em **c822ed3** (branch
`kofagent-baseline` no clone do compilador) — inclui multi-arquivo parcial
(e462fcb) e os fixes JVM, sem a regressão N14. Retestar N1–N13/N10-family
quando N14 fechar.

## Notas

- N1/N4/N6/N7/N8/N9 foram descobertos por falhas **reais em execução**
  (segfault/hang/bounds), nunca por divergência silenciosa de resultado —
  exceto N9, que produzia resultado errado sem erro.
- Todos os workarounds estão concentrados em `agent/runtime/00_core.kf`
  (`splitStr`, `parseIntStr`, `escapeJson`) ou banidos por estilo.
- Ao atualizar o compilador, rodar `scripts/test.sh` + `scripts/check_compat.sh`
  e tentar REMOVER workarounds: cada bug fechado upstream deve resultar em PR
  simplificando o código afetado.
