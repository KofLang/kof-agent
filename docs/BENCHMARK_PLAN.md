# BENCHMARK_PLAN — Plano de Performance

**Status:** aceito (Milestone 0)

Performance não é sensação: é baseline versionado comparado a cada mudança.
Espírito herdado de `docs/performance.md` do Kof — benchmarks fazem parte da
arquitetura.

---

## 1. Princípios

1. Toda feature que possa ter custo em runtime responde antes: *qual é o custo?*
2. Medir tempo **e** memória (um programa 10% mais rápido com 5× mais RAM não é melhor).
3. Baseline por milestone; regressão > 20% bloqueia.
4. Zero cópias desnecessárias nos caminhos quentes; mmap e lazy loading.

## 2. O quê medir, por milestone

| Milestone | Benchmarks |
|-----------|------------|
| M1 | tempo de inicialização; dispatch do event bus (ops/s); overhead do scheduler |
| M2 | latência de compile-check (p50/p95) por arquivo; parse→AST→diagnostics |
| M3 | indexação inicial (arquivos/s); reindexação incremental (ms); memória do índice |
| M4 | overhead de dispatch da Tool API (ns/op) |
| M5 | ingestão do corpus (docs/s); atualização incremental; tamanho do cache |
| M6 | retrieval top-K (ms); recall@10 canônico; RAM do índice vetorial |
| M7 | acurácia intents canônicas; latência brain (ms/frase) |
| M8 | geração de plano (ms); validação de plano |
| M9 | E2E frase→verde por caso canônico; iterações médias do repair loop |
| M10 | tokens/s por quantização; load GGUF (s); primeiro token (ms); RSS/VRAM |
| M11 | matmul GB/s e attention por backend; seleção automática correta |
| M12 | throughput de geração de dataset (exemplos/s); validação JSONL |

## 3. Metas absolutas

| Métrica | Alvo |
|---------|------|
| Inicialização (`kof-agent version`) | < 100 ms |
| Primeiro token (modelo local, warm) | < 200 ms |
| Streaming | contínuo, sem pausas > 50 ms |
| RAM base do agente idle | mínima documentada por release |
| Cópias no caminho de streaming | zero |

## 4. Harness

Inspirado no `kof bench`:

```
compilar → executar → validar saída esperada
        → medir tempo (mediana de N) + RSS (/usr/bin/time -v)
        → comparar com baseline → sinalizar PERFORMANCE REGRESSION
```

- Saída `--json` para CI.
- Baselines versionados em `benchmarks/baselines/<target>-<milestone>.json`.
- Baselines locais (`*.local.json`) nunca são commitadas.
- Ambiente de medição registrado no baseline (CPU, RAM, SO, target).

## 5. Formato do registro

```json
{
  "name": "init",
  "target": "native",
  "milestone": "M01",
  "iterations": 20,
  "metric": "median_ms",
  "value": 41.7,
  "rss_kb": 9216,
  "env": { "cpu": "...", "os": "...", "date": "..." }
}
```

## 6. Regras

- Benchmark sem baseline é benchmark inexistente.
- Toda correção de performance vem acompanhada do benchmark que prova o ganho.
- Micro-otimização só com medição prévia (anti-pattern: premature optimization).
