#!/bin/bash
###############################################################################
# health-check.sh — validação estática dos scripts (host Linux ou Tails)
#
# USO (em qualquer pasta — o script encontra a raiz automaticamente):
#   ./system/health-check.sh
#
# NAO substitui piloto CT-01..05 em Tails real.
###############################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

TAILS_DIR="${SCRIPT_DIR}/.."   # raiz de automacao/tails/

FAILED=0
WARN=0

b "=== Health Check — Privacy-OS-Hub (automacao/tails) ==="

b "[1/4] Sintaxe bash (-n)..."
while IFS= read -r -d '' script; do
  rel="${script#${TAILS_DIR}/}"
  printf "  %s... " "$rel"
  if bash -n "$script" 2>/dev/null; then
    g "OK"
  else
    r "FAIL"
    FAILED=$((FAILED + 1))
  fi
done < <(find "$TAILS_DIR" -name '*.sh' -type f -not -path '*/hub-aliases/*' -print0)

b "[2/4] PGP fail-closed (VALIDSIG + fingerprint)..."
for script in \
  "${TAILS_DIR}/lib/common.sh" \
  "${TAILS_DIR}/haveno/verify-deb.sh" \
  "${TAILS_DIR}/feather/install.sh" \
  "${TAILS_DIR}/steps/05-verify-sig.sh"; do
  [ -f "$script" ] || continue
  rel="${script#${TAILS_DIR}/}"
  printf "  %s... " "$rel"
  if grep -q 'VALIDSIG' "$script" && grep -qE 'VALIDSIG \.\*\$\{' "$script"; then
    g "OK"
  else
    y "WARN"
    WARN=$((WARN + 1))
  fi
done

b "[3/4] Backup cifrado com confirmação de senha..."
for script in \
  "${TAILS_DIR}/haveno/backup.sh" \
  "${TAILS_DIR}/feather/backup.sh" \
  "${TAILS_DIR}/lib/common.sh"; do
  [ -f "$script" ] || continue
  rel="${script#${TAILS_DIR}/}"
  printf "  %s... " "$rel"
  if grep -q 'haveno_gpg_symmetric_encrypt' "$script"; then
    g "OK"
  else
    y "WARN"
    WARN=$((WARN + 1))
  fi
done

b "[4/4] lib/onion-grater.yml (YAML)..."
ONION_YML="${TAILS_DIR}/lib/onion-grater.yml"
if [ ! -f "$ONION_YML" ]; then
  r "  FAIL — lib/onion-grater.yml ausente"
  FAILED=$((FAILED + 1))
elif command -v python3 >/dev/null 2>&1; then
  printf "  lib/onion-grater.yml... "
  if python3 -c "import yaml; yaml.safe_load(open('${ONION_YML}'))" 2>/dev/null; then
    g "OK"
  else
    r "FAIL"
    FAILED=$((FAILED + 1))
  fi
else
  y "  WARN — python3 ausente; pulando parse YAML"
  WARN=$((WARN + 1))
fi

echo
if [ "$FAILED" -eq 0 ]; then
  g "Sintaxe: PASS (${WARN} aviso(s) informativos)."
  exit 0
fi
r "FAIL — ${FAILED} erro(s) de sintaxe."
exit 1
