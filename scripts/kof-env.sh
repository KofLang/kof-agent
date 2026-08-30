# Resolvido do ambiente: KOF4J_ROOT (checkout do compilador) e KOF (binário).
# Ordem: KOF4J_ROOT explícito > KOF explícito no PATH > candidatos conhecidos.
# Sourced pelos scripts do agente; não executa nada quando chamado.
if [ -n "${KOF4J_ROOT:-}" ]; then
  :
elif [ -n "${KOF:-}" ] && [ -x "${KOF}" ]; then
  KOF4J_ROOT="$(cd "$(dirname "$KOF")/.." && pwd)"
else
  _cand=""
  for c in "$HOME/Documentos/Kof4j" "$HOME/kof/Kof4j" "/home/luna/kof/Kof4j"; do
    if [ -x "$c/bin/kof" ]; then
      _cand="$c"
      break
    fi
  done
  if [ -n "$_cand" ]; then
    KOF4J_ROOT="$_cand"
  else
    _koftool="$(command -v kof 2>/dev/null || true)"
    if [ -n "$_koftool" ]; then
      KOF4J_ROOT="$(cd "$(dirname "$_koftool")/.." && pwd)"
    else
      echo "kof-env: Kof4j checkout nao encontrado (defina KOF4J_ROOT ou KOF)" >&2
      return 1 2>/dev/null || exit 1
    fi
  fi
  unset _cand _koftool
fi
export KOF4J_ROOT
KOF="${KOF:-$KOF4J_ROOT/bin/kof}"
export KOF
