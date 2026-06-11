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
DEST="${1:-/home/amnesia/Persistent}"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
die(){ echo -e "\033[0;31mERRO: $*\033[0m"; exit 1; }

[ -d "$DEST" ] || die "Destino inexistente: $DEST (crie a Persistencia primeiro)."

b "Copiando scripts de ${SCRIPT_DIR}/ -> ${DEST}/"
cp -v "${SCRIPT_DIR}"/*.sh "$DEST/"
# Filtro onion-grater corrigido (PoW 1.6.0) — sem ele o Haveno cai com 'Command filtered'
[ -f "${SCRIPT_DIR}/haveno-onion-grater.yml" ] && cp -v "${SCRIPT_DIR}/haveno-onion-grater.yml" "$DEST/"
chmod +x "${DEST}"/*.sh
g "Pronto. Rode: ${DEST}/haveno-auto.sh --install-only"
g "  (ou ${DEST}/haveno-setup.sh se preferir o orquestrador)"
