# SWEEP e4aff30 (kof 0.2.3-beta)

Gerado: 2026-08-30T17:36:43Z · kof=/home/mel/Documentos/Kof4j/bin/kof

| ID | Arquivo | Resultado | Esperado | Evidência (stdout/stderr) |
|----|---------|-----------|----------|---------------------------|
| N16 | regressions/N16/n16_fwd.kf | exit 0 | fix (N16-OK) | NativeBackend: assembling /tmp/kof-run-3154582212214156537/Default/Main.s N16-OK |
| N17 | regressions/N17/repro.kf | exit 0 | fix (lt0=true) | v=-1000000 lt0=true |
| N13 | regressions/N13/repro.kf | exit 0 | fix (1) | NativeBackend: assembling /tmp/kof-run-6513605158070629317/Default/Main.s 1 |
| N12 | regressions/N12/repro.kf | exit 0 | fix (6) | NativeBackend: assembling /tmp/kof-run-6834098448571250588/Default/Main.s 6 |
| N18 | regressions/N18-SUSPECT/repro.kf | exit 1 | aberto (crash/erro) | :0:0: error: Undefined function: 'openGGUF' [SEM015] 0 passed, 1 failed |
| J4 | regressions/J4/repro_full.kf | exit 0 | fix (exit 0) | NativeBackend: Generated /tmp/kof-run-18363683220508304733/Default/Main.s (1554669 bytes) NativeBackend: assembling /tmp/kof-run-18363683220508304733/Default/Main.s |
| N19 | regressions/N19-SUSPECT/repro_full.kf | exit 1 | aberto (crash/erro) | :0:0: error: Cannot resolve method 'prefill' on type 'InferenceEngine' [SEM025] :0:0: error: Cannot resolve method 'prefill' on type 'InferenceEngine' [SEM025] |
| N11 | regressions/N11/repro.kf | exit 1 | aberto (COMP001 lastIndexOf) | (.text+0x7d8e): undefined reference to `String_lastIndexOf' [COMP001] |
| N3 | regressions/N3/repro.kf | exit 0 | fix (imprime 0) | NativeBackend: assembling /tmp/kof-run-15966744523831326704/Default/Main.s 0 |
| N4 | regressions/N4/repro.kf | exit 0 | fix (a|b|c; repro evita List.size — família N20) | NativeBackend: assembling /tmp/kof-run-17208563761346668110/Default/Main.s a|b|c |
| N6 | regressions/N6/repro.kf | exit 0 | fix (ok) | NativeBackend: assembling /tmp/kof-run-13170330164920284377/Default/Main.s ok |
| N7 | regressions/N7/repro.kf | exit 0 | fix (termina, 3) | NativeBackend: assembling /tmp/kof-run-10298538972359728116/Default/Main.s 9 |
| N9 | regressions/N9/repro.kf | exit 0 | residual (esperado aabbcc; 0.2.3 devolve abbcc) | NativeBackend: assembling /tmp/kof-run-4701580031322020629/Default/Main.s abbcc |
| N8 | regressions/N8/repro.kf | exit 0 | fix (r=true, sem crash) | NativeBackend: assembling /tmp/kof-run-3269437814825946095/Default/Main.s r=true |
| N1 | regressions/N1/repro.kf | exit 0 | fix (42) | NativeBackend: assembling /tmp/kof-run-4245281625228517686/Default/Main.s 42 |
| N10 | build/tests_f3/unit_f3.kf | exit 0 | aberto (N10-progressivo; TU grande) | 0 failed of 9 tests 1 passed, 0 failed |
