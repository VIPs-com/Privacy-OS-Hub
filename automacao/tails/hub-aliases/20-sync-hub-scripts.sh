#!/usr/bin/env bash
# aliases — Atualiza scripts do repo/ZIP para ~/Persistent/hub-scripts/
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/sync-hub-scripts.sh" "$@"
