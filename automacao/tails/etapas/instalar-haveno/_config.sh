#!/bin/bash
###############################################################################
# _config.sh — SO CONSTANTES. Nenhuma logica, nenhum comando executado.
#
# Todos os scripts desta pasta leem este arquivo (e nada mais).
# ATUALIZAR PARA NOVO RELEASE: edite SOMENTE as 3 linhas do bloco "Release".
###############################################################################

# ----- Release da rede (RetoSwap 1.6.0-reto) — EDITE AQUI no proximo release -
HAVENO_DEB_URL="https://github.com/retoaccess1/haveno-reto/releases/download/1.6.0-reto/haveno-v1.6.0-linux-x86_64-installer.deb"
HAVENO_PGP_FPR="DAA24D878B8D36C90120A897CA02DAC12DAE2D0F"
RETO_KEY_URL="https://retoswap.com/reto_public.asc"

# ----- Derivados (nao editar) ------------------------------------------------
HAVENO_SIG_URL="${HAVENO_DEB_URL}.sig"
DEB_NAME="$(basename "$HAVENO_DEB_URL")"

# ----- Caminhos no Tails (nao editar) ----------------------------------------
PERSIST="/home/amnesia/Persistent"
HAVENO_DIR="${PERSIST}/haveno"
INSTALL_DIR="${HAVENO_DIR}/Install"
DATA_DIR="${HAVENO_DIR}/Data"
UTILS_DIR="${HAVENO_DIR}/App/utils"
TOR_SOCKS="127.0.0.1:9050"
ONION_GRATER_DST="/etc/onion-grater.d/haveno.yml"
