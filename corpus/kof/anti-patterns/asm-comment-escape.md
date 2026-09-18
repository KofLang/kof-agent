---
id: kof-anti-patterns-asm-comment-escape-en
title: Anti-pattern: asm-comment-escape (COMMENTS in asm-textblocks)
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,asm-comment-escape
status: stable
tags: kof,anti-patterns,en
---
[English](kof/anti-patterns/asm-comment-escape.md) | [Português](kof/anti-patterns/asm-comment-escape.pt_BR.md)

# Anti-pattern: asm-comment-escape (COMMENTS in asm-textblocks)

## What it is

The asm generation runtimes (`NativeRuntime*.java`, `NativeWebRuntime.java`
etc.) use Java text blocks (`"""..."""`) with inline `asm` strings. In these
strings any characters (including `\r`, tabs, quotes, non-ASCII) are
preserved when generating the `.s` file. The GNU assembler (`as`) is strict — a
`\r` in a comment *not-in* `.asciz` breaks the line and becomes "junk at end
of line".

## Symptoms

- **`Main.s:NNNNF: Error: junk at end of line, first unrecognized character
  is `:'`/`(`**／ or `invalid character (0xa) in mnemonic`
- **Component breaks right after a comment edit**

## Rules for asm comments inside Java text blocks

1. **Basic ASCII only** (no ç/á/é — see bytes 0x80+ in the `.s`)
2. **Never a literal `\r\n` or `\n`** in a comment. Even if Java's `"""`
   interprets it, the `\r` stays in the `.s` file and breaks
3. If you need to document a special character, write `CRLF` or `LF` in
   pure ASCII, not the literal character

## Bad example

```java
        sb.append("""
            movq %rax, %rbx
            # found \r\n\r\n: body at rsi+4     <-- breaks the assembler
            call handle_body
        """);
```

## Good example

```java
        sb.append("""
            movq %rax, %rbx
            # found CRLF CRLF; body at rsi+4
            call handle_body
        """);
```

## Quick detection tool

Before committing, compile the asm and look for lines with an unescaped CR:

```bash
grep -a $'\r' out/Default/Main.s | grep -v 'asciz\|\.quad\|\.long\|\.byte'
```

If it shows up, it is an asm-comment escape bug.

## Variant: double interpretation in EMITTED STRINGS (`\n` vs `\\n`)

The same family hits **code strings**, not just comments: a text
block that EMITS an asm line containing a literal `\n` for `as` to interpret
(e.g. a message with a newline in `.asciz`) must write `\\n` in Java — the
first `\` escapes the second in the text block, and the `.s` receives a real `\n`.
Writing only `\n` makes Java eat the escape and `as` receive the broken line
(historically: `§107-x86` shifted the critical region and assembly failed in
non-mine code; see known-bugs §138). Living convention used in
`RuntimeMemory.java`, `RuntimeObservability3.java`, `RuntimeValidation.java`.

## Reference

- Discovered on 09/03 during WEB002 T2/T3/Т4 (KofWebNativeE2ETest).
- String variant documented from the lesson of Phase 1 of the Spring
  independence plan (record in `docs/development/DECISIONS.md`).
- Related: `fake-idioms.md` (what does NOT exist in Kof); the asm comment
  essentially **harms the build**, not Kof semantics.
