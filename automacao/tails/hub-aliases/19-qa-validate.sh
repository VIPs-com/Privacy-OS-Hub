#!/usr/bin/env bash
# aliases — Validação de qualidade dos scripts (tela + qa-log)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/system/qa-validate.sh" --qa-log "$@"
