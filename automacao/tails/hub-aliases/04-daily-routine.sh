#!/usr/bin/env bash
# aliases — Passo 7: ritual de sessao direto (haveno-boot.sh)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/haveno-boot.sh" --qa-log "$@"
