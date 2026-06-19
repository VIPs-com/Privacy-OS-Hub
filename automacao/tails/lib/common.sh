# lib/common.sh — funções compartilhadas (source, não execute direto)
# Uso: source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
#
# Biblioteca canônica — sourciada por todos os scripts em haveno/ feather/ system/ qa/.

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "${LIB_DIR}/config.sh"

# Caminhos derivados de runtime (não constantes de release — ficam aqui, não no config.sh)
HUB_TAILS_DIR="${LIB_DIR}/.."
HUB_SCRIPTS_DIR="${HUB_SCRIPTS_DIR:-${PERSIST}/hub-scripts}"
HUB_ONION_YML="${HUB_ONION_YML:-${LIB_DIR}/onion-grater.yml}"

b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
die(){ r "ERRO: $*"; exit 1; }

# --- Backup cifrado: confirmar senha antes do gpg (evita .gpg irrecuperavel) -
haveno_gpg_symmetric_encrypt() {
  local outfile="$1" infile="$2" pass1 pass2
  [ -f "$infile" ] || die "haveno_gpg_symmetric_encrypt: arquivo inexistente: $infile"
  while true; do
    read -s -p "Senha do backup (forte — guarde-a): " pass1; echo
    read -s -p "Confirmar senha: " pass2; echo
    [ -n "$pass1" ] || die "Senha vazia — cancelado."
    if [ "$pass1" = "$pass2" ]; then
      break
    fi
    r "Senhas nao conferem. Tente de novo."
  done
  printf '%s' "$pass1" | gpg --batch --yes -c --cipher-algo AES256 --passphrase-fd 0 \
    -o "$outfile" "$infile" \
    || { unset pass1 pass2; die "Falha ao cifrar."; }
  unset pass1 pass2
}

# --- Modo "uma senha so" (opt-in: --one-password) -----------------------------
HAVENO_SUDOERS_DROPIN="${HAVENO_SUDOERS_DROPIN:-/etc/sudoers.d/zz-haveno-1session}"

sudo_one_password_start() {
  [ "${HAVENO_ONE_PASSWORD:-0}" = "1" ] || return 0
  [ "${HAVENO_SUDO_SESSION:-0}" = "1" ] && return 0
  y "  [--one-password] Voce vai digitar a senha de admin UMA vez agora."
  y "  Ajuste TEMPORARIO de sessao (removido ao fim do script; some no reboot)."
  sudo rm -f "$HAVENO_SUDOERS_DROPIN" 2>/dev/null || true
  if ! sudo bash -c "umask 0337; \
        printf 'Defaults timestamp_timeout=-1\n' > '$HAVENO_SUDOERS_DROPIN'; \
        visudo -cf '$HAVENO_SUDOERS_DROPIN' >/dev/null"; then
    sudo rm -f "$HAVENO_SUDOERS_DROPIN" 2>/dev/null || true
    die "Nao ativei o modo uma-senha (sudoers invalido). Rode sem --one-password."
  fi
  export HAVENO_SUDO_SESSION=1
  HAVENO_SUDO_OWNER=1
  trap 'sudo_one_password_stop' EXIT INT TERM
  g "  [--one-password] Ativo: os proximos comandos nao pedem senha ate o fim."
}

sudo_one_password_stop() {
  [ "${HAVENO_SUDO_OWNER:-0}" = "1" ] || return 0
  sudo rm -f "$HAVENO_SUDOERS_DROPIN" 2>/dev/null || true
  HAVENO_SUDO_OWNER=0
}

# --- Orquestração hub: sync repo -> hub-scripts, resolve scripts ---------------
hub_find_tails_source() {
  local d setup_dir="${HUB_SETUP_DIR:-${HUB_TAILS_DIR}}"
  for d in \
      "$setup_dir" \
      "${PERSIST}/Privacy-OS-Hub-main/automacao/tails" \
      "${HUB_SCRIPTS_DIR}" \
      "${PERSIST}"; do
    [ -f "${d}/lib/common.sh" ] && { echo "$d"; return 0; }
  done
  return 1
}

