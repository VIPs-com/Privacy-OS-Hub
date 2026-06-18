#!/usr/bin/env bash
# aliases — Passo 9: ritual 2x copias fisicas da seed
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/qa-confirm-passo9.sh" "$@"
