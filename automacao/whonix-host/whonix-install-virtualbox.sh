#!/usr/bin/env bash
#
# whonix-install-virtualbox.sh — Privacy-OS-Hub (host Linux)
#
# Passo 10 — pré-requisito: Oracle VirtualBox verificado no Debian/Ubuntu.
# Playbook: 🛡️ Privacy-OS-Hub - Versão 1.0.md §10.1 · automacao/whonix-host/README.md
#
# Uso:
#   sudo ./whonix-install-virtualbox.sh [-v VERSAO] [-y] [--no-extpack] [--skip-mok]
#
#   -v VERSAO       Série do VirtualBox (padrão: 7.2)
#   -y              Não pede confirmação (senha MOK ainda exige TTY interativo)
#   --no-extpack    Não instala Extension Pack (padrão: instala)
#   --skip-mok      Não tenta enroll/assinatura MOK (só avisa Secure Boot)
#   -e              Legado: força Extension Pack (redundante — já é padrão)
#
# Exit codes:
#   0 — sucesso; módulos vbox carregados (VMs podem ligar)
#   2 — pacote OK; falta reboot + Enroll MOK na tela azul (não é falha fatal)
#   1 — erro fatal
#
# Log: /var/log/virtualbox-install.log (linha RESULTADO: no final)
#
# Changelog jul/2026 v3.2.1:
#   - mokutil --import: envia senha 2× no stdin (mokutil pede confirmação)
# Changelog jul/2026 v3.2:
#   - Assistente em fases (fresh / pendente MOK / pós-reboot / completo)
#   - Retomada: pula passos 1–7 se VirtualBox já instalado
#   - Confirmação visual fingerprint Oracle (auto com -y)
#   - Oferta interativa: systemctl reboot -i (não confundir com systemctl -i)
# Changelog jul/2026 v3.1:
#   - mok_key_enrolled: parseia saída mokutil (Debian: exit 0 + "not enrolled")
#   - Extension Pack: --accept-license com -y; pula se já instalado
#   - Estado .mok-import-requested; reboot via systemctl -i no card MOK
# Changelog jul/2026 v3:
#   - Extension Pack ON por padrão; --no-extpack para pular
#   - MOK: gera chave, mokutil --import, assina módulos pós-enroll
#   - Tela azul MOK no boot continua manual (por design do firmware)
#   - RESULTADO + exit_code estruturados no log

set -euo pipefail

# ----------------------------- Configuração ------------------------------

VBOX_SERIES="7.2"
INSTALL_EXTPACK=1
ASSUME_YES=0
SKIP_MOK=0
KEYRING="/usr/share/keyrings/oracle-virtualbox.gpg"
REPO_FILE="/etc/apt/sources.list.d/virtualbox.list"
KEY_URL="https://www.virtualbox.org/download/oracle_vbox_2016.asc"
ORACLE_FPR_URL="https://www.virtualbox.org/wiki/Linux_Downloads"
EXPECTED_FPR="B9F8D658297AF3EFC18D5CDFA2F683C52980AECF"
LOG_FILE="/var/log/virtualbox-install.log"
DL_BASE="https://download.virtualbox.org/virtualbox/debian"
MOK_DIR="/root/module-signing"
MOK_PRIV="${MOK_DIR}/MOK.priv"
MOK_DER="${MOK_DIR}/MOK.der"
MOK_STATE_FILE="${MOK_DIR}/.mok-import-requested"
EXTPL_LICENSE="eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae"
NET_RETRIES=3
NET_TIMEOUT=15

SUPPORTED_CODENAMES=("trixie" "bookworm" "bullseye")
VBOX_KMODS=(vboxdrv vboxnetflt vboxnetadp vboxpci)

WARNINGS=()
TMP_PATHS=()
FINAL_RESULT=""
FINAL_EXIT=0
MOK_REBOOT_NEEDED=0
WIZARD_PHASE=""

# Fases do assistente (detecção automática):
#   fresh_install        — primeira vez; instala tudo
#   pending_mok_reboot   — mokutil --import OK; falta reboot + tela azul
#   post_reboot_sign     — chave enrolada; assinar módulos e carregar
#   installed_no_modules — pacote OK, SB off ou --skip-mok
#   complete             — vboxdrv já carregado

