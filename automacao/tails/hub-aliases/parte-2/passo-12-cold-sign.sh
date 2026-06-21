#!/usr/bin/env bash
# Passo 12 (Trilha A e B): confirmações pós cold-signing — Tails offline
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/hub.sh" qa cold-sign "$@"
