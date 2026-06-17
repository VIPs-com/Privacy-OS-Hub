#!/bin/bash
###############################################################################
# 05-verificar-assinatura.sh — Verifica a assinatura PGP do .deb (fail-closed).
#
# FAZ:    gpg --verify usando --status-fd, a "linguagem de maquina" do gpg.
#         Funciona em QUALQUER idioma do sistema (em PT-BR o gpg escreve
#         "Assinatura valida"; em ingles "Good signature" — scripts que
#         procuram o texto quebram; este nao).
# NAO FAZ: instalar (isso e o 07).
# OK SE:  PASS + "VALIDSIG amarrado ao fingerprint do curso".
# NOTA:   o aviso do gpg "nao esta certificada com uma assinatura confiavel"
#         e NORMAL (modelo TOFU) — o que vale e o fingerprint conferido no 04.
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

DEB="${INSTALL_DIR}/${DEB_NAME}"
SIG="${DEB}.sig"
[ -f "$DEB" ] || fail "Sem .deb em ${INSTALL_DIR}/ — rode ./02-baixar-deb.sh (ou ./03-resgatar-tmp.sh)."
[ -f "$SIG" ] || fail "Sem .sig em ${INSTALL_DIR}/ — rode ./02-baixar-deb.sh (baixa o .sig em segundos)."
gpg --list-keys "$HAVENO_PGP_FPR" >/dev/null 2>&1 || fail "Chave da Reto nao importada — rode ./04-importar-chave.sh."

y "Verificando assinatura (independe do idioma do sistema)..."
STATUS="$(gpg --status-fd 1 --verify "$SIG" "$DEB" 2>/dev/null)"

# VALIDSIG: ultimo campo = fingerprint da chave PRIMARIA (a assinatura pode vir
# de uma subchave — por isso nao se compara o primeiro campo).
if echo "$STATUS" | awk -v fpr="$HAVENO_PGP_FPR" \
     '$1=="[GNUPG:]" && $2=="VALIDSIG" && $NF==fpr {ok=1} END {exit !ok}'; then
  g "Assinatura VALIDA, amarrada a chave primaria ${HAVENO_PGP_FPR}."
  y "(Em PT-BR o gpg escreve 'Assinatura valida' = 'Good signature'. Aviso TOFU e normal.)"
  pass ".deb autentico. Proximo: ./06-deps-apt.sh"
fi

r "A assinatura NAO validou contra o fingerprint do curso."
y "Saida humana do gpg para diagnostico:"
gpg --verify "$SIG" "$DEB" 2>&1 | sed 's/^/  /' || true
fail "NAO instale este .deb. Confira URL/release em _config.sh e registre divergencia."
