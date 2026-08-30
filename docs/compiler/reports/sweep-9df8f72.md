# SWEEP 9df8f72 (kof 0.2.3-beta)

Gerado: 2026-08-30T06:38:39Z · kof=/home/mel/Documentos/Kof4j/bin/kof

| ID | Arquivo | Resultado | Esperado | Evidência (stdout/stderr) |
|----|---------|-----------|----------|---------------------------|
| N16 | regressions/N16/n16_fwd.kf | exit 0 | fix (N16-OK) | NativeBackend: assembling /tmp/kof-run-7907335416207662909/Default/Main.s N16-OK |
| N17 | regressions/N17/repro.kf | exit 0 | fix (lt0=true) | v=-1000000 lt0=true |
| N13 | regressions/N13/repro.kf | exit 0 | fix (1) | NativeBackend: assembling /tmp/kof-run-3595453226894051702/Default/Main.s 1 |
| N12 | regressions/N12/repro.kf | exit 0 | fix (6) | NativeBackend: assembling /tmp/kof-run-15941087441721914722/Default/Main.s 6 |
| N18 | regressions/N18-SUSPECT/repro.kf | exit 1 | aberto (crash/erro) | :0:0: error: Undefined function: 'openGGUF' [SEM015] 0 passed, 1 failed |
| J4 | regressions/J4/repro_full.kf | exit 0 | fix (exit 0) | NativeBackend: Generated /tmp/kof-run-18323744785193323949/Default/Main.s (1554617 bytes) NativeBackend: assembling /tmp/kof-run-18323744785193323949/Default/Main.s |
| N19 | regressions/N19-SUSPECT/repro_full.kf | exit 1 | aberto (crash/erro) | :0:0: error: Cannot resolve method 'prefill' on type 'InferenceEngine' [SEM025] :0:0: error: Cannot resolve method 'prefill' on type 'InferenceEngine' [SEM025] |
| N11 | regressions/N11/repro.kf | exit 1 | aberto (COMP001 lastIndexOf) | (.text+0x7d93): undefined reference to `String_lastIndexOf' [COMP001] |
| N3 | regressions/N3/repro.kf | exit 0 | fix (imprime 0) | NativeBackend: assembling /tmp/kof-run-12765171611275660401/Default/Main.s 0 |
| N4 | regressions/N4/repro.kf | exit 0 | fix (a|b|c; repro evita List.size — família N20) | NativeBackend: assembling /tmp/kof-run-18298775259200131368/Default/Main.s a|b|c |
| N6 | regressions/N6/repro.kf | exit 0 | fix (ok) | NativeBackend: assembling /tmp/kof-run-8699566646038265237/Default/Main.s ok |
| N7 | regressions/N7/repro.kf | exit 0 | fix (termina, 3) | NativeBackend: assembling /tmp/kof-run-1757244628360679653/Default/Main.s 9 |
| N9 | regressions/N9/repro.kf | exit 0 | residual (esperado aabbcc; 0.2.3 devolve abbcc) | NativeBackend: assembling /tmp/kof-run-11691512398192913269/Default/Main.s abbcc |
| N8 | regressions/N8/repro.kf | exit 0 | fix (r=true, sem crash) | NativeBackend: assembling /tmp/kof-run-16738211993949773813/Default/Main.s r=true |
| N1 | regressions/N1/repro.kf | exit 0 | fix (42) | NativeBackend: assembling /tmp/kof-run-8445648161135484539/Default/Main.s 42 |
| N10 | build/tests_f3/unit_f3.kf | exit 0 | aberto (N10-progressivo; TU grande) | 0 failed of 9 tests 1 passed, 0 failed |
