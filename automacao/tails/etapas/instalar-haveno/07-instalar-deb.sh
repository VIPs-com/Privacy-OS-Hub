#!/bin/bash
###############################################################################
# 07-instalar-deb.sh — Instala o .deb JA VERIFICADO (e so isso).
#
# FAZ:    limpa estado quebrado de tentativa anterior (dpkg half-configured /
#         config-files) e roda dpkg -i no .deb da persistencia.
# USO:    ./07-instalar-deb.sh
#         ./07-instalar-deb.sh --force-depends   (so se o 06 mandou; ignora as
#                                                 libs que nao existem no Tails)
# NAO FAZ: download, verificacao (rode 05 ANTES — este script nao instala nada
#         que voce nao tenha verificado), abrir o app (isso e o 08).
# OK SE:  PASS + status do dpkg "install ok installed".
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

FORCE=0
[ "${1:-}" = "--force-depends" ] && FORCE=1

DEB="${INSTALL_DIR}/${DEB_NAME}"
[ -f "$DEB" ] || fail "Sem .deb em ${INSTALL_DIR}/ — rode 02 (ou 03) antes."
SIG="${DEB}.sig"
[ -f "$SIG" ] || y "AVISO: sem .sig do lado do .deb — voce rodou ./05-verificar-assinatura.sh?"

# --- Limpar estado quebrado de rodadas anteriores ------------------------------
ST="$(dpkg-query -W -f='${Status}' haveno 2>/dev/null || true)"
case "$ST" in
  "install ok installed")
    pass "haveno JA esta instalado. Proximo: ./08-abrir-haveno.sh" ;;
  *config-files*)
    y "Sobra de tentativa anterior (config-files) — limpando..."
    sudo dpkg --purge haveno || fail "Nao limpei o estado anterior." ;;
  *half-configured*|*half-installed*|*unpacked*)
    y "haveno incompleto de tentativa anterior — removendo para reinstalar..."
    sudo dpkg --remove --force-remove-reinstreq haveno 2>/dev/null \
      || sudo dpkg --purge haveno 2>/dev/null \
      || fail "Nao limpei o estado anterior." ;;
esac

# --- Instalar -------------------------------------------------------------------
if [ "$FORCE" = "1" ]; then
  y "Instalando com --force-depends (libs de midia podem faltar; o app embute o runtime)..."
  y "Se o Haveno NAO abrir no passo 08: sudo dpkg -r haveno, e reporte a equipe."
  sudo dpkg -i --force-depends "$DEB"
  RC=$?
else
  y "Instalando (sem forcar nada)..."
  sudo dpkg -i "$DEB"
  RC=$?
fi

if [ "$RC" -ne 0 ]; then
  # nao deixar meio-instalado para tras
  sudo dpkg --remove --force-remove-reinstreq haveno 2>/dev/null || true
  r "dpkg -i falhou (provavelmente dependencias)."
  y "1) Rode ./06-deps-apt.sh e leia a tabela."
  y "2) Se o 06 disser que as libs NAO EXISTEM no Tails:"
  y "     ./07-instalar-deb.sh --force-depends"
  y "NAO rode 'apt-get install -f' (remove o haveno)."
  fail "Instalacao nao concluida."
fi

# --- Conferir -------------------------------------------------------------------
ST="$(dpkg-query -W -f='${Status}' haveno 2>/dev/null || true)"
[ "$ST" = "install ok installed" ] || fail "Status dpkg inesperado: '$ST'. Copie esta tela para a equipe."
pass "haveno instalado (dpkg: $ST). Proximo: ./08-abrir-haveno.sh"
