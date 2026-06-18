# haveno-common.sh — funcoes compartilhadas (source, nao execute direto)
# Uso: source "$(dirname "$0")/haveno-common.sh"

PERSIST="${PERSIST:-/home/amnesia/Persistent}"
HAVENO_DIR="${HAVENO_DIR:-${PERSIST}/haveno}"
UTILS_DIR="${UTILS_DIR:-${HAVENO_DIR}/App/utils}"
DOTFILES_DIR="${DOTFILES_DIR:-/live/persistence/TailsData_unlocked/dotfiles}"
ONION_GRATER_DST="${ONION_GRATER_DST:-/etc/onion-grater.d/haveno.yml}"
TOR_COOKIE="${TOR_COOKIE:-/var/run/tor/control.authcookie}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# Filtro onion-grater CORRIGIDO do hub: cobre os params PoW do ADD_ONION no
# Haveno 1.6.0, que o haveno.yml do instalador upstream bloqueia (Command
# filtered). Preferir sempre que existir ao lado dos scripts.
HUB_ONION_YML="${HUB_ONION_YML:-${SCRIPT_DIR}/haveno-onion-grater.yml}"

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
# O Tails embarca /etc/sudoers.d/always-ask-password (Defaults timestamp_timeout=0):
# por design o sudo NUNCA cacheia a senha — cada 'sudo' re-pergunta. So quando o
# operador pede (--one-password), instalamos um override de SESSAO que faz o sudo
# cachear ate o fim do fluxo, e o REMOVEMOS ao sair (e some no reboot, pois o Tails
# e amnesico). SEGURANCA: afrouxa temporariamente uma protecao do Tails -> e por
# isso opt-in (padrao continua o seguro) e auto-removido. Nao relaxar o padrao.
HAVENO_SUDOERS_DROPIN="${HAVENO_SUDOERS_DROPIN:-/etc/sudoers.d/zz-haveno-1session}"
# zz- = lido DEPOIS do always-ask (Defaults posterior vence). SEM ponto no nome:
# o sudo IGNORA arquivos de sudoers.d cujo nome contem '.'.

sudo_one_password_start() {
  [ "${HAVENO_ONE_PASSWORD:-0}" = "1" ] || return 0   # sem a flag = no-op (modo seguro)
  [ "${HAVENO_SUDO_SESSION:-0}" = "1" ] && return 0   # ja ativo por um processo pai
  y "  [--one-password] Voce vai digitar a senha de admin UMA vez agora."
  y "  Ajuste TEMPORARIO de sessao (removido ao fim do script; some no reboot)."
  sudo rm -f "$HAVENO_SUDOERS_DROPIN" 2>/dev/null || true   # limpa sobra de run anterior
  # UM unico sudo: autentica (1 prompt) + escreve + VALIDA o dropin (fail-closed).
  if ! sudo bash -c "umask 0337; \
        printf 'Defaults timestamp_timeout=-1\n' > '$HAVENO_SUDOERS_DROPIN'; \
        visudo -cf '$HAVENO_SUDOERS_DROPIN' >/dev/null"; then
    sudo rm -f "$HAVENO_SUDOERS_DROPIN" 2>/dev/null || true
    die "Nao ativei o modo uma-senha (sudoers invalido). Rode sem --one-password."
  fi
  export HAVENO_SUDO_SESSION=1     # filhos detectam e NAO reinstalam/removem
  HAVENO_SUDO_OWNER=1              # so o dono (este processo) remove no fim
  trap 'sudo_one_password_stop' EXIT INT TERM
  g "  [--one-password] Ativo: os proximos comandos nao pedem senha ate o fim."
}

sudo_one_password_stop() {
  [ "${HAVENO_SUDO_OWNER:-0}" = "1" ] || return 0
  sudo rm -f "$HAVENO_SUDOERS_DROPIN" 2>/dev/null || true
  HAVENO_SUDO_OWNER=0
}

# --- Orquestracao hub (R29): sync repo -> hub-scripts, resume install ------------
HUB_SCRIPTS_DIR="${HUB_SCRIPTS_DIR:-${PERSIST}/hub-scripts}"

