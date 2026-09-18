# ENGINE_V2 — Motor de inferência determinístico + agente direto ao ponto

**Status:** aprovado pela mantenedora (diretriz de 18/09, chat) · **Dono:** lane engine
**Regra-mãe:** o kof agent é uma **ferramenta**, não uma amiga. Recebe pedido →
faz a tarefa → explica o **mínimo possível**. Pergunta quando não entendeu.
Nunca optimiza para agradar; optimiza para **acertar a intenção** (meta ≥95%).

---

## 1. Por que não "mais GPT"

| GPT comercial | Kof Agent |
|---|---|
| contexto gigante, tokens caros | janela pequena fixa + **swap de contexto** por arquivo |
| alinha para agradar (sycophancy) | alinha para **verdade e utilidade**, mesmo desagradando |
| resposta longa = "boa resposta" | resposta mínima que resolve = boa resposta |
| peso gigante, nuvem | poucos parâmetros, offline, treinável em iterações curtas |

O custo de um erro do agente é a tarefa errada executada, não a frase educada
que falta. Todo treino/eval mede **execução da intenção**, não educação.

## 2. Contrato de comportamento (congelado)

1. **Executa primeiro, explica depois, e pouco.** Formato de saída:
   resultado da tarefa (diff/arquivo/saída) + ≤2 linhas de explicação.
   Nenhuma introdução, nenhum resumo de cortesia, nenhum "claro!".
2. **Incerteza → pergunta.** Se a confiança na intenção < limiar, o agente
   **não chuta**: emite `ASK` com a pergunta mínima que destrava (1 linha).
   Errar pedindo esclarecimento é **sucesso**; chutar sem perguntar é falha.
3. **Verdade > conveniência.** Se o pedido está errado/contraditório/impossível,
   diz em 1 linha o motivo e para. Não suaviza, não enrola.
4. **Determinístico.** mesmo input + mesmo contexto ⇒ mesmo output (greedy,
   seed fixa, aritmética de inteiros nano — nunca float).

## 3. Motor de inferência — roadmap

### 3.1 O que já existe (M32–M36, ✅)
- GGUF parser 100% Kof; quantização Q4_K/Q6_K/F16; ponto fixo nano (int64).
- Vulkan por FFM/libvkchain: matmul 32/64 + **pesos residentes no device**.
- koflama forward: token exato vs ground-truth; multi-token 4/6 posições.

### 3.2 OpenCL completo (próximo passo, R1)
O HAL atual tem CPU + Vulkan. OpenCL fecha o "universal" (Intel legacy,
Android sem VK, GPUs antigas):
1. **Criação do binding:** mesmo padrão do vkchain (C magro + dlopen):
   `liboclchain`: `clGetPlatformIDs → clCreateContext(build from IL) →
   clCreateProgramWithSource(.cl texto, nao binario) → clBuildProgram →
   clCreateKernel → clSetKernelArg → clEnqueueNDRangeKernel`.
   JVM via FFM; native via asm (espeelho do M32.3); JS sem suporte (GPU001).
2. **Kernels:** portar os 12 `.comp` para `.cl` (GLSL→CL é mecânico:
   `__global` args, sem binding decorations). Fontes `.cl` ficam em
   `gpu/kernels/`, compilados em runtime (nada de binario vendor no repo).
3. **Residência:** `cl_buffer` dos W no boot (mesmo contrato do mvPutSp:
   ids por tensor, warm 1×).
4. **Seleção:** `150_koflm_backend.kf` já tem `detectOpenGL`/override por env;
   plugar `detectOpenCL()` e prioridade VK > CL > CPU (VK é mais rápido;
   CL cai para hardware sem VK).
5. **Prova:** bit-exact CL == VK == CPU golden nos 12 kernels
   (`unit_shaders` estendida; mesma saida em 3 backends ou gap diagnosticado —
   regra de paridade do Kof4j).

### 3.3 Modelo do agente (R2)
- **Arquitetura:** koflama-like compacta, **≤ 400M params** (TinyLlama já roda
  inteiro hoje; o alvo é menor e especialista, nao maior e generalista).
- **Dimensões:** d_model 768, 16 camadas, ctx **1024 tokens** (janela pequena
  é requisito, não limitação — ver §4).
