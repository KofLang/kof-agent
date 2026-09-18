# Baseline dataset v4 (E2)

| Metrica | v3 | v4 |
|---|---|---|
| exemplos (train+val) | 456 | 511 |
| mediana output (chars) | 400 | 140 |

Acoes v4: EXECUTE=393 ASK=67 REFUSE=51
Eval rotulada: 620 itens em eval/ptbr-suite-v4.jsonl (acoes: Counter({'EXECUTE': 603, 'REFUSE': 9, 'ASK': 8}))

Regra: saida = resultado + <=2 frases; ambiguo -> ASK de 1 linha; idioma estrangeiro (Java/Kotlin) -> REFUSE tecnico. Seeds de eval sao disjuntas do train (hash bucket). Transformacao deterministica, sem saida inventada: EXECUTE so preserva codigo/documento real do v3.
