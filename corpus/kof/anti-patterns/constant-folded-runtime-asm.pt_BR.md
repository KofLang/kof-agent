---
id: kof-anti-patterns-constant-folded-runtime-asm-pt
title: Constante de runtime: concatenação literal `static final String` é DOBRADA no call-site
module: kof
category: kof-anti-patterns
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,anti-patterns,constant-folded-runtime-asm
status: stable
tags: kof,anti-patterns,pt
---
[English](kof/anti-patterns/constant-folded-runtime-asm.md) | [Português](kof/anti-patterns/constant-folded-runtime-asm.pt_BR.md)

# Constante de runtime: concatenação literal `static final String` é DOBRADA no call-site

## Problem

Uma `static final String` inicializada com **concatenação de literais de
String** (constantes JLS 15.28) é tratada pelo javac como **variável-constante**:
o valor final é embutido no *constant pool* de **cada classe que a referencia**
em tempo de compilação. Quando o valor muda (você edita uma das peças), só
quem recompilar vê o valor novo — o resto do build carrega o **valor velho
in-line**, e `mvn compile -o` incremental não recompila quem não mudou.

Resultado clássico neste repo (12/09, dia do G-0 do GC cross): a lane GC edita
`NativeRiscvAsmRt0.RISCV_RUNTIME_ASM_0` (novo header de bloco 32B no
`kof_alloc`), recompila incremental, roda a suíte →
`NativeRiscvRuntimeSliceRegistryTest` falha com
"concatenação reflexiva na ordem derivada deve ser byte-idêntica ao runtime de
produção". **Split-brain FALSO**: `RiscvSlices` lê as peças por *reflection*
(valor fresco) enquanto o LHS do teste lê `NativeRiscvAsm.RISCV_RUNTIME_ASM`
(getstatic num `.class` com bytes **dobrados na compilação anterior**). O teste
estava certo; o build é que era uma loteria.

## Bad

```java
// NativoRuntime.java
static final String RUNTIME_ASM =
        Part0.RUNTIME_ASM_0 + Part1.RUNTIME_ASM_1;   // ❌ variável-constante
```

Quem usa (`RuntimeArchEmitter`, testes, `RiscvSlices`) embute os bytes no
próprio `.class`. Editar `Part0.java` + `mvn -o compile` incremental →
`Part0.class` novo, emissor/teste **velhos**, e nenhum erro até a suíte
acusa divergência. (A `RISCV_RUNTIME_ASM_B` já tinha o mesmo remédio no repo —
"constante string too long" forçava StringBuilder — mas a justificativa da
64KB **escondeu** a razão estrutural, e as 3 constantes irmãs ficaram
dobráveis.)

## Preferred

```java
// NativoRuntime.java — mesmo bytes, resolvido no <clinit> a cada JVM
static final String RUNTIME_ASM = runtimeAsm();
private static String runtimeAsm() {
    return new StringBuilder()
            .append(Part0.RUNTIME_ASM_0)
            .append(Part1.RUNTIME_ASM_1)
            .toString();
}
```

`StringBuilder.append` não é expressão-constante → o campo **deixa de ser**
variável-constante → o valor é calculado no `<clinit>` na JVM de teste; toda
leitura (`getstatic`) vê o valor **do build atual**.

## Why

- O problema é **distribuição do valor entre .class files**, não o valor.
  Concatenação literal move bytes para N constant pools; método/`<clinit>`
  mantém os bytes só nos `.class` das peças.
- `static final String` derivada de `String.format`, `+` de variáveis, ou
  método **já não** é constante — o padrão vale só para concatenação pura de
  literais/constantes, que é exatamente o formato deste runtime fatiado.
- `RiscvSlices` (e qualquer oracle que derive ordem das peças **do fonte do
  agregador** via regex) continua funcionando: ele só precisa da **ordem e dos
  nomes** `NativeRiscvAsmXxx.CONST` no fonte — chamadas de método
  (`runtimeRt()` com `.append(...)` nas linhas seguintes) preservam ambos.

## Checklist

- [ ] A constante é **literal pura concatenada**? → método-`<clinit>`.
- [ ] Há oracle comparando por reflection/parse (fresco) vs `getstatic`
      (dobrado)? → **todas** as constantes do agregador precisam do padrão,
      nunca só a que bateu no erro dos 64KB.
- [ ] Ao reportar "produção diverge da peça": **recompile full primeiro**
      (`mvn test-compile` limpo) antes de culpar o autor do commit alheio.
