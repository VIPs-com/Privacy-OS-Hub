#!/bin/bash
###############################################################################
# haveno-auto.sh  —  Automação Haveno no Tails (rede Reto / turma)
#
# O QUE FAZ (depois de você já ter criado a Persistência + Dotfiles):
#   1. Confere que está no Tails, usuario amnesia, com senha admin ativa
#   2. Confere persistencia e Dotfiles
#   3. Garante fuso horario UTC (privacidade: nao revela localizacao)
#   4. Espera o Tor conectar (IsTor + cross-check 'Bootstrapped 100%' no boot atual)
#   5. (Opcional) Ajusta o relogio pela hora obtida ATRAVES do Tor (sem vazar local)
#   6. Baixa e roda o haveno-install.sh oficial com URL + PGP REAIS da Reto
#   7. Instala/configura via exec.sh (pkexec) e abre o Haveno
#   8. Verifica 'loaded filter: haveno'; se vier 'None', corrige onion-grater sozinho
#   9. Monitora ate o filtro ficar OK e orienta sobre o indicador VERDE
#
# NAO FAZ: nao negocia, nao mexe na carteira, nao toca em fundos.
# SEGURANCA: exploit de 20/05/2026 CORRIGIDO na 1.6.0-reto (24/05/2026, fix #2315).
#            Use 1.6.0-reto+; antes de tradear confirme a retomada nos canais oficiais.
#
# USO:
#   1. Salve este arquivo em ~/Persistent (armazenamento persistente)
#   2. No Terminal:
#        chmod +x ~/Persistent/haveno-auto.sh
#        ~/Persistent/haveno-auto.sh
#   Opcoes:
#        --no-clock   nao tenta ajustar o relogio pelo Tor
#        --watch N    monitora o log por N minutos (padrao 8)
#        --update     forca reinstalar/atualizar o .deb (mesmo se ja instalado)
#        --install-only  so [7-9]: deps apt + install.sh (sem download; recuperacao)
#        --boot-only  delega a haveno-boot.sh (sessao; sem download)
#
# ATUALIZAR PARA VERSAO NOVA:
#   1. Edite HAVENO_DEB_URL e HAVENO_PGP_FPR abaixo com os valores do NOVO release
#   2. Rode:  ~/Persistent/haveno-auto.sh --update
#   (Os dados em ~/Persistent/haveno/Data/ sao preservados.)
###############################################################################

set -uo pipefail

# ----------------------------- VALORES REAIS (Reto 1.6.0-reto) ---------------
HAVENO_DEB_URL="https://github.com/retoaccess1/haveno-reto/releases/download/1.6.0-reto/haveno-v1.6.0-linux-x86_64-installer.deb"
HAVENO_PGP_FPR="DAA24D878B8D36C90120A897CA02DAC12DAE2D0F"
INSTALL_SCRIPT_URL="https://github.com/haveno-dex/haveno/raw/master/scripts/install_tails/haveno-install.sh"

# ----------------------------- Caminhos Tails --------------------------------
PERSIST="/home/amnesia/Persistent"
HAVENO_DIR="${PERSIST}/haveno"
UTILS_DIR="${HAVENO_DIR}/App/utils"
DOTFILES_DIR="/live/persistence/TailsData_unlocked/dotfiles"
ONION_GRATER_DST="/etc/onion-grater.d/haveno.yml"
TOR_COOKIE="/var/run/tor/control.authcookie"

# ----------------------------- Opcoes ----------------------------------------
DO_CLOCK=1
DO_UPDATE=0
WATCH_MIN=8
BOOT_ONLY=0
INSTALL_ONLY=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"
while [ $# -gt 0 ]; do
  case "$1" in
    --no-clock) DO_CLOCK=0 ;;
    --update)   DO_UPDATE=1 ;;
    --install-only) INSTALL_ONLY=1; DO_CLOCK=0 ;;
    --boot-only) BOOT_ONLY=1 ;;
    --one-password) export HAVENO_ONE_PASSWORD=1 ;;  # digitar a senha admin 1x (ver haveno-common.sh)
    --qa-log) export HAVENO_QA_LOG=1 ;;  # grava ~/Persistent/qa-logs/02-haveno-auto-*.txt
    --watch)    shift; [[ "${1:-}" =~ ^[0-9]+$ ]] && WATCH_MIN="$1" ;;  # --watch N (sem N: mantem padrao)
    *)          [[ "$1" =~ ^[0-9]+$ ]] && WATCH_MIN="$1" ;;
  esac
  shift
