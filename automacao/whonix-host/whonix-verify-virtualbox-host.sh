#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Privacy-OS-Hub contributors
#
# whonix-verify-virtualbox-host.sh — Privacy-OS-Hub
#
# Validação pós-instalação do VirtualBox no HOST Linux (Debian/Ubuntu)
# com Secure Boot + MOK. Rode DEPOIS da tela azul Enroll MOK.
#
# Uso:
#   sudo ./whonix-verify-virtualbox-host.sh
#   sudo ./whonix-verify-virtualbox-host.sh --qa-log
#
# Exit codes:
#   0 — PASS (todos os checks críticos OK)
#   1 — FAIL (algum check crítico falhou)
#   2 — PASS_PARCIAL (VB instalado; falta MOK/reboot — não é erro fatal)

set -euo pipefail

VBOX_SERIES="${VBOX_SERIES:-7.2}"
MOK_DER="/root/module-signing/MOK.der"
INSTALL_LOG="/var/log/virtualbox-install.log"
QA_LOG=0
QA_LOG_DIR=""

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0
CHECK_LINES=()

b() { echo -e "\033[1;34m$*\033[0m"; }
g() { echo -e "\033[1;32m$*\033[0m"; }
y() { echo -e "\033[1;33m$*\033[0m"; }
r() { echo -e "\033[1;31m$*\033[0m"; }
m() { echo -e "\033[1;35m$*\033[0m"; }

usage() {
    grep '^#' "$0" | sed -e 's/^# \?//' -e '1,/^$/d' | head -n 18
    exit 0
}

record_check() {
    local status="$1" label="$2" detail="$3"
    CHECK_LINES+=("${status}|${label}|${detail}")
    case "$status" in
        PASS) PASS_COUNT=$((PASS_COUNT + 1)); g "  [PASS] ${label}: ${detail}" ;;
        FAIL) FAIL_COUNT=$((FAIL_COUNT + 1)); r "  [FAIL] ${label}: ${detail}" ;;
        WARN) WARN_COUNT=$((WARN_COUNT + 1)); y "  [WARN] ${label}: ${detail}" ;;
        SKIP) y "  [SKIP] ${label}: ${detail}" ;;
    esac
}

secure_boot_enabled() {
    command -v mokutil >/dev/null 2>&1 \
        && mokutil --sb-state 2>/dev/null | grep -qi "enabled"
}

mok_key_enrolled() {
    local out
    [[ -f "$MOK_DER" ]] || return 1
    command -v mokutil >/dev/null 2>&1 || return 1
    out="$(mokutil --test-key "$MOK_DER" 2>&1 || true)"
    if echo "$out" | grep -qiE 'not enrolled|is not enrolled'; then
        return 1
    fi
    echo "$out" | grep -qiE 'is enrolled|already enrolled'
}

vbox_modules_loaded() {
    lsmod 2>/dev/null | grep -q '^vboxdrv '
}

check_secure_boot() {
    b "[1/8] Secure Boot..."
    if ! command -v mokutil >/dev/null 2>&1; then
        record_check SKIP "mokutil" "comando ausente"
        return
    fi
    local sb
    sb="$(mokutil --sb-state 2>/dev/null || true)"
    if echo "$sb" | grep -qi "enabled"; then
        record_check PASS "Secure Boot" "$sb"
    elif echo "$sb" | grep -qi "disabled"; then
        record_check WARN "Secure Boot" "desligado — MOK não é obrigatório"
    else
        record_check WARN "Secure Boot" "${sb:-estado desconhecido}"
    fi
}

