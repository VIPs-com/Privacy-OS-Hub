#!/usr/bin/env bash
# aliases — Passos 4/7: backup cifrado da carteira Haveno
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/haveno-backup.sh" --qa-log "$@"
