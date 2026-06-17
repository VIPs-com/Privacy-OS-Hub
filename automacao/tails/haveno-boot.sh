#!/bin/bash
###############################################################################
# haveno-boot.sh — ritual Playbook §7 (cada sessao apos passos 1–4)
#
# O QUE FAZ: preflight -> install.sh -> exec.sh -> onion-grater
# NAO FAZ: download/reinstall do .deb (use haveno-auto.sh na 1a vez)
#
# USO: ~/Persistent/haveno-boot.sh
#      ~/Persistent/haveno-boot.sh --watch 8
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"

WATCH_MIN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --watch) shift; [[ "${1:-}" =~ ^[0-9]+$ ]] && WATCH_MIN="$1" ;;
    --one-password) export HAVENO_ONE_PASSWORD=1 ;;  # digitar a senha admin 1x (ver haveno-common.sh)
    *) [[ "$1" =~ ^[0-9]+$ ]] && WATCH_MIN="$1" ;;
  esac
  shift
done

# Modo "uma senha so" (opt-in). No-op sem --one-password ou se um pai ja ativou.
sudo_one_password_start

echo
b "==============================================================="
b "  haveno-boot.sh — abrir Haveno nesta sessao (Playbook §7)"
b "==============================================================="
echo

b "[1/3] Preflight..."
tails_preflight_check || die "Preflight falhou."

b "[2/3] Conferindo instalacao..."
haveno_check_installed || die "Haveno nao instalado. Rode: ~/Persistent/haveno-setup.sh (1a vez) ou haveno-auto.sh"
g "  Haveno instalado em ${HAVENO_DIR}."

b "[3/3] Boot da sessao (install.sh + exec.sh)..."
haveno_session_boot

if [ "$WATCH_MIN" -gt 0 ]; then
  b "Monitorando log por ${WATCH_MIN} min..."
  deadline=$(( $(date +%s) + WATCH_MIN * 60 ))
  while [ "$(date +%s)" -lt "$deadline" ]; do
    line="$(haveno_check_filter | grep -E 'loaded filter|AUTHCHALLENGE' | tail -1)"
    [ -n "$line" ] && echo "  log> $line"
    sleep 15
  done
fi

echo
g "==============================================================="
g "  Boot concluido. CONFIRME o indicador VERDE na janela do Haveno."
g "  Amarelo 5–20 min na 1a vez e normal."
g "==============================================================="
