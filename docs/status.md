# KOF AGENT — Status

**Fonte única de verdade** · Atualizar ao final de toda etapa.

---

## Snapshot

| Item | Estado |
|------|--------|
| Compilador | **HEAD 1f0f9c6 (kof 0.2.6-beta — N23 ctor >=6 args 2b09aa1; N12 ordem stack args 1f0f9c6; N11 String_lastIndexOf; + tudo do e4aff30)** · sweeps: 25d017a/9462a48/8dc4644/bdebf75/9df8f72/e4aff30/2b09aa1/67e6e8c em docs/compiler/reports/ · N16/N17/N13/N12/N3/N6/N7/N8/N1/J4/N22/N11/N23 ✅ fixed · N9 ✅ fixed (abbcc = a+bb+cc correto) · N18/N19/N10 fechados vs 0.2.6-beta (repros unit) |
| FASE 1 (M0–M9) | ✅ código completo · verificação parcial (N10-residual) |
| FASE 2 (M10–M12) | 🟡 M10 native **9/9** ✅ (Q8 destravado c/ fix N17) · JVM segue J4-residual |
| FASE 3 (M13–M15) | 🟡 código pronto · N10-progressivo persiste (1.5MB asm → 139) |
| FASE 3 (M16–M20) | 🟡 M19 ✅ Orchestrator 8/8 (20k tools/s) · M20 ✅ Runtime 6/6 · M18.1 ✅ (~9.1k tok/s pipeline) · M17 ✅ 11/11 (workaround N18 aplicado); M16.1+M16.2 ✅ (RoPE/KV/Sampler/bench): M16.1 TensorArena/softmax/RMSNorm/GELU/SiLU/causal (7t) + M16.2 RoPE V2/KVCacheV2/Q4/SamplerV3 (14t) + benchmark nativo (`2164230`) |
| FASE 3 | **COMPLETA** (M16-M20 todos verdes) |
| FASE 4 núcleo | ✅ M21–M26 módulos base 22/22 nativos (LSP/DevTools/Plugin/Journal/Observatory) |
| RC1 | ✅ Hardening 6/6 nativo + stress 100k ops (LruCache/sandbox/detectores) |
| FASE 5 núcleo | ✅ M27–M30 9/9 nativos (service/AI-engine/workspace-memory/model-manager) |
| FASE 6 | ✅ KofLM v1: núcleo 9/9 + dataset v2 453 exemplos (real+sintético, dedup SHA256) + eval 540 + LoRA manager + tokenizer verify (16/16 F6 total) |
| KofLM inferência real | ✅ **KofLM** Q4 local: 37 tok/s decode (CPU) · llama.cpp CPU+Vulkan buildado · RX 6600 aguarda ICD RADV |
| ~~N19-SUSPECT~~ | ✅ fechado vs 0.2.6-beta (rt inicializado em 152; unit_engine 3/3 jvm+native; N19u no sweep) |
| GraphExecutor | ✅ decoder plan N-layers/forward-all/steps (2/2) |
| M31 kernels | ✅ Attention+SwiGLU+LMHead+QuantDecoder Q4_0/Q8_0/F16/**Q4_K_M/Q6_K** (unit_kq 5/5) · (12/12) · TokenizerEngine (3/3, N20 contornado) · GraphExecutor execução real (attention+residual+SwiGLU+rmsnorm, tensorAdd) · **GL/VK compute shaders ✅ 7 módulos SPIR-V** (matmul/softmax_causal/rmsnorm/rope/embedding/swiglu/attention_scores em gpu/shaders/, compilados glslangValidator, validados via 159_shader_hal.kf 6/6 jvm+native + gpu/harness.py) |
| M32 FFI Vulkan | ✅ M32.1: JvmVkRuntime (FFM, JDK 21+) no compilador `b657dd8` — cadeia instance→device→pipeline validada end-to-end (RADV RX550 + llvmpipe, rc=0), structs Vulkan conferidos via C puro dlsym (stage inline no ComputePipelineCreateInfo = causa do segfault inicial); dispatch degradado p/ CPU por bug do ambiente Mesa 25.2.8 (RADV crasha no vkCmdDispatch / lvp ignora escrita — reproduzido em C puro, não é o FFI). **M32.2 ✅ namespace `gpu.*` no compilador `1436a1f`** (KofGpu: available/failReason/dispatchMatmul, GPU001 no JS, stubs asm no native) + fix COMP001 fechamento da classe KofRuntime; gpuMatmul no shader HAL com fallback golden CPU — unit_shaders 7/7 jvm+native, 16/16 suítes. **M32.3 ✅ dispatch REAL fechado (Kof4j `d895ae7`)** — RADV 25.2.8 NUNCA esteve quebrado: o crash era o `stage` embutido compacto (48B) no ComputePipelineCreateInfo (layout corrompido → deref no dispatch), reproduzido e provado com C tipado (vkmin.c, `out: 0 2 4 6 8 10 12 14` ✓). Solução: **libvkchain.so** (kof-compiler/vulkan/vkchain.c, cadeia completa C validada) + asm nativo (dlopen/dlsym 3 símbolos, lazy init, data inline KofArray lea+24, stack 16B-aligned) + JVM FFM (3 downcalls simples, sem structs). **SYS_exit_group (231)** no _start (SYS_exit 60 deixava processo pendurado com threads do driver). gpuAvailable() do HAL agora chama gpu.available() real (era hardcoded false). unit_shaders 7/7 jvm+native com GPU real (RX 550/POLARIS12, rc=0 c0=4000 c3=6000); dmin rc=0; 16/16 suítes; wrapper `scripts/kof-gpu` + `gpu-env.sh` (KOF_GPU_SPV, ICD vendor correto, KOF_DATA em disco separado). M32 COMPLETO |
| M33 GGUF binário puro Kof | ✅ `koflama_gguf.kf` (ex-161_gguf_binary): parser GGUF v2/v3 binário (magic/kv/tensor dir) + dequant Q4_K/Q6_K/F16 (fórmulas ggml exatas, get_scale_min_k4) 100% Kof — smoke no TinyLlama-Q4_K_M real: llama layers=22 heads=32 kvheads=4 embd=2048 vocab=32000 tensors=201 ✓; fixes: dataOff na base dos tensors, janela dinâmica p/ vocab (466KB strings), bounds guards, char-cast `as Char` (Kof4j `4091854`: String.valueOf estático + I2C) |
| M34 FASE B — forward LLM koflama | ✅ **TOKEN EXATO vs ground-truth float** (`koflama_forward.kf`): 22 layers TinyLlama-Q4_K_M 100% Kof — tok `<s>`→29958 igual ao gt python float32 (lg[max] 8157356 vs 8157061 = 0.004%; lg[0..3] ~0.05%), 22-layer x pós 0.02-0.1%. Fixes decisivos: residual FFN somava `act` em vez de `d`; matvec chunked (chunks 32 + resíduo, sem overflow Long nem truncar x); KV cache por layer (flat por (layer,pos) — antes attn da layer L lia K/V da layer 0); score = acc/(sqrt(hd)·1000) (estava /1e6, 1000× menor); exp estável (e^t positivo + inversão — série alternada cancelava p/ |t|>3); RoPE: log2(10000)=13288 (era 33219), rad→decimiligraus ×572958/1e7, micro rad ×174533/1e4, pow2frac ×6931/10; isqrt com round. Multi-token: [1,259]→13 exato vs llama-cli; [1,1576] diverge (rank 21, erro acumulado de trunc ~0.5% — a investigar). 16/16 suítes verdes |
| Backend abstraction | ✅ CPUBackend real + auto-select vulkan→opengl→cpu + koflm.toml parser (3/3) |
| Rebranding | ✅ models/KofLM/{metadata.json,config.toml} — origem checkpoint só em metadata |
| Distribuição modelo | ✅ HF Hub primário + GH Releases mirror (scripts/model_{publish,download}.sh) |
| Treino QLoRA | ✅ pipeline pronta (training/scripts/train_koflm.py, resume-safe) — aguarda execução longa |

**Próxima fila:**
1. ~~N22-SUSPECT~~ ✅ **FECHADO** (9df8f72: GC mark transitivo + sweep no-op + cdq; regressions/N22-SUSPECT/README.md)
2. ~~Reportar N21/N22/N18/N19 upstream~~ ✅ re-test vs 0.2.6-beta: todos passam (repros em regressions/; N23 fixado 2b09aa1)
3. PLANO 002 DESBLOQUEADO: KOF_DATA=/home/mel/Downloads/kof-data (430G livres) — stack ML + TinyLlama + checkpoints cabem; treino via CPU (RX 550 4GB é insuficiente p/ QLoRA CUDA; usar llama.cpp/train CPU)
4. ~~M31 continuação: kernels completos no GraphExecutor + QuantDecoder F16/K~~ ✅ M31.8 K-quants (q4k/q6kDecodeBlock + kqDecodeTensor, unit_kq 5/5 jvm+native)
5. ~~Instalar mesa-vulkan-drivers~~ ✅ M32.3 dispatch real RADV RX 550 (dispatchMatmul GPU verde jvm+native; benchmark de escala é fila do M32.4)
6. Test suites do agente: **16/16 verdes** (scripts/test.sh, jvm+native) — manter hermeticidade nos testes novos
7. ~~M34 FASE B — transformer forward 100% Kof (koflama)~~ ✅ **FASE B FECHADA** (token exato 29958 vs gt float, ver linha M34). Próximo: fechamento do multi-token (precisão ~0.5% acumulada troca argmax em gaps pequenos), tokenizer/detokenizer SentencePiece do GGUF, integração ao GraphExecutor/GPU
| Bugs p/ upstream | ~~N18 CONFIRMED + N10/N11/N12/N4~~ ✅ fechados vs 0.2.6-beta · J4-residual monitorado (repro exit 0) · SC3/SC4 sem repro | (fechar 9 testes, bench real) (RoPE/KV Cache/Quantização/Sampler V3) |

## Bloqueios ativos

| ID | Impacto |
|----|---------|
| ~~N22-SUSPECT~~ | ✅ fechado vs 0.2.6-beta: stress events 10k (received=10000) e tasks 100k (launched=100001) verdes com asm de 1.85MB (N10 limiar superado) |
| **J4-residual** | COMP002 ASM Frame.merge — repro_full exit 0 no sweep bdebf75, mas fix upstream 416ff4b não cobriu o caso original; manter monitoramento |
| ~~N10-progressivo~~ | limiar empurrado pelo 0.2.3: f3 9/9 (1.5MB) passa; **N22 aparenta ser o mesmo fenômeno com gatilho por conteúdo, não tamanho** |
| ~~N21~~ | ✅ FIXED upstream (bdebf75) — aritmética Int trunca 32 bits; wsHash/roundtrip windex validados |
| ~~N16/N17~~ | ✅ FIXED |

Histórico: **N10-progressivo**: translation units > ~800KB asm crasham (segfault/bounds
espúrio). Cada parte nova empurra módulos antes verdes para o limite.
Playbook de bisect em `docs/compiler-bugs.md`.

## Ledger upstream (resumo)

| Corrigidos ✅ | Abertos ❌ |
|---|---|
| J1 J2 N2 N14 SC1 SC2 SC5 N3 N4 N6 N7 N8 N9 N10 N11 N12 N13 **N18 N19 N21 N22 N23** (verificados vs 0.2.6-beta; N23 fix 2b09aa1) | N1?(reabrir se reprodutir) SC3(p) SC4(?) |

*Re-testar N1/N6/N7/N8/N9/N12 contra HEAD mais recente — podem ter sido
colaterais do N14 e voltaram.*

## FASE 3 escrito e commitado (aguardando anti-N10)

| Parte | Conteúdo | Testes autorados |
|-------|----------|-----------------|
| 87_memory.kf | MemoryLayer (episodic/semantic/session, TTL, snapshot MEMSNP v1) | 5 |
| 88_conversation.kf | ConversationEngine (turns tipados, janela deslizante, summarize, cite) | 4 |
| 89_orchestrator.kf | orchFuse (corpus+memory, dedup, budget) | — |
| specs/M18–M20 | Reasoning Engine · Multi-Agent · SLM Runtime | — |

## Fila para próxima sessão

1. **Colher FASE 3**: bisect N10 nas partes 87/88/89 → rodar os 9 testes f3.
2. **M16 Runtime AI v2**: RoPE V2, RMSNorm real, SwiGLU, MultiHead Attention,
   Sampler v3 (temp/top-k/top-p/rep-penalty), quantização Q4_0/Q5_K/Q6_K/Q8_0.
   Arena allocator para tensores.
3. **M17 GGUF Loader**: parser binário completo (metadata/tensors/tokenizer/
   rope/quant/special-tokens), lazy loading, mmap, GGUF v2/v3.
4. **M18 Local Model Runner**: loadModel/unloadModel/generate/streamGenerate +
   métricas (tokens/s, RAM, cache hit).
5. **M19 Tool Orchestrator v2**: scheduler, timeouts, retry, parallel calls,
   cost budget, tracing, permission audit.
6. **M20 Agent Runtime**: unificar Brain→Planner→Retriever→Memory→Tools→
   Executor→RepairLoop com estado completo de execução.
7. Reporte upstream formal (15 repros prontos).

## Histórico

| Data | Evento |
|------|--------|
| 08-24 | M0 fundação · repo publicado |
| 08-24 | M1 core runtime nativo (10/10 suítes) |
| 08-24 | M2 gateway 🟡 (ponte ativa; in-language aguarda upstream) |
| 08-24 | M3 workspace intelligence 🟡 |
| 08-24 | M4 tool API 🟡 |
| 08-24 | M5 corpus engine 🟡 |
| 08-24 | M6 retrieval engine 🟡 |
| 08-24 | M7 brain PT-BR 🟡 |
| 08-24 | M8 planner 🟡 |
| 08-24 | M9 executor+repair 🟡 |
| 08-24 | M10 runtime AI core 10/10 |
| 08-24 | M11 HAL CPU 5/5 |
| 08-24 | M12 dataset builder pipeline |
| 08-25 | FASE 3 M13/M14/M15 escritos (PENDENTE-N10) |