# ------------------------------- Funções ----------------------------------

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" >&2
}

warn() {
    log "AVISO: $*"
    WARNINGS+=("$*")
}

fail() {
    log "ERRO: $*"
    write_result "FAIL" 1
}

write_result() {
    FINAL_RESULT="$1"
    FINAL_EXIT="$2"
    log "RESULTADO: ${FINAL_RESULT}"
    log "exit_code: ${FINAL_EXIT}"
    exit "$FINAL_EXIT"
}

usage() {
    grep '^#' "$0" | sed -e 's/^# \?//' -e '1,/^$/d' | head -n 28
    exit 1
}

require_root() {
    # Com set -e + trap ERR: [[ ... ]] && fail quebra quando a condição é falsa
    # (ex.: EUID=0 com sudo). Usar || fail.
    [[ "${EUID}" -eq 0 ]] || fail "Este script precisa ser executado como root (use sudo)."
}

sanitize_stale_repo_file() {
    if [[ -f "$REPO_FILE" ]]; then
        local n_lines
        n_lines="$(wc -l < "$REPO_FILE" 2>/dev/null || echo 0)"
        if [[ "$n_lines" -ne 1 ]] || ! grep -q '^deb \[' "$REPO_FILE" 2>/dev/null; then
            warn "${REPO_FILE} corrompido/malformado — removendo antes do apt-get update. Conteúdo: $(cat "$REPO_FILE" 2>/dev/null | tr '\n' '|')"
            rm -f "$REPO_FILE"
        fi
    fi
}

on_error() {
    local exit_code=$1 line_no=$2 command=$3
    log "ERRO: comando '${command}' falhou (código ${exit_code}) na linha ${line_no}."
    log "Consulte ${LOG_FILE} para o histórico completo."
    cleanup_tmp
    write_result "FAIL" "$exit_code"
}

cleanup_tmp() {
    for p in "${TMP_PATHS[@]:-}"; do
        [[ -n "$p" && -e "$p" ]] && rm -rf "$p"
    done
}

trap 'on_error $? $LINENO "$BASH_COMMAND"' ERR
trap cleanup_tmp EXIT

fetch() {
    local url="$1" out="$2" attempt=1
    while (( attempt <= NET_RETRIES )); do
        if wget -q --timeout="$NET_TIMEOUT" --tries=1 -O "$out" "$url" && [[ -s "$out" ]]; then
            return 0
        fi
        warn "Download falhou (tentativa ${attempt}/${NET_RETRIES}): $url"
        ((attempt++))
        sleep 2
    done
    return 1
}

secure_boot_enabled() {
    command -v mokutil >/dev/null 2>&1 \
        && mokutil --sb-state 2>/dev/null | grep -qi "enabled"
}

vbox_modules_loaded() {
    lsmod | grep -qE '^vbox| vbox'
}

check_arch_and_codename() {
    local arch codename
    arch="$(dpkg --print-architecture)"
    # shellcheck disable=SC1091
    . /etc/os-release
    codename="${VERSION_CODENAME:-}"

    [[ "$arch" == "amd64" ]] || fail "Arquitetura não suportada: $arch (esperado: amd64)."
    [[ -n "$codename" ]] || fail "VERSION_CODENAME ausente em /etc/os-release."

    local supported=0 c
    for c in "${SUPPORTED_CODENAMES[@]}"; do
        [[ "$codename" == "$c" ]] && supported=1 && break
    done
    [[ "$supported" -eq 1 ]] || fail "Codename '$codename' não suportado (${SUPPORTED_CODENAMES[*]})."

    log "Sistema validado: arch=$arch codename=$codename"
    echo "$codename"
}

check_repo_availability() {
    local codename="$1"
    local release_url="${DL_BASE}/dists/${codename}/Release"
    local http_code
    log "Verificando repositório Oracle para '${codename}'..."
    http_code="$(curl -s -o /dev/null -w '%{http_code}' --max-time "$NET_TIMEOUT" "$release_url" || echo "000")"
    [[ "$http_code" == "200" ]] || fail "Repositório sem Release para '${codename}' (HTTP ${http_code})."
    log "Release OK (HTTP 200)."
}

