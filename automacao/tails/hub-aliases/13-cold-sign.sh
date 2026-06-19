#!/usr/bin/env bash
# aliases — Passo 12 Trilha A: confirmacoes pos cold-signing (Tails offline)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/qa/confirm-step12.sh" "$@"
