#!/bin/bash
###############################################################################
# health-check.sh — validacao estatica dos scripts (host Linux ou Tails)
#
# USO (na pasta automacao/tails/ ou hub-scripts/):
#   ./health-check.sh
#
# NAO substitui piloto CT-01..05 em Tails real.
###############################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }

FAILED=0
WARN=0

b "=== Health Check — Privacy-OS-Hub (automacao/tails) ==="

b "[1/4] Sintaxe bash (-n)..."
while IFS= read -r -d '' script; do
  rel="${script#${SCRIPT_DIR}/}"
  printf "  %s... " "$rel"
  if bash -n "$script" 2>/dev/null; then
    g "OK"
  else
    r "FAIL"
    FAILED=$((FAILED + 1))
  fi
done < <(find "$SCRIPT_DIR" -name '*.sh' -type f -print0)

b "[2/4] haveno-common.sh presente..."
if [ -f "${SCRIPT_DIR}/haveno-common.sh" ]; then
  g "  OK"
else
  r "  FAIL — haveno-common.sh ausente"
  FAILED=$((FAILED + 1))
fi

b "[3/4] PGP fail-closed (VALIDSIG + fingerprint)..."
for script in haveno-common.sh haveno-verify-deb.sh feather-install-verify.sh \
  etapas/instalar-haveno/05-verificar-assinatura.sh; do
  [ -f "$script" ] || continue
  printf "  %s... " "$script"
  if grep -q 'VALIDSIG' "$script" && grep -qE 'VALIDSIG \.\*\$\{' "$script"; then
    g "OK"
  else
    y "WARN"
    WARN=$((WARN + 1))
  fi
done

b "[4/4] Backup cifrado com confirmacao de senha..."
for script in haveno-backup.sh feather-backup.sh haveno-common.sh; do
  [ -f "$script" ] || continue
  printf "  %s... " "$script"
  if grep -q 'haveno_gpg_symmetric_encrypt' "$script"; then
    g "OK"
  else
    y "WARN"
    WARN=$((WARN + 1))
  fi
done

echo
if [ "$FAILED" -eq 0 ]; then
  g "Sintaxe: PASS (${WARN} aviso(s) informativos)."
  exit 0
fi
r "FAIL — ${FAILED} erro(s) de sintaxe."
exit 1
