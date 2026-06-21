#!/usr/bin/env bash
# Manutenção: validação estática dos scripts (tela + log simultâneos)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/hub.sh" qa validate "$@"
