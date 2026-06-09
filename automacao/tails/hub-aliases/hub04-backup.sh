#!/usr/bin/env bash
# hub-aliases — wrapper opcional passo 4
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/../haveno-backup.sh" --qa-log "$@"
