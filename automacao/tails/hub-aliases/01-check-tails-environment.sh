#!/usr/bin/env bash
# aliases — Passos 1–4: ambiente Tails + Tor + admin (tails-preflight.sh)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/system/preflight.sh" --qa-log "$@"
