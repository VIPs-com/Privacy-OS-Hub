#!/bin/bash
###############################################################################
# 07-install-deb.sh — Instala o .deb JÁ VERIFICADO (e só isso).
#
# FAZ:    limpa estado quebrado de tentativa anterior (dpkg half-configured /
#         config-files) e roda dpkg -i no .deb da persistência.
# USO:    ./07-install-deb.sh
#         ./07-install-deb.sh --force-depends   (só se o 06 mandou; ignora as
#                                                libs que não existem no Tails)
# NAO FAZ: download, verificação (rode 05 ANTES — este script não instala nada
#         que você não tenha verificado), abrir o app (isso é o 08).
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
[ -f "$SIG" ] || fail "Sem .sig em ${INSTALL_DIR}/ — rode ./05-verify-sig.sh ANTES de instalar."

ST="$(dpkg-query -W -f='${Status}' haveno 2>/dev/null || true)"
case "$ST" in
  "install ok installed")
    pass "haveno JÁ está instalado. Próximo: ./08-open-haveno.sh" ;;
  *config-files*)
    y "Sobra de tentativa anterior (config-files) — limpando..."
    sudo dpkg --purge haveno || fail "Não limpei o estado anterior." ;;
  *half-configured*|*half-installed*|*unpacked*)
    y "haveno incompleto de tentativa anterior — removendo para reinstalar..."
    sudo dpkg --remove --force-remove-reinstreq haveno 2>/dev/null \
      || sudo dpkg --purge haveno 2>/dev/null \
      || fail "Não limpei o estado anterior." ;;
esac

if [ "$FORCE" = "1" ]; then
  y "Instalando com --force-depends (libs de mídia podem faltar; o app embute o runtime)..."
  y "Se o Haveno NÃO abrir no passo 08: sudo dpkg -r haveno, e reporte à equipe."
  sudo dpkg -i --force-depends "$DEB"
  RC=$?
else
  y "Instalando (sem forçar nada)..."
  sudo dpkg -i "$DEB"
  RC=$?
fi

if [ "$RC" -ne 0 ]; then
  sudo dpkg --remove --force-remove-reinstreq haveno 2>/dev/null || true
  r "dpkg -i falhou (provavelmente dependências)."
  y "1) Rode ./06-check-deps.sh e leia a tabela."
  y "2) Se o 06 disser que as libs NÃO EXISTEM no Tails:"
  y "     ./07-install-deb.sh --force-depends"
  y "NÃO rode 'apt-get install -f' (remove o haveno)."
  fail "Instalação não concluída."
fi

ST="$(dpkg-query -W -f='${Status}' haveno 2>/dev/null || true)"
[ "$ST" = "install ok installed" ] || fail "Status dpkg inesperado: '$ST'. Copie esta tela para a equipe."
pass "haveno instalado (dpkg: $ST). Próximo: ./08-open-haveno.sh"
