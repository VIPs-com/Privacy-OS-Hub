#!/bin/bash
###############################################################################
# 04-importar-chave.sh — Importa a chave PGP da Reto e confere o fingerprint.
#
# FAZ:    baixa reto_public.asc pelo Tor, importa no GPG e compara o
#         fingerprint com a constante do curso (_config.sh).
# NAO FAZ: verificar o .deb (isso e o 05).
# OK SE:  PASS + fingerprint identico ao do curso. CONFIRA COM SEUS OLHOS.
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

# Ja esta no chaveiro?
if gpg --list-keys "$HAVENO_PGP_FPR" >/dev/null 2>&1; then
  y "Chave ja estava no chaveiro."
else
  y "Baixando a chave publica da Reto pelo Tor..."
  TMPKEY="$(mktemp)"
  curl -fsSL --socks5-hostname "$TOR_SOCKS" --max-time 120 -o "$TMPKEY" "$RETO_KEY_URL" \
    || fail "Nao baixei a chave ($RETO_KEY_URL). Tor ok? URL mudou?"
  gpg --import "$TMPKEY" || { rm -f "$TMPKEY"; fail "gpg --import falhou."; }
  rm -f "$TMPKEY"
fi

# Conferencia do fingerprint contra a constante do curso.
gpg --list-keys "$HAVENO_PGP_FPR" >/dev/null 2>&1 \
  || fail "A chave importada NAO tem o fingerprint do curso. PARE e registre divergencia (possivel chave trocada)."

echo
y "CONFIRA COM SEUS OLHOS (deve ser identico ao README do curso):"
gpg --fingerprint "$HAVENO_PGP_FPR" | sed 's/^/  /'
echo
y "Esperado: DAA2 4D87 8B8D 36C9 0120  A897 CA02 DAC1 2DAE 2D0F"
pass "Chave da Reto no chaveiro com o fingerprint do curso. Proximo: ./05-verificar-assinatura.sh"
