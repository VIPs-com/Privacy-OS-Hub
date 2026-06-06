#!/bin/bash
###############################################################################
# 04-setup-xmrig.sh — Minerador xmrig conectado ao P2Pool local (servico systemd)
#
# >>> RODE NO HOME LAB (Debian/Ubuntu), NAO no Tails. <<<
# Requer root:  sudo ./04-setup-xmrig.sh
# Pre-requisito: P2Pool rodando (script 03) com stratum em 127.0.0.1:3333.
#
# O que faz:
#   - Baixa o xmrig (release mais recente do GitHub) e instala
#   - VERIFICA com GPG: assinatura xmrig (SHA256SUMS.sig) + hash; ABORTA se falhar (fail-closed)
#   - Cria o servico systemd 'xmrig' minerando para o P2Pool local
#
# Variaveis (env):
#   STRATUM          (padrao 127.0.0.1:3333)  -> stratum do P2Pool
#   DIFF             (opcional) dificuldade fixa p/ stats (ex.: 50000). NAO muda recompensa.
#   DL_URL           (opcional) URL .tar.gz do xmrig linux-static-x64 (se auto-deteccao falhar)
#   XMRIG_SHA256     (opcional) hash fixado p/ comparacao direta (pula a verificacao GPG)
#   XMRIG_SIGNER_FPR (padrao 9AC4CEA8...8BE94409, de xmrig.com/docs/gpg-key)
###############################################################################
set -euo pipefail

STRATUM="${STRATUM:-127.0.0.1:3333}"
DIFF="${DIFF:-}"
DL_URL="${DL_URL:-}"
BIN_DST="/usr/local/bin"

# Verificacao GPG do xmrig (fingerprint de xmrig.com/docs/gpg-key)
XMRIG_SIGNER_FPR="${XMRIG_SIGNER_FPR:-9AC4CEA8E66E35A5C7CDDC1B446A53638BE94409}"
XMRIG_KEY_URL="${XMRIG_KEY_URL:-https://raw.githubusercontent.com/xmrig/xmrig/master/doc/gpg_keys/xmrig.asc}"
XMRIG_SHA256="${XMRIG_SHA256:-}"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
die(){ echo -e "\033[0;31mERRO: $*\033[0m"; exit 1; }

[ "$(id -u)" -eq 0 ] || die "Rode como root: sudo $0"
id monero >/dev/null 2>&1 || die "Usuario 'monero' nao existe. Rode os scripts 01 e 03 primeiro."

