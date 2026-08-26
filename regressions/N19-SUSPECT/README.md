# N19-SUSPECT — SIGSEGV combinando InferenceEngine+KoflmRuntime no mesmo TU

- Commit: 416ff4b · Target: native · Categoria: N (N10-family evoluída)
- Sintoma: artefato ~784KB fonte (~1MB asm) crasha (139) quando
  InferenceEngine (152) referencia rt.runner.generateStep através de
  KoflmRuntime (144). Mesmos símbolos funcionam via ModelRunner direto (M18.1 8/8).
- Workaround aplicado: engine usa composição indireta / aguarda fix.
- Repro: repro_full.kf + unit_engine.kf
- Status: CONFIRMED-COMPORTAMENTO, minimização pendente
