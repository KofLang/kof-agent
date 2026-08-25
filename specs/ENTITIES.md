# ENTITIES (M7)
Extração determinística: quoted ("..."), diagCode (lista de códigos do ledger),
path (.kf|contém /). Required-entities por intent: RepairDiagnostic→diagCode;
Edit*/Refactor→path. Ausente + sem histórico = ambiguity estruturada
([{"missing":X,"question":"Qual X?"}]) e confidence rebaixada a 40 — nunca assumir.
