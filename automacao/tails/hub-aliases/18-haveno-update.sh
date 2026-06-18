#!/usr/bin/env bash
# aliases — Novo release Reto: backup + atualizar .deb (--url / --pgp se preciso)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/haveno-update.sh" --one-password "$@"
