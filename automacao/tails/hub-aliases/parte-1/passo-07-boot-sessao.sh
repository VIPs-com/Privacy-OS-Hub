#!/usr/bin/env bash
# Passo 7: abrir Haveno nesta sessão — rode a cada reinício do Tails
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/hub.sh" boot --qa-log "$@"
