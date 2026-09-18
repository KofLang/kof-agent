# TOOL API REFERENCE (M4)

## Execução

```
toolExec(registry, ctx, ToolCall(toolId, requestId, argA, argB, argN)) -> ToolResult
```

- `ToolCtx`: requestId · bus · clock (TimeSource injetável) · grants ·
  cancelled · met (Metrics) · wsi (WorkspaceIndex carregado pelo host).
- Permissões verificadas ANTES do handler; negação publica `tool.denied`
  e retorna status=denied com a permissão faltante em data.
- Toda execução publica tool.started/tool.finished/tool.failed e incrementa
  métricas (tasks.launched/completed/failed).

## ToolResult

| Campo | Tipo | Significado |
|-------|------|-------------|
| status | String | ok · error · denied · gap · cancelled |
| data | String | payload JSON da ferramenta ou `CODE\|detail` |
| durationMs | Long | medido pelo clock injetado |
| rollback | ToolRollback | kind (restore/delete-created) + backupPath |

## Rollback

Ferramentas destrutivas gravam `<path>.katool-bak` antes de mutar;
`fs.rollbackRestore(backupPath,target)` restaura e consome o backup.
`ws.invalidate` derruba o índice persistido (reescaneia no próximo open).

## Convenções de args (até json.decode nativo)

Args são posicionais documentados por ferramenta no catálogo
(`a`, `b`, `n`). Ferramentas que precisam de par usam separador `|`
(ex.: patch.replace: b = "from|to").

## Estados e gaps

| status | causa |
|--------|-------|
| ok | executou |
| error | FS-*/PATCH-*/WS-* codes em data |
| denied | permissão ausente |
| gap | GW-EXEC/GW-AST-DUMP/GW-NET/GW-SYS/GW-UI/WS-NOTLOADED/GIT-NOLOG |
| cancelled | ctx.cancelled antes do handler |
