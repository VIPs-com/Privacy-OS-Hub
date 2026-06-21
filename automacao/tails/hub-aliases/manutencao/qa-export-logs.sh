#!/usr/bin/env bash
# Manutenção: exportar qa-logs/ para pendrive USB (para enviar ao suporte)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/hub.sh" qa export-logs --usb "$@"
