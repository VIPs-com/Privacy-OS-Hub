#!/usr/bin/env bash
# aliases — Passo 5: auditar .deb em Install/ (haveno-verify-deb.sh)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/haveno/verify-deb.sh" "$@"