hub_find_tails_source() {
  local d setup_dir="${HUB_SETUP_DIR:-${SCRIPT_DIR}}"
  for d in \
      "$setup_dir" \
      "${PERSIST}/Privacy-OS-Hub-main/automacao/tails" \
      "${HUB_SCRIPTS_DIR}" \
      "${PERSIST}"; do
    [ -f "${d}/haveno-common.sh" ] && { echo "$d"; return 0; }
  done
  return 1
}

hub_sync_scripts_to_persistent() {
  local src="${1:-}"
  [ -n "$src" ] || return 0
  [ -d "$src" ] || return 0
  local src_common="${src}/haveno-common.sh"
  local dst_common="${HUB_SCRIPTS_DIR}/haveno-common.sh"
  [ -f "$src_common" ] || return 0
  if [ ! -f "$dst_common" ] || [ "$src_common" -nt "$dst_common" ]; then
    y "  Scripts do repo mais novos — sincronizando para ${HUB_SCRIPTS_DIR}/..."
    mkdir -p "${HUB_SCRIPTS_DIR}" || return 1
    cp -f "${src}"/*.sh "${HUB_SCRIPTS_DIR}/" 2>/dev/null || true
    [ -f "${src}/haveno-onion-grater.yml" ] && cp -f "${src}/haveno-onion-grater.yml" "${HUB_SCRIPTS_DIR}/"
    [ -f "${src}/haveno-backup.desktop" ] && cp -f "${src}/haveno-backup.desktop" "${HUB_SCRIPTS_DIR}/"
    chmod +x "${HUB_SCRIPTS_DIR}"/*.sh 2>/dev/null || true
    g "  Sync OK (${src} -> ${HUB_SCRIPTS_DIR})."
  fi
}

hub_resolve_script() {
  local name="$1"
  local hub="${HUB_SCRIPTS_DIR}/${name}"
  local persist="${PERSIST}/${name}"
  local local="${SCRIPT_DIR}/${name}"
  local pick="" best=""
  for pick in "$hub" "$persist" "$local"; do
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
    y "  Doc: canônico PASSO 2 ou docs/MANUAL.md"
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
# Tamanho minimo plausivel do .deb Haveno (~255 MiB no release 1.6.0-reto).
HAVENO_DEB_MIN_BYTES="${HAVENO_DEB_MIN_BYTES:-104857600}"
# Abaixo disto: pagina de erro do GitHub / wget -c envenenado (ex.: 119 B).
HAVENO_DEB_POISON_MAX_BYTES="${HAVENO_DEB_POISON_MAX_BYTES:-1048576}"
# Assinatura detached GPG real costuma ter centenas de bytes; 119 B = HTML de erro.
HAVENO_SIG_MIN_BYTES="${HAVENO_SIG_MIN_BYTES:-400}"

haveno_deb_size_ok() {
  local f="$1" sz
  [ -f "$f" ] || return 1
  sz="$(stat -c%s "$f" 2>/dev/null || echo 0)"
  [ "${sz:-0}" -ge "${HAVENO_DEB_MIN_BYTES}" ]
}

# Retorna caminho do .deb em Install/ (ou vazio).
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

# Remove .deb/.part minusculos (erro HTML) que fazem wget -c travar em 119 B na .download/.
# Remove tambem .sig envenenada (< 400 B). Mantem parciais de .deb >= 1 MiB.
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
    done < <(find "$dir" -maxdepth 1 \( -name '*.deb' -o -name '*.deb.*' -o -name '*.part' \) -type f -print0 2>/dev/null)
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

# Baixa .deb para a CWD (.download/) com barra curl — espelha 02-baixar-deb.sh.
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

# .deb completo na CWD + App/utils/ prontos → verifica PGP e move para Install/.
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

# App/utils/ ja existe: curl com barra → verify → Install/ (sem upstream).
haveno_hub_download_and_promote_deb() {
  local deb_url="$1" pgp_fpr="$2" expected="${3:-0}"
  [ -d "$UTILS_DIR" ] || return 1
  haveno_hub_download_deb_to_cwd "$deb_url" "$expected"
  haveno_predownload_sig "$deb_url"
  haveno_finalize_verified_deb_in_cwd "$deb_url" "$pgp_fpr"
}

# haveno-install.sh upstream + monitor ASCII + fallback PGP local.
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
      y "  haveno-install.sh falhou apos o .deb completo — tentando verificar PGP localmente..."
      haveno_purge_poisoned_partial_debs "${expected:-0}" "."
      haveno_predownload_sig "$deb_url"
      if haveno_finalize_verified_deb_in_cwd "$deb_url" "$pgp_fpr"; then
        install_rc=0
      fi
    fi
  fi
  return "$install_rc"
}

haveno_deb_download_failed_msg() {
  r "ERRO: haveno-install.sh falhou (PGP/URL/rede)."
  y "  · .deb COMPLETO so em .download/: sync-hub-scripts.sh + haveno-setup.sh --qa-log"
  y "  · .deb+.sig ja em Install/ (App/utils/ OK): haveno-setup.sh --install-only"
  y "  · Fallback: automacao/docs-aluno/TRES-PASSOS-HAVENO-TAILS.md"
  exit 1
}

# DIV-20260617-02: o haveno-install.sh upstream baixa a assinatura com 'wget -cq'
# SEM checar erro (e gera a URL da .sig por conta propria). Se a .sig nao vier
# (URL/rede), o 'gpg --verify .sig .deb' do upstream aborta com
# "No such file or directory" — e o .deb de ~255 MB ja baixado NAO e verificado
# (visto em campo 2026-06-17: .download/ ficou so com .deb, sem .sig). Garantimos
# a .sig (pequena) na PASTA ATUAL antes do upstream, fail-closed; o 'wget -c' do
# upstream a acha completa e a verificacao roda. Espelha o atomico 02-baixar-deb.sh.
# CHAMAR com a CWD ja na pasta de download (.download), antes de 'bash haveno-install.sh'.
# Uso: haveno_predownload_sig "<URL_DO_DEB>"
haveno_predownload_sig() {
  local deb_url="${1:-}" deb_name sig_url sz
  [ -n "$deb_url" ] || die "haveno_predownload_sig: URL do .deb vazia."
  deb_name="$(basename "$deb_url")"
  sig_url="${deb_url}.sig"
  y "  Garantindo a assinatura .sig na pasta de download (fail-closed)..."
  rm -f "${deb_name}.sig" 2>/dev/null || true
  if ! curl -fL --socks5-hostname 127.0.0.1:9050 --progress-bar --max-time 180 \
      -o "${deb_name}.sig" "$sig_url" 2>/dev/null; then
    curl -fL --progress-bar --max-time 180 -o "${deb_name}.sig" "$sig_url" 2>/dev/null \
      || die "Nao baixei a assinatura .sig (${sig_url}) pelo Tor. Confira a URL do release."
  fi
  echo
  sz="$(stat -c%s "${deb_name}.sig" 2>/dev/null || echo 0)"
  haveno_sig_size_ok "${deb_name}.sig" \
    || die "Assinatura .sig suspeita (${sz} bytes) — provavel erro de rede/GitHub, nao PGP."
  head -1 "${deb_name}.sig" 2>/dev/null | grep -q 'BEGIN PGP SIGNATURE' \
    || die "Arquivo .sig nao parece assinatura PGP (conteudo invalido)."
  g "  Assinatura .sig pronta (${deb_name}.sig, ${sz} bytes)."
}

haveno_ensure_reto_pgp_key() {
  local fpr="${1:-}"
  fpr="$(echo "$fpr" | tr -d ' ')"
  [ -n "$fpr" ] || return 1
  gpg --list-keys "$fpr" >/dev/null 2>&1 && return 0
  y "  Importando chave PGP do release..."
  local key_file tmp
  tmp="$(mktemp)"
  if curl -fsSL --socks5-hostname 127.0.0.1:9050 --max-time 120 -o "$tmp" \
      "https://retoswap.com/reto_public.asc" 2>/dev/null \
    || curl -fsSL --max-time 120 -o "$tmp" "https://retoswap.com/reto_public.asc" 2>/dev/null; then
    gpg --import "$tmp" >/dev/null 2>&1 || true
  fi
  rm -f "$tmp"
  gpg --list-keys "$fpr" >/dev/null 2>&1 && return 0
  key_file="${fpr: -16}.asc"
  if curl -fsSL --socks5-hostname 127.0.0.1:9050 --max-time 120 -o "$key_file" \
      "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${fpr}" 2>/dev/null \
    || curl -fsSL --max-time 120 -o "$key_file" \
      "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${fpr}" 2>/dev/null; then
    gpg --import "$key_file" >/dev/null 2>&1 || true
  fi
  gpg --list-keys "$fpr" >/dev/null 2>&1
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

# Verifica PGP e promove .deb+.sig da CWD (ex.: .download/) para Install/.
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

# install.sh upstream espera Install/haveno.deb — cria symlink se so existir nome longo.
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

# Recupera estado quebrado apos 'apt-get install -f' (config-files) ou dpkg sem deps.
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
  # Tails e amnesico: as listas apt ZERAM a cada boot. Sem update completo,
  # nada tem candidato. Fail-closed com retry (DIV-20260611-05).
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
  # Le o Depends DE DENTRO do .deb e classifica (DIV-20260610-02: nomes Ubuntu)
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
      y "  Veja Cap. 7 FAQ 7.11 ou ative Software adicional na persistencia."
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
  [ -f "${utils}/install.sh" ] || die "install.sh nao encontrado. Rode haveno-auto.sh primeiro."
  haveno_ensure_install_deb_link
  haveno_fix_dpkg_state
  haveno_ensure_deb_deps || die "Dependencias do .deb nao instaladas."
  b "Rodando install.sh (pkexec — pode pedir senha admin)..."
  chmod +x "${utils}/install.sh" 2>/dev/null || true
  if ! sudo "${utils}/install.sh"; then
    # Deps com nome Ubuntu inexistentes no Debian (DIV-20260610-02): o dpkg -i
    # do install.sh falha por Depends, mas o app roda sem elas (runtime embutido).
    # Fallback validado em campo: --force-depends + reconfigure.
    if [ "${HAVENO_DEPS_MISSING:-0}" = "1" ] && [ -f "${HAVENO_DIR}/Install/haveno.deb" ]; then
      y "  install.sh falhou por Depends Ubuntu-only — aplicando dpkg --force-depends..."
      if sudo dpkg -i --force-depends "${HAVENO_DIR}/Install/haveno.deb"; then
        sudo dpkg --configure -a 2>/dev/null || true
        g "  haveno instalado com --force-depends (DIV-20260610-02)."
        # NAO re-rodar o install.sh aqui (DIV-20260617): o 'dpkg -i' simples dele
        # volta a DESCONFIGURAR o haveno pelas deps Ubuntu-only E sobrescreve o
        # nosso onion-grater corrigido pelo yml do upstream (quebra o filtro PoW,
        # 'loaded filter: haveno' nao carrega). O haveno fica "install ok installed"
        # -> o exec.sh nao precisa re-rodar o install.sh. O app roda do binario
        # /opt/haveno (runtime embutido); onion-grater + cookie ficam por conta do
        # haveno_fix_onion_grater (chamado depois, com o yml certo).
        return 0
      fi
    fi
    r "  install.sh falhou."
    y "  Nao rode install.sh direto sem passar por haveno-auto.sh — faltam deps apt."
    y "  Recuperacao: ~/Persistent/hub-scripts/haveno-auto.sh --install-only"
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
  # Cookie do Tor: chmod se perde a cada boot (Tails amnesico) — aplicar SEMPRE,
  # mesmo com o filtro ja carregado, senao o Haveno aborta com 'not readable'.
  [ -e "$TOR_COOKIE" ] && sudo chmod o+r "$TOR_COOKIE" 2>/dev/null || true
  local yml_src="${utils}/haveno.yml"
  if [ -f "$HUB_ONION_YML" ]; then
    yml_src="$HUB_ONION_YML"
  fi
  # Se o yml instalado ja e identico ao desejado E o filtro carregou, nada a fazer.
  # (Filtro carregado com yml DIFERENTE = pode ser o upstream quebrado p/ PoW —
  # DIV-20260611-02 — entao reinstala e reinicia mesmo assim.)
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

  # onion-grater + cookie ANTES do exec.sh — o Haveno le o cookie na partida.
  b "Verificando onion-grater..."
  haveno_fix_onion_grater || true

  b "Abrindo Haveno (exec.sh)..."
  chmod +x "${utils}/exec.sh" 2>/dev/null || true
  nohup "${utils}/exec.sh" >/tmp/haveno-exec.log 2>&1 &
  sleep 8
  g "  exec.sh iniciado (log: /tmp/haveno-exec.log)."
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
