#!/usr/bin/env bash
# aliases — Passo 2: 1a instalacao Haveno ate o verde (haveno-setup.sh)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/haveno-setup.sh" --qa-log "$@"
