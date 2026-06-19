#!/usr/bin/env bash
# aliases — Igual ao 07: haveno-backup.sh ja cifra com GPG por padrao (nao use --no-encrypt).
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/haveno/backup.sh" --qa-log "$@"
