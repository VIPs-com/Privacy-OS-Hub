#!/bin/bash
###############################################################################
# 01-pastas.sh — Cria as pastas do Haveno na persistencia. E MAIS NADA.
#
# FAZ:    mkdir de ~/Persistent/haveno/{Install,Data,App/utils}
# NAO FAZ: download, chave, instalacao.
# OK SE:  imprimir PASS com as 3 pastas listadas.
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

[ -d "$PERSIST" ] || fail "Persistencia nao encontrada ($PERSIST). Ative o armazenamento persistente e reinicie."

mkdir -p "$INSTALL_DIR" "$DATA_DIR" "$UTILS_DIR" || fail "Nao consegui criar as pastas em $HAVENO_DIR"

ls -ld "$INSTALL_DIR" "$DATA_DIR" "$UTILS_DIR"
pass "Pastas prontas. Proximo: ./02-baixar-deb.sh (ou ./03-resgatar-tmp.sh se o .deb ja foi baixado antes)"
