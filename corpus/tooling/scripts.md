---
id: tool-scripts
title: scripts de build, teste e varredura
module: tooling
category: tooling
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: build.sh,test.sh,compat,sweep,cli
status: stable
tags: tooling
---
# Tooling do repo

- `scripts/kof-env.sh` — resolve `KOF4J_ROOT` (=~/Documentos/Kof4j) e `$KOF`.
- `scripts/build.sh <in.kf> <out.kf> [--native-clock]` — concatena as `PARTS`
  numa TU so na ordem topologica fixa. `--only=a,b` resolve basename em
  agent/runtime, engine, training/kf. Mover `.kf` exige re-`cmp` do TU.
- `scripts/build_cli.sh` — `build.sh apps/cli/main.kf` + `kof build --target
  native` → `build/out/Default/Main`; roda via `scripts/kof-agent`.
- `scripts/test.sh` — gate nativo: 13 suites (inclui unit_context, unit_contract).
  JVM roda as restantes; hoje 5 ws falham por N24.
- `scripts/check_compat.sh` — grep de java-isms em agent/runtime, apps/cli,
  tests, benchmarks (engine/ e training/kf/ estao FORA: null-narrowing e
  exigido la). rc!=0 = violacao.
- `scripts/sweep.sh` — roda `regressions/N*/repro.kf` contra `$KOF` e grava
  `docs/compiler/reports/sweep-<hash>.md`. So o TU atual confirma um fix;
  repros antigos com `fn` dao PARSE085 e NAO contam como evidencia.
- `scripts/test_corpus.sh` — roda `tests/corpus/*` listados em MANIFEST.
- `scripts/sync_corpus.py` — re-sincroniza `corpus/kof/` a partir de
  `$KOF4J_ROOT/training` (regra Kof: linguagem, idioms, migracao Java→Kof,
  anti-padroes, reference). Idempotente; regravar nao muda bytes. Rode apos
  `git -C ~/Documentos/Kof4j pull`.
