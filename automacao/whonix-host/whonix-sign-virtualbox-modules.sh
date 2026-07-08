#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Privacy-OS-Hub contributors
#
# whonix-sign-virtualbox-modules.sh — Privacy-OS-Hub (host Linux)
#
# Passo 10 — compilar, assinar (Secure Boot) e carregar módulos vboxdrv.
# Rode DEPOIS de whonix-install-virtualbox.sh + tela azul MOK (se SB ON).
# Repita após cada apt upgrade que troca o kernel.
#
# Uso:
#   sudo ./whonix-sign-virtualbox-modules.sh [-y] [--qa-log] [--sign-only]
#
# Exit codes:
#   0 — PASS (vboxdrv carregado)
#   2 — FAIL_MOK (SB ON; chave não enrolada — falta tela azul)
#   1 — FAIL (erro fatal)
#
# Log: /var/log/virtualbox-sign.log

set -euo pipefail

ASSUME_YES=0
QA_LOG=0
QA_LOG_DIR=""
SIGN_ONLY=0
VBOX_KMODS=(vboxdrv vboxnetflt vboxnetadp vboxpci)
MOK_DIR="/root/module-signing"
MOK_PRIV="${MOK_DIR}/MOK.priv"
MOK_DER="${MOK_DIR}/MOK.der"
PROGRESS_FILE="${MOK_DIR}/.hub-vbox-progress"
LOG_FILE="/var/log/virtualbox-sign.log"

_b() { echo -e "\033[1;34m$*\033[0m" >&2; }
_g() { echo -e "\033[1;32m$*\033[0m" >&2; }
_y() { echo -e "\033[1;33m$*\033[0m" >&2; }
_m() { echo -e "\033[1;35m$*\033[0m" >&2; }

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" >&2
}

warn() { log "AVISO: $*"; }

fail() {
    log "ERRO: $*"
    log "RESULTADO: FAIL"
    log "exit_code: 1"
    exit 1
}

pass_result() {
    log "RESULTADO: PASS"
    log "exit_code: 0"
    exit 0
}

mok_fail() {
    log "ERRO: $*"
    log "RESULTADO: FAIL_MOK"
    log "exit_code: 2"
    exit 2
}

usage() {
    grep '^#' "$0" | sed -e 's/^# \?//' -e '1,/^$/d' | head -n 22
    exit 0
}

progress_mark() {
    install -d -m 0700 "$MOK_DIR"
    grep -q "^${1}=" "$PROGRESS_FILE" 2>/dev/null \
        && sed -i "s/^${1}=.*/${1}=$(date -Iseconds)/" "$PROGRESS_FILE" \
        || echo "${1}=$(date -Iseconds)" >>"$PROGRESS_FILE"
}

secure_boot_enabled() {
    command -v mokutil >/dev/null 2>&1 \
        && mokutil --sb-state 2>/dev/null | grep -qi "enabled"
}

vbox_modules_loaded() {
    lsmod 2>/dev/null | grep -q '^vboxdrv '
}

mok_key_enrolled() {
    local out fp_der
    [[ -f "$MOK_DER" ]] || return 1
    out="$(mokutil --test-key "$MOK_DER" 2>&1 || true)"
    if echo "$out" | grep -qiE 'not enrolled|is not enrolled'; then
        return 1
    fi
    if echo "$out" | grep -qiE 'is enrolled|already enrolled'; then
        rm -f "${MOK_DIR}/.mok-import-requested"
        return 0
    fi
    fp_der="$(openssl x509 -inform DER -in "$MOK_DER" -noout -fingerprint -sha1 2>/dev/null \
        | cut -d= -f2 | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]:')"
    [[ -n "$fp_der" ]] \
        && mokutil --list-enrolled 2>/dev/null \
            | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]:' \
            | grep -q "$fp_der" \
        && { rm -f "${MOK_DIR}/.mok-import-requested"; return 0; }
    return 1
}

find_module_path() {
    local m="$1" p
    p="$(modinfo -F filename "$m" 2>/dev/null || true)"
    [[ -n "$p" && -f "$p" ]] && { echo "$p"; return 0; }
    find "/lib/modules/$(uname -r)" -name "${m}.ko" -o -name "${m}.ko.zst" 2>/dev/null | head -1
}

ensure_kernel_headers() {
    local kver hdr
    kver="$(uname -r)"
    hdr="/usr/src/linux-headers-${kver}"
    if [[ ! -d "$hdr" ]]; then
        log "Instalando linux-headers-${kver}..."
        apt-get update -qq || fail "apt-get update falhou."
        apt-get install -y -qq "linux-headers-${kver}" \
            || fail "linux-headers-${kver} ausente — kernel pode ter sido removido."
    fi
    [[ -x "${hdr}/scripts/sign-file" ]] \
        || fail "sign-file ausente em ${hdr}/scripts/sign-file"
}

run_vboxconfig() {
    log "[1/4] Recompilando módulos para kernel $(uname -r)..."
    if [[ -x /sbin/vboxconfig ]]; then
        /sbin/vboxconfig 2>&1 | tee -a "$LOG_FILE" >&2 \
            || warn "vboxconfig retornou erro — tentando assinar módulos existentes."
    elif [[ -x /usr/lib/virtualbox/vboxdrv.sh ]]; then
        /usr/lib/virtualbox/vboxdrv.sh setup 2>&1 | tee -a "$LOG_FILE" >&2 \
            || warn "vboxdrv.sh setup retornou erro."
    else
        fail "vboxconfig não encontrado — instale virtualbox primeiro."
    fi
    progress_mark "VBOXCONFIG"
}

