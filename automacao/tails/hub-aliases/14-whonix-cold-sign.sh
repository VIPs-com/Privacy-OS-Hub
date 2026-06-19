#!/usr/bin/env bash
# aliases — Passo 12 Trilha B: mesmas confirmacoes (qa-confirm-passo12.sh)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/qa/confirm-step12.sh" "$@"
