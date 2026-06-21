#!/usr/bin/env bash
# Passo 4: confirmar seed anotada em papel (não grava palavras no log — só booleanos)
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec "${HUB}/hub.sh" qa confirm-seed "$@"
