# RANKING (M6)
score = overlap(expandido, doc) + 5·(id|title match) + 3·symbolBoost
+ 4·diagnosticBoost + 2·recipeBoost + 2·recentFileBoost.
Empates: ordem de varredura estável (determinístico). Dedup por (source,id).
Orçamento: maxChars; item que estourar interrompe seleção.