confirm() {
    [[ "$ASSUME_YES" -eq 1 ]] && return 0
    read -r -p "$1 [s/N] " resp
    [[ "$resp" =~ ^[sSyY]$ ]]
}

virtualbox_pkg_installed() {
    dpkg -l "virtualbox-${VBOX_SERIES}" 2>/dev/null | grep -q '^ii'
}

detect_wizard_phase() {
    if vbox_modules_loaded; then
        WIZARD_PHASE="complete"
        return
    fi
    if ! virtualbox_pkg_installed; then
        WIZARD_PHASE="fresh_install"
        return
    fi
    if secure_boot_enabled && [[ "$SKIP_MOK" -eq 0 ]]; then
        [[ -f "$MOK_DER" ]] || WIZARD_PHASE="installed_need_mok"
        if [[ -z "$WIZARD_PHASE" ]]; then
            if mok_enrollment_pending; then
                WIZARD_PHASE="pending_mok_reboot"
            elif mok_key_enrolled; then
                WIZARD_PHASE="post_reboot_sign"
            else
                WIZARD_PHASE="installed_need_mok"
            fi
        fi
    else
        WIZARD_PHASE="installed_no_modules"
    fi
}

print_wizard_intro() {
    local phase_msg
    case "$WIZARD_PHASE" in
        complete)
            phase_msg="Fase: COMPLETO — módulos vbox já carregados."
            ;;
        pending_mok_reboot)
            phase_msg="Fase: AGUARDANDO REBOOT — Enroll MOK na tela azul (1 ação humana no firmware)."
            ;;
        post_reboot_sign)
            phase_msg="Fase: PÓS-REBOOT — assinando módulos com chave MOK enrolada."
            ;;
        installed_need_mok)
            phase_msg="Fase: MOK — VirtualBox instalado; falta registrar chave Secure Boot."
            ;;
        installed_no_modules)
            phase_msg="Fase: MÓDULOS — VirtualBox instalado; compilando/carregando drivers."
            ;;
        *)
            phase_msg="Fase: INSTALAÇÃO — download Oracle verificado + pacote + MOK se necessário."
            ;;
    esac
    cat >&2 <<EOF

===================================================================
  Assistente VirtualBox — Privacy-OS-Hub (Passo 10)
===================================================================
  ${phase_msg}

  Automático (script): repo Oracle · GPG · apt · DKMS · Extension Pack
  Interativo (você):   senha MOK · tela AZUL no boot · confirmação visual
                       da fingerprint Oracle (pula com -y)

  Limite do Linux: a tela azul "Enroll MOK" NÃO pode ser scriptada —
  é proteção do Secure Boot (diferente do .exe no Windows).

  Log: ${LOG_FILE}
===================================================================
EOF
    log "Assistente: ${phase_msg}"
}

confirm_fingerprint_visual() {
    local fpr="$1"
    local grouped expected_grouped
    grouped="$(echo "$fpr" | sed 's/\(..\)/\1:/g; s/:$//')"
    expected_grouped="$(echo "$EXPECTED_FPR" | sed 's/\(..\)/\1:/g; s/:$//')"
    echo "" >&2
    echo "┌─ Confirmação visual — chave Oracle (fonte oficial) ─────────" >&2
    echo "│  Site:  ${ORACLE_FPR_URL}" >&2
    echo "│  Chave: ${KEY_URL}" >&2
    echo "│  FPR obtida:  ${grouped}" >&2
    echo "│  FPR esperada: ${expected_grouped}" >&2
    echo "└─ Script já validou com GPG (fail-closed). Confira se quiser." >&2
    if [[ "$ASSUME_YES" -eq 1 ]]; then
        log "Fingerprint Oracle aceita automaticamente (-y)."
        return 0
    fi
    read -r -p "Fingerprint confere com o site oficial? [S/n] " resp
    [[ ! "$resp" =~ ^[nN]$ ]]
}

