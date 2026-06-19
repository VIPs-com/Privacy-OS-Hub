#!/bin/bash
###############################################################################
# 05-verify-sig.sh — Verifica a assinatura PGP do .deb (fail-closed).
#
# FAZ:    gpg --verify usando --status-fd, a "linguagem de máquina" do gpg.
#         Funciona em QUALQUER idioma do sistema (em PT-BR o gpg escreve
#         "Assinatura válida"; em inglês "Good signature" — scripts que
#         procuram o texto quebram; este não).
# NAO FAZ: instalar (isso é o 07).
# OK SE:  PASS + "VALIDSIG amarrado ao fingerprint do curso".
# NOTA:   o aviso do gpg "não está certificada com uma assinatura confiável"
#         é NORMAL (modelo TOFU) — o que vale é o fingerprint conferido no 04.
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

DEB="${INSTALL_DIR}/${DEB_NAME}"
SIG="${DEB}.sig"
[ -f "$DEB" ] || fail "Sem .deb em ${INSTALL_DIR}/ — rode ./02-download-deb.sh (ou ./03-rescue-tmp.sh)."
[ -f "$SIG" ] || fail "Sem .sig em ${INSTALL_DIR}/ — rode ./02-download-deb.sh (baixa o .sig em segundos)."
gpg --list-keys "$HAVENO_PGP_FPR" >/dev/null 2>&1 || fail "Chave da Reto não importada — rode ./04-import-key.sh."

y "Verificando assinatura (independe do idioma do sistema)..."
STATUS="$(gpg --status-fd 1 --verify "$SIG" "$DEB" 2>/dev/null)"

if echo "$STATUS" | grep -q "^\[GNUPG:\] VALIDSIG .*${HAVENO_PGP_FPR}"; then
  g "Assinatura VÁLIDA, amarrada à chave primária ${HAVENO_PGP_FPR}."
  y "(Em PT-BR o gpg escreve 'Assinatura válida' = 'Good signature'. Aviso TOFU é normal.)"
  pass ".deb autêntico. Próximo: ./06-check-deps.sh"
fi

r "A assinatura NÃO validou contra o fingerprint do curso."
y "Saída humana do gpg para diagnóstico:"
gpg --verify "$SIG" "$DEB" 2>&1 | sed 's/^/  /' || true
fail "NÃO instale este .deb. Confira URL/release em lib/config.sh e registre divergência."
