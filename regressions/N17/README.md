# N17 — Comparação signed quebrada no Native para valores negativos vindos de Int[]

- Commit: 65f748f · Target: native (JVM correto) · Categoria: N (Codegen)
- Esperado: lt0=true · Obtido: false (tratado como unsigned)
- Repro: kof run repro.kf --target native
- Workaround: evitar negativos em tensors (offset/bias positivo); máscara causal usa penalidade positiva
