# N18-SUSPECT — Instabilidade nativa tipo-N10: crash depende de padrão de acesso a campos

- Commit: 416ff4b · Target: native · Categoria: N (Codegen/N10-family)
- Sintoma: mesmo openGGUF("fixtures/tiny.gguf"): teste c/ `hasTensor` PASSA;
  teste c/ `println(h.header.version + ...)` → SIGSEGV 139; teste c/
  `assert(h.header.version == 3)` roda e falha assertion (sem crash).
  Ou seja: resultado muda com forma de consumo dos campos do record retornado.
- Artefato: ~831KB asm (build/run_t0.kf pipeline --only)
- Repro: regressions/N18-SUSPECT/repro.kf + fixtures/tiny.gguf
- Esperado: campos consistentes em qualquer padrão de acesso
- Status: CONFIRMED-COMPORTAMENTO, minimização pendente
