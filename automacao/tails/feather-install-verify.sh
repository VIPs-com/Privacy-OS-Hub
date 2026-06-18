#!/bin/bash
###############################################################################
# feather-install-verify.sh — Feather no Tails (Vol II Playbook §2)
#
# NAO FAZ: criar carteira, anotar seed, trades (isso e na UI — humano).
# USO: ~/Persistent/hub-scripts/feather-install-verify.sh [--qa-log] [--no-launch]
#      Baixa chave + AppImage via Tor se ausentes; PGP fail-closed; abre a UI (como Haveno).
#      --no-launch  so re-verifica PGP sem abrir janela.
#      Fallback manual: Tor Browser -> featherwallet.org/download -> ~/Persistent/feather/
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"

DO_LAUNCH=1
while [ $# -gt 0 ]; do
  case "$1" in
    --qa-log) export HAVENO_QA_LOG=1 ;;
    --no-launch) DO_LAUNCH=0 ;;
    *) die "Opcao desconhecida: $1" ;;
  esac
  shift
done

qa_log_tee_begin "05-feather"

FEATHER_DIR="${PERSIST}/feather"
WALLETS_DIR="${FEATHER_DIR}/wallets"
DOWNLOADS="${HOME}/Tor Browser/Browser/Downloads"
FEATHER_FPR="8185E158A33330C7FD61BC0D1F76E155CEFBA71C"
# Fallback se scrape falhar: export FEATHER_VERSION_FALLBACK=x.y.z (validar em featherwallet.org)
FEATHER_VERSION_FALLBACK="${FEATHER_VERSION_FALLBACK:-}"
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

b "[1/6] Preflight..."
tails_preflight_check || die "Preflight falhou."

b "[2/6] Preparando pastas..."
mkdir -p "$WALLETS_DIR"
g "  ${FEATHER_DIR}"

b "[3/6] Coletando artefatos..."
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
  if [ -z "$FEATHER_VER" ] && [ -n "$FEATHER_VERSION_FALLBACK" ]; then
    y "  Scrape falhou — usando FEATHER_VERSION_FALLBACK=${FEATHER_VERSION_FALLBACK}"
    y "  Confira a versao em https://featherwallet.org/download antes de confiar."
    FEATHER_VER="$FEATHER_VERSION_FALLBACK"
  fi
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

b "[4/6] Verificacao PGP..."
gpg --import "${FEATHER_DIR}/featherwallet.asc" 2>/dev/null || true
fp="$(gpg --with-colons --fingerprint dev@featherwallet.org 2>/dev/null | awk -F: '$1=="fpr"{print $10; exit}')"
fp_clean="$(echo "${fp:-}" | tr -d ' ')"
if [ "$fp_clean" != "$FEATHER_FPR" ]; then
  die "Fingerprint Feather incorreto: ${fp_clean:-ausente} (esperado ${FEATHER_FPR})"
fi
g "  Fingerprint OK: ${FEATHER_FPR}"

# Gate humano (padrao do hub: "confira com seus proprios olhos") — mesma
# interatividade do fluxo Haveno. O script confere por software acima; aqui
# VOCE compara com a fonte oficial antes de seguir.
echo
y "  CONFIRA NO OLHO — fingerprint da chave importada:"
gpg --fingerprint dev@featherwallet.org 2>/dev/null | grep -A1 "^pub" | tail -1 | sed 's/^/    /'
y "  Esperado (README do curso / docs.featherwallet.org):"
echo "      8185 E158 A333 30C7 FD61  BC0D 1F76 E155 CEFB A71C"
read -rp "  Os dois batem, caractere por caractere? (s/n) " FPR_OK
[ "${FPR_OK:-n}" = "s" ] || die "Fingerprint NAO confirmado pelo operador. PARE: nao execute o AppImage; avise a equipe."
g "  Confirmado humano em $(date -u '+%Y-%m-%d %H:%M UTC')."

# Fail-closed locale-independente: amarra a assinatura ao fingerprint (status-fd + VALIDSIG).
# Nao usar grep "Good signature" (quebra em PT-BR: "Assinatura valida") nem aceita chave de mesmo User ID.
gpg --status-fd 1 --verify "$ASCFILE" "$APPIMAGE" > /tmp/feather-gpg.log 2>&1 || true
if ! grep -q "^\[GNUPG:\] VALIDSIG .*${FEATHER_FPR}" /tmp/feather-gpg.log; then
  cat /tmp/feather-gpg.log >&2
  die "Assinatura GPG FALHOU ou nao casa o fingerprint ${FEATHER_FPR}. NAO execute o AppImage."
fi
g "  VALIDSIG ${FEATHER_FPR} (assinatura amarrada ao fingerprint)."

b "[5/6] Executavel..."
chmod +x "$APPIMAGE"
g "  chmod +x OK."

FEATHER_DESKTOP="${FEATHER_DIR}/feather.desktop"
if [ "$DO_LAUNCH" = "1" ]; then
  b "[6/6] Abrindo Feather (como Haveno apos install)..."
  cat > "$FEATHER_DESKTOP" <<EOF
[Desktop Entry]
Name=Feather Wallet
Comment=Carteira Monero verificada (PGP fail-closed)
Exec=${APPIMAGE}
Terminal=false
Type=Application
Categories=Finance;
EOF
  g "  Atalho: ${FEATHER_DESKTOP}"
  if [ -d "${HOME}/Desktop" ]; then
    cp "$FEATHER_DESKTOP" "${HOME}/Desktop/Feather-Wallet.desktop"
    g "  Atalho: ~/Desktop/Feather-Wallet.desktop"
  fi
  if pgrep -f "feather-.*AppImage" >/dev/null 2>&1; then
    y "  Feather ja parece aberto — nao abro outra janela."
  else
    nohup "$APPIMAGE" >/tmp/feather-app.log 2>&1 &
    sleep 5
    g "  Feather iniciado (log: /tmp/feather-app.log)."
  fi
  echo
  y "  Na janela do Feather: Create wallet -> seed em PAPEL -> Settings -> Always over Tor"
  y "  Volte a este terminal quando terminar a 1a configuracao."
else
  y "[6/6] Pulado (--no-launch). Abra manualmente: ${APPIMAGE}"
fi

echo
g "==============================================================="
g "  Feather verificado${DO_LAUNCH:+ e aberto}."
g "  ${APPIMAGE}"
g "  Wallets: ${WALLETS_DIR}/"
g "  Backup depois (feche o Feather antes): ~/Persistent/hub-scripts/feather-backup.sh"
g "==============================================================="
qa_log_line "REDE: tails_online_tor_esperado=SIM"
qa_log_finish 0
