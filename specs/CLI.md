# SPEC — CLI (M1)

**Status:** implementado (binário `kof-agent`, alvo Native)
**Módulo:** `apps/cli/main.kf` (entrada) + partes do runtime

## 1. Comandos

| Comando | Efeito |
|---------|--------|
| `version` | nome, versão, milestone, target |
| `help` | usage com todos os comandos e flags |
| `status [--root <dir>]` | boota o runtime silencioso e imprime: lifecycle, scheduler, métricas, workspace |
| `doctor [--root <dir>]` | diagnósticos do ambiente; exit 2 se algo falhar |
| `config show [--file <path>]` | imprime config efetiva (entries carregadas) |

Flags globais: `--json` (saída estruturada estável), `--root <dir>`,
`--file <path>`, `--quiet`.

## 2. Exit codes determinísticos

| Código | Significado |
|--------|-------------|
| 0 | sucesso |
| 1 | uso inválido (comando/flag desconhecidos) |
| 2 | falha funcional (doctor com itens reprovados, status sem workspace) |

Nenhum caminho de saída fica sem código definido.

## 3. Saída `--json`

Chaves estáveis, prontas para consumo por editores (Editor Protocol M4):

```json
{"name":"kof-agent","version":"0.1.0-m01","target":"native"}
{"state":"READY","scheduler":{"pending":0,"completed":3},"uptimeMs":12,"workspace":{"kfFiles":4,"hasGit":false}}
{"checks":[{"id":"workspace","ok":true,"detail":"..."}],"allOk":true}
```

## 4. Doctor — checks da M1

1. `workspace` — raiz existe e é diretório.
2. `config` — arquivo carrega (ou ausente → ok com default).
3. `log-level` — `log.level` configurado é válido (0–5).
4. `cache` — consegue criar/escrever/remover probe em `<root>/build/cache`.

Autocomplete: estrutura de comandos é tabela única consultável (`help --json`
planejado na M4 junto do Editor Protocol); geração de script bash/zsh fica
para a M5+.

## 5. Não objetivos (M1)

`run/plan/ask/index/corpus/bench` como comandos (chegam com as milestones
respectivas), daemon interativo, protocolo de editor.
