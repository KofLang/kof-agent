# AUDIT v0.1.0-beta (HEAD 8df415e)

## Corrigidos nesta versão (validados por repro)
N1 · N6 · N7 · N8 · N9 · N12 · SC1(SEM020) · SC2(SEM021) · SC5(SEM024)

## Parciais
SC3 (falha no link String_naoExiste em vez de diagnóstico SEM)

## Persistem
N3 (argv segfault) · N4 (split segfault) · N10 (progressivo; brain 12/22,
ws parcial) · N11 (lastIndexOf) · N13

## Security (novo na beta)
PBKDF2+verify ✓ · SHA-256 ✓ · JWT create ✓ — **tudo no target Native**

## Impacto no agente
Brain saltou 0→12 testes verdes; workarounds N1/N6/N7/N8/N9/N12 podem ser
removidos incrementalmente (gate check_compat continua ativo até re-sweep).
