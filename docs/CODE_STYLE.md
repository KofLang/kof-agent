# CODE_STYLE — Estilo Kof Obrigatório

**Status:** obrigatório desde a primeira linha de Kof (M1)

Este documento aplica as convenções idiomáticas da linguagem Kof ao código
do agente. Fonte de verdade: `training/` do repositório Kof
(idioms + anti-patterns + fake-idioms). Em conflito, vence a implementação
do compilador.

---

## 1. Princípios

1. **Intenção acima da implementação** — o código diz *o quê*; a plataforma decide *o como*.
2. **Represente o domínio, não a implementação acidental.**
3. **Dados → record · comportamento → classe · lógica → função top-level.**
4. **Sem comentários no código.** Nomes e tipos explicam.
5. Menos cerimônia: se o compilador deduz, não escreva.

## 2. Funções

Sem a palavra `fun`. Formas válidas:

```kof
main() { ... }
String saudacao() { ... }
despedida(): String { ... }
void fazIsso() { ... }
Bool positivo(Int x) = x > 0
```

- Lógica sem estado → função top-level. Utility class é anti-pattern.
- `main()` é a única função sem tipo explícito.
- Default parameters permitidos; `return` nu válido em void.

## 3. Dados

```kof
record User(String name, Int age)
```

- Dado imutável → **record**, sempre. Nunca classe com getters.
- Classe com construtor primário quando há comportamento:

```kof
class Session(String id) {
    touch(): Session { ... }
}
```

- Construção **sem `new`**: `Session("s1")` é a forma idiomática
  (`new` apenas em código legado).

## 4. Campos

- Campo direto, sem getter/setter:

```kof
class Cart {
    List<Patch> patches
}
```

- Estado mutável global da sessão → campos estáticos de classe
  (`class App { static Int count = 0 }`) — padrão oficial para estado entre
  chamadas/lambdas.

## 5. Strings

- `==` compara conteúdo. `.equals()` não existe — nunca escreva.
- Concatenação com `+`/`+=`. StringBuilder não existe — não invente.
- Conversões: `"42".toInt()` etc.

## 6. Erros

- Exceções são Strings: `throw "not found: " + key`, `catch (String e)`.
- **Sentinela (`""`/`-1`/null mágico) é proibida como idiom.** Quando
  ausência for valor legítimo do domínio, marque `WORKAROUND` no commit/docs
  até existir `Option<T>`.
- `finally` para cleanup; erros de runtime (bounds/null) são fatais — trate
  antes quando possível.

## 7. Controle de fluxo

- Valor condicional → if-expression:

```kof
var status = if (ativo) "online" else "offline"
```

- Coleção → `for (var item in items)`. `for` com índice só quando o índice importa.
- `switch case N:` com `break`; dois casos → if/else.

## 8. Coleções e tipos

- Sequência → `List<T>` / `listOf(...)` / `listOf<T>()`.
- **`Map`/`Set` não existem ainda** — associação usa `List<record>` com busca
  linear ou função dedicada. Não fingir que existe.
- Arrays fixos → `new Int[n]`; literal `[1,2,3]` não existe.
- Lambdas `(x: Int) -> expr`; capturas são **fotos somente-leitura** — estado
  mutável entre chamadas vai em campo estático.

## 9. Nomeação

| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| Classe/Record | PascalCase | `PlanBuilder` |
| Método/função/campo/local | camelCase | `applyPatch` |
| Constante | SCREAMING_SNAKE | `MAX_REPAIR_ROUNDS` |
| Package | lowercase | `dev.kof.agent.executor` |

Booleanos: `isX`/`hasX`/`canX`. Funções: verbo + substantivo.

## 10. Concorrência

- `spawn tarefa()` / `spawn { }` quando disponível no target — nunca expor
  Thread/Executor na API do agente.
- Native sem `spawn` (CONC001): módulos concorrentes mantêm design que
  degrada com diagnóstico explícito, nunca stub silencioso.

## 11. Performance

- Zero cópias desnecessárias; mmap/lazy loading nos caminhos quentes.
- Sem otimização prematura: versão idiomática → medir → otimizar o ponto medido.
- Toda abstração responde: qual seu custo em runtime?

## 12. Proibições explícitas (fake idioms)

`map/filter/higher-order` · `Option<T>` · pattern matching · array literal ·
`Map`/`Set` · `async/await` · `Thread` na API pública · annotations para
recursos da própria plataforma · getters/setters · `.equals()` ·
StringBuilder · utility classes · camadas Controller/Service/Repository sem
problema real.

## 13. Compatibilidade do backend nativo 0.0.14 (obrigatória)

Impostas por `scripts/check_compat.sh`; justificativas em
`docs/compiler-bugs.md`:

1. Acúmulo de String SEMPRE explícito: `out = out + e`. Nunca `+=`.
2. Nunca comparar String com `null`.
3. Nunca usar `continue`.
4. Não depender de curto-circuito de `&&`/`||` — aninhar ifs.
5. Um artefato = um translation-unit gerado por `scripts/build.sh`.
6. Toda definição antes do `main` do artefato.
7. Sem campos estáticos mutáveis — estado em `RuntimeContext` injetado.
