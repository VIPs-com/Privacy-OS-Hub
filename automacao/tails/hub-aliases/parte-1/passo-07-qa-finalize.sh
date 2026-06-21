#!/usr/bin/env bash
# Passo 7 (1ª vez): validar scripts + confirmar seed em papel — finaliza instalação
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/hub.sh" qa finalize "$@"
