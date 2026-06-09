#!/bin/bash
###############################################################################
# qa-export-logs.sh — copia ~/Persistent/qa-logs/ para pendrive transitório
#
# USO:
#   ~/Persistent/qa-export-logs.sh --usb
#   ~/Persistent/qa-export-logs.sh --dest /media/amnesia/MEU-PENDRIVE
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"

SRC="${QA_LOG_DIR}"
DEST=""
USE_USB=0
MEDIA_DIR="/media/amnesia"

while [ $# -gt 0 ]; do
  case "$1" in
    --usb) USE_USB=1 ;;
    --dest) shift; DEST="${1:-}" ;;
    *) die "Opcao desconhecida: $1" ;;
  esac
  shift
done

[ -d "$SRC" ] || die "Pasta vazia ou ausente: $SRC (rode scripts com --qa-log primeiro)"

if [ "$USE_USB" = "1" ] && [ -z "$DEST" ]; then
  mapfile -t VOLS < <(find "$MEDIA_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  [ "${#VOLS[@]}" -gt 0 ] || die "Nenhum USB em ${MEDIA_DIR}"
  if [ "${#VOLS[@]}" -eq 1 ]; then
    DEST="${VOLS[0]}/logs-tails"
  else
    y "Volumes:"
    i=1; for v in "${VOLS[@]}"; do echo "  [$i] $v"; i=$((i+1)); done
    printf "Numero: "; read -r n
    DEST="${VOLS[$((n-1))]:-}/logs-tails"
  fi
fi

[ -n "$DEST" ] || die "Use --usb ou --dest /caminho"

mkdir -p "$DEST" || die "Nao consegui criar $DEST"
cp -v "$SRC"/*.txt "$DEST/" 2>/dev/null || die "Nenhum .txt em $SRC"

sync
g "Exportado para: $DEST"
g "Ejetar com seguranca antes de remover o pendrive."
y "No Debian: copie os logs do Tails para Privacy-OS-Hub-equipe-dev/testes/evidencias/qa-logs/"