offer_reboot_now() {
    [[ "$MOK_REBOOT_NEEDED" -eq 1 ]] || return 0
    [[ -t 0 ]] || return 0
    echo "" >&2
    echo "┌─ Reiniciar agora? ───────────────────────────────────────────" >&2
    echo "│  Comando CORRETO:  sudo systemctl reboot -i" >&2
    echo "│  ERRADO:           sudo systemctl -i   (só lista serviços!)" >&2
    echo "│  Na tela azul: Enroll MOK → Continue → Yes → senha → Reboot" >&2
    echo "└──────────────────────────────────────────────────────────────" >&2
    read -r -p "Reiniciar agora com systemctl reboot -i? [s/N] " resp
    if [[ "$resp" =~ ^[sSyY]$ ]]; then
        log "Reiniciando em 5 segundos (systemctl reboot -i)..."
        sleep 5
        systemctl reboot -i
    else
        log "Reboot adiado — rode quando estiver pronto: sudo systemctl reboot -i"
    fi
}

install_build_deps() {
    log "[Passo 1/11] apt update + dependências de build (DKMS, headers, openssl)..."
    apt-get update -qq || fail "apt-get update falhou — verifique /etc/apt/sources.list.d/."
    apt-get install -y -qq \
        "linux-headers-$(uname -r)" dkms build-essential gcc make perl \
        curl wget gnupg2 openssl mokutil \
        || fail "Falha ao instalar dependências (headers/DKMS/openssl/mokutil)."
    [[ -d "/usr/src/linux-headers-$(uname -r)" ]] \
        || fail "Headers do kernel ausentes: linux-headers-$(uname -r)."
    log "Dependências OK."
}

install_and_verify_key() {
    log "[Passo 2/11] Baixando chave Oracle..."
    local tmp_key tmp_keyring fpr
    tmp_key="$(mktemp)"; TMP_PATHS+=("$tmp_key")
    fetch "$KEY_URL" "$tmp_key" || fail "Falha ao baixar chave Oracle."

    tmp_keyring="$(mktemp)"; TMP_PATHS+=("$tmp_keyring")
    gpg --dearmor --yes -o "$tmp_keyring" "$tmp_key" || fail "gpg --dearmor falhou."

    log "[Passo 3/11] Verificando fingerprint Oracle (OBRIGATÓRIO)..."
    fpr="$(gpg --show-keys --with-colons --fingerprint "$tmp_keyring" | awk -F: '/^fpr:/ {print $10; exit}')"
    [[ "$fpr" == "$EXPECTED_FPR" ]] \
        || fail "Fingerprint Oracle inválida. Esperado: $EXPECTED_FPR | Obtido: ${fpr:-<vazio>}."
    confirm_fingerprint_visual "$fpr" || fail "Instalação cancelada — fingerprint Oracle não confirmada."
    install -m 0644 "$tmp_keyring" "$KEYRING"
    log "Fingerprint Oracle OK: $fpr"
}

add_repo() {
    local codename="$1" tmp_repo
    log "[Passo 4/11] Configurando repositório para '$codename'..."
    tmp_repo="$(mktemp)"; TMP_PATHS+=("$tmp_repo")
    echo "deb [arch=amd64 signed-by=${KEYRING}] ${DL_BASE} ${codename} contrib" >"$tmp_repo"
    [[ "$(wc -l <"$tmp_repo")" -eq 1 ]] && grep -q '^deb \[' "$tmp_repo" \
        || fail "Linha de repo inválida: $(cat "$tmp_repo")"
    install -m 0644 "$tmp_repo" "$REPO_FILE"
    log "Repo: $(cat "$REPO_FILE")"
}

verify_repo_signature() {
    log "[Passo 5/11] apt-get update + verificação de assinatura do repo..."
    local update_out apt_status
    update_out="$(mktemp)"; TMP_PATHS+=("$update_out")
    set +e
    apt-get update 2>&1 | tee -a "$LOG_FILE" >"$update_out"
    apt_status=${PIPESTATUS[0]}
    set -e
    [[ "$apt_status" -eq 0 ]] || fail "apt-get update falhou (exit ${apt_status}): $(tail -n 5 "$update_out")"
    if grep -qiE "NO_PUBKEY|BADSIG" "$update_out"; then
        fail "NO_PUBKEY/BADSIG no repositório VirtualBox."
    fi
    log "Índice apt OK; sem NO_PUBKEY/BADSIG."
}

