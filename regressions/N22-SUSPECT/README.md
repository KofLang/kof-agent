# N22 — Native SIGSEGV: GC mark-sweep sem marcação transitiva (0.2.3-beta)

## Causa raiz (confirmada por gdb no .s)
`kof_gc_try_mark` marca apenas o objeto raiz (vindo do scan de stack/BSS),
**sem marcar transitivamente os objetos apontados por seus campos**.
Ex.: `ctx.bus` aponta pro EventBus alocado; o mark marca o ctx mas nunca o bus;
o sweep coloca o bus na free-list; o próximo publishEnvelope reusa essa memória
para o EventEnvelope (mesma faixa de heap); `ctx+0x20` lê type_id errado e
chama vtable corrompida → rip=0x1 → SIGSEGV.

## Repro determinístico
- stress_events_10k (PARTs 00..25 + 98): crash consistente no publish #813
  (gdb: "SWEEP no publish-hit #812" — o sweep #2 é o que mata o bus)
- `./a.out` direto: 139; rip=0x0000000000000001, rdi=rax=0x32c (seq do envelope
  que reusou a memória)
- loop de 812 passa; 813+ crasha (sweep da iteração 812 libera o bus)
- stress_tasks_100k: exit 136 (mesma causa, scheduler)

## Fórmula
SWEEP hit #N == primeiro publish após o 4096º alloc (tick & 4095 == 0)

## Fix esperado no compilador
`kof_gc_try_mark` precisa marcar transitivamente os campos do objeto
(ou BFS/fila de marcação). Alternativa conservadora: não sweep nunca
(no-op) até a implementação completa.

## Evidência
- .s em /tmp/kof_asm_debug.s (NativeBackend.java:292 drop debug)
- vtable do EventBus correta; heap em 0x7ffff7fb5020 com type 0x1b (EventEnvelope)
  no lugar de type 30 (EventBus) no crash