check_mok_enrolled() {
    b "[2/8] Chave MOK no firmware..."
    if ! secure_boot_enabled; then
        record_check SKIP "MOK enrolada" "Secure Boot off"
        return
    fi
    if [[ ! -f "$MOK_DER" ]]; then
        record_check FAIL "MOK.der" "ausente em ${MOK_DER}"
        return
    fi
    local out cn
    cn="$(openssl x509 -inform DER -in "$MOK_DER" -noout -subject 2>/dev/null \
        | sed 's/subject=//' || echo '?')"
    out="$(mokutil --test-key "$MOK_DER" 2>&1 || true)"
    if mok_key_enrolled; then
        record_check PASS "MOK enrolada" "$cn"
    else
        record_check FAIL "MOK enrolada" "$(echo "$out" | head -1) — falta tela azul Enroll MOK"
    fi
}

check_vbox_package() {
    b "[3/8] Pacote VirtualBox..."
    local pkg="virtualbox-${VBOX_SERIES}" ver
    if dpkg -l "$pkg" 2>/dev/null | grep -q '^ii'; then
        ver="$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null || echo '?')"
        record_check PASS "pacote ${pkg}" "$ver"
    else
        record_check FAIL "pacote ${pkg}" "não instalado — rode whonix-install-virtualbox.sh"
    fi
}

check_vboxmanage() {
    b "[4/8] VBoxManage..."
    local ver
    if command -v VBoxManage >/dev/null 2>&1; then
        ver="$(VBoxManage --version 2>/dev/null || echo '?')"
        record_check PASS "VBoxManage" "$ver"
    else
        record_check FAIL "VBoxManage" "comando ausente"
    fi
}

check_vbox_modules() {
    b "[5/8] Módulos kernel vbox..."
    if vbox_modules_loaded; then
        record_check PASS "vboxdrv" "$(lsmod | grep '^vbox' | tr '\n' ' ')"
    else
        if secure_boot_enabled && ! mok_key_enrolled; then
            record_check FAIL "vboxdrv" "não carregado — enrol MOK na tela azul primeiro"
        else
            local err
            err="$(modprobe vboxdrv 2>&1 || true)"
            if vbox_modules_loaded; then
                record_check PASS "vboxdrv" "carregado após modprobe"
            elif echo "$err" | grep -qi 'Key was rejected'; then
                record_check FAIL "vboxdrv" "Key was rejected — MOK não enrolada ou kernel novo"
            else
                record_check FAIL "vboxdrv" "${err:-não carregado — rode whonix-install-virtualbox.sh -y}"
            fi
        fi
    fi
}

check_extpack() {
    b "[6/8] Extension Pack..."
    if ! command -v VBoxManage >/dev/null 2>&1; then
        record_check SKIP "Extension Pack" "VBoxManage ausente"
        return
    fi
    if VBoxManage list extpacks 2>/dev/null | grep -A3 "Oracle VirtualBox Extension Pack" | grep -q "Usable"; then
        record_check PASS "Extension Pack" "instalado e utilizável"
    else
        record_check WARN "Extension Pack" "ausente ou não utilizável (USB 2.0 etc.)"
    fi
}

check_install_log() {
    b "[7/8] Log do instalador..."
    if [[ ! -f "$INSTALL_LOG" ]]; then
        record_check WARN "install log" "${INSTALL_LOG} ausente"
        return
    fi
    local resultado exit_code
    resultado="$(grep 'RESULTADO:' "$INSTALL_LOG" 2>/dev/null | tail -1 | awk '{print $2}' || true)"
    exit_code="$(grep 'exit_code:' "$INSTALL_LOG" 2>/dev/null | tail -1 | awk '{print $2}' || true)"
    if [[ "$resultado" == "PASS" && "$exit_code" == "0" ]]; then
        record_check PASS "install log" "RESULTADO: PASS exit_code: 0"
    elif [[ "$resultado" == "PASS_PENDING_MOK_REBOOT" ]]; then
        record_check WARN "install log" "RESULTADO: PASS_PENDING_MOK_REBOOT — falta tela azul"
    else
        record_check WARN "install log" "último: ${resultado:-?} exit_code: ${exit_code:-?}"
    fi
}