install_virtualbox() {
    local pkg="virtualbox-${VBOX_SERIES}"
    log "[Passo 6/11] Instalando ${pkg}..."
    apt-cache policy "$pkg" | grep -q "download.virtualbox.org" \
        || fail "${pkg} não disponível no repo Oracle para este codename."
    apt-get install -y "$pkg" || fail "apt-get install ${pkg} falhou."
    log "Pacote ${pkg} instalado."
}

run_full_install_pipeline() {
    local codename="$1"
    confirm "Instalar virtualbox-${VBOX_SERIES} no Debian '${codename}'?" \
        || { log "Cancelado."; exit 0; }
    install_build_deps
    install_and_verify_key
    add_repo "$codename"
    verify_repo_signature
    install_virtualbox
    configure_vboxusers
}

run_resume_pipeline() {
    log "Retomada automática: VirtualBox já instalado — pulando passos 1–7."
    configure_vboxusers
}

configure_vboxusers() {
    log "[Passo 7/11] Grupo vboxusers..."
    local target_user="${SUDO_USER:-$USER}"
    if [[ "$target_user" == "root" ]]; then
        warn "usuário root — pulei vboxusers."
    elif usermod -aG vboxusers "$target_user"; then
        log "Usuário '$target_user' → vboxusers (relogin necessário)."
    else
        warn "Falha ao adicionar '$target_user' ao grupo vboxusers."
    fi
    if command -v kvm-ok >/dev/null 2>&1 || lsmod | grep -qE '^kvm_intel|^kvm_amd'; then
        warn "KVM carregado — pode conflitar com VirtualBox em Debian 13+."
    fi
}

ensure_mok_keypair() {
    if [[ -f "$MOK_PRIV" && -f "$MOK_DER" ]]; then
        log "Par MOK já existe em ${MOK_DIR}."
        chmod 600 "$MOK_PRIV"
        return 0
    fi
    log "Gerando par de chaves MOK em ${MOK_DIR}..."
    install -d -m 0700 "$MOK_DIR"
    openssl req -new -x509 -newkey rsa:2048 \
        -keyout "$MOK_PRIV" -outform DER -out "$MOK_DER" \
        -nodes -days 36500 -subj "/CN=VirtualBox MOK Privacy-OS-Hub/" \
        || fail "openssl falhou ao gerar par MOK."
    chmod 600 "$MOK_PRIV"
    chmod 644 "$MOK_DER"
    log "Par MOK gerado (MOK.priv + MOK.der)."
}

mok_test_key_output() {
    # Debian trixie: mokutil --test-key imprime "is not enrolled" mas sai com exit 0.
    # Nunca confiar só no exit code — parsear a mensagem.
    [[ -f "$MOK_DER" ]] || return 1
    command -v mokutil >/dev/null 2>&1 || return 1
    mokutil --test-key "$MOK_DER" 2>&1
}

mok_enrollment_pending() {
    [[ -f "$MOK_STATE_FILE" ]] && return 0
    command -v mokutil >/dev/null 2>&1 \
        && mokutil --list-new 2>/dev/null | grep -q .
}

mok_key_enrolled() {
    local out fp_der
    [[ -f "$MOK_DER" ]] || return 1
    out="$(mok_test_key_output 2>/dev/null || true)"
    if echo "$out" | grep -qiE 'not enrolled|is not enrolled'; then
        return 1
    fi
    if echo "$out" | grep -qiE 'is enrolled|already enrolled'; then
        rm -f "$MOK_STATE_FILE"
        return 0
    fi
    # Fallback: SHA1 do nosso .der aparece em --list-enrolled
    fp_der="$(openssl x509 -inform DER -in "$MOK_DER" -noout -fingerprint -sha1 2>/dev/null \
        | cut -d= -f2 | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]:')"
    [[ -n "$fp_der" ]] \
        && mokutil --list-enrolled 2>/dev/null \
            | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]:' \
            | grep -q "$fp_der" \
        && { rm -f "$MOK_STATE_FILE"; return 0; }
    return 1
}

mark_mok_import_pending() {
    install -d -m 0700 "$MOK_DIR"
    date -Iseconds >"$MOK_STATE_FILE"
}

