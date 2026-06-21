#!/bin/bash
# =================================================================
# INTERNO — chamado por hub.sh. Não execute diretamente.
# Comando do aluno: hub.sh backup
# =================================================================
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
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

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
FULL_BACKUP=0
RESTORE_FILE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --usb) USE_USB=1 ;;
    --dest) shift; DEST="${1:-}" ;;
    --no-encrypt) ENCRYPT=0 ;;
    --full) FULL_BACKUP=1 ;;
    --restore) shift; RESTORE_FILE="${1:-}" ;;
    --qa-log) export HAVENO_QA_LOG=1 ;;
    *) y "Opcao desconhecida: $1 (ignorada)" ;;
  esac
  shift
done

qa_log_tee_begin "04-haveno-backup"

echo
b "==============================================================="
b "  haveno/backup.sh — backup da carteira Haveno (Tails)"
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

  # Detecta tipo pelo nome do arquivo
  _IS_FULL=0
  [[ "$(basename "$RESTORE_FILE")" == tails-persist-full-* ]] && _IS_FULL=1

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
  if [ -f "${RESTORE_FILE}.sha256" ]; then
    b "  Verificando sha256 do backup original..."
    ( cd "$(dirname "$RESTORE_FILE")" && sha256sum -c "$(basename "${RESTORE_FILE}.sha256")" >/dev/null ) \
      && g "  sha256 OK." || { rm -rf "$TMP"; die "sha256 nao confere — backup corrompido ou substituido."; }
  else
    y "  Aviso: .sha256 ausente — integridade verificada apenas via tar."
  fi
  g "  Arquivo OK."

  STAMP_SAFE="$(date +%Y%m%d-%H%M%S)"
  if [ "$_IS_FULL" = "1" ]; then
    y "  Backup COMPLETO: restaura haveno/Data/ + feather/wallets/ + dotfiles/"
    printf "Confirmar restauracao completa (estado atual salvo como .bak)? (s/N): "; read -r ans
    case "${ans:-N}" in s|S|sim|SIM) ;; *) rm -rf "$TMP"; die "Cancelado."; esac
    for _d in haveno/Data feather/wallets dotfiles; do
      [ -d "${PERSIST}/${_d}" ] && mv "${PERSIST}/${_d}" "${PERSIST}/${_d}.bak-${STAMP_SAFE}"
    done
    tar -xzf "$TARFILE" -C "$PERSIST" || { rm -rf "$TMP"; die "Falha ao extrair."; }
    rm -rf "$TMP"
    g "Restauracao completa concluida em: ${PERSIST}/"
    y "Rode: hub.sh boot  (Haveno) · abra o Feather para confirmar carteiras."
    qa_log_line "Restauracao completa concluida: ${PERSIST}/"
  else
    if [ -d "$DATA_DIR" ]; then
      SAFETY="${PERSIST}/haveno/Data.bak-${STAMP_SAFE}"
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
  fi
  qa_log_finish 0
  exit 0
fi

###############################################################################
# MODO BACKUP
###############################################################################
if [ "$FULL_BACKUP" = "0" ]; then
  [ -d "$DATA_DIR" ] || die "Pasta de dados nao encontrada ($DATA_DIR). Instale/abra o Haveno antes."
fi

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
    case "${n:-}" in
      ''|*[!0-9]*|0) die "Escolha invalida (use 1-${#VOLS[@]})." ;;
    esac
    [ "$n" -le "${#VOLS[@]}" ] || die "Escolha invalida (use 1-${#VOLS[@]})."
    DEST="${VOLS[$((n-1))]}"
  fi
fi
[ -n "$DEST" ] || DEST="$DEFAULT_DEST"

mkdir -p "$DEST" || die "Nao consegui criar/usar o destino: $DEST"
[ -w "$DEST" ] || die "Sem permissao de escrita em: $DEST"
g "  Destino: $DEST"

STAMP="$(date +%Y%m%d-%H%M%S)"
if [ "$FULL_BACKUP" = "1" ]; then
  BASE="tails-persist-full-${STAMP}"
  _FULL_DIRS=()
  [ -d "${PERSIST}/haveno/Data" ]     && _FULL_DIRS+=(haveno/Data)
  [ -d "${PERSIST}/feather/wallets" ] && _FULL_DIRS+=(feather/wallets)
  [ -d "${PERSIST}/dotfiles" ]        && _FULL_DIRS+=(dotfiles)
  [ "${#_FULL_DIRS[@]}" -gt 0 ] || die "Nenhuma pasta encontrada para backup completo (Data/, wallets/, dotfiles/)."
else
  BASE="haveno-data-${STAMP}"
fi
TMP="$(mktemp -d)"
TARFILE="${TMP}/${BASE}.tar.gz"

