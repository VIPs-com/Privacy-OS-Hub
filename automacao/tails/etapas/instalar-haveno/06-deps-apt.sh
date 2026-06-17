#!/bin/bash
###############################################################################
# 06-deps-apt.sh — Confere e instala as dependencias que o .deb pede.
#
# FAZ:    le a lista "Depends" DE DENTRO do proprio .deb (nao de lista fixa),
#         confere uma a uma no apt do Tails e instala as que existirem.
#         Mostra tabela clara: instalada / instalavel / NAO EXISTE no Tails.
# NAO FAZ: 'apt-get install -f' — NUNCA (com haveno desconfigurado, ele REMOVE
#         o haveno; foi o [S/n] perigoso do piloto de 2026-06-10).
# OK SE:  PASS "todas as dependencias presentes".
# SE FALHAR: o proprio FAIL explica as opcoes (e o resultado ja serve de
#         evidencia para a divergencia DIV-20260610-02).
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

DEB="${INSTALL_DIR}/${DEB_NAME}"
[ -f "$DEB" ] || fail "Sem .deb — rode ./02-baixar-deb.sh ou ./03-resgatar-tmp.sh antes."

DEPS_RAW="$(dpkg-deb -f "$DEB" Depends 2>/dev/null)" || fail "Nao li o campo Depends do pacote."
[ -n "$DEPS_RAW" ] || pass "O .deb nao declara dependencias. Proximo: ./07-instalar-deb.sh"
y "Depends declarado no .deb:"
echo "  $DEPS_RAW"
echo

esta_instalado(){ dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"; }
existe_no_apt(){ LC_ALL=C apt-cache policy "$1" 2>/dev/null | grep -q 'Candidate: [0-9]'; }

INSTALADAS=(); INSTALAVEIS=(); FALTANDO=()
IFS=',' read -ra ITENS <<< "$DEPS_RAW"
for item in "${ITENS[@]}"; do
  # remove restricao de versao "(...)" e espacos
  item="$(echo "$item" | sed 's/([^)]*)//g')"
  # alternativas "a | b": aceita a primeira que estiver instalada ou exista no apt
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

# Instalar as que existem no apt
if [ "${#INSTALAVEIS[@]}" -gt 0 ]; then
  y "Instalando ${#INSTALAVEIS[@]} dependencia(s) via apt (update pelo Tor: 3-6 min)..."
  sudo apt-get update || y "apt-get update falhou — tentando instalar mesmo assim."
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${INSTALAVEIS[@]}" \
    || fail "apt nao instalou: ${INSTALAVEIS[*]} — copie esta tela para a equipe."
fi

if [ "${#FALTANDO[@]}" -gt 0 ]; then
  r "Dependencias que NAO EXISTEM nos repositorios deste Tails:"
  for d in "${FALTANDO[@]}"; do r "  - $d"; done
  y ""
  y "Causa conhecida (DIV-20260610-02): o .deb 1.6.0-reto foi empacotado com nomes"
  y "de bibliotecas do Ubuntu; o Tails (Debian) usa nomes/versoes diferentes."
  y ""
  y "Opcoes:"
  y "  a) ./07-instalar-deb.sh --force-depends   (instala ignorando essas libs;"
  y "     o Haveno embute o proprio runtime Java — em geral abre normalmente."
  y "     Se NAO abrir: sudo dpkg -r haveno, e reporte a equipe.)"
  y "  b) Aguardar correcao do curso/upstream (.deb com Depends compativeis)."
  y ""
  y "NAO rode 'apt-get install -f' — ele propoe REMOVER o haveno."
  fail "${#FALTANDO[@]} dependencia(s) indisponiveis. Copie ESTA TELA para capturas-erros/."
fi

pass "Todas as dependencias presentes. Proximo: ./07-instalar-deb.sh"