done

# --boot-only: delega a haveno-boot.sh ANTES de virar dono da sessao 1-senha — o
# exec substitui este processo (perderia o trap de limpeza); quem ativa/limpa e o
# boot.sh (herda HAVENO_ONE_PASSWORD pelo ambiente).
if [ "$BOOT_ONLY" = "1" ]; then
  if [ "${HAVENO_QA_LOG:-0}" = "1" ]; then
    exec "${SCRIPT_DIR}/haveno-boot.sh" --qa-log ${WATCH_MIN:+"$WATCH_MIN"}
  else
    exec "${SCRIPT_DIR}/haveno-boot.sh" ${WATCH_MIN:+"$WATCH_MIN"}
  fi
fi

# QA log (--qa-log): tee de TODA a saida para ~/Persistent/qa-logs/ — captura ate
# os erros de install (antes so dava print). No-op sem a flag. Depois do boot-only
# (la quem loga e o boot.sh) e antes do resto, para registrar o fluxo inteiro.
qa_log_tee_begin "02-haveno-auto"

# Modo "uma senha so" (opt-in). No-op sem --one-password ou se um pai ja ativou.
sudo_one_password_start

# ----------------------------- Modo recuperacao (--install-only) -----------
if [ "$INSTALL_ONLY" = "1" ]; then
  echo
  b "==============================================================="
  b "  haveno-auto.sh --install-only (deps + install, sem download)"
  b "==============================================================="
  echo
  b "[recuperacao] Conferindo minimo..."
  sudo -v 2>/dev/null || die "Senha de administrador nao ativa."
  [ -d "$PERSIST" ] || die "Persistencia nao encontrada ($PERSIST)."
  [ -f "${UTILS_DIR}/install.sh" ] || die "install.sh ausente em ${UTILS_DIR}/."
  [ -f "${UTILS_DIR}/exec.sh" ] || die "exec.sh ausente."
  INSTALL_SHA="$(sha256sum "${UTILS_DIR}/install.sh" 2>/dev/null | awk '{print $1}')"
  g "  install.sh sha256: ${INSTALL_SHA:-desconhecido} (auditoria de procedencia em disco)"
  haveno_has_install_deb || die "Nenhum .deb em ${HAVENO_DIR}/Install/ — nao precisa recomecar do zero se ja copiou o .deb."
  g "  .deb na persistencia OK."
  b "[7/9] Dependencias apt + install.sh + onion-grater + exec.sh..."
  chmod +x "${UTILS_DIR}/exec.sh" 2>/dev/null || true
  haveno_run_install || die "install.sh falhou."
  # cookie + onion-grater ANTES do exec.sh (senao o Haveno encerra com cookie
  # ilegivel — DIV-20260611-01). Mesma ordem do haveno-boot.sh.
  b "  Preparando onion-grater + cookie do Tor (antes de abrir)..."
  haveno_fix_onion_grater || true
  nohup "${UTILS_DIR}/exec.sh" >/tmp/haveno-exec.log 2>&1 &
  HAVENO_BG=$!
  sleep 8
  g "  exec.sh iniciado (log: /tmp/haveno-exec.log)."
  b "[8/9] Confirmando onion-grater..."
  sleep 4
  if haveno_check_filter | grep -q "loaded filter: haveno"; then
    g "  loaded filter: haveno (OK)."
  else
    haveno_fix_onion_grater || true
  fi
  b "[9/9] Monitorando por ${WATCH_MIN} min..."
  y "  CONFIRME o indicador VERDE na janela do Haveno."
  deadline=$(( $(date +%s) + WATCH_MIN*60 ))
  while [ "$(date +%s)" -lt "$deadline" ]; do
    sleep 15
  done
  g "  Concluido --install-only. Dados: ${HAVENO_DIR}/Data/"
  qa_log_finish 0
  exit 0
fi

# ----------------------------- Cores -----------------------------------------
b(){ echo -e "\033[1;34m$*\033[0m"; }       # azul
g(){ echo -e "\033[1;32m$*\033[0m"; }       # verde
y(){ echo -e "\033[1;33m$*\033[0m"; }       # amarelo
r(){ echo -e "\033[0;31m$*\033[0m"; }       # vermelho
die(){
  r "ERRO: $*"
  echo "Abortando. Apendice B (erros comuns) no arquivo canonico do curso."
  echo "  Recuperacao: automacao/docs-aluno/TRES-PASSOS-HAVENO-TAILS.md"
  exit 1
}

