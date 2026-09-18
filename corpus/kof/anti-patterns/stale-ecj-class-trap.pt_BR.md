---
id: kof-anti-patterns-stale-ecj-class-trap-pt
title: Os "297 erros" que não eram regressão — error-stubs ECJ velhos em `target/classes`
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,stale-ecj-class-trap
status: stable
tags: kof,anti-patterns,pt
---
[English](kof/anti-patterns/stale-ecj-class-trap.md) | [Português](kof/anti-patterns/stale-ecj-class-trap.pt_BR.md)

# Os "297 erros" que não eram regressão — error-stubs ECJ velhos em `target/classes`

## Problema

O Maven daqui compila com **ECJ** (o Eclipse compiler), não javac. Quando um
arquivo-fonte tem erro de compilação, o ECJ não para o build como o javac:
ele **emite um `.class` que lança
`java.lang.Error: Unresolved compilation problem`** na linha exata, e o
reactor pode passar reto por isso. Esse classe então **mora em
`<modulo>/target/classes/`** e é empacotada no que os testes carregam — e
como o build é incremental, uma classe velha quebrada pode sobreviver muito
depois de a fonte ter sido consertada, se os timestamps nunca forçaram
recompilar o módulo **dependente**.

A armadilha: você roda a suíte completa num tip que moveu código, e em vez de
umas falhas pontuais você vê **centenas de ERROS** (este repo, 16/09: 297
erros — todo teste que encosta em `--target js` explodia com
`Unresolved compilation problem: KofJsWebview cannot be resolved` em
`KofJsRunner.run`), e o instinto diz "alguém publicou uma regressão".
Ninguém publicou: `kof-runtime/target/classes/.../KofJsRunner.class` era um
error-stub velho de um build interrompido anterior, enquanto as fontes
ATUAIS compilam limpas. Um `grep -rl FAILURE` nos relatórios parece um
incêndio; um `mvn -pl kof-runtime clean` e uma segunda corrida parece que
nada aconteceu. É a **mesma família de armadilha que o repo já conhece como
§165 / §257** (inlining `static final` mostrando valor velho) — esta entrada
é a face "estoura em runtime", que se disfarça de regressão EM MASSA em vez
de valor errado.

## Ruim

```
tip move código (commit de outra pessoa) → mvn test -o (incremental)
→ 297 erros em todo teste que toca JS
→ conclusão: "a fatia A da .18 regridiu o runtime" (ERRADO)
→ "conserto": reverter / culpar / abaixar as asserções para passar  ← proibido (Q5)
```

## Preferível

```
297 erros num tip que você não quebrou
→ (1) LEIA UMA stack trace antes de acreditar na contagem:
      grep -m1 -A8 '<<< ERROR' kof-compiler/target/surefire-reports/<Primeiro>.txt
      "Unresolved compilation problem" = STUB, não falha real
→ (2) reconstrua LIMPO o módulo implicado:
      mvn -o -pl kof-runtime clean compile
      strings kof-runtime/target/classes/<Suspeita>.class | grep -c "Unresolved compilation"  → tem que ser 0
→ (3) rode a suíte de novo. Se foi de 297 → 0 erros, a "regressão" era
      ambiental: registre a mordida da armadilha na mensagem do commit e siga.
→ (4) só se os erros SOBREVIVEREM ao rebuild limpo você tem vermelho real —
      aí vale Q0: raiz, dona, entrada no known-bugs.
```

## Porquê

- A regra "a suíte é o gate" presume que a suíte mede as FONTES. Com ECJ +
  build incremental, ela pode medir uma **mistura** de fontes e fantasmas —
  o número é real mas a causa não está em nenhum commit.
- "Qualquer falha que não seja uma guarda ambiental documentada é SUA"
  (AGENTS.md) continua valendo — mas **diagnosticar** de quem é vem antes de
  **agir** sobre isso. Uma leitura de erros-em-massa tem assinatura: centenas
  de ERROS (não falhas), todos passando pela mesma linha `Error:`, em
  módulo(s) que você não tocou.
- Culpar o código publicado de outra lane sem ler uma stack trace é o jeito
  mais rápido de envenenar a coordenação multi-agente (a .18 estava no meio
  do DB001 quando isso disparou em 16/09 — a conclusão "reverte aquela
  fatia" estava a um grep de distância).
- Relacionado neste repo: §165 (mesma família de armadilha, face de valor),
  §257 (mesma família, face `static final`), `weak-green-proof.md` (o erro
  espelhado: acreditar num verde). Esta entrada: **não acredite num vermelho
  tampouco — verifique se as classes são as que você acha que são.**

## Segunda face (16/09 ~05:00) — o worktree `skip-worktree` que mede uma árvore-fantasma

`git worktree add` **herda as flags `skip-worktree` (e `assume-unchanged`) do
índice sujo do repo pai**. Um arquivo marcado `S` *nunca* é tocado no checkout:
o **disco** do worktree mantém o que a árvore principal tinha (a edição
não-commitada de um agente concorrente), enquanto `git show HEAD:<arquivo>` lê
o blob real do commit. `git diff`/`git status` reportam **limpo** (a flag manda
o git ignorar o arquivo), então o worktree *parece* imaculado mas **não é o
HEAD**. A mesma família "Unresolved compilation" de erros-em-massa, porém
silenciosa: nenhum stub lançado, só conteúdo errado.

Mordida real (16/09, lane docs/development): um worktree "medir o tip" mostrou
`ConformanceMatrixDocTest` VERMELHO (célula `methodoverload` faltando na
matriz) — e a matriz em disco de fato não tinha a anotação commitada (o
arquivo casava com uma edição concorrente, não com `574c9419`). Limpar as
flags, `checkout --force`, até `reset --hard` NÃO restauraram (o split-index
re-marcava `S`). A medição era uma **fantasma**. O tip autoritativo é um
**`git clone` fresco**, onde disco == commit == índice == HEAD.

```
diagnosticar um vermelho que outro checkout já mostrou VERDE (ou que você não
tocou nos arquivos que ele nomeia):
→ git ls-files -v | grep -c '^S'      # >0 = contaminado
→ md5sum <arquivo> ; git show HEAD:<arquivo> | md5sum   # DIVERGE com status limpo = ESTA armadilha
→ medir num CLONE FRESCO (git clone + checkout <tip> + status 0 + sem ^S),
   nunca num worktree de um repo que tem flags skip-worktree no índice.
```
