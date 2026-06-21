#!/usr/bin/env bash
# Manutenção: verificar Tor + onion-grater após upgrade do Tails
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/system/post-session.sh" --qa-log "$@"
