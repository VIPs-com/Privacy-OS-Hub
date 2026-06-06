#!/bin/bash
###############################################################################
# tails-preflight.sh — valida passos 1–4 antes de scripts Haveno/Feather
#
# NAO FAZ: gravar USB, criar persistencia, ativar Dotfiles (GUI Tails).
# USO: chmod +x ~/Persistent/tails-preflight.sh && ~/Persistent/tails-preflight.sh
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"

echo
b "==============================================================="
b "  tails-preflight.sh — checagem passos 1–4 (Tails + Tor + admin)"
b "==============================================================="
echo

if tails_preflight_check; then
  echo
  g "Preflight OK — pode rodar haveno-setup.sh, haveno-auto.sh ou feather-install-verify.sh"
  exit 0
fi
echo
r "Corrija os itens acima antes de continuar."
exit 1
