# N23-SUSPECT — SIGSEGV native: constructor de record/class com >= 6 args (1º stack arg)

- Commit: 0.2.6-beta (jar local, compiler main pós 727196e) · Target: native · Categoria: N (call-conv)
- Sintoma: qualquer constructor com 6+ argumentos no record/class: o 6º arg
  (1º stack arg na SysV amd64) é lido errado no call site — o receptor `this`
  e o primeiro argumento (retorno de kof_alloc/init_object) ficam pendurados
  na stack através de calls intermediários e os pops do call site consomem os
  valores errados; rdi acaba recebendo uma List em vez do objeto. Acesso a
  campo depois = SIGSEGV 139 (rip=0x1, vtable corrompida).
- Repro: regressions/N23-SUSPECT/repro.kf (record 6 campos Int, literal args,
  acesso x.f → 139). JVM passa; native crasha. R5 passa; R6/R7 crasham.
- Caminho crítico: NativeBackend emitCall — arg >= 6 empilhado depois dos
  pushes-pendurados do receptor/arg1; callee lê 16(%rbp)/24(%rbp) deslocado.
- Esperado: args de stack lidos na ordem certa (arg6..argN em 16(rbp)..).
- Status: FIXED — fix no NativeBackend (Kof4j commit 2b09aa1): cleanup dos stack args apos o call do ctor (addq $(stackArgs*8), %rsp); R3-R7 + repro verdes, 16/16 suites.
