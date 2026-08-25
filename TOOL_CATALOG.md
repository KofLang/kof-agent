# TOOL CATALOG — Kof Agent (M4)

Total: 37 ferramentas registradas em defaultRegistry().

> Gaps estruturais retornam ToolResult status=gap com código (GW-*);
> nunca falham silenciosamente.


## AST (1)

| id | permissão | nome |
|----|-----------|------|
| `ast.findNode` | — | findNode |

## Compiler (3)

| id | permissão | nome |
|----|-----------|------|
| `compiler.check` | compiler.execute | check |
| `compiler.build` | compiler.execute | build |
| `compiler.run` | compiler.execute | run |

## Diagnostics (1)

| id | permissão | nome |
|----|-----------|------|
| `compiler.diagnostics` | compiler.execute | diagnostics |

## Diff (1)

| id | permissão | nome |
|----|-----------|------|
| `diff.file` | filesystem.read | diff.file |

## Filesystem (12)

| id | permissão | nome |
|----|-----------|------|
| `fs.read` | filesystem.read | readFile |
| `fs.exists` | filesystem.read | exists |
| `fs.metadata` | filesystem.read | metadata |
| `fs.list` | filesystem.read | listDirectory |
| `fs.append` | filesystem.write | appendFile |
| `fs.copy` | filesystem.write | copyFile |
| `fs.mkdir` | filesystem.write | createDirectory |
| `fs.readDirRaw` | filesystem.read | readRaw |
| `fs.write` | filesystem.write | writeFile |
| `fs.delete` | filesystem.write | deleteFile |
| `fs.rename` | filesystem.write | renameFile |
| `fs.rollbackRestore` | filesystem.write | restoreBackup |

## Git (2)

| id | permissão | nome |
|----|-----------|------|
| `git.branch` | filesystem.read | git.branch |
| `git.log` | filesystem.read | git.log |

## HTTP (1)

| id | permissão | nome |
|----|-----------|------|
| `http.request` | web.network | httpRequest |

## Patch (3)

| id | permissão | nome |
|----|-----------|------|
| `patch.file` | filesystem.write | patch.file |
| `patch.replace` | filesystem.write | patch.replace |
| `patch.append` | filesystem.write | patch.append |

## Search (3)

| id | permissão | nome |
|----|-----------|------|
| `search.text` | filesystem.read | search.text |
| `search.symbol` | filesystem.read | search.symbol |
| `search.path` | filesystem.read | search.path |

## System (1)

| id | permissão | nome |
|----|-----------|------|
| `system.exec` | system.execute | exec |

## UI (1)

| id | permissão | nome |
|----|-----------|------|
| `ui.preview` | — | preview |

## Web (1)

| id | permissão | nome |
|----|-----------|------|
| `web.request` | web.network | request |

## Workspace (7)

| id | permissão | nome |
|----|-----------|------|
| `ws.open` | — | workspace.open |
| `ws.snapshot` | — | workspace.snapshot |
| `ws.diff` | — | workspace.diff |
| `ws.findSymbol` | — | workspace.findSymbol |
| `ws.findFile` | — | workspace.findFile |
| `ws.graph` | — | workspace.graph |
| `ws.invalidate` | filesystem.write | workspace.invalidate |
