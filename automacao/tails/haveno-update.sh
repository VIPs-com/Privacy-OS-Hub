#!/bin/bash
###############################################################################
# haveno-update.sh  —  Atualizar o Haveno no Tails com BACKUP automatico antes
#
# O QUE FAZ:
#   1. Confere ambiente (Tails, amnesia, admin, Tor)
#   2. Mostra a versao do Tails e orienta o upgrade do SISTEMA (Tails Upgrader)
#   3. FAZ BACKUP da carteira ANTES de mexer (chama haveno-backup.sh)
#   4. Baixa e reinstala o Haveno com a URL + PGP do NOVO release (verifica assinatura)
#   5. Abre o Haveno e confere 'loaded filter: haveno'
#
# IMPORTANTE — TAILS (SISTEMA OPERACIONAL):
#   Este script NAO atualiza o Tails. O Tails se atualiza pelo proprio
#   "Tails Upgrader" (aparece apos conectar ao Tor) ou por reinstalacao manual
#   em saltos grandes. Faca o upgrade do SO pela ferramenta oficial.
#
# SEGURANCA: exploit 20/05/2026 corrigido na 1.6.0-reto. Use sempre a versao
#   mais recente da sua rede e confirme nos canais oficiais.
#
# USO:
#   chmod +x ~/Persistent/haveno-update.sh
#   ~/Persistent/haveno-update.sh --url "URL_DO_NOVO_DEB" --pgp "FINGERPRINT"
#   (sem --url/--pgp usa os valores padrao abaixo)
#   Opcoes: --no-backup (NAO recomendado)  ·  --no-clock
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"   # traz sudo_one_password_start (modo --one-password)

# ----------------------------- VALORES PADRAO (editar p/ nova versao) --------
HAVENO_DEB_URL="https://github.com/retoaccess1/haveno-reto/releases/download/1.6.0-reto/haveno-v1.6.0-linux-x86_64-installer.deb"
HAVENO_PGP_FPR="DAA24D878B8D36C90120A897CA02DAC12DAE2D0F"
INSTALL_SCRIPT_URL="https://github.com/haveno-dex/haveno/raw/master/scripts/install_tails/haveno-install.sh"

# ----------------------------- Caminhos --------------------------------------
PERSIST="/home/amnesia/Persistent"
HAVENO_DIR="${PERSIST}/haveno"
UTILS_DIR="${HAVENO_DIR}/App/utils"
DATA_DIR="${HAVENO_DIR}/Data"
BACKUP_SCRIPT="${PERSIST}/haveno-backup.sh"
ONION_GRATER_DST="/etc/onion-grater.d/haveno.yml"
TOR_COOKIE="/var/run/tor/control.authcookie"

# ----------------------------- Opcoes ----------------------------------------
DO_BACKUP=1
NEW_URL=""
NEW_PGP=""
while [ $# -gt 0 ]; do
  case "$1" in
    --url) shift; NEW_URL="${1:-}" ;;
    --pgp) shift; NEW_PGP="${1:-}" ;;
    --no-backup) DO_BACKUP=0 ;;
    --no-clock) ;;  # aceito por compatibilidade; sem efeito aqui
    --one-password) export HAVENO_ONE_PASSWORD=1 ;;  # digitar a senha admin 1x (ver haveno-common.sh)
    *) echo "Opcao desconhecida: $1 (ignorada)" ;;
  esac
  shift
done
[ -n "$NEW_URL" ] && HAVENO_DEB_URL="$NEW_URL"
[ -n "$NEW_PGP" ] && HAVENO_PGP_FPR="$NEW_PGP"

# ----------------------------- Cores -----------------------------------------
b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
die(){ r "ERRO: $*"; exit 1; }

# Modo "uma senha so" (opt-in). No-op sem --one-password.
sudo_one_password_start

echo
b "==============================================================="
b "  haveno-update.sh — atualizar Haveno (backup antes)"
b "==============================================================="
echo

# ----------------------------- 1. Ambiente -----------------------------------
b "[1/6] Conferindo ambiente..."
[ "$(whoami)" = "amnesia" ] || y "  Aviso: usuario nao e 'amnesia'."
sudo -v 2>/dev/null || die "Senha de administrador nao ativa (use '+ Mais opcoes' no boot)."
[ -d "$PERSIST" ] || die "Persistencia nao encontrada."
[ -d "$UTILS_DIR" ] || die "Haveno nao instalado ainda. Use haveno-auto.sh primeiro."
g "  OK."

# ----------------------------- 2. Versao do Tails (SO) -----------------------
b "[2/6] Versao do Tails (sistema)..."
TAILS_VER="$( . /etc/os-release 2>/dev/null; echo "${VERSION:-}" )"
[ -n "${TAILS_VER:-}" ] && g "  Tails: ${TAILS_VER}" || y "  (versao nao detectada)"
y "  O SISTEMA Tails NAO e atualizado por este script."
y "  Atualize o Tails pelo 'Tails Upgrader' (apos conectar ao Tor) ou,"
y "  em saltos grandes, reinstalando pela ferramenta oficial (tails.net)."
y "  >>> Faca isso DEPOIS de garantir o backup abaixo. <<<"

