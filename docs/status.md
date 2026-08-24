# Status do Projeto Kof Agent

> **Fonte única de verdade sobre o estado atual.** Atualizar este arquivo ao
> final de TODA etapa/milestone (obrigação registrada em
> [CONTRIBUTING.md](CONTRIBUTING.md) §6). Em conflito entre documentos,
> vence: implementação → testes → este arquivo → demais docs.

**Última atualização:** 24 de agosto de 2026
**Milestone corrente:** M1 — Core Runtime (não iniciada)
**Milestones concluídas:** M0 — Fundação ✅

---

## Snapshot

| Item | Estado |
|------|--------|
| Repositório | `github.com/KofLang/kof-agent` · branch `main` · sincronizado |
| Histórico | `75cc779 first commit` → `5c0f56b docs(m0): fundação` |
| Código | **nenhum ainda** (por definição da M0) |
| Linguagem / target | Kof · Native (ELF x86-64) primário (D0001) |
| Próxima ação | specs `specs/SCHEDULER.md`, `specs/EVENT_BUS.md`, `specs/LIFECYCLE.md`, `specs/CLI.md` |

---

## M0 — Fundação ✅ (concluída em 24/08/2026)

Entregue:

- Documentação de engenharia completa: SPEC (RF-1..RF-13), ARCHITECTURE,
  MODULES (27 módulos, dependências só para baixo), ROADMAP M0–M12 com DoD,
  TASKS, CONTRIBUTING (Regra Zero + template de report), CODE_STYLE,
  DECISIONS (D0001–D0012 + Q1–Q4), RISKS (R01–R10), BENCHMARK_PLAN,
  TEST_PLAN.
- Árvore completa de diretórios com README por pasta.
- README raiz no estilo do ecossistema Kof; LICENSE GPLv3; .gitignore.
- REPORT_M00.md no template oficial.
- Publicação no GitHub (`main` tracking `origin/main`).

Verificação rápida do estado dos documentos:

| Documento | Estado |
|-----------|--------|
| docs/SPEC.md | ✅ aceito |
| docs/ARCHITECTURE.md | ✅ aceito |
| docs/MODULES.md | ✅ aceito |
| docs/ROADMAP.md | ✅ aceito |
| docs/TASKS.md | ✅ M0 fechada; backlog M1 rascunhado |
| docs/CONTRIBUTING.md | ✅ obrigatório desde já |
| docs/CODE_STYLE.md | ✅ vale a partir da primeira linha de Kof (M1) |
| docs/DECISIONS.md | ✅ 12 decisões; 4 questões em aberto |
| docs/RISKS.md | ✅ 10 riscos vivos |
| docs/BENCHMARK_PLAN.md | ✅ gates por milestone definidos |
| docs/TEST_PLAN.md | ✅ gates por milestone definidos |

## Testes & Benchmarks

Nenhum executado — sem código na fundação. Gates começam na M1
(init < 100 ms, dispatch do event bus) conforme TEST_PLAN/BENCHMARK_PLAN.

## Questões em aberto (bloqueiam decisões futuras, não o início da M1)

- **Q1** mecanismo Compiler Gateway: subprocess vs residente vs API embutida — decidir antes da M2 com benchmark das vias.
- **Q2** FP no Native (FLT001 do compilador Kof): estratégia SIMD/HAL para o runtime AI — revisar antes da M10 (spike cedo).
- **Q3** Map/Set ausentes na linguagem: padrão atual = `List<record>` + busca linear.
- **Q4** formato binário dos índices vetoriais — spec antes da M6.

## Riscos no radar (top 3)

1. **R01** FLT001 pode limitar performance nativa do runtime AI → spike técnico cedo; HAL isolada.
2. **R05** corpus defasado → checksum/versionamento obrigatórios desde a M5.
3. **R09** ambiguidade do Brain PT-BR → intents tipadas; ambiguidade vira pergunta.

## Pendências conhecidas

- Nenhuma pêndencia técnica de código (nada foi implementado ainda).
- Specs individuais por interface começam na M1.

## Próximos passos imediatos (M1)

1. Escrever as 4 specs (Scheduler, Event Bus, Lifecycle, CLI) — Regra Zero.
2. Implementar scheduler cooperativo + thread pool + event bus tipado em
   Kof compilando para Native.
3. Logger (`KOF_AGENT_LOG_LEVEL`) e Config (arquivo > env > default) no
   espírito kof.log/kof.config.
4. CLI mínima (`version`, `help`, `status`) com exit codes determinísticos
   e `--json`.
5. Benchmarks init/dispatch + primeiro baseline `benchmarks/baselines/native-M01.json`.
6. Fechar com REPORT_M01.md e **atualizar este status.md**.

---

## Histórico resumido

| Data | Evento |
|------|--------|
| 2026-08-24 | M0 concluída; repo publicado em `main`; status.md criado |
