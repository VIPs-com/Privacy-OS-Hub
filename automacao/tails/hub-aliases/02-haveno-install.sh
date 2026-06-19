#!/usr/bin/env bash
# aliases — Passo 2: 1a instalacao Haveno ate o verde
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/hub.sh" install --qa-log "$@"
