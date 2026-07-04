#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Privacy-OS-Hub contributors
#
# whonix-verificar-tor.sh — Privacy-OS-Hub
#
# Rode DENTRO da Whonix-Workstation (após Gateway com Tor conectado).
# Passo 10 pós-import — complementa systemcheck manual do curso.
#
# Uso: ./whonix-verificar-tor.sh [--skip-systemcheck]

set -euo pipefail

SKIP_SYSTEMCHECK=0

for arg in "$@"; do
    case "$arg" in
        --skip-systemcheck) SKIP_SYSTEMCHECK=1 ;;
        -h|--help)
            echo "Uso: $0 [--skip-systemcheck]"
            exit 0
            ;;
        *)
            echo "Opção desconhecida: $arg" >&2
            exit 1
            ;;
    esac
done

echo "=== Privacy-OS-Hub — verificação Tor (Whonix Workstation) ==="

if [[ "$SKIP_SYSTEMCHECK" -eq 0 ]] && command -v systemcheck >/dev/null 2>&1; then
    echo ""
    echo "[1/2] systemcheck (interativo — leia a saída)..."
    systemcheck || {
        echo "ERRO: systemcheck falhou. Investigue antes do passo 11." >&2
        exit 1
    }
else
    echo "[1/2] systemcheck pulado (--skip-systemcheck ou comando ausente)."
fi

echo ""
echo "[2/2] check.torproject.org via SOCKS Tor local..."
if ! curl --silent --fail --socks5-hostname 127.0.0.1:9050 \
    https://check.torproject.org/api/ip 2>/dev/null | grep -qi '"IsTor":true'; then
    echo "Tentando página HTML..."
    if ! curl --silent --fail --socks5-hostname 127.0.0.1:9050 \
        https://check.torproject.org 2>/dev/null | grep -qi congratulations; then
        echo "ERRO: Tor não confirmado." >&2
        echo "Gateway rodando primeiro? Tor verde no Gateway?" >&2
        exit 1
    fi
fi

echo ""
echo "OK: Tor operacional. Próximo: passo 11 do curso (cold-signing / ferramentas)."
