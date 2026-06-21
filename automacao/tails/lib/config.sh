#!/bin/bash
###############################################################################
# lib/config.sh — ÚNICA FONTE DE VERDADE
#
# NOVO RELEASE: edite SOMENTE as 3 linhas do bloco "Release".
# Não há mais URL/PGP hardcoded em haveno-auto.sh, haveno-update.sh, etc.
###############################################################################

# ----- Release da rede (RetoSwap 1.6.0-reto) — EDITE AQUI no próximo release -
HAVENO_VERSION="1.6.0-reto"
HAVENO_PGP_FPR="DAA24D878B8D36C90120A897CA02DAC12DAE2D0F"
RETO_KEY_URL="https://retoswap.com/reto_public.asc"

# ----- Derivados do release (não editar) -------------------------------------
# TAG do GitHub: HAVENO_VERSION completo (ex: "1.6.0-reto", "v1.8.0-reto")
# Nome do arquivo: só o número, sem prefixo "v" ou sufixo de rede (ex: "1.6.0", "1.8.0")
_HAVENO_VER_NUM="${HAVENO_VERSION%-*}"   # remove sufixo "-reto": "v1.8.0-reto" → "v1.8.0"
_HAVENO_VER_NUM="${_HAVENO_VER_NUM#v}"  # remove prefixo "v" se existir: "v1.8.0" → "1.8.0"
HAVENO_DEB_URL="https://github.com/retoaccess1/haveno-reto/releases/download/${HAVENO_VERSION}/haveno-v${_HAVENO_VER_NUM}-linux-x86_64-installer.deb"
HAVENO_SIG_URL="${HAVENO_DEB_URL}.sig"
DEB_NAME="$(basename "$HAVENO_DEB_URL")"
INSTALL_SCRIPT_URL="https://github.com/haveno-dex/haveno/raw/master/scripts/install_tails/haveno-install.sh"
# MANUTENCAO: URL aponta para branch master (mutavel). A cada release upstream verificar se
# o hash mudou: curl -sL "$INSTALL_SCRIPT_URL" | sha256sum — e atualizar INSTALL_SCRIPT_HASH.
INSTALL_SCRIPT_HASH="658780708f1556a8135f2800c9182067909c5c77682bda68a98d70086779eeba"  # sha256 haveno-install.sh confirmado em campo 21/06/2026 — atualizar a cada release upstream

# ----- Caminhos no Tails (não editar) ----------------------------------------
PERSIST="/home/amnesia/Persistent"
HAVENO_DIR="${PERSIST}/haveno"
INSTALL_DIR="${HAVENO_DIR}/Install"
DATA_DIR="${HAVENO_DIR}/Data"
UTILS_DIR="${HAVENO_DIR}/App/utils"
DOTFILES_DIR="${DOTFILES_DIR:-/live/persistence/TailsData_unlocked/dotfiles}"
TOR_SOCKS="127.0.0.1:9050"
ONION_GRATER_DST="/etc/onion-grater.d/haveno.yml"
TOR_COOKIE="${TOR_COOKIE:-/var/run/tor/control.authcookie}"
