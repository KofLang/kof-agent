#!/usr/bin/env bash
# Sessao do kof-agent em terminal. CLI native nao tem readLine (gap do
# backend), entao cada turno e um one-shot: este script faz o loop de tty.
#   bash scripts/session.sh                 (digitar no terminal)
#   bash scripts/session.sh --fifo P --log F (driver externo escreve em P)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
BIN="$ROOT/scripts/kof-agent"
FIFO="" LOG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --fifo) FIFO="$2"; shift 2 ;;
    --log)  LOG="$2"; shift 2 ;;
    *) shift ;;
  esac
done
TL="${LOG:-/dev/null}"
note() { printf '%s\n' "$*"; printf '%s\n' "$*" >> "$TL"; }
turn() {
  local line="$1" out rc
  note "kof> $line"
  case "$line" in
    "") ;;
    sair|exit|quit) note "sessao encerrada"; return 99 ;;
    status*) "$BIN" status --root . 2>&1 | tee -a "$TL" ;;
    ctx) sed 's/^/    /' workspace/context.yaml | tee -a "$TL" ;;
    ask\ *) out=$("$BIN" ask --root . "${line#ask }" 2>&1); rc=$?; note "    $out (rc=$rc)" ;;
    *) out=$("$BIN" ask --root . "$line" 2>&1); rc=$?; note "    $out (rc=$rc)" ;;
  esac
  return 0
}
note "== kof-agent $( "$BIN" version ) — sessão $(date '+%H:%M:%S') =="
note "comandos: ask <pedido> | status | ctx | sair"
if [ -n "$FIFO" ]; then
  [ -p "$FIFO" ] || mkfifo "$FIFO"
  exec 3<>"$FIFO"
  while IFS= read -r l <&3; do turn "$l" || break; done
else
  while IFS= read -r l; do turn "$l" || break; done
fi