print_mok_reboot_card() {
    cat >&2 <<'EOF'

===================================================================
  REBOOT OBRIGATÓRIO — Enroll MOK (ação humana no firmware)
===================================================================
  VirtualBox no Linux com Secure Boot ≠ .exe do Windows: o kernel só
  aceita módulos assinados com SUA chave MOK enrolada no firmware.

  O pacote já está instalado. Falta 1 reboot + confirmação na tela azul.

  1) Reinicie (GNOME pode bloquear "sudo reboot" — use uma destas):
       sudo systemctl reboot -i
     ou feche apps e: sudo reboot

  2) No boot, tela AZUL "MOK Management" (só neste reboot):
       Enroll MOK → Continue → Yes → senha MOK → Reboot

  3) De volta ao Debian, rode ESTE SCRIPT DE NOVO (só comandos, não texto):
       cd ~/Downloads/Privacy-OS-Hub/automacao/whonix-host
       sudo ./whonix-install-virtualbox.sh -y
       lsmod | grep vbox

  Esperado: RESULTADO: PASS · exit 0 · vboxdrv listado.

  A tela azul não pode ser automatizada — é proteção do Secure Boot.
===================================================================
EOF
}

enroll_mok_key() {
    local pw1 pw2 import_out import_rc=0
    log "Registrando chave MOK no firmware (mokutil --import)..."
    if [[ ! -t 0 ]]; then
        warn "Sem TTY — não consigo pedir senha MOK. Rode manualmente:"
        warn "  sudo mokutil --import ${MOK_DER}"
        warn "  sudo systemctl reboot -i  →  Enroll MOK na tela azul  →  rode este script de novo"
        mark_mok_import_pending
        MOK_REBOOT_NEEDED=1
        return 1
    fi
    echo "" >&2
    echo "=== Secure Boot: defina senha MOK (mesma senha na tela AZUL do boot) ===" >&2
    read -r -s -p "Senha MOK: " pw1; echo >&2
    read -r -s -p "Confirme senha MOK: " pw2; echo >&2
    [[ "$pw1" == "$pw2" && -n "$pw1" ]] || fail "Senhas MOK não conferem ou vazias."
    # mokutil --import pede senha duas vezes (input password / input password again)
    import_out="$(printf '%s\n%s\n' "$pw1" "$pw2" | mokutil --import "$MOK_DER" 2>&1)" || import_rc=$?
    if [[ "$import_rc" -ne 0 ]]; then
        if echo "$import_out" | grep -qiE 'already in the enrollment request|already enrolled'; then
            log "Chave MOK já agendada para enroll — falta reboot + tela azul."
            mark_mok_import_pending
            MOK_REBOOT_NEEDED=1
            return 0
        fi
        fail "mokutil --import falhou: ${import_out}"
    fi
    log "mokutil --import OK — reboot necessário para Enroll MOK."
    mark_mok_import_pending
    MOK_REBOOT_NEEDED=1
}

sign_vbox_kernel_modules() {
    local kernelver signfile mod m modpath signed=0
    kernelver="$(uname -r)"
    signfile="/usr/src/linux-headers-${kernelver}/scripts/sign-file"
    [[ -x "$signfile" ]] || fail "sign-file ausente: ${signfile}"

    log "Assinando módulos DKMS VirtualBox com chave MOK..."
    for m in "${VBOX_KMODS[@]}"; do
        modpath="$(modinfo -F filename "$m" 2>/dev/null || true)"
        if [[ -n "$modpath" && -f "$modpath" ]]; then
            "$signfile" sha256 "$MOK_PRIV" "$MOK_DER" "$modpath" \
                && log "  Assinado: $m → $modpath" \
                || warn "Falha ao assinar $m"
            signed=1
        fi
    done
    [[ "$signed" -eq 1 ]] || warn "Nenhum módulo vbox encontrado para assinar — rode /sbin/vboxconfig primeiro."
    depmod -a
}

run_vboxconfig() {
    if [[ -x /sbin/vboxconfig ]]; then
        log "Executando /sbin/vboxconfig..."
        /sbin/vboxconfig 2>&1 | tee -a "$LOG_FILE" >&2 || warn "vboxconfig retornou erro."
    elif [[ -x /usr/lib/virtualbox/vboxdrv.sh ]]; then
        /usr/lib/virtualbox/vboxdrv.sh setup 2>&1 | tee -a "$LOG_FILE" >&2 \
            || warn "vboxdrv.sh setup retornou erro."
    else
        warn "vboxconfig não encontrado — módulos podem já estar compilados."
    fi
}

