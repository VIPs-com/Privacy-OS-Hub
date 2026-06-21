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
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
UPDATE="${HUB_SCRIPTS_DIR}/haveno/update.sh"
BACKUP="${HUB_SCRIPTS_DIR}/haveno/backup.sh"
[ -x "$UPDATE" ] || UPDATE="${SCRIPT_DIR}/update.sh"
[ -x "$BACKUP" ] || BACKUP="${SCRIPT_DIR}/backup.sh"

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

# ---- Guarda cruzada URL↔PGP contra fingerprint configurado em config.sh -----
_url_reto=0; _pgp_reto=0
echo "$URL" | grep -q "retoaccess1/haveno-reto" && _url_reto=1
[ "$PGP" = "${HAVENO_PGP_FPR:-}" ] && _pgp_reto=1

if [ "$_url_reto" = "1" ] && [ "$_pgp_reto" = "0" ]; then
  r "CRITICO: a URL e da rede RetoSwap mas o PGP fornecido NAO e o fingerprint RetoSwap."
  r "  RetoSwap (config.sh): ${HAVENO_PGP_FPR:-N/A}"
  r "  PGP informado:        ${PGP}"
  y "  Se voce verificou essa chave manualmente (nova release com TOFU), confirme."
  printf "  Digite CONFIRMO para prosseguir mesmo assim: "
  read -r _chk
  [ "${_chk:-}" = "CONFIRMO" ] || die "Abortado. Verifique URL e PGP — mesma rede, mesmo release."
elif [ "$_url_reto" = "0" ] && [ "$_pgp_reto" = "1" ]; then
  r "AVISO: a URL nao e da rede RetoSwap mas o PGP e o fingerprint RetoSwap."
  r "  Confirme que URL e PGP sao da MESMA rede antes de prosseguir."
  printf "  Continuar mesmo assim? (s/N): "
  read -r _chk2
  case "${_chk2:-N}" in s|S|sim|SIM) ;; *) die "Abortado."; esac
fi

echo
b "haveno-switch-network.sh — trocar rede (backup + reinstall)"
y "Feche trades abertos no Haveno antes."
y "NUNCA misture URL de uma rede com PGP de outra."
printf "Continuar? (s/N): "
read -r ans
case "${ans:-N}" in s|S|sim|SIM) ;; *) die "Cancelado."; esac

if [ -d "${DATA_DIR:-}" ] && [ -n "$(ls -A "$DATA_DIR" 2>/dev/null)" ]; then
  [ -x "$BACKUP" ] && "$BACKUP" || die "haveno/backup.sh nao encontrado — rode hub.sh backup manualmente."
else
  y "  Data/ vazia ou ausente (Haveno ainda nao instalado?) — pulando backup antes da troca de rede."
fi
exec "$UPDATE" --url "$URL" --pgp "$PGP"
