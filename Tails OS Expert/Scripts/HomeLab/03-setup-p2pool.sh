#!/bin/bash
###############################################################################
# 03-setup-p2pool.sh — Mineracao descentralizada com P2Pool (servico systemd)
#
# >>> RODE NO HOME LAB (Debian/Ubuntu), NAO no Tails. <<<
# Requer root:  sudo WALLET=SEU_ENDERECO_PRIMARIO_4xxxx ./03-setup-p2pool.sh
#
# Pre-requisitos:
#   - No Monero FULL (PRUNED=0 no script 01) com ZMQ e RPC local 18081
#   - O monerod precisa das flags do P2Pool (ver NOTA abaixo)
#
# O que faz:
#   - Baixa o P2Pool (release mais recente do GitHub) e instala
#   - VERIFICA o binario contra o checksums oficial do release e ABORTA se nao conferir
#   - Cria o servico systemd 'p2pool' com a sua carteira primaria
#
# Variaveis (env):
#   WALLET            (OBRIGATORIO) endereco Monero PRIMARIO (comeca com 4)
#   MINI              (padrao 1; 1 = sidechain mini, ideal p/ PC domestico)
#   DL_URL            (opcional) URL .tar.gz do P2Pool linux-x64 (se a auto-deteccao falhar)
#   P2POOL_SHA256     (opcional) hash esperado p/ comparacao direta (use com DL_URL custom)
#   P2POOL_SIGNER_FPR (opcional) fingerprint GPG do SChernykh p/ validar sha256sums.txt.asc
###############################################################################
set -euo pipefail

WALLET="${WALLET:-}"
MINI="${MINI:-1}"
DL_URL="${DL_URL:-}"
WORKDIR="/var/lib/p2pool"
BIN_DST="/usr/local/bin"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
die(){ echo -e "\033[0;31mERRO: $*\033[0m"; exit 1; }

[ "$(id -u)" -eq 0 ] || die "Rode como root: sudo WALLET=4xxxx $0"
[ -n "$WALLET" ] || die "Defina WALLET com seu endereco PRIMARIO. Ex.: sudo WALLET=4ABC... $0"
case "$WALLET" in 4*) ;; *) die "WALLET deve ser um endereco PRIMARIO (comeca com 4). Subenderecos (8...) nao sao aceitos.";; esac
[ "${#WALLET}" -ge 90 ] || y "Aviso: o endereco parece curto demais para um endereco Monero."

b "[1/4] Verificando pre-requisitos do no..."
id monero >/dev/null 2>&1 || die "Usuario 'monero' nao existe. Rode o 01-setup-monero-node.sh primeiro (com PRUNED=0)."
y "  Lembrete: o monerod precisa estar FULL e iniciado com as flags do P2Pool:"
y "   --zmq-pub tcp://127.0.0.1:18083 --out-peers 32 --in-peers 64 \\"
y "   --add-priority-node=p2pmd.xmrvsbeast.com:18080 --add-priority-node=nodes.hashvault.pro:18080 \\"
y "   --enable-dns-blocklist --enforce-dns-checkpointing --rpc-bind-ip=127.0.0.1 --rpc-bind-port=18081"
y "  (banda de upload < 10 Mbit: use --out-peers 8 --in-peers 16)"

b "[2/4] Baixando e VERIFICANDO o P2Pool..."
command -v curl >/dev/null 2>&1 || { apt-get update -y && apt-get install -y curl tar; }
REL_JSON=""
if [ -z "$DL_URL" ] || [ -z "${P2POOL_SHA256:-}" ]; then
  REL_JSON="$(curl -fsSL https://api.github.com/repos/SChernykh/p2pool/releases/latest || true)"
