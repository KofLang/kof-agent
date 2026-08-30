# SWEEP 25d017a (kof 0.2.3-beta)

Gerado: 2026-08-30T01:57:00Z · kof=/home/mel/Documentos/Kof4j/bin/kof

| ID | Arquivo | Resultado | Esperado | Evidência (stdout/stderr) |
|----|---------|-----------|----------|---------------------------|
| N16 | regressions/N16/n16_fwd.kf | exit 0 | fix (N16-OK) | NativeBackend: assembling /tmp/kof-run-14552264934512945922/Default/Main.s N16-OK |
| N17 | regressions/N17/repro.kf | exit 0 | fix (lt0=true) | v=-1000000 lt0=true |
| N13 | regressions/N13/repro.kf | exit 0 | fix (1) | NativeBackend: assembling /tmp/kof-run-8695208138995701244/Default/Main.s 1 |
| N12 | regressions/N12/repro.kf | exit 0 | fix (6) | NativeBackend: assembling /tmp/kof-run-11641548578201924141/Default/Main.s 6 |
| N18 | regressions/N18-SUSPECT/repro.kf | exit 1 | aberto (crash/erro) | :0:0: error: Undefined function: 'openGGUF' [SEM015] 0 passed, 1 failed |
| J4 | regressions/J4/repro_full.kf | exit 0 | fix (exit 0) | NativeBackend: Generated /tmp/kof-run-12001704549610456287/Default/Main.s (1554004 bytes) NativeBackend: assembling /tmp/kof-run-12001704549610456287/Default/Main.s |
| N19 | regressions/N19-SUSPECT/repro_full.kf | exit 1 | aberto (crash/erro) | :0:0: error: Cannot resolve method 'prefill' on type 'InferenceEngine' [SEM025] :0:0: error: Cannot resolve method 'prefill' on type 'InferenceEngine' [SEM025] |
| N11 | regressions/N11/repro.kf | exit 1 | aberto (COMP001 lastIndexOf) | (.text+0x7d4c): undefined reference to `String_lastIndexOf' [COMP001] |
| N3 | regressions/N3/repro.kf | exit 0 | fix (imprime 0) | NativeBackend: assembling /tmp/kof-run-13314195714907010697/Default/Main.s 0 |
| N4 | regressions/N4/repro.kf | exit 1 | fix (a|b|c) | (.text+0x7d62): undefined reference to `size' [COMP001] |
| N6 | regressions/N6/repro.kf | exit 0 | fix (ok) | NativeBackend: assembling /tmp/kof-run-1126550169607684797/Default/Main.s ok |
| N7 | regressions/N7/repro.kf | exit 0 | fix (termina, 3) | NativeBackend: assembling /tmp/kof-run-6725774062498977670/Default/Main.s 9 |
| N9 | regressions/N9/repro.kf | exit 0 | fix (aabbcc) | NativeBackend: assembling /tmp/kof-run-10458415351608641501/Default/Main.s abbcc |
| N8 | regressions/N8/repro.kf | exit 0 | fix (r=true, sem crash) | NativeBackend: assembling /tmp/kof-run-3957685340867697043/Default/Main.s r=true |
| N1 | regressions/N1/repro.kf | exit 0 | fix (42) | NativeBackend: assembling /tmp/kof-run-4002944176583398445/Default/Main.s 42 |
| N10 | build/tests_f3/unit_f3.kf | exit 1 | aberto (N10-progressivo; TU grande) | exit code: 1 0 passed, 1 failed |
