#!/bin/bash
###############################################################################
# haveno-backup.sh  —  Backup/restauracao da carteira Haveno no Tails
#
# O QUE FAZ:
#   - Compacta ~/Persistent/haveno/Data/ (carteira, historico, contas)
#   - Cifra com GPG (senha) — backups do Haveno NAO sao cifrados por padrao
#   - Salva na persistencia (~/Persistent/Backups) ou num USB montado
#   - Verifica a integridade do arquivo e gera um .sha256
#   - Pode RESTAURAR um backup (com copia de seguranca do estado atual)
#
# PRIVACIDADE/SEGURANCA:
#   - Nao usa rede. Mantenha o arquivo .gpg offline.
#   - A SEED nao entra aqui: anote-a pela interface (Account > Wallet seed).
#   - FECHE o Haveno antes de rodar (evita copiar carteira em uso).
#
# USO:
#   chmod +x ~/Persistent/haveno-backup.sh
#
#   Backup (destino padrao = ~/Persistent/Backups):
#     ~/Persistent/haveno-backup.sh
#   Backup para um USB montado (escolhe/escolha o volume):
#     ~/Persistent/haveno-backup.sh --usb
#   Backup para pasta especifica:
#     ~/Persistent/haveno-backup.sh --dest /media/amnesia/MEU_USB
#   Sem cifrar (NAO recomendado):
#     ~/Persistent/haveno-backup.sh --no-encrypt
#   Restaurar:
#     ~/Persistent/haveno-backup.sh --restore /caminho/haveno-data-AAAA....tar.gz.gpg
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=haveno-common.sh
source "${SCRIPT_DIR}/haveno-common.sh"

# ----------------------------- Caminhos --------------------------------------
PERSIST="/home/amnesia/Persistent"
DATA_DIR="${PERSIST}/haveno/Data"
DEFAULT_DEST="${PERSIST}/Backups"
MEDIA_DIR="/media/amnesia"

# ----------------------------- Cores -----------------------------------------
b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
die(){ r "ERRO: $*"; exit 1; }

# ----------------------------- Opcoes ----------------------------------------
DEST=""
USE_USB=0
ENCRYPT=1
RESTORE_FILE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --usb) USE_USB=1 ;;
    --dest) shift; DEST="${1:-}" ;;
    --no-encrypt) ENCRYPT=0 ;;
    --restore) shift; RESTORE_FILE="${1:-}" ;;
    --qa-log) export HAVENO_QA_LOG=1 ;;
    *) y "Opcao desconhecida: $1 (ignorada)" ;;
  esac
  shift
done

qa_log_tee_begin "04-haveno-backup"

echo
b "==============================================================="
b "  haveno-backup.sh — backup da carteira Haveno (Tails)"
b "==============================================================="
echo

# ----------------------------- Pre-checagens ---------------------------------
[ "$(whoami)" = "amnesia" ] || y "Aviso: usuario nao e 'amnesia' (esperado no Tails)."

if pgrep -f "/opt/haveno/bin/Haveno" >/dev/null 2>&1; then
  y "ATENCAO: o Haveno parece estar ABERTO."
  y "Feche-o antes de continuar para nao copiar a carteira em uso."
  printf "Continuar mesmo assim? (s/N): "; read -r ans
  case "${ans:-N}" in s|S|sim|SIM) ;; *) die "Cancelado. Feche o Haveno e rode de novo."; esac
fi

###############################################################################
# MODO RESTAURACAO
###############################################################################
if [ -n "$RESTORE_FILE" ]; then
  b "[restore] Restaurando de: $RESTORE_FILE"
  [ -f "$RESTORE_FILE" ] || die "Arquivo de backup nao encontrado."

  TMP="$(mktemp -d)"
  TARFILE="${TMP}/restore.tar.gz"

  case "$RESTORE_FILE" in
    *.gpg)
      b "  Descriptografando (vai pedir a senha do backup)..."
      gpg -o "$TARFILE" -d "$RESTORE_FILE" || { rm -rf "$TMP"; die "Falha ao descriptografar (senha?)."; }
      ;;
    *.tar.gz)
      cp "$RESTORE_FILE" "$TARFILE" ;;
    *) rm -rf "$TMP"; die "Formato nao reconhecido (.tar.gz ou .tar.gz.gpg)." ;;
  esac

  b "  Testando integridade do arquivo..."
  tar -tzf "$TARFILE" >/dev/null 2>&1 || { rm -rf "$TMP"; die "Arquivo corrompido."; }
  g "  Arquivo OK."

  # Copia de seguranca do estado atual antes de sobrescrever
  if [ -d "$DATA_DIR" ]; then
    SAFETY="${PERSIST}/haveno/Data.bak-$(date +%Y%m%d-%H%M%S)"
    y "  Estado atual sera salvo em: $SAFETY"
    printf "Confirmar restauracao (sobrescreve Data/)? (s/N): "; read -r ans
    case "${ans:-N}" in s|S|sim|SIM) ;; *) rm -rf "$TMP"; die "Cancelado."; esac
    mv "$DATA_DIR" "$SAFETY" || { rm -rf "$TMP"; die "Nao consegui salvar o estado atual."; }
  fi

  mkdir -p "$DATA_DIR"
  tar -xzf "$TARFILE" -C "$(dirname "$DATA_DIR")" || { rm -rf "$TMP"; die "Falha ao extrair."; }
  rm -rf "$TMP"
  g "Restauracao concluida em: $DATA_DIR"
  y "Abra o Haveno pelo menu e confirme a carteira/historico."
  qa_log_line "Restauracao concluida: $DATA_DIR"
  qa_log_finish 0
  exit 0
