# CHANGELOG

## 2026-09-18
- Limpeza: `build/` gerado (581 arquivos) fora do índice; lixo solto removido (logs, .class, .deb, tmp*/); REPORT_* → `docs/reports/`; dirs-fantasma de fundação dissolvidos.
- Reorganização: `engine/` (motor de inferência) e `training/kf/` (pipeline) separados de `agent/runtime/` — TU byte-identico, ordem topológica preservada; `build.sh` resolve `--only` nos 3 dirs.
- **Port kof 0.4.0-beta**: `fn`→sintaxe tipada; records mutados→classes (CorpMeta, ExecTaskState); `Map.get` `Int?`→`getOrDefault` no tokenizer KOFLM; clamps Long→`as Int`. `kof check` limpo no TU completo; suíte 11/16 nativas (5 ws vermelhas = N24, registrado com repro).
- Diretriz v2 + plano: `specs/ENGINE_V2.md` (ferramenta não amiga: executa→explica ≤2 linhas→pergunta se duvida; ctx pequeno + swap YAML hot-reload; OpenCL completo no HAL; modelo ≤400M treinável por iteração com dataset mínimo/ASK/RECUSA; meta ≥95% precisão de intenção). Fila nova em `TASKS.md`.
- E1: `engine/160_context.kf` + `workspace/context.yaml` — swap de contexto por hash de conteúdo, prompt determinístico, clamp de explicação; unit_context 7/7 nativo.
- E2: `scripts/build_koflm_v4.py` — dataset v4 EXECUTE/ASK/REFUSE (mediana 400→140 chars, −65%), eval 620 rotulada; baseline `docs/dataset-v4-baseline.md`.
- E3(a): OpenCL — 14 kernels `.cl` + `gpu/tests_ocl.c` (dlopen + referências bit-exatas, skip rc=77 sem ICD) + `detectOpenCL()`; unit_backends 6/6. E3(b): gpu.cl.* no compilador + `mesa-opencl-icd`.
- E4: `models/kof-LM/model-v2.json` (~238M, ctx-1024, greedy/temp-0, gate de métricas) + `KofTrainer.useDataset`.
- E5: `engine/161_contract.kf` — outFmt/outAsk/outRefuse/outFromCtx; unit_contract 5/5. Gate: 13/18 nativo (5 ws presas por N24).
- Auditoria (acusação "corpus vazio" — procedente): corpus tinha 6 docs finos + 15 README-stub; +14 docs factuais novos (20 total). README perdia a verdade em `M0–M31 ✅` — corrigido. `check_compat.sh` em rc=1 por culpa minha (glob que eu alarguei). Sweep b120945c: 5 linhas "fix" sem evidência → relotadas INVALIDO. **Bug real**: `parseLongSafe` descartava não-dígitos e aceitava cache com CRC violado → estrito (com sinal; wsHash é Int). `test_corpus.sh` (que eu nunca rodara): 12/15 antes — 2 falhas pré-existentes escondidas (broken-link dependia de acidente de API; registry com contagem pinada) → 15/15. TASKS: 3 caixas infladas voltam a [ ] honestos.

## 2026-08-31
- M32.3: dispatch Vulkan compute REAL (GPU) nos 2 backends — libvkchain.so (C validado RADV) + asm nativo dlopen/dlsym + JVM FFM 3 downcalls; SYS_exit_group fix (hang pós-main com threads do driver); gpuAvailable() real no HAL; unit_shaders 7/7 com GPU (RX 550); 16/16 suítes.
- gpu-env.sh/kof-gpu wrapper: detecção universal (dGPU/iGPU/llvmpipe/CPU), KOF_DATA em disco separado, KOF_GPU_SPV.
- GPU001 (SYS_exit_group) e COMP002-descobertas: structs Vulkan manual era a causa do "bug RADV" do M32.1 — reaberto e fechado com C tipado (vkmin.c).

## 2026-08-25
- M16.1: TensorArena, softmax estável, RMSNorm, GELU/SiLU, causal mask (7 testes).
- M16.2: RoPE V2, KVCacheV2, Q4 quant, Sampler V3 core (14 testes, bench nativo).
- M19+M20: FASE 3 COMPLETA — orchestrator 8/8, agent runtime 6/6.
- M18.1: ModelRunner 8/8 nativo, bench 9.1k tok/s.
- M17: núcleo GGUF loader tipado + fixture golden + flag --only anti-N10.
- Bugs: N16/N17/J4 documentados c/ repros.
