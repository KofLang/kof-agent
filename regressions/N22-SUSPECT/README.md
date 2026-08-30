# N22-SUSPECT — Native SIGSEGV com record+class via Subscription (0.2.3-beta)

## Repro
build.sh --only=00_core.kf,05_log.kf,20_scheduler.kf,25_event.kf tests/isorepro/main.kf
kof run build/tests_iso/.../main.kf --target native → exit 139 (SIGSEGV) no assemble/run,
mesmo com main() apenas imprimindo. JVM: ClassFormatError "Truncated class file".

## Bisect
- TU 484KB (6 PARTs): SIGSEGV consistente (5/5)
- TU 1.5MB (f3, sweep bdebf75): passa — não é progressivo por tamanho puro
- Gatilho: combinação core+log+sched+event; record com class contendo campo record
- Ambos targets afetados (native SIGSEGV / jvm truncated class) → suspeita de codegen compartilhado

## Evidência
sweep-bdebf75.md (stress_events_10k/stress_tasks_100k: 139/136)
