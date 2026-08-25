# Kof Agent

> **Uma linguagem. Um compilador. Vários mundos. Uma inteligência.**

**Kof Agent** é o componente oficial de inteligência do ecossistema Kof: um
agente de programação escrito **em Kof**, compilado primariamente para
**binário nativo**, que planeja, edita, compila, testa e repara código usando
exclusivamente as ferramentas oficiais da linguagem — nunca inventando regras.

O agente não adivinha a linguagem. O compilador é a fonte da verdade.

---

# O que é

```
Kof Editor / CLI
        │  Editor Protocol (JSON-RPC sobre stdio)
        ▼
   Kof Agent Core ──── sessões · lifecycle · event bus · scheduler
        │
        ├── Brain       texto em português → Intents tipadas
        ├── Planner     Intent → plano (nunca código direto)
        ├── Executor    plano → patches → compile → repair loop
        │
        ├── Tool API          filesystem · compiler · search · patch · diff ...
        ├── Workspace         índice de arquivos, símbolos e targets
        ├── Compiler Gateway  AST · símbolos · diagnostics · IR (via compilador)
        ├── Corpus Engine     conhecimento oficial versionado
        ├── Retrieval Engine  RAG local (sem banco externo)
        └── Runtime AI        GGUF · sampler · KV cache → Compute HAL
                                ├─ Vulkan · Metal · DirectML · CUDA · ROCm
                                └─ CPU SIMD fallback
```

O usuário escreve o objetivo ("faz um site", "arruma esse erro"). O agente
produz um **plano**, mostra o **diff**, executa, compila pelo compilador Kof,
recebe **diagnostics**, consulta o corpus e corrige até verde. Ações
destrutivas nunca acontecem silenciosamente: sempre plano, diff e rollback.

---

# Filosofias herdadas do Kof

| Princípio | Consequência no agente |
|-----------|------------------------|
| Intenção acima da implementação | o usuário descreve *o quê*; planner/executor decidem *o como* |
| O compilador é a fonte da verdade | nenhuma regra da linguagem é reimplementada; tudo via Compiler Gateway |
| Menos cerimônia | APIs pequenas, zero configuração obrigatória |
| Backend agnostic | a mesma arquitetura serve JVM, Native e JS |
| Ferramentas fazem parte da plataforma | AST, diagnostics, type system, IR e workspace são Tool API oficial |
| Sem magia silenciosa | limitações viram diagnósticos explícitos — nunca comportamento escondido |

---

# Estado

Projeto em fase de fundação (**Milestone 0** — documentação de engenharia).

| Milestone | Nome | Status |
|-----------|------|--------|
| M0 | Fundação (docs + árvore) | ✅ |
| M1 | Core Runtime | ✅ |
| M2 | Compiler Gateway | 🟡 (ponte ativa; execução in-language aguarda upstream) |
| M3 | Workspace Intelligence | 🟡 (N10 upstream bloqueia 21/37 testes) |
| M4 | Tool API | 🟡 (N10) |
| M5 | Corpus Engine | ⬜ |
| M6 | Retrieval Engine | ⬜ |
| M7 | Kof Brain | ⬜ |
| M8 | Planner | ⬜ |
| M9 | Executor + Repair Loop | ⬜ |
| M10 | Runtime AI | ⬜ |
| M11 | GPU Universal | ⬜ |
| M12 | Dataset + Futuro SLM | ⬜ |

Regra: uma milestone por vez. Documentação antes de implementação.
Cada milestone gera testes, benchmarks e `REPORT_MXX.md`.

---

# Estrutura

```
apps/ cli/ editor/ agent/ brain/ planner/ executor/ runtime/
compiler/ workspace/ tools/ protocol/ memory/ retrieval/
embeddings/ tokenizer/ scheduler/ gpu/ cpu/ backends/
corpus/ datasets/ tests/ benchmarks/ docs/ specs/ scripts/
```

Cada pasta tem um `README.md` com sua responsabilidade. O mapa completo de
módulos, dependências permitidas e APIs previstas está em
[docs/MODULES.md](docs/MODULES.md).

---

# Documentação

| Documento | Conteúdo |
|-----------|----------|
| [docs/status.md](docs/status.md) | **estado atual do projeto (fonte única — atualizado a cada etapa)** |
| [docs/SPEC.md](docs/SPEC.md) | especificação do produto (requisitos e interfaces) |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | arquitetura oficial em camadas |
| [docs/MODULES.md](docs/MODULES.md) | mapa de módulos e dependências |
| [docs/ROADMAP.md](docs/ROADMAP.md) | milestones M0–M12 com critérios de aceite |
| [docs/TASKS.md](docs/TASKS.md) | tarefas da milestone corrente |
| [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) | processo e Regra Zero |
| [docs/CODE_STYLE.md](docs/CODE_STYLE.md) | estilo Kof obrigatório |
| [docs/DECISIONS.md](docs/DECISIONS.md) | registro de decisões arquiteturais |
| [docs/RISKS.md](docs/RISKS.md) | riscos e mitigações |
| [docs/BENCHMARK_PLAN.md](docs/BENCHMARK_PLAN.md) | plano de performance |
| [docs/TEST_PLAN.md](docs/TEST_PLAN.md) | plano de testes |

Reports por milestone: [`REPORT_M00.md`](REPORT_M00.md), ...

---

# Tecnologias

* Linguagem: **Kof**
* Target principal: **Native** (ELF x86-64)
* Todo código precisa compilar no target Native
* Sem dependência obrigatória de JVM, Node ou serviços externos
* Providers externos (Ollama/OpenAI/Gemini/Claude) são **opcionais**, atrás
  de interface única

Metas de performance: inicialização < 100 ms (**medido: ~120 µs**) · primeiro
token < 200 ms · streaming contínuo · baixo consumo de RAM/VRAM · mmap e lazy
loading · zero cópias desnecessárias.

Estado detalhado: [docs/status.md](docs/status.md).

---

# Licença

Kof Agent é software livre distribuído sob a **GNU General Public License
v3.0** — mesma licença do compilador Kof.

**Programas e datasets produzidos com o Kof Agent NÃO são automaticamente
GPLv3.** Quem usa o agente mantém o direito de escolher a licença do próprio
software. Detalhes: [LICENSE](LICENSE).
