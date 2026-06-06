#!/bin/bash
###############################################################################
# 00-verificar-requisitos.sh — Pre-voo do Home Lab (so LEITURA, nao muda nada)
#
# >>> RODE NO SEU HOME LAB (Debian/Ubuntu), NAO no Tails. <<<
# NAO precisa de root para a maioria das checagens (use sudo para ver tudo).
#
# Verifica antes de instalar o no/mineracao:
#   - Arquitetura (x86_64 / aarch64)
#   - RAM total
#   - Espaco livre e tipo de disco (SSD vs HDD) no destino
#   - Ferramentas (curl, tar, systemctl, tor)
#   - Conectividade
# E diz se da para no PRUNED, FULL e/ou mineracao.
#
# Variaveis (env):
#   DATA_DIR  (padrao /var/lib/monero)  -> onde a blockchain vai ficar
###############################################################################
set -uo pipefail

DATA_DIR="${DATA_DIR:-/var/lib/monero}"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m  OK   $*\033[0m"; }
y(){ echo -e "\033[1;33m  AVISO $*\033[0m"; }
r(){ echo -e "\033[0;31m  FALHA $*\033[0m"; }

PASS=0; WARN=0; FAIL=0
ok(){ g "$*"; PASS=$((PASS+1)); }
warn(){ y "$*"; WARN=$((WARN+1)); }
bad(){ r "$*"; FAIL=$((FAIL+1)); }

echo
b "=== Pre-voo Home Lab (Monero / P2Pool) ==="
echo

# 1) Sistema
b "[1] Sistema operacional"
if grep -qiE "debian|ubuntu" /etc/os-release 2>/dev/null; then
  ok "$(. /etc/os-release; echo "$PRETTY_NAME")"
else
  warn "Nao parece Debian/Ubuntu — os scripts assumem apt/systemd."
fi
if command -v systemctl >/dev/null 2>&1; then ok "systemd presente"; else bad "systemd ausente (os scripts usam servicos systemd)"; fi

# 2) Arquitetura
b "[2] Arquitetura da CPU"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ok "x86_64 (use os binarios linux64)";;
  aarch64|arm64) warn "aarch64/ARM — use os binarios ARM (Raspberry Pi 4/5); o monerod tem build ARM";;
  *) warn "Arquitetura '$ARCH' incomum — confirme se ha binario disponivel";;
esac
CORES="$(nproc 2>/dev/null || echo '?')"
echo "        nucleos de CPU: $CORES"

# 3) RAM
b "[3] Memoria RAM"
RAM_MB="$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
echo "        RAM total: ${RAM_MB} MB"
if   [ "$RAM_MB" -ge 8000 ]; then ok "RAM suficiente para no full + mineracao"
elif [ "$RAM_MB" -ge 4000 ]; then warn "RAM ok para no pruned; mineracao pode ficar apertada (RandomX usa ~2-3 GB)"
else bad "RAM baixa (<4 GB) — nem o no pruned roda confortavelmente"; fi

# 4) Disco / espaco / SSD
b "[4] Disco em $DATA_DIR"
CHECK_PATH="$DATA_DIR"; [ -d "$CHECK_PATH" ] || CHECK_PATH="$(dirname "$DATA_DIR")"; [ -d "$CHECK_PATH" ] || CHECK_PATH="/"
FREE_GB="$(df -BG --output=avail "$CHECK_PATH" 2>/dev/null | tail -1 | tr -dc '0-9')"
[ -n "${FREE_GB:-}" ] || FREE_GB=0
echo "        espaco livre em $CHECK_PATH: ${FREE_GB} GB"
if   [ "$FREE_GB" -ge 300 ]; then ok "Espaco para no FULL (~250 GB) + folga"
elif [ "$FREE_GB" -ge 120 ]; then warn "Espaco para no PRUNED (~100 GB); insuficiente para FULL"
else bad "Espaco insuficiente (<120 GB) ate para no pruned"; fi

# Tipo de disco (SSD vs HDD) — rotational 0 = SSD, 1 = HDD
SRC_DEV="$(df --output=source "$CHECK_PATH" 2>/dev/null | tail -1)"
BASE="$(lsblk -no pkname "$SRC_DEV" 2>/dev/null | head -1)"
[ -z "${BASE:-}" ] && BASE="$(basename "$SRC_DEV" 2>/dev/null | sed 's/[0-9]*$//')"
ROT_FILE="/sys/block/${BASE}/queue/rotational"
if [ -r "$ROT_FILE" ]; then
  if [ "$(cat "$ROT_FILE")" = "0" ]; then ok "Disco parece SSD/NVMe (rotational=0) — ideal"
  else bad "Disco parece HDD (rotational=1) — sync inicial fica MUITO lento; use SSD"; fi
else
  warn "Nao consegui detectar SSD/HDD automaticamente — confirme que e SSD"
fi

# 5) Ferramentas
b "[5] Ferramentas necessarias"
for c in curl tar; do command -v "$c" >/dev/null 2>&1 && ok "$c presente" || warn "$c ausente (sera instalado via apt pelos scripts)"; done
command -v tor >/dev/null 2>&1 && ok "tor presente" || warn "tor ausente (o script 02 instala)"

# 6) Conectividade
b "[6] Conectividade"
if curl -fsS --max-time 12 https://downloads.getmonero.org/cli/linux64 -o /dev/null -r 0-0 2>/dev/null; then
  ok "Internet/HTTPS acessivel (getmonero)"
else
  warn "Nao consegui contatar downloads.getmonero.org agora (rede/proxy?)"
fi

# Resumo
echo
b "=== Resumo: $PASS OK · $WARN avisos · $FAIL falhas ==="
echo "  Recomendacao:"
[ "$FREE_GB" -ge 300 ] && [ "$RAM_MB" -ge 8000 ] && echo "   - Da para no FULL (mineracao P2Pool incluida)."
[ "$FREE_GB" -ge 120 ] && [ "$FREE_GB" -lt 300 ] && echo "   - Da para no PRUNED. Para mineracao/FULL, adicione disco."
[ "$RAM_MB" -lt 4000 ] && echo "   - Aumente a RAM antes de prosseguir."
echo
if [ "$FAIL" -gt 0 ]; then
  r "Ha falhas acima — resolva antes de rodar 01-setup-monero-node.sh"
  exit 1
else
  g "Pre-voo concluido. Proximo: sudo ./01-setup-monero-node.sh"
fi
