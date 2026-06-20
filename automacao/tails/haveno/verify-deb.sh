#!/bin/bash
# =================================================================
# AVANÇADO — use apenas se orientado pelo suporte.
# Uso normal: hub.sh install  |  hub.sh boot
# =================================================================
###############################################################################
# haveno/verify-deb.sh — re-auditar .deb em Install/ (AVANÇADO)
# USO: ~/Persistent/hub-scripts/haveno/verify-deb.sh
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# HAVENO_PGP_FPR e INSTALL_DIR vêm de lib/config.sh (via common.sh)

echo
b "haveno/verify-deb.sh — re-auditar .deb em Install/"
echo

shopt -s nullglob
debs=("${INSTALL_DIR}"/*.deb)
shopt -u nullglob
[ "${#debs[@]}" -gt 0 ] || die "Nenhum .deb em ${INSTALL_DIR}"

DEB="${debs[0]}"
[ "${#debs[@]}" -eq 1 ] || y "Varios .deb — verificando: $(basename "$DEB")"

# haveno-install.sh ja verifica o .deb na INSTALACAO (PGP fail-closed).
# Esta re-auditoria verifica de novo SE houver um .asc/.sig ao lado do .deb.
sig=""
for cand in "${DEB}.asc" "${DEB}.sig"; do
  [ -f "$cand" ] && { sig="$cand"; break; }
done

if [ -n "$sig" ]; then
  VERIFY_LOG="$(mktemp /tmp/haveno-deb-verify.XXXXXX.log)"
  gpg --status-fd 1 --verify "$sig" "$DEB" > "$VERIFY_LOG" 2>&1 || true
  if grep -q "^\[GNUPG:\] NO_PUBKEY" "$VERIFY_LOG"; then
    y "Chave da rede ausente no keyring. Importe antes de re-auditar:"
    y "  curl -x socks5h://127.0.0.1:9050 -fsSL ${RETO_KEY_URL} | gpg --import"
    rm -f "$VERIFY_LOG"
    die "Sem a chave publica para verificar (fingerprint esperado ${HAVENO_PGP_FPR})."
  fi
  if ! grep -q "^\[GNUPG:\] VALIDSIG .*${HAVENO_PGP_FPR}" "$VERIFY_LOG"; then
    cat "$VERIFY_LOG" >&2
    rm -f "$VERIFY_LOG"
    die "Assinatura invalida ou fingerprint != ${HAVENO_PGP_FPR}. NAO confie neste .deb."
  fi
  rm -f "$VERIFY_LOG"
  g "OK: VALIDSIG ${HAVENO_PGP_FPR} em $(basename "$DEB") (URL e PGP do mesmo release)."
else
  y "Sem $(basename "$DEB").asc/.sig ao lado do .deb — este modo NAO verifica a assinatura aqui."
  y "A verificacao PGP fail-closed ja ocorreu na INSTALACAO (via hub.sh install)."
  y "Fingerprint esperado da rede: ${HAVENO_PGP_FPR}"
  ls -la "$DEB"
fi
