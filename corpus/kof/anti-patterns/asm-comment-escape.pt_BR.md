---
id: kof-anti-patterns-asm-comment-escape-pt
title: Anti-pattern: asm-comment-escape (COMENTARIOS em asm-textblocks)
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,asm-comment-escape
status: stable
tags: kof,anti-patterns,pt
---
[English](kof/anti-patterns/asm-comment-escape.md) | [Português](kof/anti-patterns/asm-comment-escape.pt_BR.md)

# Anti-pattern: asm-comment-escape (COMENTARIOS em asm-textblocks)

## O que é

Os runtimes de geração asm (`NativeRuntime*.java`, `NativeWebRuntime.java`
etc.) usam Java text blocks (`"""..."""`) com strings `asm` inline. Nessas
cadeias quaisquer caracteres (incluindo `\r`, tabs, aspas, non-ASCII) são
preservados ao gerar o arquivo `.s`. O assembler GNU (`as`) é estrito — um
`\r` num comentário *não-em*`.asciz` quebra a linha e se torna "junk at end
of line".

## Sintomas

- **`Main.s:NNNNF: Error: junk at end of line, first unrecognized character
  is `:'`/`(`**／ ou `invalid character (0xa) in mnemonic`
- **Componente quebra logo após edição de comentário**

## Regras para comentários em asm dentro de text blocks Java

1. **Apenas ASCII básico** (sem ç/á/é — veja bytes 0x80+ no `.s`)
2. **Nunca `\r\n` ou `\n` literal** em comment. Mesmo que o `"""` Java
   interprete, o `\r` fica no arquivo `.s` e quebra
3. Se precisar documentar caractere especial, escreva `CRLF` ou `LF` em
   ASCII puro, não o caractere literal

## Exemplo ruim

```java
        sb.append("""
            movq %rax, %rbx
            # achou \r\n\r\n: body em rsi+4     <-- quebra o assembler
            call handle_body
        """);
```

## Exemplo bom

```java
        sb.append("""
            movq %rax, %rbx
            # achou CRLF CRLF; body em rsi+4
            call handle_body
        """);
```

## Ferramenta de detecção rápida

Antes de commit, compile o asm e busque por linhas com CR sem escape:

```bash
grep -a $'\r' out/Default/Main.s | grep -v 'asciz\|\.quad\|\.long\|\.byte'
```

Se aparecer, ro is an asm-comment escape bug.

## Variante: dupla interpretação em STRINGS emitidas (`\n` vs `\\n`)

A mesma família atinge **strings de código**, não só comentários: um text
block que EMITE uma linha asm contendo `\n` literal para o `as` interpretar
(p.ex. mensagem com newline em `.asciz`) precisa escrever `\\n` no Java — o
primeiro `\` escapa o segundo no text block, e o `.s` recebe `\n` de verdade.
Escrever só `\n` faz o Java comer o escape e o `as` receber a linha quebra
(no histórico: `§107-x86` deslocou a região crítica e a montagem falhou em
código non-mine; ver known-bugs §138). Convenção viva usada em
`RuntimeMemory.java`, `RuntimeObservability3.java`, `RuntimeValidation.java`.

## Referência

- Discovered em 03/09 durante WEB002 T2/T3/Т4 (KofWebNativeE2ETest).
- Variante de string documentada a partir da lição da Fase 1 do plano de
  independência Spring (registro em `docs/development/DECISIONS.md`).
- Relacionado: `fake-idioms.md` (o que NÃO existe em Kof); o comentário em
  asm essencialmente **prejudica a build**, não a semântica Kof.
