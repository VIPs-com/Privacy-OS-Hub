#!/usr/bin/env bash
# hub-aliases — wrapper opcional passo 9
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/../qa-confirm-passo9.sh" "$@"
