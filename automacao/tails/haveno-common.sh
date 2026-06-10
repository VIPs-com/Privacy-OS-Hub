# haveno-common.sh — funcoes compartilhadas (source, nao execute direto)
# Uso: source "$(dirname "$0")/haveno-common.sh"

PERSIST="${PERSIST:-/home/amnesia/Persistent}"
HAVENO_DIR="${HAVENO_DIR:-${PERSIST}/haveno}"
UTILS_DIR="${UTILS_DIR:-${HAVENO_DIR}/App/utils}"
DOTFILES_DIR="${DOTFILES_DIR:-/live/persistence/TailsData_unlocked/dotfiles}"
ONION_GRATER_DST="${ONION_GRATER_DST:-/etc/onion-grater.d/haveno.yml}"
TOR_COOKIE="${TOR_COOKIE:-/var/run/tor/control.authcookie}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
die(){ r "ERRO: $*"; exit 1; }

# Retorna 0 se OK; imprime falhas em stderr
tails_preflight_check() {
  local fail=0
  local -a fails=()

  if [ -f /etc/os-release ] && grep -qi "tails" /etc/os-release; then
    g "  [OK] Tails detectado."
  else
    y "  [??] Nao parece Tails — siga so se souber o que faz."
  fi

  if [ "$(whoami)" = "amnesia" ]; then
    g "  [OK] Usuario amnesia."
  else
    fails+=("Usuario nao e 'amnesia' (esperado no Tails).")
    fail=1
  fi

  if sudo -v 2>/dev/null; then
    g "  [OK] Senha admin ativa."
  else
    fails+=("Senha admin inativa — reinicie e use '+ Mais opcoes' na tela de boas-vindas (Playbooks §4).")
    fail=1
  fi

  if [ -d "$PERSIST" ]; then
    g "  [OK] Persistencia montada ($PERSIST)."
  else
    fails+=("Persistencia ausente ($PERSIST) — Playbooks §3.")
    fail=1
  fi

  if [ -d "$DOTFILES_DIR" ]; then
    g "  [OK] Dotfiles ativo."
  else
    fails+=("Dotfiles nao ativado — marque em Armazenamento Persistente e reinicie (Playbooks §3).")
    fail=1
  fi

  sudo timedatectl set-timezone UTC 2>/dev/null || true
  local tzn
  tzn="$(timedatectl show -p Timezone --value 2>/dev/null || echo '?')"
  if [ "$tzn" = "UTC" ]; then
    g "  [OK] Fuso UTC ($tzn)."
  else
    g "  [OK] Fuso: $tzn (UTC ajustado se possivel)."
  fi

  local tor_ok=0 elapsed=0 tor_max="${TOR_MAX:-120}"
  b "  Aguardando Tor (ate ${tor_max}s)..."
  while [ "$elapsed" -lt "$tor_max" ]; do
    if curl -s --socks5-hostname 127.0.0.1:9050 --max-time 12 https://check.torproject.org/api/ip 2>/dev/null | grep -q '"IsTor":true'; then
      tor_ok=1
      break
    fi
    sleep 5
    elapsed=$((elapsed + 5))
  done
  if [ "$tor_ok" = "1" ]; then
    g "  [OK] Tor conectado (IsTor: true)."
    if sudo journalctl -u tor@default -b --no-pager 2>/dev/null | grep -q "Bootstrapped 100%"; then
      g "  [OK] Tor bootstrap 100% no log."
    else
      y "  [??] Bootstrap 100% ainda nao no log — IsTor OK, seguindo."
    fi
  else
    fails+=("Tor nao conectou em ${tor_max}s — assistente 'Conexao a rede Tor' (Playbooks §2).")
    fail=1
  fi

  if [ "$fail" = "1" ]; then
    r "Preflight FALHOU:"
    for msg in "${fails[@]}"; do r "  - $msg"; done
    y "  Playbook: modulos/m1-tails-haveno/Playbooks/Playbooks.md §1–4"
    return 1
  fi
  return 0
}

# Dependencias do .deb Haveno 1.6.0-reto no Tails 7.8+ (Debian 13 Trixie).
# O install.sh upstream so faz dpkg -i; o hub instala isto antes (idempotente).
HAVENO_DEB_DEPS=(
  libavcodec60 libavformat60 libavutil58 libicu74
  libjpeg-turbo8 libjxl0.7 libmbedcrypto7t64 librav1e0
  libssh-gcrypt-4 libsvtav1enc1d1 libswresample4 libx265-199
)

haveno_ensure_deb_deps() {
  if ! command -v apt-get >/dev/null 2>&1; then
    y "  apt-get ausente — ambiente nao-Debian; pulando deps."
    return 0
  fi
  b "  Dependencias do .deb (apt)..."
  y "  O install.sh oficial so roda dpkg -i; no Tails as libs nao vem pre-instaladas."
  y "  Sem 'Software adicional' persistido, o apt repete a cada boot — automatico e rapido se ja instaladas."
  y "  NAO rode 'apt-get install -f' ANTES disto com haveno desconfigurado — pode REMOVER o pacote."
  sudo apt-get update -qq 2>/dev/null || y "  apt-get update falhou (rede?) — tentando install mesmo assim."
  if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${HAVENO_DEB_DEPS[@]}"; then
    r "  Falha ao instalar dependencias do .deb."
    y "  Veja Cap. 7 FAQ 7.11 (Curso-Tails-OS-Expert.md) ou ative Software adicional na persistencia."
    return 1
  fi
  g "  Dependencias do .deb OK."
  return 0
}

