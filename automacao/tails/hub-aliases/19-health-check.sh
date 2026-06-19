#!/usr/bin/env bash
# aliases — Diagnostico estatico dos scripts (mantenedor; bash -n + YAML)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${HUB}/system/health-check.sh" "$@"