_fetch_http_date() {
  local url="$1"
  curl -sI --socks5-hostname 127.0.0.1:9050 --max-time 30 "$url" 2>/dev/null \
    | grep -i '^date:' | head -1 | sed -E 's/^[Dd]ate:[[:space:]]*//' | tr -d '\r'
}

echo
b "==============================================================="
b "  haveno-auto.sh — Haveno no Tails (Reto 1.6.0-reto)  "
b "  Exploit 20/05 CORRIGIDO na 1.6.0-reto · tradear com cautela"
b "==============================================================="
echo

# ----------------------------- 1. Ambiente Tails -----------------------------
b "[1/9] Conferindo ambiente Tails..."
[ -f /etc/os-release ] && grep -qi "tails" /etc/os-release || y "  Aviso: nao parece Tails (siga so se souber o que faz)."
[ "$(whoami)" = "amnesia" ] || y "  Aviso: usuario nao e 'amnesia' (esperado no Tails)."

# senha admin ativa? (sudo configurado)
if ! sudo -v 2>/dev/null; then
  die "Senha de administrador nao esta ativa. Reinicie e use '+ Mais opcoes' na tela de boas-vindas."
fi
g "  Admin OK."

# ----------------------------- 2. Persistencia + Dotfiles --------------------
b "[2/9] Conferindo Persistencia e Dotfiles..."
[ -d "$PERSIST" ] || die "Persistencia nao encontrada ($PERSIST). Crie o Armazenamento Persistente."
if [ ! -d "$DOTFILES_DIR" ]; then
  die "Dotfiles nao ativado. Abra 'Armazenamento persistente' e marque Dotfiles, depois reinicie."
fi
g "  Persistencia + Dotfiles OK."

# ----------------------------- 3. Fuso UTC (privacidade) ---------------------
b "[3/9] Garantindo fuso horario UTC (sem revelar localizacao)..."
sudo timedatectl set-timezone UTC 2>/dev/null || true
TZNOW="$(timedatectl show -p Timezone --value 2>/dev/null || echo '?')"
g "  Fuso: $TZNOW (UTC = padrao privado do Tails)."

# ----------------------------- 4. Esperar Tor --------------------------------
b "[4/9] Esperando o Tor conectar (ate 3 min)..."
TOR_MAX=180        # segundos
tor_ok=0
elapsed=0
while [ "$elapsed" -lt "$TOR_MAX" ]; do
  if curl -s --socks5-hostname 127.0.0.1:9050 --max-time 12 https://check.torproject.org/api/ip 2>/dev/null | grep -q '"IsTor":true'; then
    tor_ok=1; break
  fi
  printf "  ... aguardando Tor (%ss/%ss)\r" "$elapsed" "$TOR_MAX"
  sleep 10; elapsed=$((elapsed + 10))
done
echo
[ "$tor_ok" = "1" ] || die "Tor nao conectou em ${TOR_MAX}s. Abra o assistente 'Conexao a rede Tor' e tente de novo."
g "  Tor conectado (IsTor: true)."

# Cross-check (herdado do script v2): confirma bootstrap 100% no boot ATUAL.
if sudo journalctl -u tor@default -b --no-pager 2>/dev/null | grep -q "Bootstrapped 100%"; then
  g "  Tor bootstrap 100% confirmado no log."
else
  y "  Sem 'Bootstrapped 100%' no log ainda — IsTor ja respondeu true, seguindo."
fi

