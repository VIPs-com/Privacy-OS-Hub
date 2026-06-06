#!/bin/bash
###############################################################################
# 02-tor-hidden-service.sh — Publica o RPC do no Monero via Tor (hidden service)
#
# >>> RODE NO HOME LAB (Debian/Ubuntu), NAO no Tails. <<<
# Requer root:  sudo ./02-tor-hidden-service.sh
# Pre-requisito: o no Monero ja rodando (script 01), RPC restrito em RPC_PORT.
#
# O que faz:
#   - Instala o Tor (apt)
#   - Adiciona um HiddenService no /etc/tor/torrc apontando para o RPC local
#   - Reinicia o Tor e mostra o endereco .onion para usar na carteira
#
# Variaveis (env):
#   RPC_PORT  (padrao 18089)   -> deve casar com o no (script 01)
#   HS_DIR    (padrao /var/lib/tor/monero-rpc/)
###############################################################################
set -euo pipefail

RPC_PORT="${RPC_PORT:-18089}"
HS_DIR="${HS_DIR:-/var/lib/tor/monero-rpc/}"
TORRC="/etc/tor/torrc"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
die(){ echo -e "\033[0;31mERRO: $*\033[0m"; exit 1; }

[ "$(id -u)" -eq 0 ] || die "Rode como root: sudo $0"

b "[1/3] Instalando o Tor..."
command -v tor >/dev/null 2>&1 || { apt-get update -y && apt-get install -y tor; }
g "  Tor presente."

b "[2/3] Configurando o HiddenService no torrc..."
if grep -q "HiddenServiceDir ${HS_DIR}" "$TORRC" 2>/dev/null; then
  y "  Entrada ja existe no $TORRC (nao duplico)."
else
  {
    echo ""
    echo "## Monero RPC HiddenService (gerado por 02-tor-hidden-service.sh)"
    echo "HiddenServiceDir ${HS_DIR}"
    echo "HiddenServicePort ${RPC_PORT} 127.0.0.1:${RPC_PORT}"
  } >> "$TORRC"
  g "  Adicionado ao $TORRC."
fi

b "[3/3] Reiniciando o Tor e obtendo o endereco .onion..."
systemctl restart tor
sleep 3
HOSTFILE="${HS_DIR%/}/hostname"
for i in $(seq 1 10); do [ -f "$HOSTFILE" ] && break; sleep 1; done
[ -f "$HOSTFILE" ] || die "hostname nao gerado ainda. Veja: journalctl -u tor -e"
ONION="$(cat "$HOSTFILE")"

echo
g "================================================================"
g "  No Monero publicado via Tor."
g "  Endereco .onion:  ${ONION}"
g "  Porta:            ${RPC_PORT}"
echo
g "  Na carteira (Feather/Monero GUI no Tails):"
g "   - SOCKS proxy 127.0.0.1:9050"
g "   - No remoto: ${ONION} porta ${RPC_PORT} (marcar como confiavel)"
echo
g "  Teste (de uma maquina com Tor):"
g "   curl --socks5-hostname 127.0.0.1:9050 http://${ONION}:${RPC_PORT}/get_info"
g "================================================================"
y "Lembrete: o monerod NAO sincroniza pela Tor; o .onion serve so o RPC."
