#!/usr/bin/env bash
# aliases — Exporta qa-logs/ para pendrive (ex.: --usb ou --dest /media/amnesia/...)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/qa-export-logs.sh" "$@"
