# TASKS — Milestone corrente

**Milestone atual:** M0 — Fundação
**Última atualização:** 24 de agosto de 2026

---

## M0 — Fundação

| # | Tarefa | Status |
|---|--------|--------|
| 0.1 | Árvore completa de diretórios com README por pasta | ✅ |
| 0.2 | README.md raiz (estilo Kof) | ✅ |
| 0.3 | LICENSE GPLv3 + postura de licenciamento de outputs | ✅ |
| 0.4 | .gitignore | ✅ |
| 0.5 | docs/SPEC.md — requisitos funcionais e não funcionais | ✅ |
| 0.6 | docs/ARCHITECTURE.md — camadas, fluxos, decisões estruturais | ✅ |
| 0.7 | docs/MODULES.md — mapa de módulos e dependências | ✅ |
| 0.8 | docs/ROADMAP.md — M0–M12 com critérios de aceite | ✅ |
| 0.9 | docs/CONTRIBUTING.md — processo, Regra Zero, template de report | ✅ |
| 0.10 | docs/CODE_STYLE.md — estilo Kof obrigatório | ✅ |
| 0.11 | docs/DECISIONS.md — registro de decisões + dúvidas em aberto | ✅ |
| 0.12 | docs/RISKS.md — riscos e mitigações | ✅ |
| 0.13 | docs/BENCHMARK_PLAN.md | ✅ |
| 0.14 | docs/TEST_PLAN.md | ✅ |
| 0.15 | REPORT_M00.md no template oficial | ✅ |
| 0.16 | Repositório publicado em `main` (origin: github.com/KofLang/kof-agent) | 🟡 |

Critério de fechamento da M0: todos os itens ✅ e consistência cruzada entre
os documentos (nenhum documento contradiz outro).

## Backlog M1 — Core Runtime (rascunho; será refinado ao abrir a milestone)

| # | Tarefa |
|---|--------|
| 1.1 | Spec `specs/SCHEDULER.md` (task scheduler cooperativo + thread pool) |
| 1.2 | Spec `specs/EVENT_BUS.md` (eventos tipados, assinatura, cancelamento) |
| 1.3 | Spec `specs/LIFECYCLE.md` (init → ready → running → shutdown) |
| 1.4 | Spec `specs/CLI.md` (comandos, flags, exit codes, --json) |
| 1.5 | Logger com níveis (`KOF_AGENT_LOG_LEVEL`) — espírito kof.log |
| 1.6 | Config com precedência arquivo > env > default — espírito kof.config |
| 1.7 | DI simples por construtores (sem container, sem reflexão) |
| 1.8 | Command Router + Plugin Loader (registro estático em compile-time) |
| 1.9 | Workspace esqueleto (abrir diretório, listar `.kf`, checksums) |
| 1.10 | Benchmarks: init < 100 ms; dispatch do event bus |
| 1.11 | REPORT_M01.md |

Regra: nenhuma tarefa da M1 começa antes do fechamento oficial da M0.
