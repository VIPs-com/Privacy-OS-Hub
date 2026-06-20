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
INSTALL_SCRIPT_HASH=""  # sha256 do haveno-install.sh — vazio=só loga; preenchido=verifica fail-closed (atualizar a cada release)

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
