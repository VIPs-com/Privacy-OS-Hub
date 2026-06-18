#!/usr/bin/env bash
# aliases — Passo 7: cada sessao (haveno-setup --boot)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/haveno-setup.sh" --boot --qa-log "$@"
