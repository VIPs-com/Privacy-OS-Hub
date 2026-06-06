#!/bin/bash
###############################################################################
# haveno-setup.sh — orquestrador fino (um comando apos passos 1–4 manuais)
#
# USO:
#   ~/Persistent/haveno-setup.sh              # 1a vez: preflight -> auto -> backup?
#   ~/Persistent/haveno-setup.sh --boot       # sessao: preflight -> boot
#   ~/Persistent/haveno-setup.sh --feather    # + feather-install-verify.sh
#   ~/Persistent/haveno-setup.sh --skip-backup
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PERSIST="/home/amnesia/Persistent"

MODE="install"
DO_FEATHER=0
SKIP_BACKUP=0

while [ $# -gt 0 ]; do
  case "$1" in
    --boot) MODE="boot" ;;
    --feather) DO_FEATHER=1 ;;
    --skip-backup) SKIP_BACKUP=1 ;;
    *) echo "Opcao desconhecida: $1"; exit 1 ;;
  esac
  shift
done

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
die(){ r "ERRO: $*"; exit 1; }

run() {
  b ">>> $*"
  "$@" || die "Falhou: $*"
}

echo
b "==============================================================="
b "  haveno-setup.sh — orquestrador Tails OS Expert"
b "==============================================================="
echo

PREFLIGHT="${PERSIST}/tails-preflight.sh"
AUTO="${PERSIST}/haveno-auto.sh"
BOOT="${PERSIST}/haveno-boot.sh"
BACKUP="${PERSIST}/haveno-backup.sh"
FEATHER="${PERSIST}/feather-install-verify.sh"

# Fallback: scripts na mesma pasta do repo (antes de copiar p/ Persistent)
[ -x "$PREFLIGHT" ] || PREFLIGHT="${SCRIPT_DIR}/tails-preflight.sh"
[ -x "$AUTO" ] || AUTO="${SCRIPT_DIR}/haveno-auto.sh"
[ -x "$BOOT" ] || BOOT="${SCRIPT_DIR}/haveno-boot.sh"
[ -x "$BACKUP" ] || BACKUP="${SCRIPT_DIR}/haveno-backup.sh"
[ -x "$FEATHER" ] || FEATHER="${SCRIPT_DIR}/feather-install-verify.sh"

run "$PREFLIGHT"

if [ "$MODE" = "boot" ]; then
  run "$BOOT" --watch 8
else
  run "$AUTO"
  if [ "$SKIP_BACKUP" = "0" ]; then
    echo
    y "Recomendado: backup cifrado antes do 1o deposito."
    printf "Rodar haveno-backup.sh agora? (s/N): "
    read -r ans
    case "${ans:-N}" in s|S|sim|SIM)
      [ -x "$BACKUP" ] && run "$BACKUP" || y "haveno-backup.sh nao encontrado — rode depois manualmente."
      ;;
    *) y "Pulando backup. Rode: ~/Persistent/haveno-backup.sh" ;;
    esac
  fi
fi

if [ "$DO_FEATHER" = "1" ]; then
  [ -x "$FEATHER" ] && run "$FEATHER" || die "feather-install-verify.sh nao encontrado."
fi

echo
g "haveno-setup.sh concluido."
g "Proxima sessao: ~/Persistent/haveno-setup.sh --boot"
