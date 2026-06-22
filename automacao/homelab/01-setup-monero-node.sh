#!/bin/bash
###############################################################################
# 01-setup-monero-node.sh — Instala o no Monero (monerod) como servico systemd
#
# >>> RODE NO SEU HOME LAB (Debian/Ubuntu), NAO no Tails. <<<
# Requer root:  sudo ./01-setup-monero-node.sh
#
# O que faz:
#   - Cria usuario dedicado 'monero' (sem login)
#   - Baixa o monerod oficial (getmonero) e instala em /usr/local/bin
#   - VERIFICA o binario: hash fixado (MONEROD_SHA256) OU assinatura GPG de
#     binaryfate em hashes.txt — e ABORTA se nao conferir (fail-closed)
#   - Escreve /etc/monerod.conf (pruned por padrao; PRUNED=0 para full)
#   - Cria e ativa o servico systemd 'monerod'
#
# Variaveis (env):
#   DATA_DIR          (padrao /var/lib/monero)  -> use um SSD com espaco
#   PRUNED            (padrao 1; 0 = no full ~250 GB)
#   RPC_PORT          (padrao 18089)            -> porta do RPC restrito (Tor publica)
#   DL_URL            (padrao downloads.getmonero.org/cli/linux64)
#   MONEROD_SHA256    (opcional) hash esperado p/ comparacao direta (pula a verificacao GPG)
#   MONERO_SIGNER_FPR (padrao binaryfate 81AC591F...2A0BDF92)
###############################################################################
set -euo pipefail

DATA_DIR="${DATA_DIR:-/var/lib/monero}"
PRUNED="${PRUNED:-1}"
RPC_PORT="${RPC_PORT:-18089}"
DL_URL="${DL_URL:-https://downloads.getmonero.org/cli/linux64}"
LOG_DIR="/var/log/monero"
BIN_DST="/usr/local/bin"

# Verificacao do binario (getmonero). Se MONEROD_SHA256 vier preenchido, compara direto;
# senao, verifica hashes.txt assinado por binaryfate e ABORTA se nao conferir (fail-closed).
# DL_URL segue o redirect oficial (linux64) — nao fixa versao; upstream 0.18.5.0+ em jun/2026.
MONERO_SIGNER_FPR="${MONERO_SIGNER_FPR:-81AC591FE9C4B65C5806AFC3F0AF4D462A0BDF92}"   # binaryfate
HASHES_URL="${HASHES_URL:-https://www.getmonero.org/downloads/hashes.txt}"
MONEROD_SHA256="${MONEROD_SHA256:-}"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
die(){ echo -e "\033[0;31mERRO: $*\033[0m"; exit 1; }

[ "$(id -u)" -eq 0 ] || die "Rode como root: sudo $0"
grep -qiE "debian|ubuntu" /etc/os-release 2>/dev/null || y "Aviso: este script foi feito para Debian/Ubuntu."

b "[1/6] Criando usuario e pastas..."
id monero >/dev/null 2>&1 || useradd --system --home "$DATA_DIR" --shell /usr/sbin/nologin monero
mkdir -p "$DATA_DIR" "$LOG_DIR"
chown -R monero:monero "$DATA_DIR" "$LOG_DIR"
g "  Usuario 'monero' e pastas OK (data-dir: $DATA_DIR)."

b "[2/6] Baixando e VERIFICANDO o monerod oficial..."
command -v curl >/dev/null 2>&1 || { apt-get update -y && apt-get install -y curl; }
command -v tar  >/dev/null 2>&1 || { apt-get update -y && apt-get install -y tar bzip2; }
command -v gpg  >/dev/null 2>&1 || { apt-get update -y && apt-get install -y gnupg; }
TMP="$(mktemp -d)"
if ! EFFECTIVE_URL="$(curl -fSL -w '%{url_effective}' "$DL_URL" -o "$TMP/monero.tar.bz2")"; then
  die "Falha no download ($DL_URL)."
fi
BIN_NAME="$(basename "$EFFECTIVE_URL")"

DL_SHA="$(sha256sum "$TMP/monero.tar.bz2" | awk '{print $1}')"
y "  SHA256 baixado: $DL_SHA"

if [ -n "$MONEROD_SHA256" ]; then
  # Caminho 1: hash fixado pelo operador (env MONEROD_SHA256)
  [ "$DL_SHA" = "$MONEROD_SHA256" ] \
    && g "  OK: hash confere com MONEROD_SHA256 fixado." \
    || { rm -rf "$TMP"; die "Hash NAO confere com MONEROD_SHA256 (esperado $MONEROD_SHA256). Abortando."; }
