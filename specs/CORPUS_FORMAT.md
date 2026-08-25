# SPEC — CORPUS FORMAT (M5)

Estrutura oficial: corpus/{language,stdlib,compiler,runtime,editor,tooling,
patterns,anti-patterns,diagnostics,learn,examples,recipes,architecture,
future,training}/ + README por pasta.

Cache em `<root>/build/corpus.{idx,hashes,meta}`:
`MAGIC|VERSION|CRC\n<payload>` (CRPIDX/CRPHSH/CRPMET v1), payload seccionado
\u0001 entradas \u0002 campos \u0003 (mesmo formato WSIDX).
