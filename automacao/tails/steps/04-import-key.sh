#!/bin/bash
###############################################################################
# 04-import-key.sh — Importa a chave PGP da Reto e confere o fingerprint.
#
# FAZ:    baixa reto_public.asc pelo Tor, importa no GPG e compara o
#         fingerprint com a constante do curso (lib/config.sh).
# NAO FAZ: verificar o .deb (isso é o 05).
# OK SE:  PASS + fingerprint idêntico ao do curso. CONFIRA COM SEUS OLHOS.
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

if gpg --list-keys "$HAVENO_PGP_FPR" >/dev/null 2>&1; then
  y "Chave já estava no chaveiro."
else
  y "Baixando a chave pública da Reto pelo Tor..."
  TMPKEY="$(mktemp)"
  curl -fsSL --socks5-hostname "$TOR_SOCKS" --max-time 120 -o "$TMPKEY" "$RETO_KEY_URL" \
    || fail "Não baixei a chave ($RETO_KEY_URL). Tor ok? URL mudou?"
  gpg --import "$TMPKEY" || { rm -f "$TMPKEY"; fail "gpg --import falhou."; }
  rm -f "$TMPKEY"
fi

gpg --list-keys "$HAVENO_PGP_FPR" >/dev/null 2>&1 \
  || fail "A chave importada NÃO tem o fingerprint do curso. PARE e registre divergência (possível chave trocada)."

echo
y "CONFIRA COM SEUS OLHOS (deve ser idêntico ao README do curso):"
gpg --fingerprint "$HAVENO_PGP_FPR" | sed 's/^/  /'
echo
y "Esperado: DAA2 4D87 8B8D 36C9 0120  A897 CA02 DAC1 2DAE 2D0F"
pass "Chave da Reto no chaveiro com o fingerprint do curso. Próximo: ./05-verify-sig.sh"
