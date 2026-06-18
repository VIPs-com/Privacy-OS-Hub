#!/bin/bash
###############################################################################
# 02-baixar-deb.sh — Baixa o .deb + .sig DIRETO para a persistencia, pelo Tor.
#
# FAZ:    download com PORCENTAGEM na tela e RETOMADA (se cair, rode de novo:
#         continua de onde parou). Salva em ~/Persistent/haveno/Install/
#         — nada vai para /tmp.
# NAO FAZ: verificar assinatura (isso e o 05), instalar (isso e o 07).
# OK SE:  imprimir PASS com o tamanho final do .deb.
# DEMORA: 30-90 min pelo Tor. Pode fechar a tampa nao — deixe o terminal aberto.
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

DEB="${INSTALL_DIR}/${DEB_NAME}"
SIG="${DEB}.sig"
[ -d "$INSTALL_DIR" ] || fail "Pasta Install/ nao existe — rode ./01-pastas.sh primeiro."

# --- Tor respondendo? ---------------------------------------------------------
y "Conferindo Tor..."
curl -s --socks5-hostname "$TOR_SOCKS" --max-time 30 https://check.torproject.org/api/ip 2>/dev/null \
  | grep -q '"IsTor":true' \
  || fail "Tor nao respondeu. Conecte pelo assistente 'Conexao a rede Tor' e rode de novo."
g "Tor OK."

# --- Tamanho esperado (para validar e mostrar % correta) ----------------------
EXPECTED="$(curl -sIL --socks5-hostname "$TOR_SOCKS" --max-time 60 "$HAVENO_DEB_URL" 2>/dev/null \
  | tr -d '\r' | grep -i '^content-length:' | tail -1 | awk '{print $2}')"
if [ -n "${EXPECTED:-}" ]; then
  y "Tamanho esperado do .deb: $EXPECTED bytes (~$((EXPECTED / 1048576)) MiB)."
else
  y "Nao consegui ler o tamanho esperado (segue mesmo assim)."
fi

# --- .sig (pequeno, rapido) ----------------------------------------------------
y "Baixando a assinatura (.sig)..."
curl -fsSL --socks5-hostname "$TOR_SOCKS" --max-time 120 -o "$SIG" "$HAVENO_SIG_URL" \
  || fail "Nao baixei o .sig ($HAVENO_SIG_URL). Confira a URL do release em _config.sh."
sz="$(stat -c%s "$SIG" 2>/dev/null || echo 0)"
[ "${sz:-0}" -ge 400 ] \
  || fail "Assinatura .sig suspeita (${sz} bytes) — lixo GitHub/rede. Apague ${SIG} e rode de novo."
head -1 "$SIG" 2>/dev/null | grep -q 'BEGIN PGP SIGNATURE' \
  || fail "Arquivo .sig nao parece PGP valido. Apague ${SIG} e rode de novo."
g ".sig OK (${sz} bytes)."

# --- .deb: pular se completo, retomar se parcial, baixar se nao existe --------
NOW=0; [ -f "$DEB" ] && NOW="$(stat -c%s "$DEB")"
if [ -n "${EXPECTED:-}" ] && [ "$NOW" = "$EXPECTED" ]; then
  pass ".deb ja completo em ${DEB} (${NOW} bytes). Proximo: ./04-importar-chave.sh"
fi
if [ "$NOW" -gt 0 ]; then
  y "Arquivo parcial encontrado (${NOW} bytes) — RETOMANDO download..."
else
  y "Baixando o .deb pelo Tor (barra de porcentagem abaixo)..."
fi
curl -fL -C - --socks5-hostname "$TOR_SOCKS" --progress-bar -o "$DEB" "$HAVENO_DEB_URL" \
  || fail "Download interrompido. Rode ./02-baixar-deb.sh de novo — ele CONTINUA de onde parou."

# --- Conferir tamanho ----------------------------------------------------------
NOW="$(stat -c%s "$DEB")"
if [ -n "${EXPECTED:-}" ] && [ "$NOW" != "$EXPECTED" ]; then
  fail "Tamanho diferente do esperado ($NOW de $EXPECTED bytes). Rode de novo para completar."
fi
[ "$NOW" -gt 100000000 ] || fail "Arquivo suspeito de incompleto (so $NOW bytes). Rode de novo."

ls -lh "$DEB" "$SIG"
pass ".deb completo na persistencia. Proximo: ./04-importar-chave.sh"
