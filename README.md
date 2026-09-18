# Kof Agent

Agente de IA **100% escrito em Kof**, compilado para binário nativo, com SLM local
(**KofLM/koflama**) rodando offline via GGUF. Ferramenta, não amiga: recebe um pedido,
executa a tarefa, explica o mínimo possível, pergunta quando não entende.

## Estado (2026-09-18)

| Camada | Estado |
|---|---|
| M0–M31 runtime/tools/corpus/retrieval/AI/HAL/shaders | ✅ |
| M32 GPU Vulkan (FFM vkchain, dispatch matmul 32/64) | ✅ |
| M33 GGUF parser binário 100% Kof (Q4_K/Q6_K/F16) | ✅ |
| M34 forward TinyLlama token exato + tokenizer SPM + geração | ✅ |
| M35 precisão nano (rmsnorm/matvec/attention sem overflow) | ✅ 4/6 posições exatas vs GT |
| M36 pesos residentes no device (Vulkan, int64) | ✅ warm 1×, zero cópia/token |
| **Port kof 0.4.0-beta** (fn, record-imutável, `Map.get → getOrDefault`, `as Int`) | ✅ |
| Suíte nativa | 🟡 11/16 — 5 vermelhas por **N24** (VerifyError `gpu.dispatchMatmul` posicional em TU grande — upstream) |

Compilador: **Kof4j beta-0.4.0** (`~/Documentos/Kof4j`). Ledger: `docs/compiler/bug-ledger.md`.
Missão e motor de inferência v2: `specs/ENGINE_V2.md`.

## Estrutura

```
agent/runtime/     PARTS do loop do agente (core, tools, workspace, brain, planner…)
engine/            motor de inferência (tensor, gguf, koflama forward/tokenizer, HAL/shaders)
training/kf/       pipeline de treino/dataset em Kof (builder, corpus-intel, gguf-builder, trainer)
apps/              hosts (cli, gateway)
gpu/shaders/       SPIR-V (matmul 32/64, rmsnorm, rope, swiglu, attention, matvec residente)
tests/             suítes por milestone (uma fonte .kf por suíte)
specs/ docs/       specs por milestone + documentação viva (docs/status.md = fonte de verdade)
regressions/       repros mínimos de bugs do compilador (N1–N24)
models/ datasets/ eval/ benchmarks/  modelo oficial, dados, avaliação PT-BR, baselines
```

## Build & Teste

```bash
bash scripts/build.sh tests/unit_core.kf build/t.kf       # concatena PARTS (ordem topológica)
kof test build/t.kf --target native
bash scripts/test.sh          # suíte completa
bash scripts/sweep.sh         # ledger de regressões vs HEAD do compilador
```

## KofLM (SLM oficial)

```bash
scripts/download_tinyllama.sh              # base GGUF (setup único)
python3 scripts/build_koflm_dataset.py     # dataset PT-BR
```

Inferência validada: 37 tok/s decode CPU; GPU Vulkan residente (RX 6600). OpenCL
é o próximo backend do HAL (`specs/ENGINE_V2.md` §3).

## Filosofia

KOF é KOF. Offline-first · determinístico · zero cloud · tudo tipado ·
specs antes de código · resposta curta e verdadeira, mesmo quando desagrada —
na contramão de agente que busca agradar. Não vendemos tokens: o sucesso é
acertar o pedido (≥95%) explicando o mínimo.
