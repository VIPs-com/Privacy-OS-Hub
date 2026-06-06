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

# haveno-install.sh verifica na instalacao; re-auditoria manual via arquivos .asc se existirem
asc="${DEB}.asc"
if [ -f "$asc" ]; then
  gpg --verify "$asc" "$DEB" 2>&1 | tee /tmp/haveno-deb-verify.log
  grep -q "Good signature" /tmp/haveno-deb-verify.log || die "Assinatura invalida."
  g "Good signature em $(basename "$DEB")"
else
  y "Sem ${asc} — confira que instalou com haveno-install.sh (PGP na instalacao)."
  y "Fingerprint esperado da rede: ${HAVENO_PGP_FPR}"
  ls -la "$DEB"
fi
g "OK se: Good signature + mesma rede (URL e PGP do mesmo release)."
