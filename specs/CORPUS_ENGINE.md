# SPEC — CORPUS ENGINE (M5)
**Status:** implementado · verificação nativa bloqueada por N10 (15 testes autorados)

- Loader: varre `corpus/**/*.md`, parseia frontmatter YAML-min (16 campos),
  calcula checksum djb2 do arquivo inteiro, monta CorpusIndex.
- Validator: duplicate-id · invalid-file (sem frontmatter) · checksum-changed
  · broken-link (links relativos resolvidos contra root) · orphan-symbol
  (símbolo declarado fora da lista builtin da linguagem).
- Registries: Diagnostics (docs em category=diagnostics → código + workaround
  via assinaturas do ledger) e Recipes (category=recipes + `example:` path com
  verificação de existência).
- Symbol Registry builtin: spawn, record, constructor, Window, Palette.red,
  web.app, json.decode/encode, passwords.hash, db.connect, orm.save, log.info,
  config.str, crypto.sha256, secrets.get, jwt.verify.
- Cache: CRPIDX/CRPHSH/CRPMET v1 (mesmo envelope MAGIC|VERSION|CRC das outras
  persistências). Eventos: corpus.loading/loaded · registry.updated.
- Consultas: corpusById/byCategory/searchKeyword/symbolDocs.
