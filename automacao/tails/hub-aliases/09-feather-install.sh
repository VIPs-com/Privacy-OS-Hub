#!/usr/bin/env bash
# aliases — Passo 5: Feather PGP + AppImage (feather-install-verify.sh)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/feather-install-verify.sh" --qa-log "$@"
