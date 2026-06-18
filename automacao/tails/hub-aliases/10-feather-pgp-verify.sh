#!/usr/bin/env bash
# aliases — Passo 5: so re-verifica PGP Feather (sem abrir janela)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/feather-install-verify.sh" --qa-log --no-launch "$@"
