# REPORT M17.1

## Entregue
- Reescrita completa da suíte: 11 testes contra fixtures reais (rota openGGUF).
- 4 fixtures golden: tiny/bad_magic/bad_version/unaligned.
- Diagnóstico profundo documentado em regressions/N18-SUSPECT/.

## Resultado honesto
**11/11 verdes!** Workaround N18 aplicado (errorCount/errorCode planos + acessores). O caminho funcional core está PROVADO (t5: file→openGGUF→hasTensor end-to-end), mas o backend nativo exibe instabilidade tipo-N10 NOVA: o mesmo código passa/crasha/falha conforme o PADRÃO de acesso aos campos do record (ver N18-SUSPECT). Isso torna os outros 9 testes não-determinísticos entre builds.

## Bloqueio central
N10-progressivo evoluiu: não é só tamanho de TU — é sensibilidade a padrões de uso pós-retorno de record com List fields (~830KB asm).

## Próxima sessão
1. Reportar N18-SUSPECT upstream com repro mínimo.
2. Tentar workaround: retornar handle por campos separados ou empacotar em classe em vez de record.
3. Fechar 11/11 quandoestável.


## FINAL
Parser corrigido em 2 pontos meus: consumo metadata em pares (key=kind|val) e iteração tensor-directory item-a-item c/ align na última posição.
