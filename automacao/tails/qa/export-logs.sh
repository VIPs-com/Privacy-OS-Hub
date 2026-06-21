#!/bin/bash
###############################################################################
# qa/export-logs.sh — copia ~/Persistent/qa-logs/ para pendrive transitório
#
# USO:
#   hub.sh qa export-logs --usb
#   hub.sh qa export-logs --dest /media/amnesia/MEU-PENDRIVE
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

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
    case "$n" in
      ''|*[!0-9]*) die "Número inválido: $n" ;;
    esac
    [ "$n" -ge 1 ] && [ "$n" -le "${#VOLS[@]}" ] || die "Número fora do range: $n"
    DEST="${VOLS[$((n-1))]}/logs-tails"
  fi
fi

[ -n "$DEST" ] || die "Use --usb ou --dest /caminho"

mkdir -p "$DEST" || die "Nao consegui criar $DEST"
cp -v "$SRC"/*.txt "$DEST/" 2>/dev/null || die "Nenhum .txt em $SRC"

sync
g "Exportado para: $DEST"
g "Ejetar com seguranca antes de remover o pendrive."
y "Para enviar ao suporte: compacte a pasta logs-tails/ e envie pelo canal indicado."
