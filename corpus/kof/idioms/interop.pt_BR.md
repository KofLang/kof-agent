---
id: kof-idioms-interop-pt
title: Idiomas — Interop (tipos JVM e FFI C)
module: kof
category: kof-idioms
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,idioms,interop
status: stable
tags: kof,idioms,pt
---
[English](kof/idioms/interop.md) | [Português](kof/idioms/interop.pt_BR.md)

# Idiomas — Interop (tipos JVM e FFI C)

**Status:** parcial (whitelist) · **Introduzido:** 0.3.x (TIER 2.1) · **Atualizado:** 18/09 (R3 JVM generalizado — ABI escalar + void + retorno String; **callbacks C2 — gate da JVM ABERTO**; ver `IMPLEMENTATION-UNIVERSAL-PLATFORM.pt_BR.md` 3.6/3.4) · **Atualizado:** 17/09

## O que é

Duas superfícies, uma regra: a plataforma já existe — não a reconstrua.
**(a)** JVM: qualquer tipo Java no classpath por nome qualificado. **(b)** FFI C:
`extern "<lib>" f(T): R` prende uma função nativa (JVM via `java.lang.foreign`).

## API real (medida no compilador — 0.4.0-beta)

```kof
// (a) interop JVM — nome qualificado, sem wrapper
var now = java.time.Instant.now()
println(now.toString())

// (b) FFI C — o JVM liga QUALQUER assinatura ESCALAR (R3 generalizado 18/09):
extern "/lib/x86_64-linux-gnu/libm.so.6" cos(Double x): Double   // ok
extern "/lib/x86_64-linux-gnu/libc.so.6" atoi(String s): Int    // ok (String->Int)
extern "/lib/x86_64-linux-gnu/libm.so.6" fmod(Double a, Double b): Double  // ok — 1.5 medido
extern "/lib/x86_64-linux-gnu/libm.so.6" ldexp(Double x, Int e): Double    // ok — 12.0 medido (misto)
extern "/lib/x86_64-linux-gnu/libc.so.6" puts(String s): void     // ok — void liga
extern "/lib/x86_64-linux-gnu/libc.so.6" getenv(String n): String // ok — "mel" medido
// O NOME da funcao Kof e o simbolo C (sem alias) — kof_fmod falhou no lookup, fmod funciona.
// Tipos nao-escalares (objetos, genericos) -> FFI001 em tempo de compilacao:
// runner JS  -> MESMA ABI escalar via KofJsFfiBridge (F2/F3 ✅ 18/09; FfiE2ETest 16/16); browser -> erro honesto de runtime (R7, sem host); nao-escalar -> FFI002
// Native     -> FFI001 até o §61 (libc não inicializada)

// (c) CALLBACKS (C2 ✅ JVM + paridade JS C3 ✅, 18/09): uma função Kof entregue
// ao C como ponteiro de função. Parâmetro tipo-função + lambda no call site;
// só ABI de callback PRIMITIVA + arg `String` (síncrono, não-escapante):
extern "libcallback.so" kof_cb_add(Int a, Int b, (Int, Int) -> Int cb): Int
// call site — a lambda vira o ponteiro de função C (Linker.upcallStub):
kof_cb_add(20, 22, (x: Int, y: Int) -> x + y)   // 42 medido
kof_cb_mixed(3, 2.5, (i: Int, d: Double) -> i * d)  // ABI escalar mista ok
kof_cb_slen("hello", (x: String) -> x.length())  // char* -> arg String (C3.4)
// callback JS no host runner -> MESMA ABI (C3.2/C3.4 ✅ 18/09,
// jvmAndJsCallbacksMatchByteForByte 42/42/6.0/7.5; stringCallbackArgsBindAndMatchJvmJs 5/104/2026); browser -> degrade honesto
// em runtime (R7, sem host); struct/ponteiro-no-callback, retorno `String` e
// callback-como-retorno -> FFI001/FFI002 — nunca um stub silencioso.
```

## RUIM → BOM

| ❌ RUIM | ✅ BOM | Por quê |
|---|---|---|
| ligar um simbolo sob outro nome Kof (`kof_fmod`) | o NOME e o simbolo C (sem alias, medido 18/09) — ligar `fmod`, envolver numa fn Kof para nome amigavel | multi-arg/`void`/retorno `String` ja ligam desde R3 18/09 — NAO emita bytecode na mao para furar o compilador |
| assumir que o caminho da lib é checado em compile | trate lib/símbolo ausente como falha `kof_ffi_*` de **runtime** | o caminho resolve em runtime (`SymbolLookup`), não em compile |
| guardar o ponteiro do callback para chamar DEPOIS (atexit/signal/async) | mantenha callbacks síncronos e não-escapantes | escapantes exigem política de vida/GC-rooting (R12) — ficam `FFI001`, nunca stub pendurado |
| reimplementar sin/cos/strcmp em Kof | prenda a lib do sistema (qualquer forma escalar desde 18/09) | complexidade é da plataforma (regra de ferro 2) |

## Veja também

`docs/language-reference/syntax.md` (§FFI com C), `grammar.md`
(`extern-declaration`), `modules.md` §6; gaps `FFI001`/`FFI002`;
R3 landado: JVM escalar arbitrario (aridade/void/retorno String, 18/09) + paridade JS host (3.6.F2/F3 ✅ 18/09) + **callbacks ligam na JVM E no host runner JS, paridade byte-for-byte (C2 ✅ + C3.2/C3.3/C3.4 ✅ 18/09 — callbacks primitivos + com argumento `String`; `JvmFfiCallbackE2ETest` incl. `jvmAndJsCallbacksMatchByteForByte` e `stringCallbackArgsBindAndMatchJvmJs`)**; restantes: opaque handles (3.3), variadics (3.5, ⛔ decisao de surface), ABI struct/array (D6 ⛔), Native §61.
