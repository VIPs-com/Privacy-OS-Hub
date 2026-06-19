#!/bin/bash
###############################################################################
# 01-setup-dirs.sh — Cria as pastas do Haveno na persistência. E MAIS NADA.
#
# FAZ:    mkdir de ~/Persistent/haveno/{Install,Data,App/utils}
# NAO FAZ: download, chave, instalação.
# OK SE:  imprimir PASS com as 3 pastas listadas.
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

[ -d "$PERSIST" ] || fail "Persistência não encontrada ($PERSIST). Ative o armazenamento persistente e reinicie."

mkdir -p "$INSTALL_DIR" "$DATA_DIR" "$UTILS_DIR" || fail "Não consegui criar as pastas em $HAVENO_DIR"

ls -ld "$INSTALL_DIR" "$DATA_DIR" "$UTILS_DIR"
pass "Pastas prontas. Próximo: ./02-download-deb.sh (ou ./03-rescue-tmp.sh se o .deb já foi baixado antes)"
