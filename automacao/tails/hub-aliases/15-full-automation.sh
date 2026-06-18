#!/usr/bin/env bash
# aliases — 1a instalacao com menos prompts de senha admin (--one-password)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/haveno-setup.sh" --qa-log --one-password "$@"
