#!/usr/bin/env bash
# Passo 2: 1ª instalação Haveno até o indicador verde
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/hub.sh" install --qa-log "$@"
