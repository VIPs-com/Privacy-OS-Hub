#!/usr/bin/env bash
# aliases — Passo 4: confirmacoes humanas seed em papel (sem gravar palavras no log)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/qa/confirm-seed.sh" "$@"
