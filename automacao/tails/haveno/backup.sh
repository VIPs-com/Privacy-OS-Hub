#!/bin/bash
# =================================================================
# INTERNO — chamado por hub.sh. Não execute diretamente.
# Comando do aluno: hub.sh backup
# =================================================================
###############################################################################
# haveno/backup.sh  —  Backup/restauracao da carteira Haveno no Tails
#
# O QUE FAZ:
#   - Compacta ~/Persistent/haveno/Data/ (carteira, historico, contas)
#   - Cifra com GPG (senha) — backups do Haveno NAO sao cifrados por padrao
#   - Salva na persistencia (~/Persistent/Backups) ou num USB montado
#   - Verifica a integridade do arquivo e gera um .sha256
#   - Pode RESTAURAR um backup (com copia de seguranca do estado atual)
#   - --full: hub stack + ~/Persistent/my-locker/ (docs pessoais do aluno)
#   - Tar/grava em DISCO no destino (pipe gpg) — nao usa /tmp/RAM
#
# PRIVACIDADE/SEGURANCA:
#   - Nao usa rede. Mantenha o arquivo .gpg offline.
#   - A SEED nao entra aqui: anote-a pela interface (Account > Wallet seed).
#   - FECHE o Haveno antes de rodar (evita copiar carteira em uso).
#   - my-locker/: KeePass, comprovantes — NUNCA seed em arquivo.
#
# USO:
#   hub.sh backup
#   hub.sh backup --usb
#   hub.sh backup --full --usb
#   hub.sh backup --restore /caminho/haveno-data-AAAA....tar.gz.gpg
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# ----------------------------- Caminhos --------------------------------------
PERSIST="/home/amnesia/Persistent"
DATA_DIR="${PERSIST}/haveno/Data"
MY_LOCKER_DIR="${PERSIST}/my-locker"
DEFAULT_DEST="${PERSIST}/Backups"
MEDIA_DIR="/media/amnesia"

# Pastas incluidas em --full (hub + cofre pessoal do aluno)
FULL_BACKUP_REL_DIRS=(
  haveno/Data
  feather/wallets
  dotfiles
  my-locker
)

# ----------------------------- Cores -----------------------------------------
b(){ echo -e "\033[1;34m$*\033[0m"; }
g(){ echo -e "\033[1;32m$*\033[0m"; }
y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
die(){ r "ERRO: $*"; [ -n "${QA_LOG_FILE:-}" ] && qa_log_finish 1 2>/dev/null || true; exit 1; }

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
    printf "  Continuar restauracao sem verificacao sha256? (s/N): "
    read -r _sha_ans
    case "${_sha_ans:-N}" in s|S|sim|SIM) ;; *) rm -rf "$TMP"; die "Cancelado."; esac
  fi
  g "  Arquivo OK."

  STAMP_SAFE="$(date +%Y%m%d-%H%M%S)"
  if [ "$_IS_FULL" = "1" ]; then
    y "  Backup COMPLETO: haveno/Data + feather/wallets + dotfiles + my-locker (se no arquivo)"
    printf "Confirmar restauracao completa (estado atual salvo como .bak)? (s/N): "; read -r ans
    case "${ans:-N}" in s|S|sim|SIM) ;; *) rm -rf "$TMP"; die "Cancelado."; esac
    for _d in "${FULL_BACKUP_REL_DIRS[@]}"; do
      [ -d "${PERSIST}/${_d}" ] && mv "${PERSIST}/${_d}" "${PERSIST}/${_d}.bak-${STAMP_SAFE}"
    done
    tar -xzf "$TARFILE" -C "$PERSIST" \
      || { rm -rf "$TMP"
           r "Seus dados estao intactos em *.bak-${STAMP_SAFE} — nenhum dado perdido."
           r "Para reverter: mv <pasta>.bak-${STAMP_SAFE} <pasta>  (ex: mv haveno/Data.bak-... haveno/Data)"
           die "Falha ao extrair."; }
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
_FULL_DIRS=()
if [ "$FULL_BACKUP" = "1" ]; then
  BASE="tails-persist-full-${STAMP}"
  for _rel in "${FULL_BACKUP_REL_DIRS[@]}"; do
    [ -d "${PERSIST}/${_rel}" ] && _FULL_DIRS+=("$_rel")
  done
  [ "${#_FULL_DIRS[@]}" -gt 0 ] || die "Nenhuma pasta encontrada para backup completo (Data/, my-locker/, etc.)."
else
  BASE="haveno-data-${STAMP}"
fi

# Tamanho estimado + espaco livre no DESTINO (disco/USB — nao RAM)
_DATA_PATHS=()
if [ "$FULL_BACKUP" = "1" ]; then
  for _rel in "${_FULL_DIRS[@]}"; do
    _DATA_PATHS+=("${PERSIST}/${_rel}")
  done
else
  _DATA_PATHS+=("$DATA_DIR")
fi
DATA_MiB="$(du -sm "${_DATA_PATHS[@]}" 2>/dev/null | awk '{s+=$1} END{print s+0}')"
DEST_MiB="$(df -m "$DEST" 2>/dev/null | awk 'NR==2{print $4}')"
DEST_MARGIN_MiB=64
[ "${DEST_MiB:-0}" -gt "$((${DATA_MiB:-0} + DEST_MARGIN_MiB))" ] \
  || die "Espaco insuficiente em ${DEST} (dados ~${DATA_MiB:-?}MiB, livre ${DEST_MiB:-?}MiB). Use pendrive maior ou reduza ~/Persistent/my-locker/."

