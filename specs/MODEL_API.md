# MODEL API (M11 bridge)
interface ModelBackend: loadModel(path) / unloadModel() / generate(prompt,
maxTokens) / cancel() / tokenize(s) / detokenize(ids) / deviceInfo().
Implementações: LocalGgufBackend (gap GW-WEIGHTS p/ geração; tokenizer e
header reais), ExternalProvider (fora do escopo nativo — D0002/D0007).
