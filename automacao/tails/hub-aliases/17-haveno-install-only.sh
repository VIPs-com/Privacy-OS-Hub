#!/usr/bin/env bash
# aliases — Recuperacao: .deb ja em Install/ — deps + install sem download
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/hub.sh" install --install-only --qa-log "$@"