if [ "$ENCRYPT" = "1" ]; then
  OUT="${DEST}/${BASE}.tar.gz.gpg"
else
  OUT="${DEST}/${BASE}.tar.gz"
fi

if [ "$ENCRYPT" = "1" ]; then
  b "[1/3] Compactando e cifrando em disco (${OUT})..."
  y "  (tar | gpg direto no destino — nao usa /tmp/RAM)"
  haveno_read_backup_passphrase _bk_pass
  if [ "$FULL_BACKUP" = "1" ]; then
    tar -czf - -C "$PERSIST" "${_FULL_DIRS[@]}" | \
      gpg --batch --yes -c --cipher-algo AES256 --passphrase-fd 3 -o "$OUT" - 3<<<"$_bk_pass" \
      || { unset _bk_pass; rm -f "$OUT"; die "Falha ao compactar/cifrar."; }
  else
    tar -czf - -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")" | \
      gpg --batch --yes -c --cipher-algo AES256 --passphrase-fd 3 -o "$OUT" - 3<<<"$_bk_pass" \
      || { unset _bk_pass; rm -f "$OUT"; die "Falha ao compactar/cifrar."; }
  fi
  b "[2/3] Verificando integridade do .gpg..."
  gpg --batch --passphrase-fd 3 -d "$OUT" 3<<<"$_bk_pass" | tar -tzf - >/dev/null 2>&1 \
    || { unset _bk_pass; die "Arquivo gerado esta corrompido."; }
  unset _bk_pass
else
  r "AVISO: --no-encrypt grava a carteira SEM cifrar (NAO recomendado)."
  printf "Gravar sem cifrar? Digite sim para confirmar (N): "
  read -r _noenc_ans
  case "${_noenc_ans:-N}" in sim|SIM) ;;
    *) die "Cancelado. Rode hub.sh backup sem --no-encrypt (recomendado)." ;;
  esac
  b "[1/3] Compactando em ${OUT} (disco direto)..."
  if [ "$FULL_BACKUP" = "1" ]; then
    tar -czf "$OUT" -C "$PERSIST" "${_FULL_DIRS[@]}" || die "Falha ao compactar."
  else
    tar -czf "$OUT" -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")" || die "Falha ao compactar."
  fi
  b "[2/3] Verificando integridade..."
  tar -tzf "$OUT" >/dev/null 2>&1 || die "Arquivo gerado esta corrompido."
fi

SIZE="$(du -h "$OUT" | cut -f1)"
g "  OK (${SIZE})."

# Hash de integridade
b "[3/3] Gerando soma de verificacao (.sha256)..."
( cd "$DEST" && sha256sum "$(basename "$OUT")" > "$(basename "$OUT").sha256" ) \
  && g "  $(basename "$OUT").sha256 criado." || y "  (nao consegui gerar sha256)"

# Imutabilidade (principio 3-2-1-1-0): arquivo somente leitura apos gravar
chmod 444 "$OUT" "${OUT}.sha256" 2>/dev/null || true

echo
g "==============================================================="
g "  Backup concluido:"
g "  $OUT"
[ "$ENCRYPT" = "1" ] && g "  (cifrado — precisa da senha para restaurar)"
g "  Verificar depois:  sha256sum -c \"${OUT}.sha256\""
g "  Restaurar:         hub.sh backup --restore \"$OUT\""
g "==============================================================="
if [ "$FULL_BACKUP" = "1" ]; then
  y "Incluido no --full: ${_FULL_DIRS[*]}"
  y "NAO incluido (de proposito): Backups/ qa-logs/ hub-scripts/"
  y "  Backups/: copie os .gpg para pendrive B manualmente ou use --usb ao gerar."
  y "  qa-logs/: hub.sh qa export-logs --usb | hub-scripts/: sync-hub-scripts.sh"
  y "Estrategia 3-2-1-1-0:"
  y "  [3] 3 copias: Persistent + Pendrive A + Pendrive B"
  y "  [2] 2 midias: USB Tails + pendrives de backup"
  y "  [1] Offsite: Pendrive B guardado fora de casa"
  y "  [1] Imutavel: arquivo .gpg com timestamp + chmod 444 (nao sobrescrito)"
  y "  [0] 0 erros: verifique a cada 3 meses:"
  y "      sha256sum -c \"${OUT}.sha256\""
  y "  Seed em papel e independente — sem ela nenhum .gpg recupera os fundos."
  y "  my-locker/: mantenha enxuto (<500MB) — USB grande != RAM ilimitada na sessao."
else
  y "Lembrete: anote a SEED (Account > Wallet seed) em papel/metal — guardada"
  y "separada deste arquivo. Seed != backup de dados."
  y "Snapshot completo (3-2-1-1-0): hub.sh backup --full --usb"
fi
qa_log_line "Backup concluido: $OUT"
qa_log_line "REDE: tails_online_tor_esperado=SIM"
y "Apos anotar a seed no papel, rode: ~/Persistent/hub-scripts/qa/confirm-seed.sh"
qa_log_finish 0