b "[1/3] Baixando e VERIFICANDO o xmrig (GPG obrigatorio)..."
command -v curl >/dev/null 2>&1 || { apt-get update -y && apt-get install -y curl tar; }
command -v gpg  >/dev/null 2>&1 || { apt-get update -y && apt-get install -y gnupg; }
REL_JSON="$(curl -fsSL https://api.github.com/repos/xmrig/xmrig/releases/latest || true)"
if [ -z "$DL_URL" ]; then
  DL_URL="$(printf '%s' "$REL_JSON" | grep -oE '"browser_download_url": *"[^"]+"' | cut -d'"' -f4 | grep -iE 'linux-static-x64\.tar\.gz$' | head -1)"
  [ -n "$DL_URL" ] || DL_URL="$(printf '%s' "$REL_JSON" | grep -oE '"browser_download_url": *"[^"]+"' | cut -d'"' -f4 | grep -iE 'linux-x64\.tar\.gz$' | head -1)"
fi
[ -n "$DL_URL" ] || die "Nao detectei a URL do xmrig. Passe: sudo DL_URL=...linux-static-x64.tar.gz XMRIG_SHA256=<hash> $0"
TMP="$(mktemp -d)"
curl -fSL "$DL_URL" -o "$TMP/xmrig.tar.gz" || { rm -rf "$TMP"; die "Falha no download do xmrig."; }
DL_SHA="$(sha256sum "$TMP/xmrig.tar.gz" | awk '{print $1}')"
y "  SHA256 baixado: $DL_SHA"

if [ -n "${XMRIG_SHA256:-}" ]; then
  [ "$DL_SHA" = "$XMRIG_SHA256" ] && g "  OK: confere com XMRIG_SHA256 fixado." \
    || { rm -rf "$TMP"; die "Hash NAO confere com XMRIG_SHA256. Abortando."; }
else
  SUMS_URL="$(printf '%s' "$REL_JSON" | grep -oE '"browser_download_url": *"[^"]+"' | cut -d'"' -f4 | grep -iE 'sha256sums$' | head -1)"
  SIG_URL="$(printf '%s' "$REL_JSON" | grep -oE '"browser_download_url": *"[^"]+"' | cut -d'"' -f4 | grep -iE 'sha256sums\.sig$' | head -1)"
  { [ -n "$SUMS_URL" ] && [ -n "$SIG_URL" ]; } || { rm -rf "$TMP"; die "Release sem SHA256SUMS/.sig. Verifique manualmente ou passe XMRIG_SHA256=<hash>."; }
  curl -fsSL "$SUMS_URL" -o "$TMP/SHA256SUMS"     || { rm -rf "$TMP"; die "Nao baixei SHA256SUMS."; }
  curl -fsSL "$SIG_URL"  -o "$TMP/SHA256SUMS.sig" || { rm -rf "$TMP"; die "Nao baixei SHA256SUMS.sig."; }
  { curl -fsSL "$XMRIG_KEY_URL" -o "$TMP/xmrig.asc" 2>/dev/null && gpg --batch --import "$TMP/xmrig.asc" 2>/dev/null; } \
    || gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$XMRIG_SIGNER_FPR" 2>/dev/null \
    || { rm -rf "$TMP"; die "Nao importei a chave do xmrig ($XMRIG_SIGNER_FPR)."; }
  gpg --batch --status-fd 1 --verify "$TMP/SHA256SUMS.sig" "$TMP/SHA256SUMS" 2>/dev/null | grep -q "VALIDSIG.*${XMRIG_SIGNER_FPR}" \
    || { rm -rf "$TMP"; die "Assinatura de SHA256SUMS NAO valida com a chave xmrig ($XMRIG_SIGNER_FPR). Abortando."; }
  BIN_NAME="$(basename "$DL_URL")"
  grep -F -- "$DL_SHA" "$TMP/SHA256SUMS" | grep -Fq -- "$BIN_NAME" \
    || { rm -rf "$TMP"; die "Assinatura OK, mas hash/nome ($BIN_NAME) NAO conferem no SHA256SUMS. Abortando."; }
  g "  OK: assinatura xmrig ($XMRIG_SIGNER_FPR) valida; hash + nome ($BIN_NAME) conferem em SHA256SUMS."
fi
tar -xzf "$TMP/xmrig.tar.gz" -C "$TMP"
XMRIG_BIN="$(find "$TMP" -type f -name xmrig | head -1)"
[ -n "$XMRIG_BIN" ] || die "binario xmrig nao encontrado no pacote."
install -m 0755 "$XMRIG_BIN" "$BIN_DST/xmrig"
rm -rf "$TMP"
g "  xmrig instalado em $BIN_DST/xmrig."

b "[2/3] Criando o servico systemd 'xmrig'..."
USERSPEC="x"; [ -n "$DIFF" ] && USERSPEC="x+${DIFF}"
cat > /etc/systemd/system/xmrig.service <<UNIT
[Unit]
Description=xmrig (minerador RandomX)
After=p2pool.service
Wants=p2pool.service

[Service]
User=monero
Group=monero
Type=simple
ExecStart=$BIN_DST/xmrig -o $STRATUM -u $USERSPEC --no-color
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now xmrig

b "[3/3] Status:"
sleep 2
systemctl --no-pager --full status xmrig | head -12 || true

echo
g "================================================================"
g "  xmrig (GPG verificado) minerando para o P2Pool em $STRATUM."
g "  Acompanhe:  journalctl -u xmrig -f   (procure por 'accepted')"
g "================================================================"
y "Tuning (opcional): hugepages e MSR (precisam de root) aumentam o hashrate."
y "Sem isso o xmrig minera igual, so um pouco mais devagar."
