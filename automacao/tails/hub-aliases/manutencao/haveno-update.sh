#!/usr/bin/env bash
# Manutenção: novo release RetoSwap — faz backup antes e atualiza o .deb
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/haveno/update.sh" --qa-log "$@"