# ----------------------------- 3. Esperar Tor --------------------------------
b "[3/6] Esperando Tor (ate 2 min)..."
tor_ok=0; el=0
while [ "$el" -lt 120 ]; do
  curl -s --socks5-hostname 127.0.0.1:9050 --max-time 12 https://check.torproject.org/api/ip 2>/dev/null | grep -q '"IsTor":true' && { tor_ok=1; break; }
  printf "  ... Tor (%ss)\r" "$el"; sleep 10; el=$((el+10))
done
echo
[ "$tor_ok" = "1" ] || die "Tor nao conectou. Conecte e tente de novo."
g "  Tor OK."

# ----------------------------- 4. BACKUP antes de tudo -----------------------
if [ "$DO_BACKUP" = "1" ]; then
  b "[4/6] Backup da carteira ANTES de atualizar..."
  if pgrep -f "/opt/haveno/bin/Haveno" >/dev/null 2>&1; then
    y "  Feche o Haveno para um backup consistente."
    printf "  Continuar? (s/N): "; read -r a; case "${a:-N}" in s|S|sim|SIM) ;; *) die "Cancelado."; esac
  fi
  if [ -f "$BACKUP_SCRIPT" ]; then
    bash "$BACKUP_SCRIPT" || die "Backup falhou — atualizacao abortada (seus dados estao intactos)."
  else
    y "  haveno-backup.sh nao encontrado — backup simples (cifrado) agora."
    STAMP="$(date +%Y%m%d-%H%M%S)"; mkdir -p "${PERSIST}/Backups"
    TMP="$(mktemp -d)"
    tar -czf "${TMP}/haveno-data-${STAMP}.tar.gz" -C "$HAVENO_DIR" Data || { rm -rf "$TMP"; die "Falha ao compactar."; }
    gpg -c -o "${PERSIST}/Backups/haveno-data-${STAMP}.tar.gz.gpg" "${TMP}/haveno-data-${STAMP}.tar.gz" \
      || { rm -rf "$TMP"; die "Falha ao cifrar backup."; }
    rm -rf "$TMP"
    g "  Backup em ${PERSIST}/Backups/haveno-data-${STAMP}.tar.gz.gpg"
  fi
  g "  Backup concluido."
else
  y "[4/6] --no-backup: PULANDO backup (NAO recomendado)."
fi

# ----------------------------- 5. Atualizar o .deb ---------------------------
b "[5/6] Atualizando Haveno (verifica PGP)..."
echo "  URL: $HAVENO_DEB_URL"
echo "  PGP: $HAVENO_PGP_FPR"
# Pasta de download PERSISTENTE (DIV-20260617-01): Tails e amnesico, /tmp = RAM.
# Em ~/Persistent/haveno/.download o 'wget -c' do install.sh upstream retoma o .deb
# no proximo boot em vez de perder o download em /tmp. Em FALHA NAO apagamos a
# pasta (deixa o download retomar); so limpamos no sucesso. (Igual ao haveno-auto.sh.)
WORK="${HAVENO_DIR}/.download"
mkdir -p "$WORK" || die "Nao criei a pasta de download persistente (${WORK})."
cd "$WORK" || die "Nao entrei em ${WORK}."
if ! curl -fsSLO "$INSTALL_SCRIPT_URL" 2>/dev/null; then
  curl -x socks5h://127.0.0.1:9050 -fsSLO "$INSTALL_SCRIPT_URL" 2>/dev/null || { cd /; die "Nao baixei haveno-install.sh."; }
fi
if ! bash haveno-install.sh "$HAVENO_DEB_URL" "$HAVENO_PGP_FPR"; then
  cd /
  die "Atualizacao falhou (PGP/URL/rede). Seus dados em ${DATA_DIR} estao intactos. O download fica salvo em ${WORK} para retomar."
fi
cd /; rm -rf "$WORK"
g "  Novo .deb verificado e preparado (dados preservados)."

# ----------------------------- 6. Abrir e verificar --------------------------
b "[6/6] Abrindo o Haveno e conferindo o filtro..."
chmod +x "${UTILS_DIR}/exec.sh" 2>/dev/null || true
nohup "${UTILS_DIR}/exec.sh" >/tmp/haveno-exec.log 2>&1 &
sleep 10
if sudo journalctl -u onion-grater -b --no-pager 2>/dev/null | grep -q "loaded filter: haveno"; then
  g "  loaded filter: haveno (OK)."
else
  y "  Filtro ainda nao confirmado — corrigindo onion-grater..."
  sudo cp "${UTILS_DIR}/haveno.yml" "$ONION_GRATER_DST" 2>/dev/null || true
  [ -e "$TOR_COOKIE" ] && sudo chmod o+r "$TOR_COOKIE" 2>/dev/null || true
  sudo systemctl restart onion-grater 2>/dev/null || true
  sleep 4
  sudo journalctl -u onion-grater -b --no-pager 2>/dev/null | grep -q "loaded filter: haveno" \
    && g "  Corrigido." || y "  Ainda nao — veja o Capitulo 7 (FAQ) do livro Curso-Tails-OS-Expert.md"
fi

echo
g "==============================================================="
g "  Atualizacao do Haveno concluida."
g "  CONFIRME o indicador VERDE na janela do Haveno."
g "  Dados preservados em: ${DATA_DIR}"
g "  Lembrete: para atualizar o SISTEMA Tails, use o Tails Upgrader."
g "==============================================================="
