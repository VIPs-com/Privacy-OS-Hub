#!/bin/bash
# =================================================================
# AVANÇADO — use apenas se orientado pelo suporte.
# Uso normal: hub.sh install  |  hub.sh boot
# =================================================================
###############################################################################
# haveno-switch-network.sh — trocar rede Haveno (Vol II §8)
# USO: ~/Persistent/haveno-switch-network.sh --url URL_DEB --pgp FINGERPRINT
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PERSIST="/home/amnesia/Persistent"
UPDATE="${HUB_SCRIPTS_DIR}/haveno/update.sh"
BACKUP="${HUB_SCRIPTS_DIR}/haveno/backup.sh"
[ -x "$UPDATE" ] || UPDATE="${SCRIPT_DIR}/update.sh"
[ -x "$BACKUP" ] || BACKUP="${SCRIPT_DIR}/backup.sh"

b(){ echo -e "\033[1;34m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
die(){ r "ERRO: $*"; exit 1; }

URL=""
PGP=""
while [ $# -gt 0 ]; do
  case "$1" in
    --url) shift; URL="${1:-}" ;;
    --pgp) shift; PGP="${1:-}" ;;
    *) die "Opcao desconhecida: $1 (use --url URL_DO_DEB --pgp FINGERPRINT)" ;;
  esac
  shift
done

[ -n "$URL" ] && [ -n "$PGP" ] || die "Uso: $0 --url URL_DO_DEB --pgp FINGERPRINT_DA_MESMA_REDE"

echo
b "haveno-switch-network.sh — trocar rede (backup + reinstall)"
y "Feche trades abertos no Haveno antes."
y "NUNCA misture URL de uma rede com PGP de outra."
printf "Continuar? (s/N): "
read -r ans
case "${ans:-N}" in s|S|sim|SIM) ;; *) die "Cancelado."; esac

[ -x "$BACKUP" ] && "$BACKUP" || die "haveno/backup.sh nao encontrado — rode hub.sh backup manualmente."
exec "$UPDATE" --url "$URL" --pgp "$PGP"
