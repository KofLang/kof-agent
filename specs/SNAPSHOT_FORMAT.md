# SPEC — SNAPSHOT FORMAT (M3)

## Arquivos (em `<root>/build/`)

| Arquivo | Formato | Conteúdo |
|---------|---------|----------|
| workspace.idx | texto versionado | meta + files + symbols + imports + deps |
| workspace.snapshot | texto versionado (mesmo payload do idx) | cópia para inspeção/ferramentas |
| workspace.hashes | TEXTO versionado (WSHSH) — hashes um por linha separado por \u0002 | tabela plana path-order→hash |

> Nota honesta: a intenção era binário puro via `writeBytes`, mas a stdlib
> 0.0.14 não expõe conversão confiável byte↔char para decodificação. O
> container é versionado + checksum (mesma garantia de integridade); binário
> real entra quando a plataforma expor primitivas de byte-string.

## Layout do cabeçalho

```
MAGIC|VERSION|CRC\n<payload>
MAGIC ∈ {WSIDX, WSSNP, WSHSH} · VERSION = 3 · CRC = djb2(payload)
```

Carga rejeita magic/version/CRC divergentes → `root=""` + evento
`workspace.cacheInvalid` (nunca dado corrompido silencioso).

## Payload (idx/snapshot)

Seções separadas por `\u0001`; entradas por `\u0002`; campos por `\u0003`
(strings sanitizadas — ocorrência desses códigos vira `?`):

```
meta(workspaceId,root,branch,commit,target,timestamp)
files(path,hash,size)… symbols(name,kind,file)…
imports(file,name)… deps(from,to)…
```

Compatibilidade: versão anterior → rejeitado com evento (fullRescan resolve).
