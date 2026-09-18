# N24 — VerifyError no emit JVM de `gpu.dispatchMatmul` em TU grande (regressao do port 0.4.0-beta)

**Sintoma:** classes que chamam `gpu.dispatchMatmul(...)` num TU grande falham no load com
`VerifyError: Bad type on operand stack — Type integer not assignable to java/lang/Object`
(checkcast sobre o resultado int do invokestatic `kof_vk_dispatch`).

**Evidence:** `kof test build/tests/unit_ws_scan.kf --target jvm` (suite 5 ws vermelhas;
mensagem JavaFX do launcher engole o VerifyError — ver truco do Run.java no AGENTS do Kof4j).

**Repro minimo NAO falha** — o trigger e posicional/tamanho (familia N10): o mesmo
`return gpu.dispatchMatmul(...)` em TU pequeno roda ok. Wrapper com parametros tipados
concretos NAO corrige (testado).

**Gatilho:** TU contendo `engine/159_shader_hal.kf` (gpuMatmul) concatenado na ordem atual.
**Workaround:** rodar as suites ws em `--target native` (8/9; 1 assert de hash é native-only
provavel, nao-N24) ate fix upstream. JVM: remover o call ou isolar em TU pequeno.
**Dono:** lane compilador Kof4j (reportar com esta evidencia).
