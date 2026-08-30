#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$(dirname "$0")/kof-env.sh"
F="$1"; [ -f "$F" ] || { echo "{\"error\":\"arquivo ausente\"}"; exit 2; }
N_OUT=$("$KOF" run "$F" --target native 2>/dev/null); N_RC=$?
J_OUT=$("$KOF" run "$F" --target jvm 2>/dev/null); J_RC=$?
MATCH=false
if [ "$N_OUT" = "$J_OUT" ] && [ "$N_RC" = "$J_RC" ]; then MATCH=true; fi
python3 -c "
import json,sys
print(json.dumps({'file':sys.argv[1],'native':{'stdout':sys.argv[2],'exitcode':int(sys.argv[3])},'jvm':{'stdout':sys.argv[4],'exitcode':int(sys.argv[5])},'match':sys.argv[6]=='true'}))" \
  "$F" "$(printf '%s' "$N_OUT" | head -c 200)" "$N_RC" "$(printf '%s' "$J_OUT" | head -c 200)" "$J_RC" "$MATCH"
