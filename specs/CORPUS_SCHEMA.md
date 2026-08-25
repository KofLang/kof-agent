# SPEC — CORPUS SCHEMA (M5)
Frontmatter obrigatório entre `---`:

id · title · module · category · version · languageVersion · author ·
createdAt · updatedAt · keywords(csv) · symbols(csv) · dependencies(csv) ·
status · tags(csv) · example(path, só recipes)

Documento sem frontmatter entra com status=unparsed e é apontado pelo
Validator (invalid-file). id duplicado = issue. Símbolo fora da registry
builtin = orphan-symbol issue.
