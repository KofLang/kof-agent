# Spike Q1 — Compiler Gateway (M2)

**Data:** 2026-08-25T01:09:22.921035Z · **Compilador:** kof 0.0.14-alpha · **Host do gateway:** JVM (GW001 no native)

## Arquiteturas testadas

| Gateway | Desenho | Status |
|---------|---------|--------|
| A — Subprocess | `process.run("kof","check",file)` por operação | ✅ medido |
| B — Residente | processo persistente c/ pipes JSON-RPC | ❌ **impossível hoje**: `process.run` é one-shot, sem stdin/stdin streams (upstream). Variante medida: **B' batch-amortizado** (1 JVM valida N arquivos) |
| C — Embedded | compilador dentro do binário do agente | ❌ **BLOCKED** (sem FFI/Java-interop na linguagem) |

## Resultados (ms salvo indicado)

### A — subprocess por operação (250 ops)
p50=201 · p95=206 · p99=208 · mean=201.2 · min/max=195/210

O custo dominante é o startup da JVM a cada op (~201 ms).

### B' — batch amortizado (1 processo × 10 arquivos × 60 rodadas)
- batch total (10 arquivos): p50=217 ms
- **custo por arquivo: p50=21784 µs** (~9× mais barato que A)
- incremental (touch 1 arquivo + revalidar dir): p50=219 ms
- projeto grande (50 arquivos): p50=254 ms

## Leitura

1. Para **uma operação isolada**, A custa ~201 ms — inviável como caminho quente do repair loop.
2. Para **N operações**, o batch (B') derruba o custo marginal para µs por arquivo:
   a JVM startup é o gargalo, e ela se amortiza.
3. O canal estruturado ideal (LSP residente com pipes) exige process API com
   streams — gap upstream GW002.

## Decisão (ADR-001)

**Adotar Gateway B'-híbrido**: API única `CompilerGateway` com implementação
`BatchedSubprocessGateway` (default) que agrupa checagens por diretório/snapshot,
mais `SubprocessGateway` single-shot para casos pontuais. `EmbeddedGateway` fica
definida na interface mas retorna gap `GW003`. Quando upstream entregar pipes
(GW002) ou FFI (GW003), as implementações Resident/Embedded entram atrás da
MESMA interface sem mudar chamadores.
