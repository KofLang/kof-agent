# TASKS — fila v2 (desde 18/09; specs/ENGINE_V2.md)

## Bloqueado upstream
- [ ] **N24** — VerifyError `gpu.dispatchMatmul` posicional em TU grande (JVM).
  Report Kof4j com repro em `regressions/N24/`. Libera as 5 suítes ws no JVM.

## E1 — Swap de contexto YAML (R3)
- [x] `engine/160_context.kf` parser YAML subset + hot-reload por hash de conteudo + `workspace/context.yaml`
- [ ] orquestrador reconstrói prompt quando hash muda (`ctxChanged()` pronto/testado; falta ligar no loop)
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

## E6 — Performance do corpus (aberto 18/09, medido)
- [ ] `corpusLoad` ~15 s e `retBuildContext` ~25 s para 131 docs (nativo): re-tokeniza corpo de cada doc a cada chamada e re-parseia tudo a cada processo. Fix: tokens memoizados no CorpusIndex no load + aproveitar cache CRPIDX (corpusSaveCache já existe; falta o load path). Workaround atual: ask humano não carrega corpus (routing não usa contexto; --json sim).
- [ ] medir de novo após fix (alvo: ask --json < 2 s com cache quente).

## E5 — CLI no contrato §2
- [x] engine/161_contract.kf: outFmt/outAsk/outRefuse/outFromCtx (unit_contract 5/5)
- [x] clamp/regras do YAML no contrato (unit_contract 5/5)
- [x] modo ASK quando confiança < limiar: gatilho real em koflearn (confiança = margem top−2º; `perguntar_se_confianca: 0.15`), com harvest em `datasets/jsonl/koflm-errors.jsonl` p/ próximo treino (medição real: "crie um site sobre kof em html" conf 429→ASK honesto)

## E7 — KofLearn: modelo treinável em Kof puro (aberto 18/09)
- [x] engine/164_koflearn.kf: bag-of-features (tokens + 3-gramas) + 3 sigmoides int64-micro (SGD one-vs-rest, lr 0.06), treino/eval/predict 100% Kof, pesos serializados "KFLR" com CRC (45_windex)
- [x] CLI `train` (incremental: carrega pesos existentes, soma epochs, consome errors.jsonl) e `eval` (suite PT-BR, rc 2 se ruim)
- [x] tests/learn 8/8 nativo: parser JSONL (com/sem espaço), aprende, confiança alta no visto, "não sei" no inédito, roundtrip de pesos, CRC corrompido rejeitado, harvest, eval
- [x] workaround splitStr O(n²) em jsonl grande: scan por indexOf (164) — 55 s→navegável
- [ ] E7b: fixar `splitStr` de 00_core (usado por corpusLoad→15 s e yamlParse) — perf geral, não só do learner
- [ ] nºs finais de acc/chute/ask no suite 620 (treino n-gram 12 epochs em andamento; meta §5.2: acc≥95% chute≤5%; reportar o que vier, sem maquiar)
- [ ] E8: fechar o ciclo com o transformer real (KofLM): backward/LoRA do TinyLlama em Kof para o executador gerar código de verdade (GGUFs em ~/Downloads/kof-data/models; sha256 divergente do registrado — verificar no load)
