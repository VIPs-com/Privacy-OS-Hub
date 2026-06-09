#!/bin/bash
###############################################################################
# post-session-check.sh — pos-upgrade Tails (Tor + onion-grater + lembrete backup)
# USO: ~/Persistent/post-session-check.sh
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"

while [ $# -gt 0 ]; do
  case "$1" in
    --qa-log) export HAVENO_QA_LOG=1 ;;
    *) y "Opcao desconhecida: $1 (ignorada)" ;;
  esac
  shift
done

qa_log_tee_begin "07-post-session"

echo
b "post-session-check.sh — checagem pos-upgrade Tails"
echo

tails_preflight_check || { qa_log_finish 1; exit 1; }

if haveno_check_installed; then
  g "Haveno instalado."
  haveno_fix_onion_grater || true
else
  y "Haveno ainda nao instalado — rode haveno-setup.sh"
fi

y "Lembrete: backup com ~/Persistent/haveno-backup.sh"
y "Tails SO: use Tails Upgrader (NAO script nao oficial)."
qa_log_line "REDE: tails_online_tor=SIM"
qa_log_finish 0
