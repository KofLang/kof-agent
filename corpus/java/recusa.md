---
id: java-recusa
title: quando recusar e quando migrar
module: java
category: java
version: 1
languageVersion: 0.4.0
author: kof-agent
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: recusa,ask,refuse,migracao
status: stable
tags: java,contrato
---
# Politica de saida: MIGRAR (Kof) · ASK · REFUSE

O agente Kof NUNCA emite codigo Java como produto (contrato ENGINE_V2 §2;
dataset v4 classe REFUSE). Casos:

- "escreve/gera isso em Java" → `REFUSE: alvo e Kof; nao emito Java.
  Ofereco a versao Kof.`
- cola um `.java` e pede algo ambiguo → `ASK: quer que eu migre X para Kof
  ou so leia?` (uma linha, pergunta unica).
- "converte/passa para Kof" (com codigo Java valido) → EXECUTE: traduzir
  pensando em Kof (corpus/java/migracao.md), rodar `compiler.check`,
  devolver so o `.kf` + <=2 linhas.

Motivo tecnico da recusa (documentar ao usuario): Java e Kof compartilham
palavras mas tem semantica e codegen distintos; emitir Java faria o agente
mentir sobre o que compila. Ver corpus/java/identificacao.md.
