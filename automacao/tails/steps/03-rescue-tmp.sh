#!/bin/bash
###############################################################################
# 03-rescue-tmp.sh — Resgata .deb/.sig perdidos em /tmp para a persistência.
#
# QUANDO USAR: o haveno-install.sh upstream (ou uma rodada antiga) baixou o
#   .deb numa pasta aleatória /tmp/tmp.XXXXXX e o fluxo abortou. /tmp do Tails
#   é RAM: se reiniciar, o download de 30-90 min SOME. Este script salva ele.
# FAZ:    procura haveno-*.deb e .sig em /tmp e copia para Install/.
# NAO FAZ: download, verificação, instalação.
# OK SE:  PASS listando o que copiou (ou avisando que já estava salvo).
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

[ -d "$INSTALL_DIR" ] || fail "Pasta Install/ não existe — rode ./01-setup-dirs.sh primeiro."

SAVED="$(find "$INSTALL_DIR" -maxdepth 1 -name '*.deb' -type f 2>/dev/null | head -1)"
if [ -n "$SAVED" ]; then
  pass "Já existe .deb salvo na persistência ($SAVED) — nada a resgatar. Próximo: ./04-import-key.sh"
fi

y "Procurando haveno-*.deb em /tmp (pastas temporárias de rodadas anteriores)..."
mapfile -t DEBS < <(find /tmp -maxdepth 3 -name 'haveno-*.deb' -type f 2>/dev/null)
if [ "${#DEBS[@]}" -eq 0 ]; then
  fail "Nenhum .deb em /tmp. Use ./02-download-deb.sh para baixar direto na persistência."
fi

BEST=""; BEST_SIZE=0
for f in "${DEBS[@]}"; do
  s="$(stat -c%s "$f" 2>/dev/null || echo 0)"
  echo "  encontrado: $f ($s bytes)"
  if [ "$s" -gt "$BEST_SIZE" ]; then BEST="$f"; BEST_SIZE="$s"; fi
done

cp -v "$BEST" "$INSTALL_DIR/" || fail "Cópia falhou (espaço na persistência?)."
if [ -f "${BEST}.sig" ]; then
  cp -v "${BEST}.sig" "$INSTALL_DIR/"
else
  y "Sem .sig junto do .deb — o ./02-download-deb.sh baixa só o .sig rapidinho (re-rode ele)."
fi

ls -lh "$INSTALL_DIR"
pass "Resgatado para a persistência. Próximo: ./04-import-key.sh"