check_vboxusers() {
    b "[8/8] Grupo vboxusers..."
    local user="${SUDO_USER:-${USER:-}}"
    if [[ -z "$user" || "$user" == "root" ]]; then
        record_check SKIP "vboxusers" "rode sem sudo ou com SUDO_USER definido"
        return
    fi
    if id -nG "$user" 2>/dev/null | grep -qw vboxusers; then
        record_check PASS "vboxusers" "$user é membro"
    else
        record_check WARN "vboxusers" "$user não está no grupo — relogin após install"
    fi
}

write_qa_log() {
    local log_dir log_file final_result exit_code
    log_dir="${QA_LOG_DIR:-$(pwd)/qa-logs}"
    mkdir -p "$log_dir"
    log_file="${log_dir}/10-virtualbox-host-$(date +%Y%m%d-%H%M%S).txt"
    if [[ "$FAIL_COUNT" -gt 0 ]]; then
        final_result="FAIL"
        exit_code=1
    elif vbox_modules_loaded && { ! secure_boot_enabled || mok_key_enrolled; }; then
        final_result="PASS"
        exit_code=0
    else
        final_result="PASS_PARCIAL"
        exit_code=2
    fi
    {
        echo "=== 10-virtualbox-host — $(date -Iseconds 2>/dev/null || date) ==="
        echo "script: whonix-verify-virtualbox-host.sh"
        echo "host: $(hostname 2>/dev/null || echo ?)"
        echo "kernel: $(uname -r 2>/dev/null || echo ?)"
        echo "secure_boot: $(mokutil --sb-state 2>/dev/null || echo ?)"
        echo "--- checks ---"
        for line in "${CHECK_LINES[@]}"; do
            echo "$line" | tr '|' ' '
        done
        echo "---"
        echo "PASS: ${PASS_COUNT}  FAIL: ${FAIL_COUNT}  WARN: ${WARN_COUNT}"
        echo "RESULTADO: ${final_result}"
        echo "exit_code: ${exit_code}"
        if [[ -f "$INSTALL_LOG" ]]; then
            echo "--- tail install log ---"
            tail -15 "$INSTALL_LOG"
        fi
    } >"$log_file"
    g "  QA log: $log_file"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --qa-log) QA_LOG=1; shift ;;
            --qa-log-dir) QA_LOG_DIR="${2:?}"; QA_LOG=1; shift 2 ;;
            -h|--help) usage ;;
            *)
                r "Opção desconhecida: $1"
                usage
                ;;
        esac
    done
}

main() {
    parse_args "$@"

    echo ""
    m "==============================================================="
    m "  whonix-verify-virtualbox-host.sh — validação host (Passo 10)"
    m "==============================================================="
    echo ""

    check_secure_boot
    check_mok_enrolled
    check_vbox_package
    check_vboxmanage
    check_vbox_modules
    check_extpack
    check_install_log
    check_vboxusers

    echo ""
    m "----- Resumo -----"
    g "  PASS: ${PASS_COUNT}"
    [[ "$WARN_COUNT" -gt 0 ]] && y "  WARN: ${WARN_COUNT}"
    [[ "$FAIL_COUNT" -gt 0 ]] && r "  FAIL: ${FAIL_COUNT}"
    echo ""

    local final_exit=0
    if [[ "$FAIL_COUNT" -gt 0 ]]; then
        r "RESULTADO: FAIL — corrija os itens [FAIL] acima."
        r "  Próximo: sudo ./whonix-install-virtualbox.sh -y"
        final_exit=1
    elif vbox_modules_loaded && { ! secure_boot_enabled || mok_key_enrolled; }; then
        g "RESULTADO: PASS — VirtualBox funcional no host."
        g "  Próximo: whonix-verify-image.sh → whonix-import-ova.sh"
        final_exit=0
    else
        y "RESULTADO: PASS_PARCIAL — pacote OK; falta concluir MOK ou carregar módulos."
        y "  Próximo: sudo ./whonix-install-virtualbox.sh -y"
        final_exit=2
    fi

    [[ "$QA_LOG" -eq 1 ]] && write_qa_log
    exit "$final_exit"
}

main "$@"
