#!/bin/bash
###############################################################################
# 02-download-deb.sh — Baixa o .deb + .sig DIRETO para a persistência, pelo Tor.
#
# FAZ:    download com PORCENTAGEM na tela e RETOMADA (se cair, rode de novo:
#         continua de onde parou). Salva em ~/Persistent/haveno/Install/
#         — nada vai para /tmp.
# NAO FAZ: verificar assinatura (isso e o 05), instalar (isso e o 07).
# OK SE:  imprimir PASS com o tamanho final do .deb.
# DEMORA: 30-90 min pelo Tor. Deixe o terminal aberto.
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

DEB="${INSTALL_DIR}/${DEB_NAME}"
SIG="${DEB}.sig"
[ -d "$INSTALL_DIR" ] || fail "Pasta Install/ não existe — rode ./01-setup-dirs.sh primeiro."

y "Conferindo Tor..."
curl -s --socks5-hostname "$TOR_SOCKS" --max-time 30 https://check.torproject.org/api/ip 2>/dev/null \
  | grep -q '"IsTor":true' \
  || fail "Tor não respondeu. Conecte pelo assistente 'Conexão à rede Tor' e rode de novo."
g "Tor OK."

EXPECTED="$(curl -sIL --socks5-hostname "$TOR_SOCKS" --max-time 90 "$HAVENO_DEB_URL" 2>/dev/null \
  | tr -d '\r' | grep -i '^content-length:' | tail -1 | awk '{print $2}')"
if [ -n "${EXPECTED:-}" ]; then
  y "Tamanho esperado do .deb: $EXPECTED bytes (~$((EXPECTED / 1048576)) MiB)."
else
  y "Não consegui ler o tamanho esperado via Tor (timeout) — segue sem validar tamanho."
fi

y "Baixando a assinatura (.sig)..."
curl -fsSL --socks5-hostname "$TOR_SOCKS" --max-time 120 -o "$SIG" "$HAVENO_SIG_URL" \
  || fail "Não baixei o .sig ($HAVENO_SIG_URL). Confira a URL do release em lib/config.sh."
sz="$(stat -c%s "$SIG" 2>/dev/null || echo 0)"
[ "${sz:-0}" -ge 60 ] \
  || fail "Assinatura .sig muito pequena (${sz} bytes) — truncada. Apague ${SIG} e rode de novo."
# Aceita binário OpenPGP (0x88/0x89/0xC2 — Ed25519 ~119 B) OU ASCII-armored.
b1="$(od -A n -t x1 -N 1 "$SIG" 2>/dev/null | tr -d ' \n')"
case "$b1" in
  88|89|c2) ;; # binário OpenPGP válido
  *) head -c 27 "$SIG" 2>/dev/null | grep -q 'BEGIN PGP SIGNATURE' \
       || fail "Arquivo .sig não é PGP (binário nem armored). Apague ${SIG} e rode de novo." ;;
esac
g ".sig OK (${sz} bytes)."

NOW=0; [ -f "$DEB" ] && NOW="$(stat -c%s "$DEB")"
if [ -n "${EXPECTED:-}" ] && [ "$NOW" = "$EXPECTED" ]; then
  pass ".deb já completo em ${DEB} (${NOW} bytes). Próximo: ./04-import-key.sh"
fi
if [ "$NOW" -gt 0 ]; then
  y "Arquivo parcial encontrado (${NOW} bytes) — RETOMANDO download..."
else
  y "Baixando o .deb pelo Tor (barra de porcentagem abaixo)..."
fi
curl -fL -C - --socks5-hostname "$TOR_SOCKS" --progress-bar -o "$DEB" "$HAVENO_DEB_URL" \
  || fail "Download interrompido. Rode ./02-download-deb.sh de novo — ele CONTINUA de onde parou."

NOW="$(stat -c%s "$DEB")"
if [ -n "${EXPECTED:-}" ] && [ "$NOW" != "$EXPECTED" ]; then
  fail "Tamanho diferente do esperado ($NOW de $EXPECTED bytes). Rode de novo para completar."
fi
[ "$NOW" -gt 100000000 ] || fail "Arquivo suspeito de incompleto (só $NOW bytes). Rode de novo."

ls -lh "$DEB" "$SIG"
pass ".deb completo na persistência. Próximo: ./04-import-key.sh"
