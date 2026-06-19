#!/bin/bash
###############################################################################
# sync-hub-scripts.sh — copia scripts atualizados do repo para ~/Persistent/
#
# USO (no Tails, após extrair ZIP ou git pull):
#   cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
#   ./sync-hub-scripts.sh
#
# Copia para DEST (padrão: ~/Persistent/hub-scripts/):
#   *.sh raiz  +  lib/  +  haveno/  +  feather/  +  system/  +  qa/
#   +  steps/  +  hub-aliases/ → aliases/
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PERSIST="/home/amnesia/Persistent"
DEST="${1:-${PERSIST}/hub-scripts}"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
die(){ echo -e "\033[0;31mERRO: $*\033[0m"; exit 1; }

[ -d "$PERSIST" ] || die "Persistência inexistente: $PERSIST (crie-a primeiro)."
mkdir -p "$DEST" || die "Não criei ${DEST}."

# ---- Scripts raiz (hub.sh, sync-hub-scripts.sh, haveno-backup.desktop) ---
b "Copiando scripts raiz de ${SCRIPT_DIR}/ -> ${DEST}/"
cp -v "${SCRIPT_DIR}"/*.sh "$DEST/"
[ -f "${SCRIPT_DIR}/haveno-backup.desktop" ] && cp -v "${SCRIPT_DIR}/haveno-backup.desktop" "$DEST/"
chmod +x "${DEST}"/*.sh

# ---- lib/ (config.sh + common.sh + onion-grater.yml) -----------------------
if [ -d "${SCRIPT_DIR}/lib" ]; then
  mkdir -p "${DEST}/lib"
  cp -v "${SCRIPT_DIR}/lib"/*.sh "${DEST}/lib/"
  [ -f "${SCRIPT_DIR}/lib/onion-grater.yml" ] && cp -v "${SCRIPT_DIR}/lib/onion-grater.yml" "${DEST}/lib/"
  chmod 644 "${DEST}/lib/config.sh" 2>/dev/null || true
  chmod 644 "${DEST}/lib/common.sh" 2>/dev/null || true
  g "lib/ → ${DEST}/lib/"
fi

# ---- haveno/ feather/ system/ qa/ (fluxos por produto) ---------------------
for sub in haveno feather system qa; do
  if [ -d "${SCRIPT_DIR}/${sub}" ]; then
    mkdir -p "${DEST}/${sub}"
    cp -v "${SCRIPT_DIR}/${sub}"/*.sh "${DEST}/${sub}/"
    chmod +x "${DEST}/${sub}"/*.sh
    g "${sub}/ → ${DEST}/${sub}/"
  fi
done

# ---- steps/ (fallback atômico) ----------------------------------------------
if [ -d "${SCRIPT_DIR}/steps" ]; then
  mkdir -p "${DEST}/steps"
  cp -v "${SCRIPT_DIR}/steps"/*.sh "${DEST}/steps/"
  cp -v "${SCRIPT_DIR}/steps/README.md" "${DEST}/steps/" 2>/dev/null || true
  chmod +x "${DEST}/steps"/*.sh
  g "steps/ → ${DEST}/steps/  (use SÓ se hub.sh falhar)"
fi

# ---- hub-aliases/ → aliases/ ------------------------------------------------
if [ -d "${SCRIPT_DIR}/hub-aliases" ]; then
  mkdir -p "${DEST}/aliases"
  cp -v "${SCRIPT_DIR}/hub-aliases"/*.sh "${DEST}/aliases/"
  chmod +x "${DEST}/aliases"/*.sh
  g "aliases/ → ${DEST}/aliases/"
fi

# ---- Limpeza opcional: scripts soltos do layout antigo em ~/Persistent/ -----
ANTIGOS=$(ls "${PERSIST}"/haveno-*.sh "${PERSIST}"/feather-*.sh "${PERSIST}"/qa-*.sh \
  "${PERSIST}"/tails-preflight.sh "${PERSIST}"/post-session-check.sh \
  "${PERSIST}"/health-check.sh "${PERSIST}"/sync-hub-scripts.sh \
  "${PERSIST}"/hub.sh 2>/dev/null | wc -l)
if [ "$ANTIGOS" -gt 0 ]; then
  y "Encontrei ${ANTIGOS} script(s) do layout antigo soltos em ${PERSIST}/ (raiz)."
  read -rp "Apagar os antigos da raiz? (s/n) " RESP
  if [ "$RESP" = "s" ]; then
    rm -f "${PERSIST}"/haveno-*.sh "${PERSIST}"/feather-*.sh "${PERSIST}"/qa-confirm-*.sh \
      "${PERSIST}"/qa-export-logs.sh "${PERSIST}"/tails-preflight.sh \
      "${PERSIST}"/post-session-check.sh "${PERSIST}"/health-check.sh \
      "${PERSIST}"/sync-hub-scripts.sh "${PERSIST}"/hub.sh \
      "${PERSIST}"/haveno-onion-grater.yml "${PERSIST}"/haveno-backup.desktop 2>/dev/null || true
    g "Raiz limpa. (Dados em haveno/, Backups/, feather/, qa-logs/ intocados.)"
  fi
fi

echo
g "Pronto. Scripts em: ${DEST}/"
g "Rode: ${DEST}/hub.sh install   (1ª vez)"
g "      ${DEST}/hub.sh boot      (cada sessão)"
g "Se hub.sh falhar: ${DEST}/steps/run-all.sh"
