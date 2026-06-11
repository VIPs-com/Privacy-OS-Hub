#!/bin/bash
###############################################################################
# sync-hub-scripts.sh — copia scripts atualizados do repo para ~/Persistent/
#
# USO (no Tails, apos extrair ZIP ou git pull):
#   cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
#   ./sync-hub-scripts.sh
#
# Copia *.sh desta pasta + haveno-common.sh (obrigatorio para deps apt).
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PERSIST="/home/amnesia/Persistent"
# Os scripts vao para UMA pasta propria (nao bagunçar a raiz da Persistent):
DEST="${1:-${PERSIST}/hub-scripts}"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
die(){ echo -e "\033[0;31mERRO: $*\033[0m"; exit 1; }

[ -d "$PERSIST" ] || die "Persistencia inexistente: $PERSIST (crie-a primeiro)."
mkdir -p "$DEST" || die "Nao criei ${DEST}."

b "Copiando scripts de ${SCRIPT_DIR}/ -> ${DEST}/"
cp -v "${SCRIPT_DIR}"/*.sh "$DEST/"
# Filtro onion-grater corrigido (PoW 1.6.0) — sem ele o Haveno cai com 'Command filtered'
[ -f "${SCRIPT_DIR}/haveno-onion-grater.yml" ] && cp -v "${SCRIPT_DIR}/haveno-onion-grater.yml" "$DEST/"
[ -f "${SCRIPT_DIR}/haveno-backup.desktop" ] && cp -v "${SCRIPT_DIR}/haveno-backup.desktop" "$DEST/"
chmod +x "${DEST}"/*.sh

# Limpeza opcional: scripts antigos soltos na raiz da Persistent (layout antigo)
ANTIGOS=$(ls "${PERSIST}"/haveno-*.sh "${PERSIST}"/feather-*.sh "${PERSIST}"/qa-*.sh \
  "${PERSIST}"/tails-preflight.sh "${PERSIST}"/post-session-check.sh \
  "${PERSIST}"/sync-hub-scripts.sh "${PERSIST}"/haveno-onion-grater.yml 2>/dev/null | wc -l)
if [ "$ANTIGOS" -gt 0 ]; then
  y "Encontrei ${ANTIGOS} script(s) do layout antigo soltos em ${PERSIST}/ (raiz)."
  read -rp "Apagar os antigos da raiz? (s/n) " RESP
  if [ "$RESP" = "s" ]; then
    rm -f "${PERSIST}"/haveno-*.sh "${PERSIST}"/feather-*.sh "${PERSIST}"/qa-confirm-*.sh \
      "${PERSIST}"/qa-export-logs.sh "${PERSIST}"/tails-preflight.sh \
      "${PERSIST}"/post-session-check.sh "${PERSIST}"/sync-hub-scripts.sh \
      "${PERSIST}"/haveno-onion-grater.yml "${PERSIST}"/haveno-backup.desktop
    g "Raiz limpa. (Dados em haveno/, Backups/, feather/, qa-logs/ intocados.)"
  fi
fi

g "Pronto. Scripts em: ${DEST}/"
g "Rode: ${DEST}/haveno-setup.sh --boot   (ou --install-only p/ recuperacao)"
