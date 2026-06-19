#!/usr/bin/env bash
# aliases — Passo 7: cada sessao (boot)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/hub.sh" boot --qa-log "$@"
