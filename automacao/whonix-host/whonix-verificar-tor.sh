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
#
# Changelog jul/2026: retry + timeout no check Tor; finais de linha LF (CRLF quebra shebang no Linux).

set -euo pipefail

SKIP_SYSTEMCHECK=0
TOR_RETRIES=3
TOR_TIMEOUT=30

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

tor_check_ok() {
    if curl --silent --fail --max-time "$TOR_TIMEOUT" --socks5-hostname 127.0.0.1:9050 \
        https://check.torproject.org/api/ip 2>/dev/null | grep -qi '"IsTor":true'; then
        return 0
    fi
    if curl --silent --fail --max-time "$TOR_TIMEOUT" --socks5-hostname 127.0.0.1:9050 \
        https://check.torproject.org 2>/dev/null | grep -qi congratulations; then
        return 0
    fi
    return 1
}

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
echo "[2/2] check.torproject.org via SOCKS Tor local (até ${TOR_RETRIES} tentativas)..."
_tor_ok=0
for _n in $(seq 1 "$TOR_RETRIES"); do
    if tor_check_ok; then
        _tor_ok=1
        break
    fi
    echo "  Tentativa ${_n}/${TOR_RETRIES} sem confirmação Tor — aguardando 10s (Gateway pode estar aquecendo)..."
    sleep 10
done

if [[ "$_tor_ok" -ne 1 ]]; then
    echo "ERRO: Tor não confirmado após ${TOR_RETRIES} tentativas." >&2
    echo "Gateway rodando primeiro? Tor verde no Gateway?" >&2
    exit 1
fi

echo ""
echo "OK: Tor operacional. Próximo: passo 11 do curso (cold-signing / ferramentas)."
