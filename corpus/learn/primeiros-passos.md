---
id: learn-primeiro-passos
title: primeiros passos no repo
module: learn
category: learn
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: inicio,build,cli,teste
status: stable
tags: tutorial
---
# Primeiros passos

1. `source scripts/kof-env.sh` — aponta `$KOF` para ~/Documentos/Kof4j
   (bin/kof 0.4.0-beta).
2. `bash scripts/build_cli.sh` — gera o ELF em `build/out/Default/Main`.
3. `./scripts/kof-agent status --root .` — boot do RuntimeContext +
   workspace scan. `--json` para saida maquina.
4. `bash scripts/test.sh` — gate nativo (13 suites; ws no JVM falham por
   N24, ja conhecido).
5. Editar contexto sem rebuild: `workspace/context.yaml` — o engine ve o
   novo conteudo via hash (160_context.kf).
6. Antes de commitar codigo novo em agent/apps/tests:
   `bash scripts/check_compat.sh` (rc 0).
