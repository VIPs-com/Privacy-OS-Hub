#!/bin/bash
###############################################################################
# feather-backup.sh — backup cifrado de ~/Persistent/feather/wallets/
#
# A SEED nao entra no arquivo — anote em papel/metal.
# USO: ~/Persistent/feather-backup.sh [--usb] [--restore ARQUIVO]
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

PERSIST="/home/amnesia/Persistent"
DATA_DIR="${PERSIST}/feather/wallets"
DEFAULT_DEST="${PERSIST}/Backups"
MEDIA_DIR="/media/amnesia"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
die(){ r "ERRO: $*"; [ -n "${QA_LOG_FILE:-}" ] && qa_log_finish 1 2>/dev/null || true; exit 1; }

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
    --list) ls -lht "${DEFAULT_DEST}"/feather-*.gpg 2>/dev/null | head -10 \
              || y "Nenhum backup Feather em ${DEFAULT_DEST}/"; exit 0 ;;
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
  g "  Arquivo OK."
  y "CUIDADO: restauracao SOBRESCREVE ${DATA_DIR}/"
  if [ -d "$DATA_DIR" ]; then
    SAFETY="${PERSIST}/feather/wallets.bak-$(date +%Y%m%d-%H%M%S)"
    y "  Estado atual sera salvo em: $SAFETY"
    printf "Confirmar restauracao (sobrescreve wallets/)? (s/N): "; read -r ans
    case "${ans:-N}" in s|S|sim|SIM) ;; *) rm -rf "$TMP"; die "Cancelado."; esac
    mv "$DATA_DIR" "$SAFETY" || { rm -rf "$TMP"; die "Nao consegui salvar o estado atual."; }
  fi
  mkdir -p "$(dirname "$DATA_DIR")"
  tar -xzf "$TARFILE" -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")" || { rm -rf "$TMP"; die "Falha ao extrair."; }
  rm -rf "$TMP"
  g "Restaurado em: $DATA_DIR"
  exit 0
fi

[ -d "$DATA_DIR" ] || die "Pasta nao encontrada ($DATA_DIR). Crie carteira no Feather primeiro."

if pgrep -f "feather-.*AppImage" >/dev/null 2>&1; then
  y "ATENCAO: o Feather parece estar ABERTO."
  y "Feche-o antes de continuar para nao copiar wallets/ em uso."
  printf "Continuar mesmo assim? (s/N): "; read -r ans
  case "${ans:-N}" in s|S|sim|SIM) ;; *) die "Cancelado. Feche o Feather e rode de novo."; esac
fi

if [ "$USE_USB" = "1" ] && [ -z "$DEST" ]; then
  mapfile -t VOLS < <(find "$MEDIA_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  if [ "${#VOLS[@]}" -eq 0 ]; then
    die "Nenhum USB montado."
  elif [ "${#VOLS[@]}" -eq 1 ]; then
    DEST="${VOLS[0]}"
  else
    y "  Varios volumes encontrados:"
    i=1; for v in "${VOLS[@]}"; do echo "    [$i] $v"; i=$((i+1)); done
    printf "  Escolha o numero: "; read -r n
    case "${n:-}" in
      ''|*[!0-9]*|0) die "Escolha invalida (use 1-${#VOLS[@]})." ;;
    esac
    [ "$n" -le "${#VOLS[@]}" ] || die "Escolha invalida (use 1-${#VOLS[@]})."
    DEST="${VOLS[$((n-1))]}"
  fi
fi
[ -n "$DEST" ] || DEST="$DEFAULT_DEST"
mkdir -p "$DEST" || die "Destino invalido: $DEST"
[ -w "$DEST" ] || die "Sem permissao de escrita em: $DEST"

STAMP="$(date +%Y%m%d-%H%M%S)"
BASE="feather-wallets-${STAMP}"

if [ "$ENCRYPT" = "1" ]; then
  OUT="${DEST}/${BASE}.tar.gz.gpg"
else
  OUT="${DEST}/${BASE}.tar.gz"
fi

if [ "$ENCRYPT" = "1" ]; then
  b "Compactando e cifrando em disco (${OUT})..."
  y "  (tar | gpg direto no destino — nao usa /tmp/RAM)"
  haveno_read_backup_passphrase _bk_pass
  tar -czf - -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")" | \
    gpg --batch --yes -c --cipher-algo AES256 --passphrase-fd 3 -o "$OUT" - 3<<<"$_bk_pass" \
    || { unset _bk_pass; rm -f "$OUT"; die "Falha ao compactar/cifrar."; }
  gpg --batch --passphrase-fd 3 -d "$OUT" 3<<<"$_bk_pass" | tar -tzf - >/dev/null 2>&1 \
    || { unset _bk_pass; die "Arquivo gerado esta corrompido."; }
  unset _bk_pass
else
  r "AVISO: --no-encrypt grava wallets SEM cifrar (NAO recomendado)."
  printf "Gravar sem cifrar? Digite sim para confirmar (N): "
  read -r _noenc_ans
  case "${_noenc_ans:-N}" in sim|SIM) ;;
    *) die "Cancelado. Rode sem --no-encrypt (recomendado)." ;;
  esac
  tar -czf "$OUT" -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")" || die "Falha ao compactar."
  tar -tzf "$OUT" >/dev/null 2>&1 || die "Arquivo gerado esta corrompido."
fi
( cd "$DEST" && sha256sum "$(basename "$OUT")" > "$(basename "$OUT").sha256" ) 2>/dev/null || true
chmod 444 "$OUT" "${OUT}.sha256" 2>/dev/null || true

g "Backup: $OUT"
y "Seed em papel/metal — separada deste arquivo."
