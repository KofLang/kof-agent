# SWEEP b120945c (kof 0.4.0-beta)

Gerado: 2026-09-18T16:41:16Z · kof=/home/mel/Documentos/Kof4j/bin/kof

| ID | Arquivo | Resultado | Esperado | Evidência (stdout/stderr) |
|----|---------|-----------|----------|---------------------------|
| N16 | regressions/N16/n16_fwd.kf | exit 0 | fix (N16-OK) | NativeBackend: assembling /tmp/kof-run-6864266489803151442/Default/Main.s N16-OK |
| N17 | regressions/N17/repro.kf | exit 1 | fix (lt0=true) | repro.kf:1:4: error: 'fn' is a reserved word (Kof has no function keyword); declare as 'Type name(...) { }' or 'name(...): Type { }' [PARSE085] |
| N13 | regressions/N13/repro.kf | exit 0 | fix (1) | NativeBackend: assembling /tmp/kof-run-3185408907050988836/Default/Main.s 1 |
| N12 | regressions/N12/repro.kf | exit 0 | fix (6) | NativeBackend: assembling /tmp/kof-run-8818627246883317404/Default/Main.s 9 |
| N18 | regressions/N18-SUSPECT/repro.kf | exit 1 | aberto (crash/erro) | :0:0: error: Undefined function: 'openGGUF' [SEM015] 0 passed, 1 failed |
| N18u | build/sweep/n18full.kf | exit 1 | fix (openGGUF v=3) | n18full.kf:7371:4: error: 'fn' is a reserved word (Kof has no function keyword); declare as 'Type name(...) { }' or 'name(...): Type { }' [PARSE085] 0 passed, 1 failed |
| N19u | build/sweep/n19u.kf | exit 1 | fix (engine 3/3) | n19u.kf:7371:4: error: 'fn' is a reserved word (Kof has no function keyword); declare as 'Type name(...) { }' or 'name(...): Type { }' [PARSE085] 0 passed, 1 failed |
| J4 | regressions/J4/repro_full.kf | exit 1 | fix (exit 0) | :0:0: error: cannot assign to 'state': record is immutable [SEM038] :0:0: error: Undefined variable or type: 'ToolHandler' in parameter 'h' of method 'register' — declare the type or fix the name (R6: undefined declared types must not compile) [SEM011] |
| N19 | regressions/N19-SUSPECT/repro_full.kf | exit 1 | aberto (crash/erro) | repro_full.kf:2718:4: error: 'fn' is a reserved word (Kof has no function keyword); declare as 'Type name(...) { }' or 'name(...): Type { }' [PARSE085] repro_full.kf:2736:4: error: 'fn' is a reserved word (Kof has no function keyword); declare as 'Type name(...) { }' or 'name(...): Type { }' [PARSE085] |
| N11 | regressions/N11/repro.kf | exit 0 | fix (1 — String_lastIndexOf runtime asm) | NativeBackend: assembling /tmp/kof-run-9031522820039024676/Default/Main.s 1 |
| N3 | regressions/N3/repro.kf | exit 0 | fix (imprime 0) | NativeBackend: assembling /tmp/kof-run-2639085720034348155/Default/Main.s 0 |
| N4 | regressions/N4/repro.kf | exit 0 | fix (a|b|c; repro evita List.size — família N20) | NativeBackend: assembling /tmp/kof-run-5567733050193595414/Default/Main.s a|b|c |
| N6 | regressions/N6/repro.kf | exit 0 | fix (ok) | NativeBackend: assembling /tmp/kof-run-3200662113719404524/Default/Main.s ok |
| N7 | regressions/N7/repro.kf | exit 0 | fix (termina, 3) | NativeBackend: assembling /tmp/kof-run-14950940441325678411/Default/Main.s 9 |
| N9 | regressions/N9/repro.kf | exit 1 | fix (abbcc — a+bb+cc; expectativa antiga aabbcc era erro do repro) | repro.kf:1:4: error: 'fn' is a reserved word (Kof has no function keyword); declare as 'Type name(...) { }' or 'name(...): Type { }' [PARSE085] |
| N8 | regressions/N8/repro.kf | exit 0 | fix (r=true, sem crash) | NativeBackend: assembling /tmp/kof-run-16484274017581658247/Default/Main.s r=true |
| N1 | regressions/N1/repro.kf | exit 1 | fix (42) | repro.kf:5:4: error: 'fn' is a reserved word (Kof has no function keyword); declare as 'Type name(...) { }' or 'name(...): Type { }' [PARSE085] |
| N10 | build/tests_f3/unit_f3.kf | exit 1 | aberto (N10-progressivo; TU grande) | :0:0: error: cannot assign to 'status': record is immutable [SEM038] 0 passed, 1 failed |
