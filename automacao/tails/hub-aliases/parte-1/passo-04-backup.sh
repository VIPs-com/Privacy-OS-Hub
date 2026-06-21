#!/usr/bin/env bash
# Passo 4: backup cifrado da carteira Haveno (rode após anotar a seed em papel)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/hub.sh" backup --qa-log "$@"
