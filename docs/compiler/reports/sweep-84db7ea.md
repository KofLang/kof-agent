# SWEEP 84db7ea (kof 0.2.6-beta)

Gerado: 2026-08-31T19:46:20Z · kof=/home/mel/Documentos/Kof4j/bin/kof

| ID | Arquivo | Resultado | Esperado | Evidência (stdout/stderr) |
|----|---------|-----------|----------|---------------------------|
| N16 | regressions/N16/n16_fwd.kf | exit 0 | fix (N16-OK) | NativeBackend: assembling /tmp/kof-run-11666362413467821120/Default/Main.s N16-OK |
| N17 | regressions/N17/repro.kf | exit 0 | fix (lt0=true) | v=-1000000 lt0=true |
| N13 | regressions/N13/repro.kf | exit 0 | fix (1) | NativeBackend: assembling /tmp/kof-run-6989981174988660616/Default/Main.s 1 |
| N12 | regressions/N12/repro.kf | exit 0 | fix (6) | NativeBackend: assembling /tmp/kof-run-4510348561092852915/Default/Main.s 6 |
| N18 | regressions/N18-SUSPECT/repro.kf | exit 1 | aberto (crash/erro) | :0:0: error: Undefined function: 'openGGUF' [SEM015] 0 passed, 1 failed |
| N18u | build/sweep/n18full.kf | exit 0 | fix (openGGUF v=3) | 0 failed of 1 tests 1 passed, 0 failed |
| N19u | build/sweep/n19u.kf | exit 0 | fix (engine 3/3) | 0 failed of 3 tests 1 passed, 0 failed |
| J4 | regressions/J4/repro_full.kf | exit 0 | fix (exit 0) | NativeBackend: Generated /tmp/kof-run-312920150297002268/Default/Main.s (1579203 bytes) NativeBackend: assembling /tmp/kof-run-312920150297002268/Default/Main.s |
| N19 | regressions/N19-SUSPECT/repro_full.kf | exit 1 | aberto (crash/erro) | :0:0: error: Cannot resolve method 'prefill' on type 'InferenceEngine' [SEM025] |
| N11 | regressions/N11/repro.kf | exit 0 | fix (1 — String_lastIndexOf runtime asm) | NativeBackend: assembling /tmp/kof-run-18094205218894261306/Default/Main.s 1 |
| N3 | regressions/N3/repro.kf | exit 0 | fix (imprime 0) | NativeBackend: assembling /tmp/kof-run-14682836282666917630/Default/Main.s 0 |
| N4 | regressions/N4/repro.kf | exit 0 | fix (a|b|c; repro evita List.size — família N20) | NativeBackend: assembling /tmp/kof-run-2491561865612405283/Default/Main.s a|b|c |
| N6 | regressions/N6/repro.kf | exit 0 | fix (ok) | NativeBackend: assembling /tmp/kof-run-15207127770601056780/Default/Main.s ok |
| N7 | regressions/N7/repro.kf | exit 0 | fix (termina, 3) | NativeBackend: assembling /tmp/kof-run-14793865512619243764/Default/Main.s 9 |
| N9 | regressions/N9/repro.kf | exit 0 | fix (abbcc — a+bb+cc; expectativa antiga aabbcc era erro do repro) | NativeBackend: assembling /tmp/kof-run-4510619282943899847/Default/Main.s abbcc |
| N8 | regressions/N8/repro.kf | exit 0 | fix (r=true, sem crash) | NativeBackend: assembling /tmp/kof-run-9576597357879586013/Default/Main.s r=true |
| N1 | regressions/N1/repro.kf | exit 0 | fix (42) | NativeBackend: assembling /tmp/kof-run-8648326934308550115/Default/Main.s 42 |
| N10 | build/tests_f3/unit_f3.kf | exit 0 | aberto (N10-progressivo; TU grande) | 0 failed of 9 tests 1 passed, 0 failed |
