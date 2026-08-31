# SWEEP 67e6e8c (kof 0.2.6-beta)

Gerado: 2026-08-31T18:59:11Z · kof=/home/mel/Documentos/Kof4j/bin/kof

| ID | Arquivo | Resultado | Esperado | Evidência (stdout/stderr) |
|----|---------|-----------|----------|---------------------------|
| N16 | regressions/N16/n16_fwd.kf | exit 0 | fix (N16-OK) | NativeBackend: assembling /tmp/kof-run-5727329074537207081/Default/Main.s N16-OK |
| N17 | regressions/N17/repro.kf | exit 0 | fix (lt0=true) | v=-1000000 lt0=true |
| N13 | regressions/N13/repro.kf | exit 0 | fix (1) | NativeBackend: assembling /tmp/kof-run-9587593325662861409/Default/Main.s 1 |
| N12 | regressions/N12/repro.kf | exit 0 | fix (6) | NativeBackend: assembling /tmp/kof-run-10601128565765039176/Default/Main.s 6 |
| N18 | regressions/N18-SUSPECT/repro.kf | exit 1 | aberto (crash/erro) | :0:0: error: Undefined function: 'openGGUF' [SEM015] 0 passed, 1 failed |
| J4 | regressions/J4/repro_full.kf | exit 0 | fix (exit 0) | NativeBackend: Generated /tmp/kof-run-12049448629406139110/Default/Main.s (1579203 bytes) NativeBackend: assembling /tmp/kof-run-12049448629406139110/Default/Main.s |
| N19 | regressions/N19-SUSPECT/repro_full.kf | exit 1 | aberto (crash/erro) | :0:0: error: Cannot resolve method 'prefill' on type 'InferenceEngine' [SEM025] |
| N11 | regressions/N11/repro.kf | exit 0 | fix (1 — String_lastIndexOf runtime asm) | NativeBackend: assembling /tmp/kof-run-11479861923488975854/Default/Main.s 1 |
| N3 | regressions/N3/repro.kf | exit 0 | fix (imprime 0) | NativeBackend: assembling /tmp/kof-run-9718582696710830217/Default/Main.s 0 |
| N4 | regressions/N4/repro.kf | exit 0 | fix (a|b|c; repro evita List.size — família N20) | NativeBackend: assembling /tmp/kof-run-5234570874708291107/Default/Main.s a|b|c |
| N6 | regressions/N6/repro.kf | exit 0 | fix (ok) | NativeBackend: assembling /tmp/kof-run-8021947836366196175/Default/Main.s ok |
| N7 | regressions/N7/repro.kf | exit 0 | fix (termina, 3) | NativeBackend: assembling /tmp/kof-run-295255571399228412/Default/Main.s 9 |
| N9 | regressions/N9/repro.kf | exit 0 | residual (esperado aabbcc; 0.2.3 devolve abbcc) | NativeBackend: assembling /tmp/kof-run-13773137462837487115/Default/Main.s abbcc |
| N8 | regressions/N8/repro.kf | exit 0 | fix (r=true, sem crash) | NativeBackend: assembling /tmp/kof-run-17074353154010250110/Default/Main.s r=true |
| N1 | regressions/N1/repro.kf | exit 0 | fix (42) | NativeBackend: assembling /tmp/kof-run-1936809173844478187/Default/Main.s 42 |
| N10 | build/tests_f3/unit_f3.kf | exit 0 | aberto (N10-progressivo; TU grande) | 0 failed of 9 tests 1 passed, 0 failed |
