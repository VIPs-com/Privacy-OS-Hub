#!/bin/bash
###############################################################################
# 06-check-deps.sh — Confere e instala as dependências que o .deb pede.
#
# FAZ:    lê a lista "Depends" DE DENTRO do próprio .deb (não de lista fixa),
#         confere uma a uma no apt do Tails e instala as que existirem.
#         Mostra tabela clara: instalada / instalável / NÃO EXISTE no Tails.
# NAO FAZ: 'apt-get install -f' — NUNCA (com haveno desconfigurado, ele REMOVE
#         o haveno; foi o [S/n] perigoso do piloto de 2026-06-10).
# OK SE:  PASS "todas as dependências presentes".
# SE FALHAR: o próprio FAIL explica as opções (e o resultado já serve de
#         evidência para a divergência DIV-20260610-02).
###############################################################################
set -uo pipefail
export LC_ALL=C LANG=C LANGUAGE=C
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

DEB="${INSTALL_DIR}/${DEB_NAME}"
[ -f "$DEB" ] || fail "Sem .deb — rode ./02-download-deb.sh ou ./03-rescue-tmp.sh antes."

DEPS_RAW="$(dpkg-deb -f "$DEB" Depends 2>/dev/null)" || fail "Não li o campo Depends do pacote."
[ -n "$DEPS_RAW" ] || pass "O .deb não declara dependências. Próximo: ./07-install-deb.sh"
y "Depends declarado no .deb:"
echo "  $DEPS_RAW"
echo

esta_instalado(){ dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"; }
existe_no_apt(){ LC_ALL=C apt-cache policy "$1" 2>/dev/null | grep -q 'Candidate: [0-9]'; }

INSTALADAS=(); INSTALAVEIS=(); FALTANDO=()
IFS=',' read -ra ITENS <<< "$DEPS_RAW"
for item in "${ITENS[@]}"; do
  item="$(echo "$item" | sed 's/([^)]*)//g')"
  IFS='|' read -ra ALTS <<< "$item"
  status=""; escolhida=""
  for alt in "${ALTS[@]}"; do
    nome="$(echo "$alt" | tr -d '[:space:]')"
    [ -n "$nome" ] || continue
    if esta_instalado "$nome"; then status="instalada"; escolhida="$nome"; break; fi
  done
  if [ -z "$status" ]; then
    for alt in "${ALTS[@]}"; do
      nome="$(echo "$alt" | tr -d '[:space:]')"
      [ -n "$nome" ] || continue
      if existe_no_apt "$nome"; then status="instalavel"; escolhida="$nome"; break; fi
    done
  fi
  if [ -z "$status" ]; then
    nome="$(echo "${ALTS[0]}" | tr -d '[:space:]')"
    [ -n "$nome" ] || continue
    status="NAO-EXISTE"; escolhida="$nome"
  fi
  case "$status" in
    instalada)  INSTALADAS+=("$escolhida");  echo "  [ok]        $escolhida" ;;
    instalavel) INSTALAVEIS+=("$escolhida"); echo "  [instalar]  $escolhida" ;;
    *)          FALTANDO+=("$escolhida");    r "  [NAO EXISTE] $escolhida" ;;
  esac
done
echo

if [ "${#INSTALAVEIS[@]}" -gt 0 ]; then
  y "Instalando ${#INSTALAVEIS[@]} dependência(s) via apt (update pelo Tor: 3-6 min)..."
  _apt_ok=0
  for _tent in 1 2 3; do
    if sudo apt-get update; then _apt_ok=1; break; fi
    [ "$_tent" -lt 3 ] && { y "apt-get update falhou (tentativa ${_tent}/3) — aguardando 30s (Tor)..."; sleep 30; }
  done
  [ "$_apt_ok" = "0" ] && y "apt-get update falhou 3x — instalando do cache (pacotes podem estar desatualizados)."
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${INSTALAVEIS[@]}" \
    || fail "apt não instalou: ${INSTALAVEIS[*]} — copie esta tela para a equipe."
fi

if [ "${#FALTANDO[@]}" -gt 0 ]; then
  r "Dependências que NÃO EXISTEM nos repositórios deste Tails:"
  for d in "${FALTANDO[@]}"; do r "  - $d"; done
  y ""
  y "Causa conhecida (DIV-20260610-02): o .deb 1.6.0-reto foi empacotado com nomes"
  y "de bibliotecas do Ubuntu; o Tails (Debian) usa nomes/versões diferentes."
  y ""
  y "Opções:"
  y "  a) ./07-install-deb.sh --force-depends   (instala ignorando essas libs;"
  y "     o Haveno embute o próprio runtime Java — em geral abre normalmente."
  y "     Se NÃO abrir: sudo dpkg -r haveno, e reporte à equipe.)"
  y "  b) Aguardar correção do curso/upstream (.deb com Depends compatíveis)."
  y ""
  y "NÃO rode 'apt-get install -f' — ele propõe REMOVER o haveno."
  fail "${#FALTANDO[@]} dependência(s) indisponíveis. Copie ESTA TELA para capturas-erros/."
fi

pass "Todas as dependências presentes. Próximo: ./07-install-deb.sh"
