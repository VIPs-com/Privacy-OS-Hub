#!/bin/bash
###############################################################################
# haveno-verify-deb.sh — auditar .deb em Install/ (Vol II §3)
# USO: ~/Persistent/haveno-verify-deb.sh
###############################################################################

set -uo pipefail

PERSIST="/home/amnesia/Persistent"
INSTALL_DIR="${PERSIST}/haveno/Install"
HAVENO_PGP_FPR="${HAVENO_PGP_FPR:-DAA24D878B8D36C90120A897CA02DAC12DAE2D0F}"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
die(){ r "ERRO: $*"; exit 1; }

echo
b "haveno-verify-deb.sh — verificar .deb instalado"
echo

shopt -s nullglob
debs=("${INSTALL_DIR}"/*.deb)
shopt -u nullglob
[ "${#debs[@]}" -gt 0 ] || die "Nenhum .deb em ${INSTALL_DIR}"

DEB="${debs[0]}"
[ "${#debs[@]}" -eq 1 ] || y "Varios .deb — verificando: $(basename "$DEB")"

# haveno-install.sh ja verifica o .deb na INSTALACAO (PGP fail-closed).
# Esta re-auditoria so verifica de novo SE houver um .asc/.sig ao lado do .deb.
sig=""
for cand in "${DEB}.asc" "${DEB}.sig"; do
  [ -f "$cand" ] && { sig="$cand"; break; }
done

if [ -n "$sig" ]; then
  # Fail-closed locale-independente: amarra a assinatura ao fingerprint (status-fd + VALIDSIG).
  gpg --status-fd 1 --verify "$sig" "$DEB" > /tmp/haveno-deb-verify.log 2>&1 || true
  if grep -q "^\[GNUPG:\] NO_PUBKEY" /tmp/haveno-deb-verify.log; then
    y "Chave da rede ausente no keyring. Importe antes de re-auditar:"
    y "  curl -x socks5h://127.0.0.1:9050 -fsSL https://retoswap.com/reto_public.asc | gpg --import"
    die "Sem a chave publica para verificar (fingerprint esperado ${HAVENO_PGP_FPR})."
  fi
  if ! grep -q "^\[GNUPG:\] VALIDSIG .*${HAVENO_PGP_FPR}" /tmp/haveno-deb-verify.log; then
    cat /tmp/haveno-deb-verify.log >&2
    die "Assinatura invalida ou fingerprint != ${HAVENO_PGP_FPR}. NAO confie neste .deb."
  fi
  g "OK: VALIDSIG ${HAVENO_PGP_FPR} em $(basename "$DEB") (URL e PGP do mesmo release)."
else
  # Sem .asc/.sig: este modo NAO verifica nada aqui — nao afirmar "OK".
  y "Sem $(basename "$DEB").asc/.sig ao lado do .deb — este modo NAO verifica a assinatura aqui."
  y "A verificacao PGP fail-closed ja ocorreu na INSTALACAO (haveno-install.sh)."
  y "Fingerprint esperado da rede: ${HAVENO_PGP_FPR}"
  ls -la "$DEB"
fi