# ----------------------------- 5. Relogio via Tor ----------------------------
if [ "$DO_CLOCK" = "1" ]; then
  b "[5/9] Ajustando relogio pela hora obtida ATRAVES do Tor (sem vazar local)..."
  y "  (Opcional/fallback: o Tails sincroniza o tempo via Tor no boot — nao e NTP classico. Use --no-clock para pular.)"
  HTTPDATE=""
  for clock_url in \
      "https://check.torproject.org/" \
      "https://www.torproject.org/" \
      "https://www.debian.org/"; do
    HTTPDATE="$(_fetch_http_date "$clock_url")"
    [ -n "${HTTPDATE:-}" ] && break
    sleep 3
  done
  if [ -n "${HTTPDATE:-}" ]; then
    if sudo date -s "$HTTPDATE" >/dev/null 2>&1; then
      g "  Relogio ajustado (UTC): $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    else
      y "  Nao consegui aplicar a hora; o Tails ja corrige sozinho. Seguindo."
      y "  Hora atual: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    fi
  else
    y "  Sem cabecalho Date pelo Tor apos 3 tentativas — nao ajustei o relogio."
    y "  No Tails, 'timedatectl' costuma mostrar synchronized: no — isso e normal (sync via Tor, nao NTP)."
    y "  Hora atual do sistema: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    y "  Confira com um relogio UTC confiavel; se TLS/PGP falharem, reinicie o Tails com Tor."
  fi
else
  y "[5/9] Pulando ajuste de relogio (--no-clock)."
fi

# ----------------------------- 6. Instalar Haveno (script oficial) -----------
b "[6/9] Baixando e verificando Haveno (script oficial + PGP da Reto)..."
# Pasta de download PERSISTENTE (DIV-20260617-01). O Tails e amnesico e /tmp = RAM:
# um mktemp -d punha o download de 30-90 min do .deb em /tmp e, se a rede caisse
# ou voce reiniciasse, TUDO se perdia (e o monitor parecia "erro de pasta tmp").
# Em ~/Persistent/haveno/.download o 'wget -cq' do install.sh upstream RETOMA de
# onde parou no proximo boot, e o monitor de progresso (que ja varre ${HAVENO_DIR})
# enxerga o .deb crescendo. So e apagada no FINAL, em caso de sucesso (linha de
# cleanup) — em falha fica para o download retomar.
WORK="${HAVENO_DIR}/.download"
mkdir -p "$WORK" || die "Nao criei a pasta de download persistente (${WORK})."
cd "$WORK" || die "Nao entrei em ${WORK}."

dl_ok=0
if curl -fsSLO "$INSTALL_SCRIPT_URL" 2>/dev/null; then dl_ok=1; fi
if [ "$dl_ok" = "0" ]; then
  y "  Tentando baixar o script via Tor..."
  curl -x socks5h://127.0.0.1:9050 -fsSLO "$INSTALL_SCRIPT_URL" 2>/dev/null && dl_ok=1
fi
[ "$dl_ok" = "1" ] || die "Nao baixei haveno-install.sh (rede/Tor)."
INSTALL_SHA="$(sha256sum haveno-install.sh 2>/dev/null | awk '{print $1}')"
g "  haveno-install.sh sha256: ${INSTALL_SHA:-desconhecido} (auditoria de procedencia)"

if [ "$DO_UPDATE" = "1" ] || [ ! -d "$UTILS_DIR" ] || ! haveno_has_install_deb; then
  [ "$DO_UPDATE" = "1" ] && y "  Modo --update: reinstalando/atualizando o .deb (dados preservados)."
  EXPECTED_DEB_BYTES="$(haveno_fetch_deb_expected_bytes "$HAVENO_DEB_URL")"
  haveno_purge_poisoned_partial_debs "${EXPECTED_DEB_BYTES:-0}" "${HAVENO_DIR}/.download" "${HAVENO_DIR}/Install" "."
  SKIP_UPSTREAM=0
  if haveno_try_promote_deb_from_cwd "$HAVENO_DEB_URL" "$HAVENO_PGP_FPR"; then
    SKIP_UPSTREAM=1
  fi
  if [ "$SKIP_UPSTREAM" = "0" ] && [ -d "$UTILS_DIR" ] && ! haveno_has_install_deb; then
    if haveno_hub_download_and_promote_deb "$HAVENO_DEB_URL" "$HAVENO_PGP_FPR" "${EXPECTED_DEB_BYTES:-0}"; then
      SKIP_UPSTREAM=1
    fi
  fi
  if [ "$SKIP_UPSTREAM" = "0" ]; then
  y "  Download do .deb pelo Tor: pode levar 30-90 min."
  y "  Progresso: barra ASCII a cada ${HAVENO_DOWNLOAD_MONITOR_SEC}s (upstream) ou barra curl (hub)."
  if [ -n "${EXPECTED_DEB_BYTES:-}" ] && [ "${EXPECTED_DEB_BYTES:-0}" -gt 0 ] 2>/dev/null; then
    y "  Tamanho esperado do .deb: $(haveno_fmt_bytes "$EXPECTED_DEB_BYTES")"
  fi
  if ! haveno_run_upstream_install_deb "$HAVENO_DEB_URL" "$HAVENO_PGP_FPR" "${EXPECTED_DEB_BYTES:-0}"; then
    haveno_deb_download_failed_msg
  fi
  fi
  g "  Haveno preparado na persistencia."
