#!/bin/bash
###############################################################################
# qa-confirm-seed-papel.sh — confirmações humanas pós passo 4 (SEM gravar seed)
#
# Rode DEPOIS de anotar a seed em papel e de haveno-backup.sh --qa-log
# USO: ~/Persistent/qa-confirm-seed-papel.sh
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"

export HAVENO_QA_LOG=1
qa_log_init "04-seed-papel"

echo
b "Confirmacoes do passo 4 (seed em papel) — responda s/N"
echo "NUNCA digite as 25 palavras neste terminal."
echo

_confirm() {
  local key="$1"
  local prompt="$2"
  printf "%s (s/N): " "$prompt"
  read -r ans
  case "${ans:-N}" in s|S|sim|SIM)
    qa_log_confirm "$key" "SIM"
    g "  ${key}=SIM"
    ;;
  *)
    qa_log_confirm "$key" "NAO"
    r "  ${key}=NAO"
    return 1
    ;;
  esac
}

ok=0
_confirm "seed_anotada_papel" "Seed anotada em papel/metal" && ok=$((ok+1)) || true
_confirm "seed_nao_fotografada" "Seed NAO fotografada nem digitada fora do papel" && ok=$((ok+1)) || true
_confirm "seed_nao_so_no_pc" "Seed NAO existe so no computador" && ok=$((ok+1)) || true

qa_log_line "REDE: tails_online_tor=SIM"

if [ "$ok" -eq 3 ]; then
  qa_log_finish 0
  g "Confirmacoes registradas em: $QA_LOG_FILE"
  exit 0
fi

qa_log_finish 1
r "Alguma confirmacao falhou — corrija antes do proximo passo."
exit 1
