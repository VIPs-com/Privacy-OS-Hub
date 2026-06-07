#!/bin/bash
###############################################################################
# feather-backup.sh — backup cifrado de ~/Persistent/feather/wallets/
#
# A SEED nao entra no arquivo — anote em papel/metal.
# USO: ~/Persistent/feather-backup.sh [--usb] [--restore ARQUIVO]
###############################################################################

set -uo pipefail

PERSIST="/home/amnesia/Persistent"
DATA_DIR="${PERSIST}/feather/wallets"
DEFAULT_DEST="${PERSIST}/Backups"
MEDIA_DIR="/media/amnesia"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
die(){ r "ERRO: $*"; exit 1; }

DEST=""
USE_USB=0
ENCRYPT=1
RESTORE_FILE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --usb) USE_USB=1 ;;
    --dest) shift; DEST="${1:-}" ;;
    --no-encrypt) ENCRYPT=0 ;;
    --restore) shift; RESTORE_FILE="${1:-}" ;;
    *) y "Opcao desconhecida: $1" ;;
  esac
  shift
done

echo
b "==============================================================="
b "  feather-backup.sh — backup Feather wallets (Tails)"
b "==============================================================="
echo

if [ -n "$RESTORE_FILE" ]; then
  [ -f "$RESTORE_FILE" ] || die "Arquivo nao encontrado."
  TMP="$(mktemp -d)"
  TARFILE="${TMP}/restore.tar.gz"
  case "$RESTORE_FILE" in
    *.gpg) gpg -o "$TARFILE" -d "$RESTORE_FILE" || die "Falha ao descriptografar." ;;
    *.tar.gz) cp "$RESTORE_FILE" "$TARFILE" ;;
    *) die "Formato nao reconhecido." ;;
  esac
  tar -tzf "$TARFILE" >/dev/null 2>&1 || die "Arquivo corrompido."
  [ -d "$DATA_DIR" ] && mv "$DATA_DIR" "${PERSIST}/feather/wallets.bak-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$(dirname "$DATA_DIR")"
  tar -xzf "$TARFILE" -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")" || die "Falha ao extrair."
  rm -rf "$TMP"
  g "Restaurado em: $DATA_DIR"
  exit 0
fi

[ -d "$DATA_DIR" ] || die "Pasta nao encontrada ($DATA_DIR). Crie carteira no Feather primeiro."

if [ "$USE_USB" = "1" ] && [ -z "$DEST" ]; then
  mapfile -t VOLS < <(find "$MEDIA_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  [ "${#VOLS[@]}" -gt 0 ] || die "Nenhum USB montado."
  DEST="${VOLS[0]}"
fi
[ -n "$DEST" ] || DEST="$DEFAULT_DEST"
mkdir -p "$DEST" || die "Destino invalido: $DEST"

STAMP="$(date +%Y%m%d-%H%M%S)"
BASE="feather-wallets-${STAMP}"
TMP="$(mktemp -d)"
TARFILE="${TMP}/${BASE}.tar.gz"

tar -czf "$TARFILE" -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")" || die "Falha ao compactar."
tar -tzf "$TARFILE" >/dev/null 2>&1 || die "Tar corrompido."

if [ "$ENCRYPT" = "1" ]; then
  OUT="${DEST}/${BASE}.tar.gz.gpg"
  gpg -c -o "$OUT" "$TARFILE" || die "Falha ao cifrar."
else
  OUT="${DEST}/${BASE}.tar.gz"
  cp "$TARFILE" "$OUT"
fi
( cd "$DEST" && sha256sum "$(basename "$OUT")" > "$(basename "$OUT").sha256" ) 2>/dev/null || true
rm -rf "$TMP"

g "Backup: $OUT"
y "Seed em papel/metal — separada deste arquivo."
