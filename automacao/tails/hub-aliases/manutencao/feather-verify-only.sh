#!/usr/bin/env bash
# Manutenção: re-verificar PGP do Feather sem abrir a janela
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/hub.sh" feather --no-launch --qa-log "$@"
