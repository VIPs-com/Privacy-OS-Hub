#!/bin/bash
###############################################################################
# steps/_config.sh — wrapper de compatibilidade
# Todos os scripts de steps/ fazem 'source "${DIR}/_config.sh"'
# As constantes vêm de lib/config.sh (única fonte de verdade).
###############################################################################
_STEPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "${_STEPS_DIR}/../lib/config.sh"