fi
if [ -z "$DL_URL" ]; then
  DL_URL="$(printf '%s' "$REL_JSON" | grep -oE '"browser_download_url": *"[^"]+"' | cut -d'"' -f4 \
    | grep -iE 'linux-x64\.tar\.gz$' | head -1)"
fi
[ -n "$DL_URL" ] || die "Nao detectei a URL do P2Pool. Passe: sudo DL_URL=...linux-x64.tar.gz P2POOL_SHA256=<hash> WALLET=4xxx $0"
TMP="$(mktemp -d)"
curl -fSL "$DL_URL" -o "$TMP/p2pool.tar.gz" || { rm -rf "$TMP"; die "Falha no download do P2Pool."; }
DL_SHA="$(sha256sum "$TMP/p2pool.tar.gz" | awk '{print $1}')"
y "  SHA256 baixado: $DL_SHA"

if [ -n "${P2POOL_SHA256:-}" ]; then
  [ "$DL_SHA" = "$P2POOL_SHA256" ] && g "  OK: confere com P2POOL_SHA256 fixado." \
    || { rm -rf "$TMP"; die "Hash NAO confere com P2POOL_SHA256. Abortando."; }
else
  SUMS_URL="$(printf '%s' "$REL_JSON" | grep -oE '"browser_download_url": *"[^"]+"' | cut -d'"' -f4 \
    | grep -iE 'sha256sums(\.txt)?(\.asc)?$' | head -1)"
  { [ -n "$SUMS_URL" ] && curl -fsSL "$SUMS_URL" -o "$TMP/sums" 2>/dev/null && grep -qi "$DL_SHA" "$TMP/sums"; } \
    || { rm -rf "$TMP"; die "Hash nao confirmado no checksums oficial (release latest). Se usou DL_URL de outra versao, passe P2POOL_SHA256=<hash>. Abortando."; }
  g "  OK: hash presente no checksums oficial do release."
  if [ -n "${P2POOL_SIGNER_FPR:-}" ] && [[ "$SUMS_URL" == *.asc ]]; then
    command -v gpg >/dev/null 2>&1 || { apt-get update -y && apt-get install -y gnupg; }
    { gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$P2POOL_SIGNER_FPR" 2>/dev/null \
      && gpg --batch --status-fd 1 --verify "$TMP/sums" 2>/dev/null | grep -q "VALIDSIG.*${P2POOL_SIGNER_FPR}"; } \
      && g "  OK: assinatura GPG ($P2POOL_SIGNER_FPR) valida." \
      || { rm -rf "$TMP"; die "GPG do checksums NAO validou com $P2POOL_SIGNER_FPR. Abortando."; }
  fi
fi
tar -xzf "$TMP/p2pool.tar.gz" -C "$TMP"
P2POOL_BIN="$(find "$TMP" -type f -name p2pool | head -1)"
[ -n "$P2POOL_BIN" ] || die "binario p2pool nao encontrado no pacote."
install -m 0755 "$P2POOL_BIN" "$BIN_DST/p2pool"
rm -rf "$TMP"
mkdir -p "$WORKDIR"; chown -R monero:monero "$WORKDIR"
g "  P2Pool instalado em $BIN_DST/p2pool."

b "[3/4] Criando o servico systemd 'p2pool'..."
MINI_FLAG=""; [ "$MINI" = "1" ] && MINI_FLAG=" --mini"
cat > /etc/systemd/system/p2pool.service <<UNIT
[Unit]
Description=P2Pool (Monero)
After=monerod.service
Wants=monerod.service

[Service]
User=monero
Group=monero
Type=simple
WorkingDirectory=$WORKDIR
ExecStart=$BIN_DST/p2pool --host 127.0.0.1 --rpc-port 18081 --zmq-port 18083 --wallet $WALLET${MINI_FLAG}
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now p2pool

b "[4/4] Status:"
sleep 2
systemctl --no-pager --full status p2pool | head -12 || true

echo
g "================================================================"
g "  P2Pool instalado (binario verificado). Stratum local na porta 3333."
g "  Acompanhe:  journalctl -u p2pool -f"
g "  Proximo:    sudo ./04-setup-xmrig.sh  (minerador)"
g "================================================================"
y "Privacidade: enderecos no P2Pool sao PUBLICOS. Use carteira separada da do Haveno."