hub_sync_scripts_to_persistent() {
  local src="${1:-}"
  [ -n "$src" ] || return 0
  [ -d "$src" ] || return 0
  local src_common="${src}/lib/common.sh"
  local dst_common="${HUB_SCRIPTS_DIR}/lib/common.sh"
  [ -f "$src_common" ] || return 0
  if [ ! -f "$dst_common" ] || [ "$src_common" -nt "$dst_common" ]; then
    y "  Scripts do repo mais novos — sincronizando para ${HUB_SCRIPTS_DIR}/..."
    mkdir -p "${HUB_SCRIPTS_DIR}" || return 1
    # Scripts raiz (hub.sh, sync-hub-scripts.sh, haveno-backup.desktop)
    cp -f "${src}"/*.sh "${HUB_SCRIPTS_DIR}/" 2>/dev/null || true
    [ -f "${src}/haveno-backup.desktop" ] && cp -f "${src}/haveno-backup.desktop" "${HUB_SCRIPTS_DIR}/"
    chmod +x "${HUB_SCRIPTS_DIR}"/*.sh 2>/dev/null || true
    # lib/ (config.sh + common.sh + onion-grater.yml)
    if [ -d "${src}/lib" ]; then
      mkdir -p "${HUB_SCRIPTS_DIR}/lib"
      cp -f "${src}/lib"/*.sh "${HUB_SCRIPTS_DIR}/lib/" 2>/dev/null || true
      [ -f "${src}/lib/onion-grater.yml" ] && cp -f "${src}/lib/onion-grater.yml" "${HUB_SCRIPTS_DIR}/lib/"
      chmod 644 "${HUB_SCRIPTS_DIR}/lib/config.sh" 2>/dev/null || true
    fi
    # haveno/ feather/ system/ qa/ (fluxos por produto)
    for _sub in haveno feather system qa; do
      if [ -d "${src}/${_sub}" ]; then
        mkdir -p "${HUB_SCRIPTS_DIR}/${_sub}"
        cp -f "${src}/${_sub}"/*.sh "${HUB_SCRIPTS_DIR}/${_sub}/" 2>/dev/null || true
        chmod +x "${HUB_SCRIPTS_DIR}/${_sub}"/*.sh 2>/dev/null || true
      fi
    done
    # steps/ (fallback atômico)
    if [ -d "${src}/steps" ]; then
      mkdir -p "${HUB_SCRIPTS_DIR}/steps"
      cp -f "${src}/steps"/*.sh "${HUB_SCRIPTS_DIR}/steps/" 2>/dev/null || true
      cp -f "${src}/steps/README.md" "${HUB_SCRIPTS_DIR}/steps/" 2>/dev/null || true
      chmod +x "${HUB_SCRIPTS_DIR}/steps"/*.sh 2>/dev/null || true
    fi
    # hub-aliases/ → aliases/
    if [ -d "${src}/hub-aliases" ]; then
      mkdir -p "${HUB_SCRIPTS_DIR}/aliases"
      cp -f "${src}/hub-aliases"/*.sh "${HUB_SCRIPTS_DIR}/aliases/" 2>/dev/null || true
      chmod +x "${HUB_SCRIPTS_DIR}/aliases"/*.sh 2>/dev/null || true
    fi
    g "  Sync OK (${src} -> ${HUB_SCRIPTS_DIR})."
  fi
}

hub_resolve_script() {
  local name="$1"
  local hub="${HUB_SCRIPTS_DIR}/${name}"
  local persist="${PERSIST}/${name}"
  local local_="${HUB_TAILS_DIR}/${name}"
  local pick="" best=""
  for pick in "$hub" "$persist" "$local_"; do
    [ -x "$pick" ] || continue
    if [ -z "${best:-}" ] || [ "$pick" -nt "$best" ]; then
      best="$pick"
    fi
  done
  [ -n "${best:-}" ] && { echo "$best"; return 0; }
  return 1
}

haveno_pkg_installed_ok() {
  dpkg-query -W -f='${Status}' haveno 2>/dev/null | grep -q 'install ok installed'
}

haveno_needs_install_only() {
  haveno_has_install_deb || return 1
  [ -f "${UTILS_DIR}/install.sh" ] || return 1
  [ -f "${UTILS_DIR}/exec.sh" ] || return 1
  if haveno_pkg_installed_ok; then
    return 1
  fi
  return 0
}

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
    y "  Doc: canonico PASSO 2 ou docs/MANUAL.md"
    return 1
  fi
  return 0
}

# Dependencias do .deb: lidas DE DENTRO do proprio pacote (dpkg-deb -f Depends),
# nao de lista fixa. Motivo (DIV-20260610-02): o .deb 1.6.0-reto declara nomes
# de libs do UBUNTU (libicu74, libavcodec60...) que NAO existem no Debian 13 do
# Tails — uma lista fixa com esses nomes falha em todo boot. O hub instala as
# que existirem e tolera as Ubuntu-only com dpkg --force-depends (o Haveno
# embute o proprio runtime; validado em campo 2026-06-10/11).
HAVENO_DEPS_MISSING=0
HAVENO_DEB_MIN_BYTES="${HAVENO_DEB_MIN_BYTES:-104857600}"
HAVENO_DEB_POISON_MAX_BYTES="${HAVENO_DEB_POISON_MAX_BYTES:-1048576}"
# Minimo para .sig: assinatura Ed25519 binaria (release 1.6.0-reto) tem exatamente
# 119 bytes — OpenPGP old-format sig packet (0x88) + corpo Ed25519.
HAVENO_SIG_MIN_BYTES="${HAVENO_SIG_MIN_BYTES:-60}"
HAVENO_SIG_DOWNLOAD_RETRIES="${HAVENO_SIG_DOWNLOAD_RETRIES:-3}"

haveno_deb_size_ok() {
  local f="$1" sz
  [ -f "$f" ] || return 1
  sz="$(stat -c%s "$f" 2>/dev/null || echo 0)"
  [ "${sz:-0}" -ge "${HAVENO_DEB_MIN_BYTES}" ]
}

haveno_find_install_deb() {
  local install_dir="${HAVENO_DIR}/Install" f
  if [ -f "${install_dir}/haveno.deb" ] && haveno_deb_size_ok "${install_dir}/haveno.deb"; then
    echo "${install_dir}/haveno.deb"
    return 0
  fi
  while IFS= read -r f; do
    [ -n "$f" ] && haveno_deb_size_ok "$f" && { echo "$f"; return 0; }
  done < <(find "$install_dir" -maxdepth 1 -name '*.deb' -type f 2>/dev/null)
  return 1
}

haveno_has_install_deb() {
  [ -n "$(haveno_find_install_deb)" ]
}

haveno_sig_size_ok() {
  local f="$1" sz
  [ -f "$f" ] || return 1
  sz="$(stat -c%s "$f" 2>/dev/null || echo 0)"
  [ "${sz:-0}" -ge "${HAVENO_SIG_MIN_BYTES}" ]
}

# Aceita assinatura PGP binaria (0x88/0x89/0xC2 — Ed25519 ~119 B) OU ASCII-armored.
haveno_sig_valid_format() {
  local f="$1" b1
  [ -f "$f" ] || return 1
  head -c 27 "$f" 2>/dev/null | grep -q 'BEGIN PGP SIGNATURE' && return 0
  b1="$(od -A n -t x1 -N 1 "$f" 2>/dev/null | tr -d ' \n')"
  [ "$b1" = "88" ] || [ "$b1" = "89" ] || [ "$b1" = "c2" ]
}

# Remove .deb/.part minusculos (erro HTML) e .sig invalidas.
# NOTA: *.sig EXCLUIDO do loop de .deb — o padrao *.deb.* casava com *.deb.sig
# (119 B) e apagava a assinatura valida (DIV-20260618-01).
haveno_purge_poisoned_partial_debs() {
  local expected="${1:-0}" dir f s
  shift || true
  local -a dirs=()
  if [ "$#" -gt 0 ]; then
    dirs=("$@")
  else
    dirs=("${HAVENO_DIR}/.download" "${HAVENO_DIR}/Install" ".")
  fi
  for dir in "${dirs[@]}"; do
    [ -d "$dir" ] || continue
    while IFS= read -r -d '' f; do
      s="$(stat -c%s "$f" 2>/dev/null || echo 0)"
      if [ "${s:-0}" -lt "${HAVENO_DEB_POISON_MAX_BYTES}" ]; then
        y "  Lixo de download removido (${s} bytes): ${f}"
        rm -f "$f" 2>/dev/null || true
      elif [ "${expected:-0}" -gt 0 ] 2>/dev/null && [ "${s:-0}" -ge "${expected}" ]; then
        : # completo
      fi
    done < <(find "$dir" -maxdepth 1 \( -name '*.deb' -o -name '*.deb.*' -o -name '*.part' \) ! -name '*.sig' -type f -print0 2>/dev/null)
    while IFS= read -r -d '' f; do
      s="$(stat -c%s "$f" 2>/dev/null || echo 0)"
      if [ "${s:-0}" -lt "${HAVENO_SIG_MIN_BYTES}" ]; then
        y "  Assinatura .sig invalida removida (${s} bytes): ${f}"
        rm -f "$f" 2>/dev/null || true
      fi
    done < <(find "$dir" -maxdepth 1 -name '*.sig' -type f -print0 2>/dev/null)
  done
}

haveno_fetch_deb_expected_bytes() {
  local url="${1:-}"
  [ -n "$url" ] || { echo 0; return 0; }
  curl -sI --socks5-hostname 127.0.0.1:9050 --max-time 45 "$url" 2>/dev/null \
    | grep -i '^content-length:' | awk '{print $2}' | tr -d '\r' | head -1
}

HAVENO_DOWNLOAD_MONITOR_SEC="${HAVENO_DOWNLOAD_MONITOR_SEC:-10}"
HAVENO_INSTALL_PID=
HAVENO_MON_PID=

haveno_fmt_bytes() {
  local b="${1:-0}"
  if command -v numfmt >/dev/null 2>&1; then
    numfmt --to=iec-i --suffix=B "$b" 2>/dev/null || echo "${b} B"
  elif [ "$b" -ge 1048576 ] 2>/dev/null; then
    awk -v n="$b" 'BEGIN{printf "%.1f MiB", n/1048576}'
  elif [ "$b" -ge 1024 ] 2>/dev/null; then
    awk -v n="$b" 'BEGIN{printf "%.1f KiB", n/1024}'
  else
    echo "${b} B"
  fi
}

haveno_deb_bytes_now() {
  local d size=0 f s
  for d in "${HAVENO_DIR}/.download" "${HAVENO_DIR}/Install" "${HAVENO_DIR}"; do
    [ -d "$d" ] || continue
    while IFS= read -r -d '' f; do
      s=$(stat -c%s "$f" 2>/dev/null || echo 0)
      [ "$s" -gt "$size" ] && size=$s
    done < <(find "$d" -maxdepth 2 \( -name '*.deb' -o -name '*.deb.*' -o -name '*.part' \) -print0 2>/dev/null)
  done
  echo "$size"
}

haveno_render_progress_bar() {
  local pct="${1:-0}" width="${2:-24}" filled empty i
  pct="$(awk -v p="$pct" 'BEGIN{if(p<0)p=0;if(p>100)p=100;printf "%d", p}')"
  filled=$(( pct * width / 100 ))
  empty=$(( width - filled ))
  printf "["
  for ((i=0; i<filled; i++)); do printf "#"; done
  for ((i=0; i<empty; i++)); do printf "-"; done
  printf "] %3d%%" "$pct"
}

haveno_monitor_deb_download() {
  local target_pid="$1" expected="${2:-0}" interval="${3:-${HAVENO_DOWNLOAD_MONITOR_SEC}}"
  mkdir -p "${HAVENO_DIR}/Install" 2>/dev/null || true
  local prev=0 now human bar pct_n
  while kill -0 "$target_pid" 2>/dev/null; do
    now=$(haveno_deb_bytes_now)
    human=$(haveno_fmt_bytes "$now")
    if [ "$expected" -gt 0 ] 2>/dev/null && [ "$now" -gt 0 ]; then
      pct_n=$(awk -v n="$now" -v e="$expected" 'BEGIN{printf "%.0f", (n/e)*100}')
      bar=$(haveno_render_progress_bar "$pct_n")
      printf "  [download] %s · %s / %s (Tor; retomavel)\n" \
        "$bar" "$human" "$(haveno_fmt_bytes "$expected")"
    elif [ "$now" -gt 0 ]; then
      printf "  [download] %s — baixando (retomavel na persistencia)...\n" "$human"
    elif [ "$prev" -eq 0 ]; then
      y "  [download] conectando ao Tor — o .deb aparece em instantes (NAO e erro)."
    fi
    prev=$now
    sleep "$interval"
  done
}

haveno_kill_download_children() {
  [ -n "${HAVENO_INSTALL_PID:-}" ] && kill "$HAVENO_INSTALL_PID" 2>/dev/null || true
  [ -n "${HAVENO_MON_PID:-}" ] && kill "$HAVENO_MON_PID" 2>/dev/null || true
}

haveno_download_interrupted() {
  haveno_kill_download_children
  qa_log_finish 130
  exit 130
}

haveno_hub_download_deb_to_cwd() {
  local deb_url="$1" expected="${2:-0}"
  local deb_basename deb_path now=0
  deb_basename="$(basename "$deb_url")"
  deb_path="./${deb_basename}"
  [ -f "$deb_path" ] && now=$(stat -c%s "$deb_path" 2>/dev/null || echo 0)
  if haveno_deb_size_ok "$deb_path"; then
    if [ "${expected:-0}" -le 0 ] 2>/dev/null || [ "$now" -ge "$expected" ]; then
      g "  .deb ja completo em .download/ ($(haveno_fmt_bytes "$now"))."
      return 0
    fi
  fi
  if [ "$now" -gt 1048576 ] 2>/dev/null; then
    y "  Retomando .deb parcial ($(haveno_fmt_bytes "$now"))..."
  else
    b "  Baixando .deb pelo Tor (barra abaixo; 30-90 min, retomavel)..."
    if [ "${expected:-0}" -gt 0 ] 2>/dev/null; then
      y "  Tamanho esperado: $(haveno_fmt_bytes "$expected")"
    fi
  fi
  curl -fL -C - --socks5-hostname 127.0.0.1:9050 --progress-bar --max-time 0 \
    -o "$deb_path" "$deb_url" \
    || die "Download do .deb interrompido em .download/. Rode de novo — retoma automaticamente."
  haveno_deb_size_ok "$deb_path" \
    || die ".deb incompleto apos download ($(stat -c%s "$deb_path" 2>/dev/null || echo 0) bytes)."
  g "  .deb completo em .download/ ($(haveno_fmt_bytes "$(stat -c%s "$deb_path")"))."
}

haveno_try_promote_deb_from_cwd() {
  local deb_url="$1" pgp_fpr="$2"
  local deb_basename
  deb_basename="$(basename "$deb_url")"
  [ -f "./${deb_basename}" ] && haveno_deb_size_ok "./${deb_basename}" || return 1
  [ -d "$UTILS_DIR" ] || return 1
  y "  .deb completo em .download/ — verificando PGP e promovendo para Install/ (sem re-download)."
  haveno_predownload_sig "$deb_url"
  haveno_finalize_verified_deb_in_cwd "$deb_url" "$pgp_fpr"
}

haveno_hub_download_and_promote_deb() {
  local deb_url="$1" pgp_fpr="$2" expected="${3:-0}"
  [ -d "$UTILS_DIR" ] || return 1
  haveno_hub_download_deb_to_cwd "$deb_url" "$expected"
  haveno_predownload_sig "$deb_url"
  haveno_finalize_verified_deb_in_cwd "$deb_url" "$pgp_fpr"
}

haveno_run_upstream_install_deb() {
  local deb_url="$1" pgp_fpr="$2" expected="${3:-0}"
  local deb_basename install_rc=0
  deb_basename="$(basename "$deb_url")"
  haveno_predownload_sig "$deb_url"
  b "  Rodando haveno-install.sh (1a vez: cria App/utils/ + verifica PGP)..."
  HAVENO_INSTALL_PID=
  HAVENO_MON_PID=
  trap 'haveno_download_interrupted' INT TERM
  LC_ALL=C bash ./haveno-install.sh "$deb_url" "$pgp_fpr" &
  HAVENO_INSTALL_PID=$!
  haveno_monitor_deb_download "$HAVENO_INSTALL_PID" "$expected" &
  HAVENO_MON_PID=$!
  wait "$HAVENO_INSTALL_PID"
  install_rc=$?
  trap - INT TERM
  haveno_kill_download_children
  wait "$HAVENO_MON_PID" 2>/dev/null || true
  HAVENO_INSTALL_PID=
  HAVENO_MON_PID=
  if [ "$install_rc" -eq 130 ] || [ "$install_rc" -eq 143 ]; then
    qa_log_finish "$install_rc"
    exit "$install_rc"
  fi
  if [ "$install_rc" -ne 0 ]; then
    if [ -f "./${deb_basename}" ] && haveno_deb_size_ok "./${deb_basename}"; then
      local _deb_now
      _deb_now="$(stat -c%s "./${deb_basename}" 2>/dev/null || echo 0)"
      if [ "${expected:-0}" -gt 0 ] 2>/dev/null && [ "$_deb_now" -lt "$expected" ] \
          && [ -d "$UTILS_DIR" ]; then
        y "  .deb parcial ($(haveno_fmt_bytes "$_deb_now") de $(haveno_fmt_bytes "$expected")) — retomando via hub (curl resume)..."
        if haveno_hub_download_and_promote_deb "$deb_url" "$pgp_fpr" "$expected"; then
          return 0
        fi
      fi
      if [ -f "./${deb_basename}" ] && haveno_deb_size_ok "./${deb_basename}"; then
        y "  haveno-install.sh falhou apos o .deb completo — tentando verificar PGP localmente..."
        haveno_purge_poisoned_partial_debs "${expected:-0}" "."
        haveno_predownload_sig "$deb_url"
        if haveno_finalize_verified_deb_in_cwd "$deb_url" "$pgp_fpr"; then
          install_rc=0
        fi
      fi
    fi
  fi
  return "$install_rc"
}

haveno_deb_download_failed_msg() {
  r "ERRO: haveno-install.sh falhou (PGP/URL/rede)."
  y "  · .deb COMPLETO so em .download/: sync-hub-scripts.sh + hub.sh install --qa-log"
  y "  · .deb+.sig ja em Install/ (App/utils/ OK): hub.sh install --install-only"
  y "  · Fallback atomico: steps/run-all.sh (passo a passo)"
  y "  · Apendice B (erros comuns) no arquivo canonico do curso"
  exit 1
}

haveno_sig_download_failed_msg() {
  local sz="${1:-0}" sig_url="${2:-}"
  r "ERRO: Assinatura .sig invalida (${sz} bytes) — provavel erro de rede/GitHub, nao PGP."
  y "  Scripts .sh no pendrive/W11 estao OK — o .deb e a .sig baixam NO Tails via Tor."
  y "  · Aguarde 2-3 min e rode: hub.sh install --qa-log"
  y "  · Fallback atomico: steps/02-download-deb.sh"
  y "  · Apendice B erro 3 no arquivo canonico · TRES-PASSOS-HAVENO-TAILS.md"
  [ -n "$sig_url" ] && y "  URL: $sig_url"
  exit 1
}

# DIV-20260617-02: garante a .sig (pequena) ANTES do upstream, fail-closed.
haveno_predownload_sig() {
  local deb_url="${1:-}" deb_name sig_url sz attempt max_attempts
  [ -n "$deb_url" ] || die "haveno_predownload_sig: URL do .deb vazia."
  deb_name="$(basename "$deb_url")"
  sig_url="${deb_url}.sig"
  max_attempts="${HAVENO_SIG_DOWNLOAD_RETRIES:-3}"
  y "  Garantindo a assinatura .sig (Tor, fail-closed — espelha steps/02-download-deb.sh)..."
  rm -f "${deb_name}.sig" 2>/dev/null || true
  for (( attempt=1; attempt<=max_attempts; attempt++ )); do
    if [ "$attempt" -gt 1 ]; then
      y "  Tentativa ${attempt}/${max_attempts} da .sig (aguarde Tor/GitHub)..."
      sleep 15
      rm -f "${deb_name}.sig" 2>/dev/null || true
    fi
    if curl -fsSL --socks5-hostname 127.0.0.1:9050 --max-time 120 \
        -o "${deb_name}.sig" "$sig_url" 2>/dev/null; then
      sz="$(stat -c%s "${deb_name}.sig" 2>/dev/null || echo 0)"
      if haveno_sig_size_ok "${deb_name}.sig" \
        && haveno_sig_valid_format "${deb_name}.sig"; then
        g "  Assinatura .sig pronta (${deb_name}.sig, ${sz} bytes)."
        return 0
      fi
      y "  .sig suspeita (${sz} bytes) nesta tentativa — descartando."
      rm -f "${deb_name}.sig" 2>/dev/null || true
    else
      y "  curl nao baixou a .sig nesta tentativa."
    fi
  done
  sz="$(stat -c%s "${deb_name}.sig" 2>/dev/null || echo 0)"
  haveno_sig_download_failed_msg "${sz:-0}" "$sig_url"
}

haveno_ensure_reto_pgp_key() {
  local fpr="${1:-}"
  fpr="$(echo "$fpr" | tr -d ' ')"
  [ -n "$fpr" ] || return 1
  gpg --list-keys "$fpr" >/dev/null 2>&1 && return 0

  y "  Importando chave PGP do release via Tor..."
  local tmp
  tmp="$(mktemp)"

  # Tentativa 1: URL oficial via Tor (sem fallback clearnet)
  if curl -fsSL --socks5-hostname 127.0.0.1:9050 --max-time 120 \
      -o "$tmp" "${RETO_KEY_URL}" 2>/dev/null; then
    gpg --import "$tmp" >/dev/null 2>&1 || true
    rm -f "$tmp"
  else
    rm -f "$tmp"
    # Tentativa 2: keyserver via Tor — sem fallback clearnet
    local key_file="${fpr: -16}.asc"
    y "  URL oficial falhou — tentando keyserver via Tor..."
    if ! curl -fsSL --socks5-hostname 127.0.0.1:9050 --max-time 120 \
        -o "$key_file" \
        "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${fpr}" 2>/dev/null; then
      rm -f "$key_file"
      die "Nao consegui importar a chave PGP via Tor. Verifique a conexao Tor e tente de novo."
    fi
    gpg --import "$key_file" >/dev/null 2>&1 || true
    rm -f "$key_file"
  fi

  gpg --list-keys "$fpr" >/dev/null 2>&1 || \
    die "Chave importada mas fingerprint nao confere (${fpr}). PARE e registre divergencia."
}

haveno_verify_deb_sig() {
  local deb="$1" sig="$2" fpr="$3" log
  fpr="$(echo "$fpr" | tr -d ' ')"
  log="$(mktemp)"
  gpg --status-fd 1 --verify "$sig" "$deb" 2>/dev/null >"$log" || true
  if grep -q "^\[GNUPG:\] VALIDSIG .*${fpr}" "$log"; then
    rm -f "$log"
    return 0
  fi
  rm -f "$log"
  return 1
}

haveno_finalize_verified_deb_in_cwd() {
  local deb_url="$1" pgp_fpr="$2"
  local deb_name sig_path deb_path install_dir="${HAVENO_DIR}/Install" fpr
  deb_name="$(basename "$deb_url")"
  sig_path="./${deb_name}.sig"
  deb_path="./${deb_name}"
  [ -f "$deb_path" ] || deb_path="$(find . -maxdepth 1 -name '*.deb' -type f 2>/dev/null | head -1)"
  [ -n "$deb_path" ] && [ -f "$deb_path" ] || return 1
  haveno_deb_size_ok "$deb_path" || return 1
  [ -f "$sig_path" ] || sig_path="${deb_path}.sig"
  [ -f "$sig_path" ] && haveno_sig_size_ok "$sig_path" || return 1
  fpr="$(echo "$pgp_fpr" | tr -d ' ')"
  haveno_ensure_reto_pgp_key "$fpr" || die "Nao importei chave PGP ${fpr}."
  haveno_verify_deb_sig "$deb_path" "$sig_path" "$fpr" \
    || die "Assinatura PGP do .deb invalida — NAO instale."
  mkdir -p "$install_dir" || die "Nao criei ${install_dir}/."
  mv -f "$deb_path" "${install_dir}/$(basename "$deb_path")"
  mv -f "$sig_path" "${install_dir}/$(basename "$sig_path")" 2>/dev/null || true
  haveno_ensure_install_deb_link
  g "  .deb verificado (VALIDSIG) e movido para ${install_dir}/."
  return 0
}

haveno_ensure_install_deb_link() {
  local install_dir="${HAVENO_DIR}/Install" deb real
  mkdir -p "$install_dir" || die "Nao criei ${install_dir}/"
  if [ -L "${install_dir}/haveno.deb" ] || [ -f "${install_dir}/haveno.deb" ]; then
    g "  Install/haveno.deb OK."
    return 0
  fi
  deb="$(find "$install_dir" -maxdepth 1 -name '*.deb' -type f 2>/dev/null | head -1)"
  [ -n "$deb" ] || die "Nenhum .deb em ${install_dir}/ — rode [6/9] ou copie o pacote verificado."
  real="$(basename "$deb")"
  ln -sf "$real" "${install_dir}/haveno.deb"
  g "  Install/haveno.deb -> ${real}"
}

haveno_fix_dpkg_state() {
  if ! dpkg-query -W -f='${Status}' haveno >/dev/null 2>&1; then
    return 0
  fi
  local st
  st="$(dpkg-query -W -f='${Status}' haveno 2>/dev/null || echo "")"
  case "$st" in
    *"config-files"*)
      y "  haveno em estado config-files (comum apos apt install -f) — limpando..."
      sudo dpkg --purge haveno 2>/dev/null || true
      ;;
    *"half-configured"*|*"half-installed"*|*"unpacked"*)
      y "  haveno incompleto (${st%% *}...) — removendo para reinstalar..."
      sudo dpkg --remove --force-remove-reinstreq haveno 2>/dev/null \
        || sudo dpkg --purge haveno 2>/dev/null || true
      ;;
  esac
  g "  Estado dpkg pronto para install.sh."
}

haveno_ensure_deb_deps() {
  export LC_ALL=C LANG=C LANGUAGE=C
  if ! command -v apt-get >/dev/null 2>&1; then
    y "  apt-get ausente — ambiente nao-Debian; pulando deps."
    return 0
  fi
  b "  Dependencias do .deb (apt)..."
  y "  O install.sh oficial so roda dpkg -i; no Tails as libs nao vem pre-instaladas."
  y "  apt-get update pelo Tor pode levar 3-6 min — aguarde."
  y "  NAO rode 'apt-get install -f' sozinho com haveno desconfigurado — remove o pacote."
  local deb="${HAVENO_DIR}/Install/haveno.deb"
  [ -f "$deb" ] || { y "  Sem ${deb} — pulando deps (install.sh vai apontar o que falta)."; return 0; }
  local tent
  for tent in 1 2 3; do
    if sudo apt-get update; then
      break
    fi
    if [ "$tent" = "3" ]; then
      r "  apt-get update falhou 3x — sem listas apt, as libs nao instalam."
      y "  Confirme o Tor conectado (Tor Connection assistant) e rode de novo."
      return 1
    fi
    y "  apt-get update falhou (tentativa ${tent}/3) — aguardando 30s (Tor)..."
    sleep 30
  done
  local deps_raw item nome status alt instalaveis=() faltando=()
  deps_raw="$(dpkg-deb -f "$deb" Depends 2>/dev/null || true)"
  [ -n "$deps_raw" ] || { g "  .deb sem Depends declarado."; return 0; }
  local IFS=','
  for item in $deps_raw; do
    item="$(echo "$item" | sed 's/([^)]*)//g')"
    status=""
    local IFS='|'
    for alt in $item; do
      nome="$(echo "$alt" | tr -d '[:space:]')"
      [ -n "$nome" ] || continue
      if dpkg-query -W -f='${Status}' "$nome" 2>/dev/null | grep -q "install ok installed"; then
        status="ok"; break
      fi
    done
    if [ -z "$status" ]; then
      for alt in $item; do
        nome="$(echo "$alt" | tr -d '[:space:]')"
        [ -n "$nome" ] || continue
        if LC_ALL=C apt-cache policy "$nome" 2>/dev/null | grep -q 'Candidate: [0-9]'; then
          status="instalar"; instalaveis+=("$nome"); break
        fi
      done
    fi
    if [ -z "$status" ]; then
      nome="$(echo "$item" | tr -d '[:space:]' | cut -d'|' -f1)"
      [ -n "$nome" ] && faltando+=("$nome")
    fi
    local IFS=','
  done
  unset IFS
  if [ "${#instalaveis[@]}" -gt 0 ]; then
    b "  Instalando ${#instalaveis[@]} dependencia(s) disponiveis: ${instalaveis[*]}"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${instalaveis[@]}" || {
      r "  apt nao instalou: ${instalaveis[*]}"
      y "  Veja Apendice B erro 11 (dependencias apt) no canonico ou ative Software adicional na persistencia."
      return 1
    }
  fi
  HAVENO_DEPS_MISSING=0
  if [ "${#faltando[@]}" -gt 0 ]; then
    HAVENO_DEPS_MISSING=1
    y "  ${#faltando[@]} dependencia(s) com nome Ubuntu, inexistentes no Debian/Tails:"
    y "    ${faltando[*]}"
    y "  Conhecido (DIV-20260610-02) — o dpkg vai usar --force-depends; o Haveno"
    y "  embute o runtime e abre normalmente (validado em campo)."
  fi
  g "  Dependencias do .deb OK."
  return 0
}

haveno_run_install() {
  local utils="${UTILS_DIR}"
  [ -f "${utils}/install.sh" ] || die "install.sh nao encontrado. Rode hub.sh install primeiro."
  haveno_ensure_install_deb_link
  haveno_fix_dpkg_state
  haveno_ensure_deb_deps || die "Dependencias do .deb nao instaladas."
  b "Rodando install.sh (pkexec — pode pedir senha admin)..."
  chmod +x "${utils}/install.sh" 2>/dev/null || true
  if ! sudo "${utils}/install.sh"; then
    # Deps com nome Ubuntu inexistentes no Debian (DIV-20260610-02).
    # Fallback validado em campo: --force-depends + reconfigure.
    if [ "${HAVENO_DEPS_MISSING:-0}" = "1" ] && [ -f "${HAVENO_DIR}/Install/haveno.deb" ]; then
      y "  install.sh falhou por Depends Ubuntu-only — aplicando dpkg --force-depends..."
      if sudo dpkg -i --force-depends "${HAVENO_DIR}/Install/haveno.deb"; then
        sudo dpkg --configure -a 2>/dev/null || true
        g "  haveno instalado com --force-depends (DIV-20260610-02)."
        return 0
      fi
    fi
    r "  install.sh falhou."
    y "  Recuperacao: hub.sh install --install-only"
    die "install.sh falhou."
  fi
}

haveno_check_installed() {
  [ -f "${UTILS_DIR}/exec.sh" ] && [ -f "${UTILS_DIR}/install.sh" ] && [ -f "${UTILS_DIR}/haveno.yml" ]
}

haveno_check_filter() {
  sudo journalctl -u onion-grater -b --no-pager 2>/dev/null | tail -40
}

haveno_wait_onion_grater_filter() {
  local max_wait="${1:-30}" i
  y "  Aguardando onion-grater recarregar (ate ${max_wait}s)..."
  for (( i=1; i<=max_wait; i++ )); do
    if haveno_check_filter | grep -q "loaded filter: haveno"; then
      g "  loaded filter: haveno (OK)."
      return 0
    fi
    sleep 1
  done
  return 1
}

haveno_fix_onion_grater() {
  local utils="${UTILS_DIR}"
  [ -e "$TOR_COOKIE" ] && sudo chmod o+r "$TOR_COOKIE" 2>/dev/null || true
  local yml_src="${utils}/haveno.yml"
  if [ -f "$HUB_ONION_YML" ]; then
    yml_src="$HUB_ONION_YML"
  fi
  if sudo cmp -s "$yml_src" "$ONION_GRATER_DST" 2>/dev/null && \
     haveno_check_filter | grep -q "loaded filter: haveno"; then
    g "  loaded filter: haveno (OK, filtro do hub)."
    return 0
  fi
  y "  Aplicando correcao onion-grater..."
  [ "$yml_src" = "$HUB_ONION_YML" ] && g "  Usando filtro corrigido do hub (com PoW do Haveno 1.6.0)."
  sudo cp "$yml_src" "$ONION_GRATER_DST" 2>/dev/null || true
  [ -e "$TOR_COOKIE" ] && sudo chmod o+r "$TOR_COOKIE" 2>/dev/null || true
  if python3 -c "import yaml; yaml.safe_load(open('${ONION_GRATER_DST}')); print('YAML OK')" 2>/dev/null; then
    g "  YAML OK."
  else
    sudo cp "$yml_src" "$ONION_GRATER_DST"
  fi
  sudo systemctl restart onion-grater 2>/dev/null || true
  if haveno_wait_onion_grater_filter 30; then
    g "  Corrigido: loaded filter: haveno."
    return 0
  fi
  y "  Ainda sem 'loaded filter: haveno'. Veja Apendice B do canonico ou docs/MANUAL.md."
  return 1
}

# Playbook §7: install.sh + exec.sh
haveno_session_boot() {
  local utils="${UTILS_DIR}"
  [ -f "${utils}/exec.sh" ] || die "exec.sh nao encontrado."
  haveno_run_install
  b "Verificando onion-grater..."
  haveno_fix_onion_grater || true
  b "Abrindo Haveno (exec.sh)..."
  chmod +x "${utils}/exec.sh" 2>/dev/null || true
  nohup "${utils}/exec.sh" >/tmp/haveno-exec.log 2>&1 &
  sleep 8
  g "  exec.sh iniciado (log: /tmp/haveno-exec.log)."
}

# --- QA logs (~/Persistent/qa-logs/) — sem seed, senha ou chaves ----------------
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

qa_log_tee_begin() {
  local slug="${1:-session}"
  qa_log_enabled || return 0
  qa_log_init "$slug"
  exec > >(tee -a "$QA_LOG_FILE") 2>&1
}
