# REPORT RC1 — FASE 4.5 Hardening

## Entregue
- `agent/runtime/120_rc1_hardening.kf`: LruCache (evict por lastTick, hit/miss counters), pluginAllowed (bitmask sandbox), detectSlowTool (3 níveis), detectLeak (growth/generations).
- **6/6 testes nativos** + stress 100k cache ops em 1431ms com cap respeitado.
- benchmarks/native-RC1.json

## Watchdog
- Palavras reservadas descobertas por PARSE: `use` e `val` não podem ser nomes de campo de record (registrado como nota — erro de parse claro, não bug).

## RC1 READY
M21-M26 núcleo estável sob stress básico. Expansão de regras/transports permanece na fila de features.
