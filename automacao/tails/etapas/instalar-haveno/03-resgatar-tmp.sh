#!/bin/bash
###############################################################################
# 03-resgatar-tmp.sh — Resgata .deb/.sig perdidos em /tmp para a persistencia.
#
# QUANDO USAR: o haveno-install.sh upstream (ou uma rodada antiga) baixou o
#   .deb numa pasta aleatoria /tmp/tmp.XXXXXX e o fluxo abortou. /tmp do Tails
#   e RAM: se reiniciar, o download de 30-90 min SOME. Este script salva ele.
# FAZ:    procura haveno-*.deb e .sig em /tmp e copia para Install/.
# NAO FAZ: download, verificacao, instalacao.
# OK SE:  PASS listando o que copiou (ou avisando que ja estava salvo).
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

[ -d "$INSTALL_DIR" ] || fail "Pasta Install/ nao existe — rode ./01-pastas.sh primeiro."

# Ja tem .deb salvo? Entao nao precisa resgatar nada.
SAVED="$(find "$INSTALL_DIR" -maxdepth 1 -name '*.deb' -type f 2>/dev/null | head -1)"
if [ -n "$SAVED" ]; then
  pass "Ja existe .deb salvo na persistencia ($SAVED) — nada a resgatar. Proximo: ./04-importar-chave.sh"
fi

y "Procurando haveno-*.deb em /tmp (pastas temporarias de rodadas anteriores)..."
mapfile -t DEBS < <(find /tmp -maxdepth 3 -name 'haveno-*.deb' -type f 2>/dev/null)
if [ "${#DEBS[@]}" -eq 0 ]; then
  fail "Nenhum .deb em /tmp. Use ./02-baixar-deb.sh para baixar direto na persistencia."
fi

# Pega o MAIOR (download mais completo) se houver mais de um.
BEST=""; BEST_SIZE=0
for f in "${DEBS[@]}"; do
  s="$(stat -c%s "$f" 2>/dev/null || echo 0)"
  echo "  encontrado: $f ($s bytes)"
  if [ "$s" -gt "$BEST_SIZE" ]; then BEST="$f"; BEST_SIZE="$s"; fi
done

cp -v "$BEST" "$INSTALL_DIR/" || fail "Copia falhou (espaco na persistencia?)."
# .sig do lado do .deb escolhido, se existir
if [ -f "${BEST}.sig" ]; then
  cp -v "${BEST}.sig" "$INSTALL_DIR/"
else
  y "Sem .sig junto do .deb — o ./02-baixar-deb.sh baixa so o .sig rapidinho (re-rode ele)."
fi

ls -lh "$INSTALL_DIR"
pass "Resgatado para a persistencia. Proximo: ./04-importar-chave.sh"
