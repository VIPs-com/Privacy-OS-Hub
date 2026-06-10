#!/bin/bash
###############################################################################
# feather-install-verify.sh — Feather no Tails (Vol II Playbook §2)
#
# NAO FAZ: criar carteira, anotar seed, trades.
# USO: baixe pelo Tor Browser primeiro, depois:
#      ~/Persistent/feather-install-verify.sh
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"

while [ $# -gt 0 ]; do
  case "$1" in
    --qa-log) export HAVENO_QA_LOG=1 ;;
    *) die "Opcao desconhecida: $1" ;;
  esac
  shift
done

qa_log_tee_begin "05-feather"

FEATHER_DIR="${PERSIST}/feather"
WALLETS_DIR="${FEATHER_DIR}/wallets"
DOWNLOADS="${HOME}/Tor Browser/Browser/Downloads"
FEATHER_FPR="8185E158A33330C7FD61BC0D1F76E155CEFBA71C"
FEATHER_KEY_URL="https://raw.githubusercontent.com/feather-wallet/feather/master/featherwallet.asc"

echo
b "==============================================================="
b "  feather-install-verify.sh — Feather no Tails (PGP fail-closed)"
b "==============================================================="
echo

b "[1/5] Preflight..."
tails_preflight_check || die "Preflight falhou."

b "[2/5] Preparando pastas..."
mkdir -p "$WALLETS_DIR"
g "  ${FEATHER_DIR}"

b "[3/5] Coletando artefatos..."
shopt -s nullglob
moved=0
for f in "${DOWNLOADS}"/feather-* "${DOWNLOADS}"/featherwallet.asc; do
  [ -e "$f" ] || continue
  mv "$f" "$FEATHER_DIR/" && moved=1
done
shopt -u nullglob

if [ ! -f "${FEATHER_DIR}/featherwallet.asc" ]; then
  y "  featherwallet.asc ausente — baixando via Tor..."
  curl -x socks5h://127.0.0.1:9050 -fsSL "$FEATHER_KEY_URL" -o "${FEATHER_DIR}/featherwallet.asc" \
    || die "Nao baixei featherwallet.asc. Baixe pelo Tor Browser: featherwallet.org/download"
fi

appimages=("${FEATHER_DIR}"/feather-*AppImage)
ascfiles=("${FEATHER_DIR}"/feather-*AppImage.asc)

if [ "${#appimages[@]}" -eq 0 ] || [ "${#ascfiles[@]}" -eq 0 ]; then
  die "AppImage + .asc ausentes. Tor Browser -> featherwallet.org/download -> mova para ${FEATHER_DIR}"
fi
if [ "${#appimages[@]}" -gt 1 ] || [ "${#ascfiles[@]}" -gt 1 ]; then
  y "  Varias versoes encontradas — use UMA:"
  ls -la "${FEATHER_DIR}"/feather-*AppImage* 2>/dev/null || true
  die "Deixe apenas um par .AppImage + .AppImage.asc em ${FEATHER_DIR}"
fi

APPIMAGE="${appimages[0]}"
ASCFILE="${ascfiles[0]}"
g "  Par: $(basename "$APPIMAGE")"

b "[4/5] Verificacao PGP..."
gpg --import "${FEATHER_DIR}/featherwallet.asc" 2>/dev/null || true
fp="$(gpg --with-colons --fingerprint dev@featherwallet.org 2>/dev/null | awk -F: '$1=="fpr"{print $10; exit}')"
fp_clean="$(echo "${fp:-}" | tr -d ' ')"
if [ "$fp_clean" != "$FEATHER_FPR" ]; then
  die "Fingerprint Feather incorreto: ${fp_clean:-ausente} (esperado ${FEATHER_FPR})"
fi
g "  Fingerprint OK: ${FEATHER_FPR}"

# Fail-closed locale-independente: amarra a assinatura ao fingerprint (status-fd + VALIDSIG).
# Nao usar grep "Good signature" (quebra em PT-BR: "Assinatura valida") nem aceita chave de mesmo User ID.
gpg --status-fd 1 --verify "$ASCFILE" "$APPIMAGE" > /tmp/feather-gpg.log 2>&1 || true
if ! grep -q "^\[GNUPG:\] VALIDSIG .*${FEATHER_FPR}" /tmp/feather-gpg.log; then
  cat /tmp/feather-gpg.log >&2
  die "Assinatura GPG FALHOU ou nao casa o fingerprint ${FEATHER_FPR}. NAO execute o AppImage."
fi
g "  VALIDSIG ${FEATHER_FPR} (assinatura amarrada ao fingerprint)."

b "[5/5] Executavel..."
chmod +x "$APPIMAGE"
g "  chmod +x OK."

echo
g "==============================================================="
g "  Feather verificado. Para abrir:"
g "  ${APPIMAGE}"
g "  UI: Create wallet -> seed em PAPEL -> Settings -> Always over Tor"
g "  Wallets: ${WALLETS_DIR}/"
g "  Backup depois: ~/Persistent/feather-backup.sh"
g "==============================================================="
qa_log_line "REDE: tails_online_tor_esperado=SIM"
y "Apos criar carteira e anotar seed no papel: qa-confirm-seed-papel.sh"
qa_log_finish 0
