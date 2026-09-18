# TASKS — fila v2 (desde 18/09; specs/ENGINE_V2.md)

## Bloqueado upstream
- [ ] **N24** — VerifyError `gpu.dispatchMatmul` posicional em TU grande (JVM).
  Report Kof4j com repro em `regressions/N24/`. Libera as 5 suítes ws no JVM.

## E1 — Swap de contexto YAML (R3)
- [ ] `workspace/context.yaml` (persona, estado, pendencias, regras_vivas)
- [ ] leitor YAML em `engine/151_koflm_config.kf` + hot-reload por mtime no orchestrador
- [ ] hash do contexto gravado no journal (determinismo reprodutível)
- [ ] teste: editar YAML entre turnos muda comportamento sem rebuild

## E2 — Dataset mínimo/ASK/RECUSA (R4.1)
- [ ] reescrita v3 → v4: resposta só-com-resultado (−60% tokens, mesma informação)
- [ ] exemplos ASK (pedido ambíguo → pergunta única) e RECUSA (errado → 1 linha)
- [ ] eval 540 rotulada `expected=EXECUTE|ASK|REFUSE` + métricas do ENGINE_V2 §5.2
- [ ] baseline antes/depois registrado em benchmarks/

## E3 — OpenCL completo (R1)
- [ ] `liboclchain` (C magro, dlopen) + FFM no JVM + asm no native (padrão vkchain M32.3)
- [ ] port dos 12 `.comp` → `.cl` em `gpu/kernels/` (build em runtime)
- [ ] residência de pesos (cl_buffer, contrato mvPutSp)
- [ ] `detectOpenCL()` em `150_koflm_backend.kf`; prioridade VK > CL > CPU
- [ ] prova: bit-exato CL == VK == CPU golden nos 12 kernels (unit_shaders estendida)

## E4 — Modelo especialista (R2)
- [ ] config ≤400M, ctx 1024, vocab PT-BR+Kof enxuto; GGUF no registry kof-LM
- [ ] ciclo de iteração: journal → exemplos → adapter no HAL → eval → publish
- [ ] gate: ≥95% precisão de intenção, <2% chute sem perguntar, 0 API alucinada

## E5 — CLI no contrato §2
- [ ] formato de saída: resultado + ≤2 linhas; zero preâmbulo/cortesia
- [ ] modo ASK quando confiança < limiar do YAML