load_vbox_modules() {
    local err
    if ! err="$(modprobe vboxdrv 2>&1)"; then
        if echo "$err" | grep -qi 'Key was rejected'; then
            warn "vboxdrv: assinatura rejeitada (Secure Boot) — falta Enroll MOK no reboot."
            MOK_REBOOT_NEEDED=1
        else
            warn "modprobe vboxdrv: ${err:-falhou}"
        fi
    fi
    modprobe vboxnetflt 2>/dev/null || true
    modprobe vboxnetadp 2>/dev/null || true
    modprobe vboxpci 2>/dev/null || true
}

handle_secure_boot_modules() {
    log "[Passo 8/11] Módulos kernel (DKMS / Secure Boot / MOK)..."

    if vbox_modules_loaded; then
        log "Módulos vbox já carregados — OK."
        return 0
    fi

    if [[ "$SKIP_MOK" -eq 1 ]]; then
        run_vboxconfig
        load_vbox_modules
        if ! vbox_modules_loaded; then
            warn "Módulos vbox ausentes (--skip-mok). Desabilite Secure Boot ou rode sem --skip-mok."
        fi
        return 0
    fi

    if ! secure_boot_enabled; then
        log "Secure Boot desligado — vboxconfig + modprobe."
        run_vboxconfig
        load_vbox_modules
        vbox_modules_loaded || warn "vboxdrv ainda não carregou — verifique DKMS/dmesg."
        return 0
    fi

    log "Secure Boot HABILITADO — fluxo MOK (Linux ≠ .exe do Windows)."
    ensure_mok_keypair

    if mok_enrollment_pending; then
        warn "Enroll MOK pendente — falta reboot + confirmação na tela azul."
        print_mok_reboot_card
        MOK_REBOOT_NEEDED=1
        offer_reboot_now
        return 0
    fi

    run_vboxconfig

    if mok_key_enrolled; then
        log "Chave MOK enrolada no firmware — assinando módulos..."
        sign_vbox_kernel_modules
        load_vbox_modules
        if vbox_modules_loaded; then
            log "Módulos vbox carregados após assinatura MOK."
            return 0
        fi
        if ! mok_key_enrolled; then
            warn "Chave MOK não enrolada no firmware — falta reboot + tela azul Enroll MOK."
            MOK_REBOOT_NEEDED=1
            print_mok_reboot_card
            offer_reboot_now
            return 0
        fi
        warn "Módulos ainda não carregaram após assinatura — kernel novo? Rode o script de novo."
        return 0
    fi

    enroll_mok_key || true
    if [[ "$MOK_REBOOT_NEEDED" -eq 1 ]]; then
        print_mok_reboot_card
        offer_reboot_now
    fi
}

install_extpack() {
    local pkg="virtualbox-${VBOX_SERIES}" full_version tmp_dir extpack_file extpack_url
    local extpack_args=(extpack install --replace)
    log "[Passo 9/11] Extension Pack (padrão ON)..."
    full_version="$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null | cut -d: -f2 | cut -d- -f1)"
    [[ -n "$full_version" ]] || { warn "Versão do pacote ausente — pulando Extension Pack."; return; }

    if VBoxManage list extpacks 2>/dev/null | grep -q "Oracle VirtualBox Extension Pack"; then
        if VBoxManage list extpacks 2>/dev/null | grep -A2 "Oracle VirtualBox Extension Pack" | grep -q "Usable"; then
            log "Extension Pack ${full_version} já instalado — pulando."
            return
        fi
    fi

    tmp_dir="$(mktemp -d)"; TMP_PATHS+=("$tmp_dir")
    extpack_file="Oracle_VirtualBox_Extension_Pack-${full_version}.vbox-extpack"
    extpack_url="https://download.virtualbox.org/virtualbox/${full_version}/${extpack_file}"

    [[ "$ASSUME_YES" -eq 1 ]] && extpack_args+=(--accept-license="$EXTPL_LICENSE")

    if fetch "$extpack_url" "${tmp_dir}/${extpack_file}"; then
        if VBoxManage "${extpack_args[@]}" "${tmp_dir}/${extpack_file}"; then
            log "Extension Pack ${full_version} instalado."
        else
            warn "VBoxManage extpack install retornou erro."
        fi
    else
        warn "Download do Extension Pack falhou: ${extpack_url}"
    fi
}

