---
id: ed-file-loop
title: o laco de edicao do agente
module: editor
category: editor
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: fs,patch,diagnostico,rollback
status: stable
tags: editor
---
# Editor (no sentido do agente, nao um IDE)

Superficie real do registro de tools (47_tools.kf, ~32 ferramentas, cada
uma com permissao propria):

- ler: `fs.read fs.exists fs.metadata fs.list` · `search.text/symbol/path`
- mudar: `fs.write` (backup p/ rollback) `fs.append fs.copy fs.rename
  fs.delete fs.mkdir` · `patch.file patch.replace diff.file`
- verificar: `compiler.check compiler.build compiler.run
  compiler.diagnostics` · `ws.open ws.snapshot ws.diff ws.graph`
- `git.branch/git.log` sao somente-leitura por design.

Fluxo de reparo: diagnostico do `compiler.*` → `diagRegistry` do corpus
(57_corpus categoriza `category: diagnostics` e mapeia workaround, p.ex. a
string `String_kof_string_to_int` → N2) → patch → re-check. O corpo deste
corpus e o que alimenta essa busca: sem doc, sem workaround.
