#!/bin/bash
###############################################################################
# haveno-update.sh  —  Atualizar o Haveno no Tails com BACKUP automatico antes
#
# O QUE FAZ:
#   1. Confere ambiente (Tails, amnesia, admin, Tor)
#   2. Mostra a versao do Tails e orienta o upgrade do SISTEMA (Tails Upgrader)
#   3. FAZ BACKUP da carteira ANTES de mexer (se Data/ existir)
#   4. Baixa e reinstala o Haveno com a URL + PGP do NOVO release (verifica assinatura)
#   5. install.sh (deps apt + dpkg) + abre Haveno + onion-grater
#
# NAO USE na 1a instalacao — use haveno-setup.sh ou haveno-auto.sh.
#
# USO:
#   ~/Persistent/haveno-update.sh --url "URL_DO_NOVO_DEB" --pgp "FINGERPRINT"
#   Opcoes: --no-backup (NAO recomendado)
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"   # traz sudo_one_password_start (modo --one-password)

# ----------------------------- VALORES PADRAO (editar p/ nova versao) --------
HAVENO_DEB_URL="https://github.com/retoaccess1/haveno-reto/releases/download/1.6.0-reto/haveno-v1.6.0-linux-x86_64-installer.deb"
HAVENO_PGP_FPR="DAA24D878B8D36C90120A897CA02DAC12DAE2D0F"
INSTALL_SCRIPT_URL="https://github.com/haveno-dex/haveno/raw/master/scripts/install_tails/haveno-install.sh"
DATA_DIR="${HAVENO_DIR}/Data"

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
    *) y "Opcao desconhecida: $1 (ignorada)" ;;
  esac
  shift
done
[ -n "$NEW_URL" ] && HAVENO_DEB_URL="$NEW_URL"
[ -n "$NEW_PGP" ] && HAVENO_PGP_FPR="$NEW_PGP"

BACKUP_SCRIPT="${HUB_SCRIPTS_DIR}/haveno-backup.sh"
[ -x "$BACKUP_SCRIPT" ] || BACKUP_SCRIPT="${PERSIST}/haveno-backup.sh"
[ -x "$BACKUP_SCRIPT" ] || BACKUP_SCRIPT="${SCRIPT_DIR}/haveno-backup.sh"

# Modo "uma senha so" (opt-in). No-op sem --one-password.
sudo_one_password_start

echo
b "==============================================================="
b "  haveno-update.sh — atualizar Haveno (backup antes)"
b "==============================================================="
echo

b "[1/6] Conferindo ambiente..."
[ "$(whoami)" = "amnesia" ] || y "  Aviso: usuario nao e 'amnesia'."
sudo -v 2>/dev/null || die "Senha de administrador nao ativa (use '+ Mais opcoes' no boot)."
[ -d "$PERSIST" ] || die "Persistencia nao encontrada."
[ -d "$UTILS_DIR" ] || die "Haveno nao instalado ainda. Use haveno-setup.sh (1a vez), nao haveno-update.sh."
g "  OK."

b "[2/6] Versao do Tails (sistema)..."
TAILS_VER="$( . /etc/os-release 2>/dev/null; echo "${VERSION:-}" )"
[ -n "${TAILS_VER:-}" ] && g "  Tails: ${TAILS_VER}" || y "  (versao nao detectada)"
y "  O SISTEMA Tails NAO e atualizado por este script."
y "  Atualize o Tails pelo 'Tails Upgrader' (apos conectar ao Tor)."

b "[3/6] Esperando Tor (ate 2 min)..."
tor_ok=0; el=0
while [ "$el" -lt 120 ]; do
  curl -s --socks5-hostname 127.0.0.1:9050 --max-time 12 https://check.torproject.org/api/ip 2>/dev/null | grep -q '"IsTor":true' && { tor_ok=1; break; }
  printf "  ... Tor (%ss)\r" "$el"; sleep 10; el=$((el+10))
done
echo
[ "$tor_ok" = "1" ] || die "Tor nao conectou. Conecte e tente de novo."
g "  Tor OK."

if [ "$DO_BACKUP" = "1" ]; then
  b "[4/6] Backup da carteira ANTES de atualizar..."
  if [ ! -d "$DATA_DIR" ] || [ -z "$(ls -A "$DATA_DIR" 2>/dev/null)" ]; then
    y "  Data/ ainda vazia (1a instalacao ou sem carteira) — pulando backup."
  else
    if pgrep -f "/opt/haveno/bin/Haveno" >/dev/null 2>&1; then
      y "  Feche o Haveno para um backup consistente."
      printf "  Continuar? (s/N): "; read -r a; case "${a:-N}" in s|S|sim|SIM) ;; *) die "Cancelado."; esac
    fi
    if [ -x "$BACKUP_SCRIPT" ]; then
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
  fi
else
  y "[4/6] --no-backup: PULANDO backup (NAO recomendado)."
fi

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
EXPECTED_DEB_BYTES="$(haveno_fetch_deb_expected_bytes "$HAVENO_DEB_URL")"
haveno_purge_poisoned_partial_debs "${EXPECTED_DEB_BYTES:-0}" "${HAVENO_DIR}/.download" "${HAVENO_DIR}/Install" "."
# Garante a .sig na CWD antes do upstream (DIV-20260617-02): sem ela o gpg do
# haveno-install.sh aborta com "No such file or directory" mesmo com o .deb OK.
haveno_predownload_sig "$HAVENO_DEB_URL"
# LC_ALL=C: o upstream confere o gpg com grep "Good signature from" (ingles); num
# Tails em PT-BR o gpg diz "Assinatura correta de..." e o grep falha mesmo com a
# assinatura boa (bug de locale, DIV-20260617-02 / DIV-20260607-02). Forca ingles.
if ! LC_ALL=C bash haveno-install.sh "$HAVENO_DEB_URL" "$HAVENO_PGP_FPR"; then
  cd /
  die "Atualizacao falhou (PGP/URL/rede). Seus dados em ${DATA_DIR} estao intactos. O download fica salvo em ${WORK} para retomar."
fi
cd /; rm -rf "$WORK"
g "  Novo .deb verificado e preparado (dados preservados)."

b "[6/6] install.sh (deps apt) + abrir Haveno..."
haveno_run_install
chmod +x "${UTILS_DIR}/exec.sh" 2>/dev/null || true
nohup "${UTILS_DIR}/exec.sh" >/tmp/haveno-exec.log 2>&1 &
sleep 10
if haveno_check_filter | grep -q "loaded filter: haveno"; then
  g "  loaded filter: haveno (OK)."
else
  haveno_fix_onion_grater || true
fi

echo
g "==============================================================="
g "  Atualizacao do Haveno concluida."
g "  CONFIRME o indicador VERDE na janela do Haveno."
g "  Dados preservados em: ${DATA_DIR}"
g "==============================================================="
