#!/bin/bash
###############################################################################
# post-session-check.sh — pos-upgrade Tails (Tor + onion-grater + lembrete backup)
# USO: ~/Persistent/post-session-check.sh
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"

echo
b "post-session-check.sh — checagem pos-upgrade Tails"
echo

tails_preflight_check || exit 1

if haveno_check_installed; then
  g "Haveno instalado."
  haveno_fix_onion_grater || true
else
  y "Haveno ainda nao instalado — rode haveno-setup.sh"
fi

y "Lembrete: backup com ~/Persistent/haveno-backup.sh"
y "Tails SO: use Tails Upgrader (NAO script nao oficial)."
