# CONTRIBUTING — Processo de Engenharia

**Status:** obrigatório desde a Milestone 0

---

## 1. Regra Zero

> NUNCA implemente grandes funcionalidades sem antes documentar e planejar.

Todo trabalho segue, nesta ordem:

1. Especificação (`specs/`).
2. Arquitetura (atualizar `docs/ARCHITECTURE.md` se necessário).
3. Interfaces (contratos tipados antes de código).
4. Testes.
5. Implementação.
6. Benchmark.
7. Report.

Se uma etapa não existir, pare e crie-a.

## 2. Modo de trabalho

- Uma milestone por vez; nunca iniciar a próxima sem fechar a atual.
- Documentação antes da implementação — sempre.
- Dúvida arquitetural? **Pare e registre em `docs/DECISIONS.md`** na seção
  "Questões em aberto" em vez de assumir comportamento.
- O projeto é escrito como infraestrutura oficial do ecossistema Kof para
  os próximos 10 anos.

## 3. Filosofias inegociáveis

Herdadas do Kof e detalhadas em `CODE_STYLE.md`:

1. Intenção acima da implementação.
2. O compilador Kof é a fonte da verdade — o agente nunca inventa regras
   da linguagem.
3. Menos cerimônia: APIs pequenas, sem boilerplate, sem configuração
   desnecessária.
4. Backend agnostic.
5. Ferramentas fazem parte da plataforma (AST, diagnostics, type system,
   IR, workspace são acessados por ferramentas oficiais).
6. Sem magia silenciosa: toda limitação aparece em compile-time ou runtime
   de forma explícita.

## 4. Pull Requests

Estilo Kof:

1. Uma feature por PR.
2. Testes para cada feature.
3. Documentação atualizada no mesmo PR (`docs/`, READMEs das pastas tocadas).
4. **Sem comentários no código.**
5. Código que compila sem warnings — em todos os targets aplicáveis.
6. Dependências só para baixo conforme `MODULES.md`; inversão é rejeitada.

## 5. Precedência em conflito

Quando fontes divergirem sobre comportamento ou estado:

```
implementação → testes → documentação → corpus/datasets
```

Corrija a fonte mais fraca imediatamente; docs nunca devem defasar mais de
uma milestone.

## 6. Atualização de documentação

Ao terminar uma etapa/milestone, atualize obrigatoriamente:

- **`docs/status.md` — sempre, em toda etapa** (fonte única de verdade sobre
  o estado atual: snapshot, entregas, questões abertas, riscos no radar,
  próximos passos e histórico resumido);
- `docs/TASKS.md` (status das tarefas),
- documentos afetados (`SPEC/ARCHITECTURE/MODULES/ROADMAP/RISKS/DECISIONS`),
- READMEs das pastas tocadas,
- `REPORT_MXX.md` da milestone.

Regra prática: se o estado do projeto mudou e `docs/status.md` não mudou
junto, o commit está incompleto.

## 7. Template oficial de report

Ao final de QUALQUER milestone, gerar `REPORT_MXX.md` na raiz com exatamente
esta estrutura:

```markdown
# Milestone XX — Nome

Status:
* ✅ Concluído | 🟡 Parcial | ❌ Bloqueado

## Resumo Executivo
## Arquivos Criados
## Arquivos Modificados
## Arquitetura Implementada
## APIs Criadas
## Ferramentas Criadas
## Testes
## Benchmarks
## Decisões Técnicas
## Pendências
## Riscos
## Próxima Milestone Recomendada
```

## 8. Qualidade

- Toda feature possui: unit test, integration test quando aplicável,
  regression test para bug corrigido, benchmark quando houver custo de
  performance, corpus test quando afeta conhecimento, compiler test quando
  toca o Gateway.
- Benchmarks exportam JSON e são comparados contra baseline
  (`BENCHMARK_PLAN.md`). Regressão > 20% bloqueia o merge.

## 9. Segurança

- Ação destrutiva jamais silenciosa: sempre plano visível, diff visível,
  rollback disponível, sandbox opcional.
- Nunca logar segredos; usar redação nos logs.
