#!/usr/bin/env bash
# aliases — Pos-upgrade Tails: Tor + onion-grater (post-session-check.sh)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/system/post-session.sh" --qa-log "$@"
