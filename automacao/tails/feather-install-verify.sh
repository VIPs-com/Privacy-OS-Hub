#!/bin/bash
###############################################################################
# feather-install-verify.sh — Feather no Tails (Vol II Playbook §2)
#
# NAO FAZ: criar carteira, anotar seed, trades.
# USO: ~/Persistent/hub-scripts/feather-install-verify.sh [--qa-log]
#      Baixa chave + AppImage via Tor se ausentes; PGP fail-closed antes de executar.
#      Fallback manual: Tor Browser -> featherwallet.org/download -> ~/Persistent/feather/
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
# URLs da chave, em ordem de preferencia (a do GitHub master morreu — 404,
# DIV-20260611-03). A 2a e o keyserver pinado pelo fingerprint completo.
FEATHER_KEY_URLS=(
  "https://featherwallet.org/files/featherwallet.asc"
  "https://keys.openpgp.org/vks/v1/by-fingerprint/${FEATHER_FPR}"
)

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
  for url in "${FEATHER_KEY_URLS[@]}"; do
    if curl -x socks5h://127.0.0.1:9050 -fsSL "$url" -o "${FEATHER_DIR}/featherwallet.asc"; then
      g "  Chave baixada de: ${url}"
      break
    fi
    y "  Falhou: ${url} — tentando a proxima..."
  done
  [ -s "${FEATHER_DIR}/featherwallet.asc" ] \
    || die "Nao baixei featherwallet.asc de nenhuma fonte. Baixe pelo Tor Browser: featherwallet.org/download"
fi

shopt -s nullglob
appimages=("${FEATHER_DIR}"/feather-*AppImage)
ascfiles=("${FEATHER_DIR}"/feather-*AppImage.asc)
shopt -u nullglob

# Sem AppImage local? Baixa via Tor direto do site oficial (igual ao .deb do
# Haveno). Seguro: a verificacao PGP fail-closed do [4/5] roda do mesmo jeito —
# arquivo adulterado = aborta.
if [ "${#appimages[@]}" -eq 0 ]; then
  y "  AppImage ausente — descobrindo versao atual via Tor (featherwallet.org)..."
  FEATHER_VER="$(curl -x socks5h://127.0.0.1:9050 -fsSL --max-time 120 "https://featherwallet.org/download/" 2>/dev/null \
    | grep -oE 'linux-appimage/feather-[0-9]+\.[0-9]+(\.[0-9]+)?\.AppImage' \
    | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)"
  [ -n "$FEATHER_VER" ] || die "Nao descobri a versao atual. Baixe pelo Tor Browser: featherwallet.org/download -> mova para ${FEATHER_DIR}"
  g "  Versao atual: ${FEATHER_VER}"
  FEATHER_BASE="https://featherwallet.org/files/releases/linux-appimage/feather-${FEATHER_VER}.AppImage"
  y "  Baixando AppImage (~50 MB via Tor — pode demorar alguns minutos)..."
  curl -x socks5h://127.0.0.1:9050 -fL --retry 3 -o "${FEATHER_DIR}/feather-${FEATHER_VER}.AppImage" "$FEATHER_BASE" \
    || die "Download do AppImage falhou. Baixe pelo Tor Browser: featherwallet.org/download"
  curl -x socks5h://127.0.0.1:9050 -fsSL -o "${FEATHER_DIR}/feather-${FEATHER_VER}.AppImage.asc" "${FEATHER_BASE}.asc" \
    || die "Download do .asc falhou. Baixe pelo Tor Browser: featherwallet.org/download"
  g "  Baixados: feather-${FEATHER_VER}.AppImage + .asc"
  shopt -s nullglob
  appimages=("${FEATHER_DIR}"/feather-*AppImage)
  ascfiles=("${FEATHER_DIR}"/feather-*AppImage.asc)
  shopt -u nullglob
fi

if [ "${#appimages[@]}" -eq 0 ] || [ "${#ascfiles[@]}" -eq 0 ]; then
  die "AppImage + .asc ausentes. Tor Browser -> featherwallet.org/download -> mova para ${FEATHER_DIR}"
fi
if [ "${#appimages[@]}" -gt 1 ] || [ "${#ascfiles[@]}" -gt 1 ]; then
  y "  Varias versoes encontradas — use UMA:"
  shopt -s nullglob
  ls -la "${FEATHER_DIR}"/feather-*AppImage* 2>/dev/null || true
  shopt -u nullglob
  die "Deixe apenas um par .AppImage + .AppImage.asc em ${FEATHER_DIR}"
fi

APPIMAGE="${appimages[0]}"
ASCFILE="${ascfiles[0]}"
[ -f "$APPIMAGE" ] || die "AppImage ausente em ${FEATHER_DIR} (glob nao encontrou arquivo real)."
[ -f "$ASCFILE" ] || die "Assinatura .asc ausente em ${FEATHER_DIR} (par incompleto)."
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
