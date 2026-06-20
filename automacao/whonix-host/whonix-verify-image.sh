#!/bin/bash
###############################################################################
# whonix-verify-image.sh — verificar imagem Whonix no HOST Linux (Playbooks M2 §1)
#
# RODE NO HOST LINUX (Debian/Ubuntu etc.) — NAO no Tails, NAO dentro da VM.
# NAO importa VM no VirtualBox (licenca/GUI manual).
#
# USO:
#   ./whonix-verify-image.sh Whonix-*.ova Whonix-*.ova.asc
#   ./whonix-verify-image.sh --kvm Whonix-*.libvirt.xz Whonix-*.libvirt.xz.asc
#   ./whonix-verify-image.sh --qa-log Whonix-*.ova Whonix-*.ova.asc
###############################################################################

set -uo pipefail

WHONIX_FPR="916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA"
DERIVATIVE_URL="https://www.whonix.org/keys/derivative.asc"
FORMAT="ova"
QA_LOG=0
IMAGE=""
SIG=""

while [ $# -gt 0 ]; do
  case "$1" in
    --kvm) FORMAT="libvirt" ;;
    --qa-log) QA_LOG=1 ;;
    --help|-h)
      echo "Uso: $0 [--kvm] [--qa-log] IMAGEM IMAGEM.asc"
      exit 0
      ;;
    *)
      if [ -z "$IMAGE" ]; then IMAGE="$1"
      elif [ -z "$SIG" ]; then SIG="$1"
      fi
      ;;
  esac
  shift
done

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
die(){ r "ERRO: $*"; exit 1; }

echo
b "==============================================================="
b "  whonix-verify-image.sh — verificacao PGP (host Linux)"
b "==============================================================="
echo

command -v gpg >/dev/null 2>&1 || die "gpg nao encontrado. Instale: sudo apt install gnupg"
command -v curl >/dev/null 2>&1 || die "curl nao encontrado."

[ -f "$IMAGE" ] || die "Imagem nao encontrada: ${IMAGE:-informe o arquivo}"
[ -f "$SIG" ] || die "Assinatura .asc nao encontrada: ${SIG:-informe o .asc}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
cd "$WORKDIR" || die "mktemp falhou"

b "[1/3] Baixando derivative.asc..."
curl -fsSL "$DERIVATIVE_URL" -o derivative.asc || die "Falha ao baixar derivative.asc"

b "[2/3] Importando chave + fingerprint..."
gpg --import derivative.asc 2>/dev/null || true
fp="$(gpg --with-colons --fingerprint "$WHONIX_FPR" 2>/dev/null | awk -F: '$1=="fpr"{print $10; exit}')"
fp_clean="$(echo "${fp:-}" | tr -d ' ')"
if [ "$fp_clean" != "$WHONIX_FPR" ]; then
  y "EXPKEYSIG? Reimporte derivative.asc (jan/2026) e confira:"
  y "  curl -fsSL $DERIVATIVE_URL -o derivative.asc && gpg --import derivative.asc"
  die "Fingerprint incorreto: ${fp_clean:-ausente} (esperado ${WHONIX_FPR})"
fi
g "  Fingerprint OK: ${WHONIX_FPR}"

b "[3/3] Verificando imagem..."
_WHONIX_LOG="${WORKDIR}/whonix-verify.log"
gpg --status-fd 1 --verify-options show-notations --verify "$SIG" "$IMAGE" \
  > "$_WHONIX_LOG" 2>&1 || true
if grep -q "^\[GNUPG:\] VALIDSIG .*${WHONIX_FPR}" "$_WHONIX_LOG"; then
  :
elif grep -qi "EXPKEYSIG" "$_WHONIX_LOG"; then
  die "EXPKEYSIG — reimporte derivative.asc e rode de novo (Instalar §5.4)."
else
  cat "$_WHONIX_LOG" >&2
  die "Assinatura GPG FALHOU. NAO importe a VM."
fi

echo
g "==============================================================="
g "  Good signature — confira o fingerprint com SEUS OLHOS: ${WHONIX_FPR}"
g "  Formato: ${FORMAT}"
g "  Proximo passo MANUAL: importar no VirtualBox/KVM (Instalar por SO)"
g "==============================================================="

if [ "$QA_LOG" = "1" ]; then
  LOG_DIR="$(dirname "$(readlink -f "$IMAGE" 2>/dev/null || echo "$IMAGE")")/qa-logs"
  mkdir -p "$LOG_DIR"
  LOG_FILE="${LOG_DIR}/10-whonix-verify-$(date +%Y%m%d-%H%M%S).txt"
  {
    echo "=== 10-whonix-verify — $(date -Iseconds 2>/dev/null || date) ==="
    echo "script: whonix-verify-image.sh"
    echo "imagem: $(basename "$IMAGE")"
    echo "Fingerprint OK: ${WHONIX_FPR}"
    echo "Good signature: SIM"
    echo "RESULTADO: PASS"
    echo "exit_code: 0"
  } >"$LOG_FILE"
  g "  QA log: $LOG_FILE"
fi