haveno_run_install() {
  local utils="${UTILS_DIR}"
  [ -f "${utils}/install.sh" ] || die "install.sh nao encontrado. Rode haveno-auto.sh primeiro."
  haveno_ensure_deb_deps || die "Dependencias do .deb nao instaladas."
  b "Rodando install.sh (pkexec — pode pedir senha admin)..."
  chmod +x "${utils}/install.sh" 2>/dev/null || true
  sudo "${utils}/install.sh" || die "install.sh falhou."
}

haveno_check_installed() {
  [ -f "${UTILS_DIR}/exec.sh" ] && [ -f "${UTILS_DIR}/install.sh" ] && [ -f "${UTILS_DIR}/haveno.yml" ]
}

haveno_check_filter() {
  sudo journalctl -u onion-grater -b --no-pager 2>/dev/null | tail -40
}

haveno_fix_onion_grater() {
  local utils="${UTILS_DIR}"
  if haveno_check_filter | grep -q "loaded filter: haveno"; then
    g "  loaded filter: haveno (OK)."
    return 0
  fi
  y "  Aplicando correcao onion-grater..."
  sudo cp "${utils}/haveno.yml" "$ONION_GRATER_DST" 2>/dev/null || true
  [ -e "$TOR_COOKIE" ] && sudo chmod o+r "$TOR_COOKIE" 2>/dev/null || true
  if python3 -c "import yaml; yaml.safe_load(open('${ONION_GRATER_DST}')); print('YAML OK')" 2>/dev/null; then
    g "  YAML OK."
  else
    sudo cp "${utils}/haveno.yml" "$ONION_GRATER_DST"
  fi
  sudo systemctl restart onion-grater 2>/dev/null || true
  sleep 4
  if haveno_check_filter | grep -q "loaded filter: haveno"; then
    g "  Corrigido: loaded filter: haveno."
    return 0
  fi
  y "  Ainda sem 'loaded filter: haveno'. Veja Playbooks §8 ou Cap. 7 FAQ."
  return 1
}

# Playbook §7: install.sh + exec.sh
haveno_session_boot() {
  local utils="${UTILS_DIR}"
  [ -f "${utils}/exec.sh" ] || die "exec.sh nao encontrado."

  haveno_run_install

  b "Abrindo Haveno (exec.sh)..."
  chmod +x "${utils}/exec.sh" 2>/dev/null || true
  nohup "${utils}/exec.sh" >/tmp/haveno-exec.log 2>&1 &
  sleep 8
  g "  exec.sh iniciado (log: /tmp/haveno-exec.log)."

  b "Verificando onion-grater..."
  sleep 4
  haveno_fix_onion_grater || true
}

# --- QA logs (~/Persistent/qa-logs/) — sem seed, senha ou chaves ----------------
# Ative com: export HAVENO_QA_LOG=1  ou  --qa-log no script
# Guia aluno: Scripts/COMO-LER-SEUS-LOGS.md

QA_LOG_DIR="${QA_LOG_DIR:-${PERSIST}/qa-logs}"
QA_LOG_FILE=""

qa_log_enabled() {
  [ "${HAVENO_QA_LOG:-0}" = "1" ]
}

qa_log_init() {
  local slug="${1:-session}"
  qa_log_enabled || return 0
  mkdir -p "$QA_LOG_DIR" || return 0
  QA_LOG_FILE="${QA_LOG_DIR}/${slug}-$(date +%Y%m%d-%H%M%S).txt"
  {
    echo "=== ${slug} — $(date -Iseconds 2>/dev/null || date) ==="
    echo "script: ${0##*/}"
    echo "host: $(uname -s 2>/dev/null || echo unknown)"
  } >>"$QA_LOG_FILE"
  g "  QA log: $QA_LOG_FILE"
}

qa_log_line() {
  [ -n "${QA_LOG_FILE:-}" ] || return 0
  echo "$*" >>"$QA_LOG_FILE"
}

qa_log_confirm() {
  local key="${1:-confirmacao}"
  local val="${2:-SIM}"
  qa_log_line "CONFIRMACAO_HUMANA: ${key}=${val}"
}

qa_log_pass() { qa_log_line "PASS: $*"; }
qa_log_fail() { qa_log_line "FAIL: $*"; }

qa_log_finish() {
  local ec="${1:-0}"
  [ -n "${QA_LOG_FILE:-}" ] || return 0
  qa_log_line "exit_code: ${ec}"
  if [ "$ec" = "0" ]; then
    qa_log_line "RESULTADO: PASS"
  else
    qa_log_line "RESULTADO: FAIL"
  fi
}

# Duplica stdout/stderr para o arquivo QA (use no inicio do script principal)
qa_log_tee_begin() {
  local slug="${1:-session}"
  qa_log_enabled || return 0
  qa_log_init "$slug"
  exec > >(tee -a "$QA_LOG_FILE") 2>&1
}