else
  # Caminho 2: verificar contra hashes.txt assinado por binaryfate (getmonero)
  b "  Conferindo assinatura de binaryfate em hashes.txt..."
  curl -fsSL "$HASHES_URL" -o "$TMP/hashes.txt" 2>/dev/null \
    || { rm -rf "$TMP"; die "Nao baixei hashes.txt ($HASHES_URL). Cheque a rede ou passe MONEROD_SHA256."; }
  gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$MONERO_SIGNER_FPR" 2>/dev/null \
    || { rm -rf "$TMP"; die "Nao importei a chave binaryfate ($MONERO_SIGNER_FPR). Importe-a e rode de novo, ou passe MONEROD_SHA256."; }
  gpg --batch --status-fd 1 --verify "$TMP/hashes.txt" 2>/dev/null | grep -q "VALIDSIG.*${MONERO_SIGNER_FPR}" \
    || { rm -rf "$TMP"; die "Assinatura de hashes.txt NAO valida com a chave esperada. Abortando."; }
  grep -F -- "$DL_SHA" "$TMP/hashes.txt" | grep -Fq -- "$BIN_NAME" \
    || { rm -rf "$TMP"; die "hashes.txt assinado, mas hash/nome ($BIN_NAME) NAO conferem. Binario suspeito — abortando."; }
  g "  OK: assinatura binaryfate valida; hash + nome ($BIN_NAME) conferem em hashes.txt."
fi

b "[3/6] Extraindo e instalando o binario..."
tar -xjf "$TMP/monero.tar.bz2" -C "$TMP" || die "Falha ao extrair."
MONEROD_BIN="$(find "$TMP" -type f -name monerod | head -1)"
[ -n "$MONEROD_BIN" ] || die "monerod nao encontrado no pacote."
install -m 0755 "$MONEROD_BIN" "$BIN_DST/monerod"
rm -rf "$TMP"
g "  Instalado: $($BIN_DST/monerod --version | head -1)"

b "[4/6] Escrevendo /etc/monerod.conf..."
{
  echo "# Gerado por 01-setup-monero-node.sh"
  echo "data-dir=$DATA_DIR"
  echo "log-file=$LOG_DIR/monerod.log"
  echo "log-level=0"
  echo "max-log-file-size=0"
  if [ "$PRUNED" = "1" ]; then
    echo "prune-blockchain=1"
    echo "sync-pruned-blocks=1"
  fi
  # p2p-bind-ip=0.0.0.0: necessario para peers na LAN; Tor hidden service expoe so o RPC (script 02)
  echo "p2p-bind-ip=0.0.0.0"
  echo "p2p-bind-port=18080"
  echo "rpc-restricted-bind-ip=127.0.0.1"
  echo "rpc-restricted-bind-port=$RPC_PORT"
  if [ "$PRUNED" = "0" ]; then
    # Full node: ZMQ + RPC local para P2Pool (script 03) — pruned nao suporta P2Pool
    echo "zmq-pub=tcp://127.0.0.1:18083"
    echo "rpc-bind-ip=127.0.0.1"
    echo "rpc-bind-port=18081"
    # Flags necessarias p/ P2Pool (script 03) — inocuas em full node sem mineracao
    echo "add-priority-node=p2pmd.xmrvsbeast.com:18080"
    echo "add-priority-node=nodes.hashvault.pro:18080"
    echo "in-peers=64"
    echo "enable-dns-blocklist=1"
    echo "enforce-dns-checkpointing=1"
  fi
  echo "no-igd=1"
  echo "out-peers=32"
  # Banda de upload baixa (< 10 Mbit): edite out-peers=8 e in-peers=16 no monerod.conf
} > /etc/monerod.conf
chown monero:monero /etc/monerod.conf
[ "$PRUNED" = "1" ] && g "  Config: no PRUNED (~100 GB)." || g "  Config: no FULL (~250 GB)."

b "[5/6] Criando o servico systemd..."
cat > /etc/systemd/system/monerod.service <<'UNIT'
[Unit]
Description=Monero Node (monerod)
After=network-online.target
Wants=network-online.target

[Service]
User=monero
Group=monero
Type=simple
ExecStart=/usr/local/bin/monerod --config-file /etc/monerod.conf --non-interactive
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now monerod

b "[6/6] Status:"
sleep 2
systemctl --no-pager --full status monerod | head -12 || true

echo
g "================================================================"
g "  No Monero instalado e iniciado (binario verificado)."
g "  Acompanhe a sincronizacao (8-48h em SSD):"
g "    journalctl -u monerod -f"
g "  Proximo: publicar via Tor  ->  sudo ./02-tor-hidden-service.sh"
g "================================================================"
