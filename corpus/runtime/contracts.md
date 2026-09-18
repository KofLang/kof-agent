---
id: rt-contracts
title: contratos do core runtime
module: runtime
category: runtime
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: scheduler,eventbus,lifecycle,determinismo
symbols: RuntimeContext,Scheduler,EventBus,Lifecycle
status: stable
tags: nucleo
---
# Core runtime (M1, docs/runtime.md atualizado a 0.4.0)

- `Scheduler` — heap de prioridades deterministica (sem wall-clock no ordem;
  `RealTimeClock` so em metrics), cooperativo via `tick`; ~144k tasks/s.
- `EventBus` — publish sincrono por default (event → handler na hora);
  PublishJob para fila async. ~56k ops/s com handler.
- `Lifecycle` — maquina BOOTING→INITIALIZING→RUNNING→STOPPING→STOPPED/FAILED
  com hooks; `RuntimeContext.wire()` faz DI por construtor de todos os modulos.
- `Logger` — TRACE..FATAL, plain/json/color/quiet; `quiet=true` no CLI boot.
- `Config` — arquivo (kof.config) > default; env ainda pendente (ENV001).
- CLI le argv via arquivo `.kofargs` (hackle ARG001 no launcher native).

Determinismo e requisito, nao perfumaria: duas execucoes do mesmo TU com o
mesmo input produzem saida identica (fixed-point int64 no engine).