else
  g "  Haveno ja estava preparado (pulando download). Use --update para forcar nova versao."
fi

[ -f "${UTILS_DIR}/exec.sh" ] || die "exec.sh nao encontrado em ${UTILS_DIR}."
[ -f "${UTILS_DIR}/install.sh" ] || die "install.sh nao encontrado em ${UTILS_DIR}."
[ -f "${UTILS_DIR}/haveno.yml" ] || die "haveno.yml nao encontrado em ${UTILS_DIR}."

# ----------------------------- 7. install.sh + onion-grater + exec.sh --------
b "[7/9] Dependencias apt + install.sh + onion-grater + exec.sh (pode pedir senha admin)..."
chmod +x "${UTILS_DIR}/exec.sh" 2>/dev/null || true
haveno_run_install || die "install.sh falhou."
# onion-grater + cookie do Tor ANTES de abrir o Haveno. O app le o cookie na
# partida; se o 'chmod o+r' vier so DEPOIS (como estava no [8/9]), ele abre e
# ENCERRA com 'torControlCookieFile ... is not readable' (DIV-20260611-01) — foi
# o que travou em campo 2026-06-17. Mesma ordem do haveno-boot.sh (validada R31).
b "  Preparando onion-grater + cookie do Tor (antes de abrir)..."
haveno_fix_onion_grater || true
nohup "${UTILS_DIR}/exec.sh" >/tmp/haveno-exec.log 2>&1 &
HAVENO_BG=$!
sleep 8
g "  exec.sh iniciado (log: /tmp/haveno-exec.log)."

# ----------------------------- 8. Re-verificar o filtro ----------------------
b "[8/9] Confirmando perfil onion-grater (loaded filter)..."
sleep 4
check_filter(){ haveno_check_filter; }

if check_filter | grep -q "loaded filter: haveno"; then
  g "  loaded filter: haveno (OK)."
else
  haveno_fix_onion_grater || true
  if check_filter | grep -qiE "bad yaml|invalid|traceback|profile" ; then
    y "  Log do onion-grater menciona possivel erro de YAML/perfil — confira Apendice B erros 1-2 e 13 no canonico"
  fi
fi

# ----------------------------- 9. Monitorar verde ----------------------------
b "[9/9] Monitorando por ${WATCH_MIN} min (Ctrl+C para sair)..."
y "  O indicador VERDE aparece na JANELA do Haveno (canto inferior)."
y "  Na 1a vez, amarelo por 5-20 min e NORMAL."
deadline=$(( $(date +%s) + WATCH_MIN*60 ))
last=""
while [ "$(date +%s)" -lt "$deadline" ]; do
  line="$(check_filter | grep -E 'loaded filter|AUTHCHALLENGE|bad YAML' | tail -1)"
  if [ -n "$line" ] && [ "$line" != "$last" ]; then echo "  log> $line"; last="$line"; fi
  if ! kill -0 "$HAVENO_BG" 2>/dev/null && ! pgrep -f "/opt/haveno/bin/Haveno" >/dev/null 2>&1; then
    y "  Processo Haveno encerrou. Reabra por: Aplicacoes -> Outros -> Haveno"
    break
  fi
  sleep 15
done

echo
g "==============================================================="
g "  Concluido o que da para automatizar."
g "  CONFIRME o indicador VERDE na janela do Haveno."
g "  Dados: ${HAVENO_DIR}/Data/"
g "  ANTES DE TRADEAR: confirme a retomada nos canais oficiais da Reto"
g "  e comece com valores pequenos (fix #2315 ja incluso na 1.6.0-reto)."
g "==============================================================="
qa_log_finish 0
# Chegou ate aqui = sucesso: o .deb ja foi movido para Install/. So agora limpamos
# a pasta de download persistente (em falha, o script sai antes e ela fica para retomar).
cd / ; rm -rf "$WORK" 2>/dev/null || true
