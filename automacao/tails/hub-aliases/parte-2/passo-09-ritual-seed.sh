#!/usr/bin/env bash
# Passo 9: confirmar 2 cópias físicas da seed em locais separados
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/hub.sh" qa confirm-step9 "$@"