# Verifica RAM disponivel antes de compactar em /tmp (tmpfs em RAM no Tails)
if [ "$FULL_BACKUP" = "1" ]; then
  DATA_MiB="$(du -sm "${PERSIST}/haveno/Data" "${PERSIST}/feather/wallets" "${PERSIST}/dotfiles" 2>/dev/null \
    | awk '{s+=$1} END{print s+0}')"
else
  DATA_MiB="$(du -sm "$DATA_DIR" 2>/dev/null | cut -f1)"
fi
TMP_MiB="$(df -m /tmp 2>/dev/null | awk 'NR==2{print $4}')"
[ "${TMP_MiB:-0}" -gt "$((${DATA_MiB:-0} * 2))" ] \
  || die "RAM insuficiente para backup em /tmp (${DATA_MiB:-?}MB de dados, ${TMP_MiB:-?}MB livres). Use: hub.sh backup --full --dest /media/amnesia/SEU_USB"

if [ "$FULL_BACKUP" = "1" ]; then
  b "[1/4] Backup completo: ${_FULL_DIRS[*]}..."
  tar -czf "$TARFILE" -C "$PERSIST" "${_FULL_DIRS[@]}" \
    || { rm -rf "$TMP"; die "Falha ao compactar."; }
else
  b "[1/4] Compactando ${DATA_DIR}..."
  tar -czf "$TARFILE" -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")" \
    || { rm -rf "$TMP"; die "Falha ao compactar."; }
fi

# Verificar o tar
b "[2/4] Verificando integridade do arquivo..."
tar -tzf "$TARFILE" >/dev/null 2>&1 || { rm -rf "$TMP"; die "Arquivo gerado esta corrompido."; }
SIZE="$(du -h "$TARFILE" | cut -f1)"
g "  OK (${SIZE})."

# Cifrar
if [ "$ENCRYPT" = "1" ]; then
  b "[3/4] Cifrando com GPG (senha forte — confirme duas vezes)..."
  OUT="${DEST}/${BASE}.tar.gz.gpg"
  haveno_gpg_symmetric_encrypt "$OUT" "$TARFILE" || { rm -rf "$TMP"; die "Falha ao cifrar."; }
else
  y "[3/4] --no-encrypt: salvando SEM cifrar (NAO recomendado)."
  OUT="${DEST}/${BASE}.tar.gz"
  cp "$TARFILE" "$OUT" || { rm -rf "$TMP"; die "Falha ao copiar."; }
fi

# Hash de integridade
b "[4/4] Gerando soma de verificacao (.sha256)..."
( cd "$DEST" && sha256sum "$(basename "$OUT")" > "$(basename "$OUT").sha256" ) \
  && g "  $(basename "$OUT").sha256 criado." || y "  (nao consegui gerar sha256)"

# Imutabilidade (principio 3-2-1-1-0): arquivo somente leitura apos gravar
# Em FAT32 o chmod e silenciosamente ignorado — sem impacto em ext4/btrfs
chmod 444 "$OUT" "${OUT}.sha256" 2>/dev/null || true

# Limpeza do temporario (tar em claro)
rm -rf "$TMP"

echo
g "==============================================================="
g "  Backup concluido:"
g "  $OUT"
[ "$ENCRYPT" = "1" ] && g "  (cifrado — precisa da senha para restaurar)"
g "  Verificar depois:  sha256sum -c \"${OUT}.sha256\""
g "  Restaurar:         hub.sh backup --restore \"$OUT\""
g "==============================================================="
if [ "$FULL_BACKUP" = "1" ]; then
  y "Estrategia 3-2-1-1-0:"
  y "  [3] 3 copias: Persistent + Pendrive A + Pendrive B"
  y "  [2] 2 midias: USB Tails + pendrives de backup"
  y "  [1] Offsite: Pendrive B guardado fora de casa"
  y "  [1] Imutavel: arquivo .gpg com timestamp + chmod 444 (nao sobrescrito)"
  y "  [0] 0 erros: verifique a cada 3 meses:"
  y "      sha256sum -c \"${OUT}.sha256\""
  y "  Seed em papel e independente — sem ela nenhum .gpg recupera os fundos."
else
  y "Lembrete: anote a SEED (Account > Wallet seed) em papel/metal — guardada"
  y "separada deste arquivo. Seed != backup de dados."
  y "Snapshot completo (3-2-1-1-0): hub.sh backup --full --usb"
fi
qa_log_line "Backup concluido: $OUT"
qa_log_line "REDE: tails_online_tor_esperado=SIM"
y "Apos anotar a seed no papel, rode: ~/Persistent/hub-scripts/qa/confirm-seed.sh"
qa_log_finish 0
