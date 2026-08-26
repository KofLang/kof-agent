# KOF AGENT — Status

**Fonte única de verdade** · Atualizar ao final de toda etapa.

---

## Snapshot

| Item | Estado |
|------|--------|
| Compilador | **HEAD origin/main @ 416ff4b** · sweep: N16✅ N17✅ N13✅ fixed; N11/N12/J4/N10 abertos · kof 0.1.0-alpha-report |
| FASE 1 (M0–M9) | ✅ código completo · verificação parcial (N10-residual) |
| FASE 2 (M10–M12) | 🟡 M10 native **9/9** ✅ (Q8 destravado c/ fix N17) · JVM segue J4-residual |
| FASE 3 (M13–M15) | 🟡 código pronto · N10-progressivo persiste (1.5MB asm → 139) |
| FASE 3 (M16–M20) | 🟡 M19 ✅ Orchestrator 8/8 (20k tools/s) · M20 ✅ Runtime 6/6 · M18.1 ✅ (~9.1k tok/s pipeline) · M17 ✅ 11/11 (workaround N18 aplicado); M16.1+M16.2 ✅ (RoPE/KV/Sampler/bench): M16.1 TensorArena/softmax/RMSNorm/GELU/SiLU/causal (7t) + M16.2 RoPE V2/KVCacheV2/Q4/SamplerV3 (14t) + benchmark nativo (`2164230`) |
| FASE 3 | **COMPLETA** (M16-M20 todos verdes) |
| FASE 4 núcleo | ✅ M21–M26 módulos base 22/22 nativos (LSP/DevTools/Plugin/Journal/Observatory) |
| RC1 | ✅ Hardening 6/6 nativo + stress 100k ops (LruCache/sandbox/detectores) |
| FASE 5 núcleo | ✅ M27–M30 9/9 nativos (service/AI-engine/workspace-memory/model-manager) |
| FASE 6 | ✅ KofLM v1: núcleo 9/9 + dataset v2 453 exemplos (real+sintético, dedup SHA256) + eval 540 + LoRA manager + tokenizer verify (16/16 F6 total) |
| KofLM inferência real | ✅ TinyLlama Q4 local: 37 tok/s decode (CPU) · llama.cpp CPU+Vulkan buildado · RX 6600 aguarda ICD RADV |
| N19-SUSPECT | 🔴 novo: crash combinando 152+144 (~1MB asm); engine aguarda workaround |
| GraphExecutor | ✅ decoder plan N-layers/forward-all/steps (2/2) |
| Backend abstraction | ✅ CPUBackend real + auto-select vulkan→opengl→cpu + koflm.toml parser (3/3) |
| Próxima fase | **FASE 4 — Tooling Avançado**: M21 LSP · M22 DevTools · M23 Plugin SDK/MCP · M24 Self Improvement · M25 Execution Journal · M26 Observatory |
| Bugs p/ upstream | **N18 CONFIRMED** (repro_minimal) + J4-residual + N10/N11/N12/N4/SC3/SC4 | (fechar 9 testes, bench real) (RoPE/KV Cache/Quantização/Sampler V3) · reportar J4+repro upstream |

## Bloqueios ativos

| ID | Impacto |
|----|---------|
| **N10-progressivo** | TU > ~800KB asm → SIGSEGV; bloqueia FASE 3 (unit_f3, 9 testes) e suítes grandes |
| ~~N17~~ | ✅ FIXED (416ff4b) — era cmp signed nativo c/ negativos de Int[]; Q8/M10 destravados. Kernels podem re-adotar negativos |
| **J4-residual** | COMP002 ASM Frame.merge em purgeExpired; fix 416ff4b não cobriu nosso repro — REABRIR upstream |
| ~~N16~~ | ✅ FIXED (416ff4b) — era SEM025 fwd-ref; workaround topológico dos PARTS agora é opcional (manter por higiene) |

Histórico: **N10-progressivo**: translation units > ~800KB asm crasham (segfault/bounds
espúrio). Cada parte nova empurra módulos antes verdes para o limite.
Playbook de bisect em `docs/compiler-bugs.md`.

## Ledger upstream (resumo)

| Corrigidos ✅ | Abertos ❌ |
|---|---|
| J1 J2 N2 N14 SC1 SC2 SC5 **N3 N6 N7 N9 N13** | N1? N4 N8? N10 N11 N12 J4-residual SC3(p) SC4(?) |

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
