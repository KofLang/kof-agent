# ROADMAP ESTENDIDO — FASE 3 → FASE 6

> Constituição técnica recebida do mantenedor. Fonte de truth para todas as
> milestones futuras. Implementar em ordem, uma por sessão, respeitando N10.

## FASE 3 — AI Runtime Completa (M16–M20)

| M | Escopo | Pré-requisito |
|---|--------|---------------|
| M16 | Tensor Arena · Quantização FP16/INT8/Q4-K/Q5-K/Q6-K/Q8_0 · MatMul/Softmax/GELU/SwiGLU/RMSNorm/LayerNorm/Residual · MHA+GQA+KV Cache+Sliding Window+RoPE V2 · Sampler V3 (temp/top-k/top-p/min-p/rep/freq/presence/deterministic) | N10 fix ou bisect |
| M17 | GGUF Loader binário completo (metadata/tensor directory/lazy/mmap/checksum/v2+v3) | N10 |
| M18 | Local Model Runner (loadModel/generate/streamGenerate/interrupt/cancel + KV persistente + batching + stop tokens + speculative prep) | M16+M17 |
| M19 | Tool Orchestrator V2 (scheduler prioridade/paralelismo/budget · retry backoff · timeout policy · permission/sandbox audit · transaction log · tracing/spans/timeline) | M1 scheduler |
| M20 | Unified Agent Runtime (pipeline único User→Brain→Planner→Retriever→Memory→Orchestrator→Tools→Executor→Repair→Response · ExecutionState serializável) | M7–M9+M13–M15 |

## FASE 4 — Tooling Avançado (M23–M30)

| M | Escopo |
|---|--------|
| M23 | Compiler Observatory CLI (run/bisect/replay/differential · AST/IR/ASM dump · crash minimizer · repro reducer) |
| M24 | LSP completo (autocomplete/semantic tokens/rename/references/code actions/hover/workspace symbols · VSCode/Neovim/Helix/Zed) |
| M25 | koffmt + koflint + kofcheck static analyzer |
| M26 | Incremental Build System (dep graph/cache/parallel/TU splitter anti-N10) |
| M27 | kofpkg package manager (kof.toml/lockfile/registry/offline cache/semver) |
| M28 | Debugger (breakpoints/watch/stack/heap/scheduler/coroutine viewer) |
| M29 | Profiler (CPU/scheduler/arena/heap/tensor/KV/flamegraph/memory timeline) |
| M30 | Release Pipeline (regression/compat/benchmarks/changelog/signed artifacts) |

## FASE 5 — Self Improvement (M31–M32)

| M | Escopo |
|---|--------|
| M31 | Self Improvement Engine offline (journal→dataset→quality filter→preference pairs→LoRA dataset→training candidate→eval harness→promotion manual). Nunca aprender em produção. |
| M32 | Execution Journal flight recorder (prompt/contexto/retrieval/plano/tools/métricas/resposta/duração/erros/replay hash · binário+JSONL) |

## FASE 6 — SLM Próprio (M33–M38)

| M | Escopo |
|---|--------|
| M33 | Dataset Builder V2 (corpus+código+docs+execuções+preference pairs+synthetic · dedup+checksums) |
| M34 | Tokenizer Trainer (BPE/Unigram/SentencePiece · export GGUF tokenizer) |
| M35 | LoRA Trainer (gradient accumulation/checkpoint/resume/mixed precision) |
| M36 | Full SLM Trainer (embeddings/transformer/optimizer/scheduler/checkpoints) |
| M37 | Evaluation Harness (MMLU/HumanEval/GSM8K/MBPP/KofBench) |
| M38 | Kof SLM Runtime (GGUF/LoRA merge/streaming/tool calling/memory integration) |

---

## BUG CATEGORIES EXPANDIDAS

Nxx Native · Jxx JVM · SCxx Semantic · RTLxx Runtime Library · Pxx Performance · Sxx Security · Oxx Optimizer · Mxx Memory

## CRITÉRIO DE DONE

Spec aprovada · implementação · unit+integration+differential tests · benchmarks registrados · regression suite executada · compat Native/JVM registrada · docs sincronizadas · status atualizado.
