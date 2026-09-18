# TASKS — fila v2 (desde 18/09; specs/ENGINE_V2.md)

## Bloqueado upstream
- [ ] **N24** — VerifyError `gpu.dispatchMatmul` posicional em TU grande (JVM).
  Report Kof4j com repro em `regressions/N24/`. Libera as 5 suítes ws no JVM.

## E1 — Swap de contexto YAML (R3)
- [ ] `workspace/context.yaml` (persona, estado, pendencias, regras_vivas)
- [ ] leitor YAML em `engine/151_koflm_config.kf` + hot-reload por mtime no orchestrador
- [ ] hash do contexto gravado no journal (determinismo reprodutível)
- [x] teste: editar YAML entre turnos muda comportamento sem rebuild

## E2 — Dataset mínimo/ASK/RECUSA (R4.1)
- [x] reescrita v3 → v4: scripts/build_koflm_v4.py — EXECUTE/ASK/REFUSE, mediana 400→140 chars (-65%) (−60% tokens, mesma informação)
- [x] exemplos ASK e RECUSA (seeds train/eval disjuntas por hash-bucket; sem saida inventada)
- [x] eval 620 rotulada em eval/ptbr-suite-v4.jsonl; baseline em docs/dataset-v4-baseline.md
- [ ] baseline antes/depois registrado em benchmarks/

## E3 — OpenCL completo (R1)
- [x] cadeia C dlopen + 14 kernels .cl portados + harness bit-exato gpu/tests_ocl.c (rc=77 skip sem ICD)
- [ ] FFM no JVM + asm no native + namespace gpu.cl.* = lane compilador Kof4j
- [x] port dos 14 `.comp` → `.cl` em gpu/kernels/ (sintaxe validada via _stub_check.c)
- [ ] residência de pesos (cl_buffer, contrato mvPutSp)
- [x] detectOpenCL() + oclDetectFrom() (unit_backends 6/6); CL fora do auto-ate gpu.cl.* real (Q7 sem facade)
- [ ] prova: bit-exato CL == VK == CPU golden nos 12 kernels (unit_shaders estendida)

## E4 — Modelo especialista (R2)
- [x] models/kof-LM/model-v2.json (~238M, ctx-1024, greedy temp-0) + KofTrainer.useDataset(v4)
- [ ] ciclo de iteração: journal → exemplos → adapter no HAL → eval → publish
- [ ] gate: ≥95% precisão de intenção, <2% chute sem perguntar, 0 API alucinada

## E5 — CLI no contrato §2
- [x] engine/161_contract.kf: outFmt/outAsk/outRefuse/outFromCtx (unit_contract 5/5)
- [x] clamp/reglas do YAML no contrato; gate de confianca<limiar -> outAsk = proximo passo no loop
