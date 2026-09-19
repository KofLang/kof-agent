# N24 — Emit JVM quebrado em TU grande (regressao do port 0.4.0-beta)

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

**Dado novo (2026-09-19, jar 0.4.6-beta local):** as 5 suites `unit_ws_*(jvm)` vermelhas de novo,
desta vez com outra fase do backend: `RuntimeException: frame crash in Default/Main.kofGgufDecodeRowsNTo`
`phase: JVM backend / ASM COMPUTE_FRAMES (visitMaxs) — ArrayIndexOutOfBoundsException: Index 0 out of
bounds for length 0` (IR: dois labels consecutivos + RETURN no fim de void com `return` cedo).
Mesma familia posicional/por-tamanho (N10): o MESMO arquivo `koflama_gguf.kf` compila e roda ok no
JVM quando isolado num TU pequeno (`build/rss/tu17`). Native 100% ok.
