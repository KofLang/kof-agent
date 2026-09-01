# CHANGELOG

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
