#!/bin/bash
###############################################################################
# qa-validate.sh — validação estática dos scripts (host Linux ou Tails)
#
# USO (via hub): hub.sh qa validate
# USO (direto):  ./system/qa-validate.sh [--qa-log]
#
# Valida (estática): sintaxe bash · grep PGP fail-closed · backup cifrado · YAML onion-grater
# Saída: tela (tempo real) + ~/Persistent/qa-logs/ (com --qa-log ou HAVENO_QA_LOG=1)
#
# IMPORTANTE: verificação estática por grep — não substitui piloto CT-01..05 em Tails real.
###############################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# ---- QA log (tela + arquivo simultâneos) ------------------------------------
for _arg in "$@"; do [ "$_arg" = "--qa-log" ] && export HAVENO_QA_LOG=1; done
[ "${HAVENO_QA_LOG:-0}" = "1" ] && qa_log_tee_begin "qa-validate"

TAILS_DIR="${SCRIPT_DIR}/.."
FAILED=0
WARN=0

b "=== QA Validate — Privacy-OS-Hub (automacao/tails) ==="

# ---- [1/5] Sintaxe bash (-n) -------------------------------------------------
b "[1/5] Sintaxe bash (-n)..."
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

# ---- [2/5] PGP fail-closed (grep estático: VALIDSIG + [GNUPG:] + fingerprint) ------
b "[2/5] PGP fail-closed (grep: VALIDSIG + fingerprint dinamico)..."
for script in \
  "${TAILS_DIR}/lib/common.sh" \
  "${TAILS_DIR}/haveno/verify-deb.sh" \
  "${TAILS_DIR}/feather/install.sh" \
  "${TAILS_DIR}/steps/05-verify-sig.sh"; do
  [ -f "$script" ] || continue
  rel="${script#${TAILS_DIR}/}"
  printf "  %s... " "$rel"
  if grep -qE 'GNUPG.*VALIDSIG \.\*\$\{' "$script"; then
    g "OK"
  else
    r "FAIL"
    FAILED=$((FAILED + 1))
  fi
done

# ---- [3/5] Backup cifrado com confirmação de senha --------------------------
b "[3/5] Backup cifrado com confirmação de senha..."
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

# ---- [4/5] lib/onion-grater.yml (YAML) --------------------------------------
b "[4/5] lib/onion-grater.yml (YAML)..."
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

# ---- [5/5] steps/08 usa filtro corrigido do hub (PoW Haveno 1.6.0) ----------
b "[5/5] steps/08 usa filtro corrigido do hub (onion-grater com PoW)..."
script_08="${TAILS_DIR}/steps/08-open-haveno.sh"
if [ -f "$script_08" ]; then
  rel="${script_08#${TAILS_DIR}/}"
  printf "  %s... " "$rel"
  if grep -qE 'HUB_ONION_YML|lib/onion-grater' "$script_08"; then
    g "OK"
  else
    r "FAIL — steps/08 nao usa lib/onion-grater.yml (filtro sem PoW fix do Haveno 1.6.0)"
    FAILED=$((FAILED + 1))
  fi
else
  y "  steps/08-open-haveno.sh ausente — pulando."
fi

# ---- Resultado ---------------------------------------------------------------
echo
if [ "$FAILED" -eq 0 ]; then
  g "QA Validate: PASS (${WARN} aviso(s) informativos)."
  [ "${HAVENO_QA_LOG:-0}" = "1" ] && qa_log_finish 0
  exit 0
fi
r "FAIL — ${FAILED} erro(s). Corrija antes de rodar com alunos."
[ "${HAVENO_QA_LOG:-0}" = "1" ] && qa_log_finish 1
exit 1