sign_modules() {
    local kernelver signfile m modpath signed=0
    kernelver="$(uname -r)"
    signfile="/usr/src/linux-headers-${kernelver}/scripts/sign-file"
    [[ -x "$signfile" ]] || fail "sign-file ausente: ${signfile}"
    [[ -f "$MOK_PRIV" && -f "$MOK_DER" ]] \
        || fail "Chaves MOK ausentes em ${MOK_DIR} — rode whonix-install-virtualbox.sh primeiro."

    log "[2/4] Assinando módulos com chave MOK (kernel ${kernelver})..."
    for m in "${VBOX_KMODS[@]}"; do
        modpath="$(find_module_path "$m" || true)"
        if [[ -n "$modpath" && -f "$modpath" ]]; then
            if "$signfile" sha256 "$MOK_PRIV" "$MOK_DER" "$modpath"; then
                log "  Assinado: ${m} → ${modpath}"
                signed=1
            else
                warn "Falha ao assinar ${m}"
            fi
        else
            warn "Módulo ${m} não encontrado após vboxconfig."
        fi
    done
    [[ "$signed" -eq 1 ]] || fail "Nenhum módulo assinado — rode vboxconfig ou reinstale virtualbox."
    depmod -a
    progress_mark "MODULES_SIGNED"
}

load_modules() {
    local err
    log "[3/4] Carregando módulos..."
    if ! err="$(modprobe vboxdrv 2>&1)"; then
        if echo "$err" | grep -qi 'Key was rejected'; then
            if secure_boot_enabled && mok_key_enrolled; then
                fail "Key was rejected com MOK enrolada — kernel novo? Rode sem --sign-only."
            elif secure_boot_enabled; then
                mok_fail "Key was rejected — falta Enroll MOK na tela azul."
            else
                fail "modprobe vboxdrv: ${err}"
            fi
        else
            fail "modprobe vboxdrv: ${err:-falhou}"
        fi
    fi
    modprobe vboxnetflt 2>/dev/null || true
    modprobe vboxnetadp 2>/dev/null || true
    modprobe vboxpci 2>/dev/null || true
    vbox_modules_loaded || fail "vboxdrv não apareceu no lsmod após modprobe."
    progress_mark "MODULES_LOADED"
}

write_qa_log() {
    local log_dir log_file
    log_dir="${QA_LOG_DIR:-$(pwd)/qa-logs}"
    mkdir -p "$log_dir"
    log_file="${log_dir}/10-virtualbox-sign-$(date +%Y%m%d-%H%M%S).txt"
    {
        echo "=== 10-virtualbox-sign — $(date -Iseconds 2>/dev/null || date) ==="
        echo "script: whonix-sign-virtualbox-modules.sh"
        echo "host: $(hostname 2>/dev/null || echo ?)"
        echo "kernel: $(uname -r 2>/dev/null || echo ?)"
        echo "secure_boot: $(mokutil --sb-state 2>/dev/null || echo ?)"
        echo "mok_enrolled: $(mok_key_enrolled && echo SIM || echo NAO)"
        echo "lsmod vbox: $(lsmod 2>/dev/null | grep '^vbox' | tr '\n' ' ' || echo vazio)"
        echo "RESULTADO: PASS"
        echo "exit_code: 0"
        echo "--- tail sign log ---"
        tail -20 "$LOG_FILE" 2>/dev/null || true
    } >"$log_file"
    _g "  QA log: $log_file"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -y) ASSUME_YES=1; shift ;;
            --qa-log) QA_LOG=1; shift ;;
            --qa-log-dir) QA_LOG_DIR="${2:?}"; QA_LOG=1; shift 2 ;;
            --sign-only) SIGN_ONLY=1; shift ;;
            -h|--help) usage ;;
            *)
                echo "Opção desconhecida: $1" >&2
                usage
                ;;
        esac
    done
}

main() {
    parse_args "$@"

    [[ "${EUID}" -eq 0 ]] || fail "Execute como root (sudo)."
    touch "$LOG_FILE"

    _m ""
    _m "==============================================================="
    _m "  whonix-sign-virtualbox-modules.sh — assinar + carregar vbox"
    _m "==============================================================="
    _b "  Kernel: $(uname -r)"
    log "===== Hub Passo 10 — assinatura módulos VirtualBox ====="

    if vbox_modules_loaded; then
        _g "Módulos vbox já carregados — nada a fazer."
        progress_mark "MODULES_LOADED"
        [[ "$QA_LOG" -eq 1 ]] && write_qa_log
        pass_result
    fi

    if secure_boot_enabled; then
        _y "Secure Boot ON — assinatura MOK obrigatória."
        mok_key_enrolled || mok_fail "Chave MOK não enrolada — tela azul Enroll MOK primeiro."
        _g "MOK enrolada — prosseguindo com vboxconfig + sign-file."
        progress_mark "MOK_ENROLLED"
        ensure_kernel_headers
        [[ "$SIGN_ONLY" -eq 0 ]] && run_vboxconfig
        sign_modules
    else
        _g "Secure Boot OFF — vboxconfig + modprobe (sem assinatura)."
        [[ "$SIGN_ONLY" -eq 0 ]] && run_vboxconfig
    fi

    load_modules
    log "[4/4] Verificação..."
    lsmod | grep '^vbox' | tee -a "$LOG_FILE" >&2
    _g "vboxdrv carregado com sucesso."
    _b "Próximo: sudo ./whonix-verify-virtualbox-host.sh --qa-log"

    [[ "$QA_LOG" -eq 1 ]] && write_qa_log
    pass_result
}

main "$@"
