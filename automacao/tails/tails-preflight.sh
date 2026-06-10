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

while [ $# -gt 0 ]; do
  case "$1" in
    --qa-log) export HAVENO_QA_LOG=1 ;;
    *) y "Opcao desconhecida: $1 (ignorada)" ;;
  esac
  shift
done

qa_log_tee_begin "01-preflight"

echo
b "==============================================================="
b "  tails-preflight.sh — checagem passos 1–4 (Tails + Tor + admin)"
b "==============================================================="
echo

if tails_preflight_check; then
  echo
  g "Preflight OK — pode rodar haveno-setup.sh, haveno-auto.sh ou feather-install-verify.sh"
  qa_log_line "REDE: tails_online_tor_esperado=SIM"
  qa_log_finish 0
  exit 0
fi
echo
r "Corrija os itens acima antes de continuar."
qa_log_finish 1
exit 1
