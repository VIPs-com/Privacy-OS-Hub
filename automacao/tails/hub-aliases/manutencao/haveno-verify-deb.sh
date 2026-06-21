#!/usr/bin/env bash
# AVANÇADO: re-auditar .deb em Install/ com GPG — use só se orientado pelo suporte
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/haveno/verify-deb.sh" "$@"
