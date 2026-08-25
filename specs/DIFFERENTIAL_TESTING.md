# DIFFERENTIAL TESTING (Fase 2.5)
Cada golden roda nas DUAS rotas (native+jvm quando o programa não usa now()/secrets/process):
compara stdout byte-a-byte e exit code. Divergência classificada:
semantic/runtime/parser/codegen/jvm-only/native-only.
scripts/differential.sh <input.kf> executa as duas rotas e emite JSON {native:{out,rc}, jvm:{out,rc}, match:bool}.
