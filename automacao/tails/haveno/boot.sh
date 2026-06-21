#!/bin/bash
# =================================================================
# INTERNO — chamado por hub.sh. Não execute diretamente.
# Comando do aluno: hub.sh boot
# =================================================================
###############################################################################
# haveno/boot.sh — boot de sessao (cada vez que o Tails reinicia)
#
# O QUE FAZ: preflight -> install.sh -> exec.sh -> onion-grater
# NAO FAZ: download/reinstall do .deb (use hub.sh install na 1a vez)
#
# USO (via hub): hub.sh boot [--watch MIN] [--qa-log] [--one-password]
# USO (direto): ~/Persistent/hub-scripts/haveno/boot.sh [--watch MIN]
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

WATCH_MIN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --watch) shift; [[ "${1:-}" =~ ^[0-9]+$ ]] && WATCH_MIN="$1" ;;
    --one-password) export HAVENO_ONE_PASSWORD=1 ;;  # digitar a senha admin 1x (ver haveno-common.sh)
    --qa-log) export HAVENO_QA_LOG=1 ;;  # grava ~/Persistent/qa-logs/07-haveno-boot-*.txt
    *) [[ "$1" =~ ^[0-9]+$ ]] && WATCH_MIN="$1" ;;
  esac
  shift
done

# QA log (--qa-log): tee de TODA a saida para ~/Persistent/qa-logs/. No-op sem a flag.
qa_log_tee_begin "07-haveno-boot"

# Modo "uma senha so" (opt-in). No-op sem --one-password ou se um pai ja ativou.
sudo_one_password_start

echo
b "==============================================================="
b "  haveno/boot.sh — abrir Haveno nesta sessao (Playbook §7)"
b "==============================================================="
echo

b "[1/3] Preflight..."
tails_preflight_check || die "Preflight falhou."

b "[2/3] Conferindo instalacao..."
haveno_check_installed || die "Haveno nao instalado. Rode: ~/Persistent/hub-scripts/hub.sh install (1a vez)"
g "  Haveno instalado em ${HAVENO_DIR}."

b "[3/3] Boot da sessao (install.sh + exec.sh)..."
haveno_session_boot

if [ "$WATCH_MIN" -gt 0 ]; then
  b "Monitorando log por ${WATCH_MIN} min..."
  deadline=$(( $(date +%s) + WATCH_MIN * 60 ))
  last=""
  while [ "$(date +%s)" -lt "$deadline" ]; do
    line="$(haveno_check_filter | grep -E 'loaded filter|AUTHCHALLENGE' | tail -1)"
    if [ -n "$line" ] && [ "$line" != "$last" ]; then echo "  log> $line"; last="$line"; fi
    sleep 15
  done
fi

echo
g "==============================================================="
g "  Boot concluido. CONFIRME o indicador VERDE na janela do Haveno."
g "  Amarelo 5–20 min na 1a vez e normal."
g "==============================================================="
qa_log_finish 0
