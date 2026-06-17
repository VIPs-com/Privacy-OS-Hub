#!/bin/bash
###############################################################################
# haveno-setup.sh — orquestrador fino (um comando apos passos 1–4 manuais)
#
# USO:
#   ~/Persistent/haveno-setup.sh              # 1a vez: preflight -> auto -> backup?
#   ~/Persistent/haveno-setup.sh --boot       # sessao: preflight -> boot
#   ~/Persistent/haveno-setup.sh --install-only  # retoma [7-9]: deps + install (sem download)
#   ~/Persistent/haveno-setup.sh --feather    # + feather-install-verify.sh
#   ~/Persistent/haveno-setup.sh --skip-backup
#   ~/Persistent/haveno-setup.sh --no-sync    # nao copia scripts do repo p/ Persistent
#   ~/Persistent/haveno-setup.sh --qa-log    # grava logs em ~/Persistent/qa-logs/
###############################################################################

set -uo pipefail

HUB_SETUP_DIR="$(cd "$(dirname "$0")" && pwd)"
PERSIST="/home/amnesia/Persistent"

MODE="install"
DO_FEATHER=0
SKIP_BACKUP=0
DO_SYNC=1

while [ $# -gt 0 ]; do
  case "$1" in
    --boot) MODE="boot" ;;
    --install-only) MODE="install-only" ;;
    --feather) DO_FEATHER=1 ;;
    --skip-backup) SKIP_BACKUP=1 ;;
    --no-sync) DO_SYNC=0 ;;
    --qa-log) export HAVENO_QA_LOG=1 ;;
    --one-password) export HAVENO_ONE_PASSWORD=1 ;;  # digitar a senha admin 1x no fluxo todo
    *) echo "Opcao desconhecida: $1"; exit 1 ;;
  esac
  shift
done

export HAVENO_QA_LOG="${HAVENO_QA_LOG:-0}"

TAILS_SRC=""
for d in "${HUB_SETUP_DIR}" "${PERSIST}/Privacy-OS-Hub-main/automacao/tails" "${PERSIST}"; do
  if [ -f "${d}/haveno-common.sh" ]; then
    TAILS_SRC="$d"
    break
  fi
done
[ -n "$TAILS_SRC" ] || { echo "ERRO: haveno-common.sh nao encontrado." >&2; exit 1; }

# shellcheck source=haveno-common.sh
source "${TAILS_SRC}/haveno-common.sh"

if [ "$DO_SYNC" = "1" ]; then
  hub_sync_scripts_to_persistent "$TAILS_SRC"
fi

run() {
  b ">>> $*"
  "$@" || die "Falhou: $*"
}

echo
b "==============================================================="
b "  haveno-setup.sh — orquestrador Tails OS Expert"
b "==============================================================="
echo

PREFLIGHT="$(hub_resolve_script tails-preflight.sh || echo "${HUB_SCRIPTS_DIR}/tails-preflight.sh")"
AUTO="$(hub_resolve_script haveno-auto.sh || echo "${HUB_SCRIPTS_DIR}/haveno-auto.sh")"
BOOT="$(hub_resolve_script haveno-boot.sh || echo "${HUB_SCRIPTS_DIR}/haveno-boot.sh")"
BACKUP="$(hub_resolve_script haveno-backup.sh || echo "${HUB_SCRIPTS_DIR}/haveno-backup.sh")"
FEATHER="$(hub_resolve_script feather-install-verify.sh || echo "${HUB_SCRIPTS_DIR}/feather-install-verify.sh")"

QA_ARGS=()
[ "${HAVENO_QA_LOG}" = "1" ] && QA_ARGS=(--qa-log)

# Modo "uma senha so" (opt-in): este orquestrador e o DONO — ativa 1x agora e segura
# ate o fim; os scripts-filhos (preflight/auto/boot) herdam e nao re-pedem senha.
sudo_one_password_start

run "$PREFLIGHT" "${QA_ARGS[@]}"

if [ "$MODE" = "boot" ]; then
  run "$BOOT" --watch 8 "${QA_ARGS[@]}"
elif [ "$MODE" = "install-only" ]; then
  y "  Modo --install-only: retomando instalacao (deps apt + install.sh, sem download)."
  run "$AUTO" --install-only "${QA_ARGS[@]}"
else
  AUTO_ARGS=("${QA_ARGS[@]}")
  if haveno_needs_install_only; then
    y "  Detectado: .deb em Install/ mas pacote haveno nao instalado — retomando com --install-only."
    AUTO_ARGS+=(--install-only)
  fi
  run "$AUTO" "${AUTO_ARGS[@]}"
  if [ "$SKIP_BACKUP" = "0" ] && haveno_pkg_installed_ok; then
    echo
    y "Recomendado: backup cifrado antes do 1o deposito."
    printf "Rodar haveno-backup.sh agora? (s/N): "
    read -r ans
    case "${ans:-N}" in s|S|sim|SIM)
      if [ -x "$BACKUP" ]; then
        run "$BACKUP" "${QA_ARGS[@]}"
      else
        y "haveno-backup.sh nao encontrado — rode depois manualmente."
      fi
      ;;
    *) y "Pulando backup. Rode: ~/Persistent/haveno-backup.sh" ;;
    esac
  elif [ "$SKIP_BACKUP" = "0" ]; then
    y "  Backup adiado: rode haveno-backup.sh apos o Haveno abrir e criar Data/."
  fi
fi

if [ "$DO_FEATHER" = "1" ]; then
  [ -x "$FEATHER" ] && run "$FEATHER" "${QA_ARGS[@]}" || die "feather-install-verify.sh nao encontrado."
fi

echo
g "haveno-setup.sh concluido."
if [ "$MODE" = "boot" ]; then
  g "Proxima sessao: ~/Persistent/hub-scripts/haveno-setup.sh --boot"
elif [ "$MODE" = "install-only" ]; then
  g "Se ainda nao verde: confira a janela do Haveno ou rode de novo com --install-only."
else
  g "Proxima sessao: ~/Persistent/hub-scripts/haveno-setup.sh --boot"
fi