fi

###############################################################################
# MODO BACKUP
###############################################################################
[ -d "$DATA_DIR" ] || die "Pasta de dados nao encontrada ($DATA_DIR). Instale/abra o Haveno antes."

# Definir destino
if [ "$USE_USB" = "1" ] && [ -z "$DEST" ]; then
  b "[dest] Procurando USB montado em ${MEDIA_DIR}..."
  mapfile -t VOLS < <(find "$MEDIA_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  if [ "${#VOLS[@]}" -eq 0 ]; then
    die "Nenhum USB montado. Abra o gerenciador de Arquivos e desbloqueie/monte o USB primeiro."
  elif [ "${#VOLS[@]}" -eq 1 ]; then
    DEST="${VOLS[0]}"
  else
    y "  Varios volumes encontrados:"
    i=1; for v in "${VOLS[@]}"; do echo "    [$i] $v"; i=$((i+1)); done
    printf "  Escolha o numero: "; read -r n
    DEST="${VOLS[$((n-1))]:-}"
    [ -n "$DEST" ] || die "Escolha invalida."
  fi
fi
[ -n "$DEST" ] || DEST="$DEFAULT_DEST"

mkdir -p "$DEST" || die "Nao consegui criar/usar o destino: $DEST"
[ -w "$DEST" ] || die "Sem permissao de escrita em: $DEST"
g "  Destino: $DEST"

STAMP="$(date +%Y%m%d-%H%M%S)"
BASE="haveno-data-${STAMP}"
TMP="$(mktemp -d)"
TARFILE="${TMP}/${BASE}.tar.gz"

# Compactar (Data/ relativo, para restaurar limpo)
b "[1/4] Compactando ${DATA_DIR}..."
tar -czf "$TARFILE" -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")" \
  || { rm -rf "$TMP"; die "Falha ao compactar."; }

# Verificar o tar
b "[2/4] Verificando integridade do arquivo..."
tar -tzf "$TARFILE" >/dev/null 2>&1 || { rm -rf "$TMP"; die "Arquivo gerado esta corrompido."; }
SIZE="$(du -h "$TARFILE" | cut -f1)"
g "  OK (${SIZE})."

# Cifrar
if [ "$ENCRYPT" = "1" ]; then
  b "[3/4] Cifrando com GPG (defina uma senha forte; guarde-a)..."
  OUT="${DEST}/${BASE}.tar.gz.gpg"
  gpg -c --cipher-algo AES256 -o "$OUT" "$TARFILE" || { rm -rf "$TMP"; die "Falha ao cifrar."; }
else
  y "[3/4] --no-encrypt: salvando SEM cifrar (NAO recomendado)."
  OUT="${DEST}/${BASE}.tar.gz"
  cp "$TARFILE" "$OUT" || { rm -rf "$TMP"; die "Falha ao copiar."; }
fi

# Hash de integridade
b "[4/4] Gerando soma de verificacao (.sha256)..."
( cd "$DEST" && sha256sum "$(basename "$OUT")" > "$(basename "$OUT").sha256" ) \
  && g "  $(basename "$OUT").sha256 criado." || y "  (nao consegui gerar sha256)"

# Limpeza do temporario (tar em claro)
rm -rf "$TMP"

echo
g "==============================================================="
g "  Backup concluido:"
g "  $OUT"
[ "$ENCRYPT" = "1" ] && g "  (cifrado — precisa da senha para restaurar)"
g "  Verificar depois:  sha256sum -c \"${OUT}.sha256\""
g "  Restaurar:         ~/Persistent/haveno-backup.sh --restore \"$OUT\""
g "==============================================================="
y "Lembrete: anote tambem a SEED (Account > Wallet seed) em papel/metal,"
y "guardada separada deste arquivo. Seed != backup completo."
qa_log_line "Backup concluido: $OUT"
qa_log_line "REDE: tails_online_tor_esperado=SIM"
y "Apos anotar a seed no papel, rode: qa-confirm-seed-papel.sh (ou adicione CONFIRMACAO no log manualmente)."
qa_log_finish 0