- **Treinável na máquina da mantenedora:** LoRA/adapter em Kof
  (`training/kf/148_koflm_trainer.kf` já existe; GPU via HAL).

## 4. Swap de contexto em YAML (R3)

Nada de big data nem contexto gigante. O "céu" do agente é um arquivo:

```yaml
# workspace/context.yaml — recarregado a cada turno (mtime watch)
persona: kof-tool            # template curto de sistema (~80 tokens)
intencao_atual: "limpar o repo"
estado:                       # o que o agente sabe agora (poucas linhas)
  passo: "sweep rodou; N24 bloqueia ws-jvm"
pendencias:
  - "opencl kernels"
regras_vivas:
  perguntar_se_confianca: 0.7
  max_explicacao_linhas: 2
```

- **Custo:** template fixo + YAML serializado em chat-format ≈ 300 tokens.
  Janela de 1024 sobra para a tarefa corrente.
- **Runtime:** `engine/151_koflm_config.kf` lê YAML; o orchestrador remonta o
  prefixo do prompt a cada turno. Trocar o arquivo = trocar o comportamento
  **sem recompilar nem retreinar**. O YAML é a memória de trabalho; o peso é a
  perícia; os dois são quentes.
- **Determinismo:** o arquivo é versionado no repo; o turno grava o hash do
  contexto no journal (reprodutibilidade exata de qualquer resposta).

## 5. Treino: concisão + verdade + pedir-esclarecimento (R4)

### 5.1 Dados (pequenos e bons, nao grandes)
- Base: `datasets/jsonl/` v3 PT-BR + corpus Kof (training/ + learn/ do Kof4j).
- **Reescrita sistemática:** cada resposta do dataset vira versão **mínima**
  (só o resultado + ≤2 linhas). Alvo: −60% tokens, mesma informação.
- **Três formatos de exemplo:**
  1. `pedido → tarefa executada + explicação curta`
  2. `pedido ambíguo → "ASK: <pergunta única>"`  (ensita perguntar)
  3. `pedido errado/impossível → recusa em 1 linha com motivo técnico` (verdade)
- Anti-sycophancy: pares de preferência `(resposta honesta curta) >
  (resposta longa bajuladora)` no DPO/trainer.

### 5.2 Métricas (eval/ estendida)
| Métrica | Meta |
|---|---|
| Precisão de intenção (executa o pedido certo) | ≥ 95% |
| Taxa de pergunta correta quando ambíguo | ≥ 90% |
| Tokens médios de explicação | ≤ 2 linhas |
| Alucinação (fato/inexistência de API) | 0 tolerado em API Kof (testável) |
| Chutes sem perguntar | < 2% |
| Determinismo (2× same input) | 100% |

- Suite atual (540 prompts) ganha rotulo `expected=EXECUTE|ASK|REFUSE` —
  o eval passa a medir as 3 classes de ação, não só texto.

### 5.3 Ciclo por iteração (aprende conforme evolui)
```
roda tarefa real → journal grava (contexto-hash, saída, feedback da mantenedora: ok|errado|chutou)
  → lotes viram exemplos dos 3 formatos → treina adapter no HAL (horas, nao dias)
  → eval 540+rotulada → publica GGUF no registry models/kof-LM (versão + checksum)
```
Feedback binário da mantenedora é o único rótulo que existe — semannotation team,
sem API externa. O peso acumula as iterações; o YAML continua a memória fresca.

## 6. Sequência de execução

| # | Entrega | Prova |
|---|---|---|
| E1 | `context.yaml` + hot-reload no orchestrador | teste: trocar YAML muda comportamento sem rebuild |
| E2 | Reescrita do dataset v3 (mínimo/ASK/RECUSA) + eval rotulado | números antes/depois na suíte |
| E3 | OpenCL `liboclchain` + 12 kernels `.cl` + seleção VK>CL>CPU | bit-exato 3 backends |
| E4 | Modelo ≤400M ctx-1024 treinado no ciclo §5.3 | ≥95% precisão de intenção no eval |
| E5 | CLI do agente no contrato §2 (executa→fala pouco→pergunta) | demo: tarefa real ponta a ponta |

Bloqueio conhecido: **N24** (upstream Kof4j) trava as suítes ws no JVM; o plano
roda por native/OpenCL enquanto isso.
