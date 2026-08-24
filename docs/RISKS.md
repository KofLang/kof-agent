# RISKS — Riscos e Mitigações

**Status:** vivo — revisado ao final de cada milestone.

| ID | Risco | Impacto | Prob. | Mitigação | Gatilho de replanejamento |
|----|-------|---------|-------|-----------|---------------------------|
| R01 | **Ponto flutuante no Native (FLT001)**: o compilador ainda não emite aritmética SSE real; runtime AI (M10/M11) exige matmul/attention FP rápidos | Alto | Alta | CPU SIMD via camada HAL isolada; medir cedo (spike técnico antes da M10); acompanhar roadmap do compilador; opção JVM temporária com gap documentado | Spike da M6/M10 mostrar throughput < 10% do alvo |
| R02 | Paridade da stdlib Kof incompleta (`Map`/`Set`, `await`) força estruturas alternativas | Médio | Alta | `List<record>` + busca linear encapsulada atrás de funções dedicadas; revisar a cada release do Kof | Custo O(n) dominar benchmarks de indexação |
| R03 | Metas agressivas (init < 100 ms, primeiro token < 200 ms) | Médio | Média | Benchmarks desde a M1; baseline por milestone; mmap/lazy desde o início | Duas milestones consecutivas sem fechar gap |
| R04 | Escopo do "GPU Universal" (6 backends) é enorme | Alto | Média | Ordem estrita: contrato HAL → CPU SIMD → Vulkan → demais backends; backends extras só após E2E do anterior | Vulkan E2E atrasar > 1 milestone |
| R05 | Corpus defasado em relação à linguagem | Alto | Média | checksum + versionamento obrigatórios; regeneração automática ligada às releases do Kof; corpus test valida exemplos compilando | Exemplo do corpus falhar em compile-check |
| R06 | Dependência de um compilador em alpha (gaps mudam por versão) | Médio | Média | Compiler Gateway isola integração (Q1); gates por versão do kof (`kof info`); diagnósticos nunca silenciados | Release do Kof quebrar golden tests do gateway |
| R07 | Segurança: agente aplica patches destrutivos ou vaza segredos em logs | Alto | Baixa | journal completo + rollback point por patch; permissões por tool; redação de segredos nos logs (espírito secrets.redact); sandbox opcional | Qualquer incidente = revisão imediata do executor |
| R08 | Repair loop infinito/custo descontrolado | Médio | Média | limite configurável de iterações; orçamento de tempo por sessão; telemetria local de custo | Taxa de loops sem convergência > 20% |
| R09 | Brain PT-BR ambíguo gerando ações erradas | Alto | Média | intents tipadas com slots obrigatórios; ambiguidade vira pergunta; dataset canônico com acurácia medida e baseline | Acurácia canônica < meta por duas iterações |
| R10 | Complexidade acidental acumulada (o projeto virar framework gigante) | Médio | Baixa | auditoria estilo complexity-audit do Kof por milestone; APIs ≤ 10 funções/namespace; regra "uma feature por PR" | Compilador do agente crescer > 2× sem feature nova correspondente |

## Postura

- Risco identificado entra aqui **antes** de virar problema.
- Mitigações são tarefas reais nas respectivas milestones (não promessas).
- Risco realizado vira item em `DECISIONS.md` + regression test.