verify_installation() {
    log "[Passo 10/11] Verificação final..."
    VBoxManage --version 2>&1 | tee -a "$LOG_FILE" >&2 || warn "VBoxManage não respondeu."
    if vbox_modules_loaded; then
        lsmod | grep vbox | tee -a "$LOG_FILE" >&2
        log "lsmod: módulos vbox presentes."
    else
        warn "lsmod: módulos vbox AUSENTES — VMs não ligam até resolver MOK/SB."
    fi
}

print_summary() {
    local next_action="Relogin (vboxusers) → whonix-import-ova.sh"
    echo "" >&2
    log "===== Resumo [11/11] ====="
    if vbox_modules_loaded; then
        log "Módulos kernel: OK (vboxdrv carregado)"
    elif [[ "$MOK_REBOOT_NEEDED" -eq 1 ]]; then
        log "Módulos kernel: PENDENTE_REBOOT_MOK"
        next_action="sudo systemctl reboot -i → Enroll MOK (tela azul) → rode este script de novo"
    else
        log "Módulos kernel: AUSENTE (verifique Secure Boot / DKMS)"
        next_action="Revise avisos acima ou use --skip-mok + desabilite SB na BIOS"
    fi
    if [[ "${#WARNINGS[@]}" -gt 0 ]]; then
        log "Avisos (${#WARNINGS[@]}):"
        for w in "${WARNINGS[@]}"; do log "  - $w"; done
    fi
    log "Próximo passo: ${next_action}"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v) VBOX_SERIES="${2:?}"; shift 2 ;;
            -y) ASSUME_YES=1; shift ;;
            -e) INSTALL_EXTPACK=1; shift ;;
            --no-extpack) INSTALL_EXTPACK=0; shift ;;
            --skip-mok) SKIP_MOK=1; shift ;;
            -h|--help) usage ;;
            *)
                echo "Opção desconhecida: $1" >&2
                usage
                ;;
        esac
    done
}

# -------------------------------- Main -------------------------------------

parse_args "$@"

require_root
sanitize_stale_repo_file
touch "$LOG_FILE"
log "===== Hub Passo 10 — VirtualBox (série ${VBOX_SERIES}) extpack=${INSTALL_EXTPACK} skip_mok=${SKIP_MOK} ====="

CODENAME="$(check_arch_and_codename)"
log "Codename: '${CODENAME}'"
detect_wizard_phase
print_wizard_intro

case "$WIZARD_PHASE" in
    complete)
        log "Retomada: sistema já pronto — verificação rápida."
        verify_installation
        print_summary
        write_result "PASS" 0
        ;;
    pending_mok_reboot)
        check_repo_availability "$CODENAME" 2>/dev/null || true
        print_mok_reboot_card
        MOK_REBOOT_NEEDED=1
        verify_installation
        print_summary
        offer_reboot_now
        write_result "PASS_PENDING_MOK_REBOOT" 2
        ;;
    fresh_install)
        check_repo_availability "$CODENAME"
        run_full_install_pipeline "$CODENAME"
        handle_secure_boot_modules
        [[ "$INSTALL_EXTPACK" -eq 1 ]] && install_extpack
        verify_installation
        print_summary
        ;;
    post_reboot_sign|installed_need_mok|installed_no_modules)
        check_repo_availability "$CODENAME" 2>/dev/null || true
        run_resume_pipeline
        handle_secure_boot_modules
        [[ "$INSTALL_EXTPACK" -eq 1 ]] && install_extpack
        verify_installation
        print_summary
        ;;
    *)
        fail "Fase do assistente desconhecida: ${WIZARD_PHASE}"
        ;;
esac

log "===== Hub Passo 10 — pacote instalado. Ver RESULTADO abaixo. ====="

if vbox_modules_loaded; then
    write_result "PASS" 0
elif [[ "$MOK_REBOOT_NEEDED" -eq 1 ]]; then
    write_result "PASS_PENDING_MOK_REBOOT" 2
else
    write_result "PASS_MODULES_MISSING" 2
fi
