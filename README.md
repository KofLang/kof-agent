# Kof Agent

Agente de IA **100% escrito em Kof**, compilado para binário nativo, com SLM local (**kof-LM**) rodando offline via GGUF.

## Estado (2026-08-25)

| Fase | Escopo | Estado |
|---|---|---|
| 1–2 | M0–M12 runtime/tools/corpus/retrieval/AI core | ✅ |
| 3 | M13–M20 memory/conversation/orchestrator/**AI runtime completo** | ✅ núcleo (M13–M15 aguardam N10 upstream) |
| 4 | M21–M26 LSP/DevTools/Plugin-MCP/SelfImprovement/Journal/Observatory | ✅ núcleo + RC1 hardening |
| 5 | M27–M30 service/AI-engine/workspace-memory/model-manager | ✅ núcleo |
| 6 | KofLM v1: dataset real PT-BR, eval 540 prompts, LoRA manager, GGUF pipeline | 🟡 treino pendente |

**~120 testes nativos verdes** · compilador @416ff4b · ledger c/ 18 bugs documentados (N18 CONFIRMED c/ repro mínimo).

## KofLM v1 (SLM oficial)

```bash
scripts/download_tinyllama.sh            # base GGUF (~1.8GB, setup único)
python3 scripts/build_koflm_dataset.py   # dataset real PT-BR
```

Inferência local validada: **37 tok/s decode / 242 tok/s prompt** (CPU, Q4_K_M).
GPU universal via Vulkan (AMD RX 6600/NVIDIA/iGPU): `build-vk/bin/llama-completion -ngl 99`
— requer ICD do driver (RADV) instalado no sistema.

## Estrutura

```
agent/runtime/   PARTs numerados (00–147) concatenados por scripts/build.sh --only=
specs/           specs por milestone
regressions/     repros mínimos de bugs do compilador
models/kof-LM/   registry do modelo oficial
datasets/        jsonl v2/v3 + sintético + manifests
eval/            540 prompts PT-BR
benchmarks/      baselines nativos por milestone
docs/compiler/   ledger, matrix, reproduções p/ time do compilador
```

## Build & Teste

```bash
bash scripts/build.sh tests/m17_src/unit_m17.kf build/t.kf \
  --native-clock "--only=00_core.kf,...,84_gguf.kf"
kof test build/t.kf --target native        # one-test-per-process (anti-N10)
```

## Filosofia

KOF é KOF. Offline-first · determinístico · zero cloud · tudo tipado · specs antes de código.
