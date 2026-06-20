#!/bin/bash
###############################################################################
# qa/confirm-step12.sh — passo 12 cold-signing (Tails SEM rede)
#
# Preencha DEPOIS do ritual air-gap. Nunca cole TX ID completo nem seed.
# USO: ~/Persistent/hub-scripts/qa/confirm-step12.sh
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

export HAVENO_QA_LOG=1
qa_log_init "12-cold-signing"

echo
b "Passo 12 — cold-signing trilha A (confirmacoes pos air-gap)"
echo "Preencha apos assinar offline. TX ID: so primeiros 8 chars + [BORRADO]"
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
_confirm "tails_sem_rede" "Tails estava sem Wi-Fi/cabo ao assinar" && ok=$((ok+1)) || true
qa_log_line "REDE: tails_offline_airgap=$([ "$ok" -ge 1 ] && echo SIM || echo NAO)"
_confirm "feather_abriu_offline" "Feather abriu no Tails offline" && ok=$((ok+1)) || true
_confirm "tx_assinada_offline" "Transacao assinada offline" && ok=$((ok+1)) || true
_confirm "tx_exportada_pendrive" "TX assinada exportada para pendrive transitorio" && ok=$((ok+1)) || true
_confirm "tx_transmitida_depois" "TX transmitida depois em ambiente online (Whonix/Tails)" && ok=$((ok+1)) || true

printf "Primeiros 8 caracteres do TX ID (resto omitido): "
read -r tx_prefix
if [[ "${tx_prefix:-}" =~ ^[0-9a-fA-F]{8}$ ]]; then
  qa_log_line "TX_ID_PREFIX: ${tx_prefix}[BORRADO]"
  ok=$((ok+1))
elif [ -n "${tx_prefix:-}" ]; then
  y "  AVISO: '${tx_prefix}' nao parece TX ID valido (8 caracteres hex)."
  qa_log_line "TX_ID_PREFIX: INVALIDO"
  r "  TX ID prefixo invalido"
else
  qa_log_line "TX_ID_PREFIX: AUSENTE"
  r "  TX ID prefixo ausente"
fi

if [ "$ok" -ge 6 ]; then
  qa_log_finish 0
  g "Passo 12 registrado: $QA_LOG_FILE"
  exit 0
fi

qa_log_finish 1
r "Passo 12 incompleto."
exit 1
