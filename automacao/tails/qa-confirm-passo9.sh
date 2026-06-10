#!/bin/bash
###############################################################################
# qa-confirm-passo9.sh — passo 9: ritual das 2 copias fisicas da seed
#
# Tails pode estar ONLINE (Tor). Nao exige segundo boot offline no Minimo M2.
# USO: ~/Persistent/qa-confirm-passo9.sh
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"

export HAVENO_QA_LOG=1
qa_log_init "09-seed-confirmacao"

echo
b "Passo 9 — confirmacao das 2 copias fisicas da seed (passo 4)"
echo

_confirm() {
  local key="$1"
  local prompt="$2"
  printf "%s (s/N): " "$prompt"
  read -r ans
  case "${ans:-N}" in s|S|sim|SIM)
    qa_log_confirm "$key" "SIM"
    g "  ${key}=SIM"
    ;;
  *)
    qa_log_confirm "$key" "NAO"
    r "  ${key}=NAO"
    return 1
    ;;
  esac
}

ok=0
qa_log_line "REDE: tails_online_tor_esperado=SIM"
_confirm "duas_copias_fisicas_separadas" "Existem 2 copias da seed em locais fisicos separados" && ok=$((ok+1)) || true
_confirm "nenhuma_copia_digital_seed" "Nenhuma copia digital da seed (foto, nuvem, chat)" && ok=$((ok+1)) || true
_confirm "seed_nunca_transmitida_rede" "Seed nunca foi enviada por rede" && ok=$((ok+1)) || true

if [ "$ok" -eq 3 ]; then
  qa_log_finish 0
  g "Passo 9 registrado: $QA_LOG_FILE"
  y "Opcional: qa-export-logs.sh --usb para entregar a equipe QA"
  exit 0
fi

qa_log_finish 1
r "Passo 9 incompleto."
exit 1
