# TOKENIZER (M10)
tkTokenize: palavras/dígitos; ids estáveis = |djb2(lower)| % 50000.
Vocab construído do corpus (dedup, cap 4096). decode v1 marca `<id>`
(vocab inverso chega com SLM). Streaming decode: interface na Model API.
