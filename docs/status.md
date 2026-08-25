# KOF AGENT — Status

**Fonte única de verdade** · Atualizar ao final de toda etapa.

---

## Snapshot

| Item | Estado |
|------|--------|
| Compilador | **HEAD origin/main @ a7949a5** · kof 0.1.0-alpha-report |
| FASE 1 (M0–M9) | ✅ código completo · verificação parcial (N10-residual) |
| FASE 2 (M10–M12) | 🟡 M10 native **8/9** (restante=N17) · JVM bloqueado por J4 |
| FASE 3 (M13–M15) | 🟡 código pronto · N10-progressivo persiste (1.5MB asm → 139) |
| FASE 3 (M16–M20) | 🟡 M16.1+M16.2 entregues (RoPE/KV/Sampler/bench): TensorArena/softmax/RMSNorm/GELU/SiLU/causal + 7 testes nativos verdes (`8fd73e9`) |
| Próxima sessão | **M16.2** (RoPE/KV Cache/Quantização/Sampler V3) · reportar J4+repro upstream |

## Bloqueios ativos

| ID | Impacto |
|----|---------|
| **N10-progressivo** | TU > ~800KB asm → SIGSEGV; bloqueia FASE 3 (unit_f3, 9 testes) e suítes grandes |
| **N17** | cmp signed nativo quebrado p/ negativos vindos de `Int[]`; mata Q8 quant (81_tensors_v2.kf:92); workaround: kernels sem negativos |
| **J4** | COMP002 ASM Frame.merge crash em MemoryLayer.purgeExpired; suite M10 não compila em JVM |
| **N16** | SEM025 fwd-ref classe; workaround: PARTS em ordem topológica + helpers movidos p/ 47_tools |

Histórico: **N10-progressivo**: translation units > ~800KB asm crasham (segfault/bounds
espúrio). Cada parte nova empurra módulos antes verdes para o limite.
Playbook de bisect em `docs/compiler-bugs.md`.

## Ledger upstream (resumo)

| Corrigidos ✅ | Abertos ❌ |
|---|---|
| J1 · J2 · N2 · N14 · SC1 · SC2 · SC5 | N1? · N3 · N4 · N6? · N7? · N8? · N9? · N10 · N11 · N12(parcial) · N13 · SC3(partial) · SC4(?) |

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
