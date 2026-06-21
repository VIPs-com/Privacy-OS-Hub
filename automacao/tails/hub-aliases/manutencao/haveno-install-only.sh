#!/usr/bin/env bash
# Manutenção: .deb já em Install/ — instalar deps sem download (recuperação)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/hub.sh" install --install-only --qa-log "$@"
