#!/usr/bin/env bash
# Passo 5: instalar Feather Wallet com verificação PGP fail-closed
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/hub.sh" feather --qa-log "$@"
