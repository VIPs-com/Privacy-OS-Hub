#!/usr/bin/env bash
# aliases — Passo 7: ritual de sessao (via hub.sh boot — inclui preflight)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/hub.sh" boot --qa-log "$@"
