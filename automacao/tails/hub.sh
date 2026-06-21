#!/bin/bash
###############################################################################
# hub.sh — ÚNICO ponto de entrada do aluno
#
# ── SUBCOMANDOS ──────────────────────────────────────────────────────────────
#
#   hub.sh install      1ª vez: preflight → download .deb → verifica PGP
#                               → instala → abre Haveno
#
#   hub.sh boot         Cada sessão: instala deps → aplica filtro Tor
#                               → abre Haveno  (SEM re-download)
#
#   hub.sh backup       Backup cifrado da carteira (Data/)
#                               → rode ANTES do 1º depósito e após cada trade
#
#   hub.sh update       Novo release: backup automático → baixa novo .deb
#                               → verifica PGP → reinstala → abre
#
#   hub.sh feather      Instala Feather Wallet (passo 5)
#                               → baixa AppImage, verifica PGP, abre
#
#   hub.sh qa <cmd>     Confirmações humanas e relatórios QA:
#
#     validate          Valida scripts (sintaxe, PGP, YAML) — tela + log
#     confirm-seed      Seed anotada em papel (passo 4) — só booleanos no log
#     confirm-step9     Ritual 2 cópias físicas separadas (passo 9)
#     confirm-step12    Pós cold-signing (passo 12 — Trilha A ou B)
#     export-logs       Exporta qa-logs/ para pendrive USB
#     finalize          validate + confirm-seed (1ª instalação, 1 vez)
#
# ── FLAGS ────────────────────────────────────────────────────────────────────
#
#   --qa-log            (todos os subcomandos)
#                       Grava log completo em ~/Persistent/qa-logs/
#                       → USE SEMPRE que algo der errado — envie o .txt ao suporte
#                       Exemplo: hub.sh install --qa-log
#
#   --one-password      (todos os subcomandos)
#                       Digita a senha de administrador apenas 1 vez
#                       → USE se cansou de redigitar a senha em cada etapa
#                       Exemplo: hub.sh install --one-password --qa-log
#
#   --install-only      (somente: install)
#                       Pula o download — usa o .deb já em Install/
#                       → USE quando o download já completou mas o install falhou
#                       → USE quando salvou o .deb de outra fonte e já verificou
#                       Exemplo: hub.sh install --install-only --qa-log
#
#   --skip-backup       (somente: install)
#                       Pula o backup automático ao final da 1ª instalação
#                       → USE raramente; por padrão o backup é recomendado
#                       Exemplo: hub.sh install --skip-backup
#
# ── EXEMPLOS COMUNS ──────────────────────────────────────────────────────────
#
#   hub.sh install --qa-log                   # 1ª vez + log (recomendado)
#   hub.sh install --one-password --qa-log    # 1ª vez com 1 senha + log
#   hub.sh install --install-only --qa-log    # retoma após download OK
#   hub.sh boot --qa-log                      # sessão + log para diagnóstico
#   hub.sh backup                             # backup rápido antes do trade
#   hub.sh update --qa-log                    # novo release + log
#   hub.sh feather                            # instalar Feather (passo 5)
#   hub.sh qa finalize                        # pós 1ª instalação (validate + seed)
#   hub.sh qa confirm-step9                   # passo 9 — ritual 2 cópias físicas
#   hub.sh qa confirm-step12                  # passo 12 — pós cold-signing
#   hub.sh qa export-logs --usb               # exportar logs para pendrive
#
# ── SE ALGO DER ERRADO ───────────────────────────────────────────────────────
#
#   steps/run-all.sh    Fallback Haveno — roda os 8 passos um a um e para
#                       no 1º FAIL com a causa exata. Haveno-only (não Feather).
#                       Leia steps/README.md antes de rodar.
#
###############################################################################

set -uo pipefail

HUB_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${HUB_DIR}/lib/common.sh"

usage() {
  b "Uso: hub.sh <subcomando> [flags]"
  b ""
  b "Subcomandos:"
  b "  install       1ª vez — preflight, download, instala, abre Haveno"
  b "  boot          cada sessão — abre Haveno (sem re-download)"
  b "  backup        backup cifrado da carteira (antes do 1º depósito)"
  b "  update        atualiza para novo release (faz backup antes)"
  b "  feather       instala e verifica Feather Wallet"
  b "  qa <cmd>      relatórios QA e confirmações humanas:"
  b "    validate      valida scripts (sintaxe, PGP, YAML) — tela + log"
  b "    confirm-seed  confirma seed anotada em papel (passo 4)"
  b "    confirm-step9 ritual 2 cópias físicas separadas (passo 9)"
  b "    confirm-step12 pós cold-signing (passo 12)"
  b "    export-logs   exporta qa-logs/ para pendrive USB"
  b "    finalize      validate + confirm-seed (1ª instalação, 1 vez)"
  b ""
  b "Flags globais (qualquer subcomando):"
  b "  --qa-log        grava log em ~/Persistent/qa-logs/"
  b "  --one-password  senha admin só uma vez"
  b ""
  b "Flags específicas de install:"
  b "  --install-only  pula download — usa .deb já em Install/"
  b "  --skip-backup   pula backup automático ao final"
  b ""
  b "Quando algo falhar: steps/run-all.sh (fallback atômico)"
  exit 1
}

# ---- QA Finalize (1ª instalação: validate + confirm-seed) -------------------
_hub_qa_finalize() {
  [ -t 0 ] || { y "Modo não interativo — qa finalize requer terminal. Rode: hub.sh qa finalize"; return 0; }
  local qa_logs="${PERSIST}/qa-logs"
  if ! grep -ql 'RESULTADO: PASS' "${qa_logs}/04-seed-papel-"*.txt 2>/dev/null; then
    b "=== QA Finalize — primeira instalação ==="
    b "[1/2] Validando integridade dos scripts..."
    bash "${HUB_DIR}/system/qa-validate.sh" --qa-log
    echo
    b "[2/2] Confirmando seed anotada em papel..."
    bash "${HUB_DIR}/qa/confirm-seed.sh"
    echo
    g "QA Finalize concluído. Logs em ~/Persistent/qa-logs/"
  else
    y "QA já finalizado nesta persistência (04-seed-papel-*.txt existe)."
    y "Para revalidar scripts: hub.sh qa validate"
  fi
}

CMD="${1:-}"
[ -n "$CMD" ] || usage
shift

# ---- Parsear flags globais ---------------------------------------------------
EXTRA_ARGS=()
for arg in "$@"; do
  case "$arg" in
    --qa-log)       export HAVENO_QA_LOG=1 ;;
    --one-password) export HAVENO_ONE_PASSWORD=1 ;;
    *)              EXTRA_ARGS+=("$arg") ;;
  esac
done
export HAVENO_QA_LOG="${HAVENO_QA_LOG:-0}"

QA_ARGS=()
[ "${HAVENO_QA_LOG}" = "1" ] && QA_ARGS=(--qa-log)

# ---- Paths diretos (estrutura conhecida — sem resolve() dinâmico) -----------
PREFLIGHT="${HUB_DIR}/system/preflight.sh"
HAVENO_INSTALL="${HUB_DIR}/haveno/install.sh"
HAVENO_BOOT="${HUB_DIR}/haveno/boot.sh"
HAVENO_BACKUP="${HUB_DIR}/haveno/backup.sh"
HAVENO_UPDATE="${HUB_DIR}/haveno/update.sh"
FEATHER_INSTALL="${HUB_DIR}/feather/install.sh"

# ---- Despachar subcomando ---------------------------------------------------
echo
b "================================================================"
b "  hub.sh — Privacy-OS-Hub · $(date -u '+%Y-%m-%d %H:%M UTC')"
b "================================================================"
echo

case "$CMD" in

  install)
    sudo_one_password_start
    bash "$PREFLIGHT" "${QA_ARGS[@]}"
    AUTO_ARGS=("${QA_ARGS[@]}")
    for a in "${EXTRA_ARGS[@]:-}"; do
      [ "$a" = "--install-only" ] && AUTO_ARGS+=(--install-only)
    done
    if haveno_needs_install_only && [[ ! " ${EXTRA_ARGS[*]:-} " =~ " --install-only " ]]; then
      y "  Detectado: .deb em Install/ mas Haveno não instalado — usando --install-only."
      AUTO_ARGS+=(--install-only)
    fi
    bash "$HAVENO_INSTALL" "${AUTO_ARGS[@]}"
    SKIP_BACKUP=0
    [[ " ${EXTRA_ARGS[*]:-} " =~ " --skip-backup " ]] && SKIP_BACKUP=1
    if [ "$SKIP_BACKUP" = "0" ] && haveno_pkg_installed_ok; then
      echo
      y "Recomendado: backup cifrado antes do 1º depósito."
      if [ -t 0 ]; then
        printf "Rodar backup agora? (S/n): "
        read -r ans
        case "${ans:-S}" in n|N)
          y "Pulando backup. Rode depois: hub.sh backup" ;;
        *)
          bash "$HAVENO_BACKUP" "${QA_ARGS[@]}" ;;
        esac
      else
        y "Modo não interativo — rode: hub.sh backup"
      fi
    fi
    # ---- QA Finalize: apenas quando seed não tem PASS confirmado ----------------
    if ! grep -ql 'RESULTADO: PASS' "${PERSIST}/qa-logs/04-seed-papel-"*.txt 2>/dev/null; then
      echo
      y "Seed ainda não confirmada em papel — relatório QA incompleto."
      if [ -t 0 ]; then
        printf "Finalizar QA agora (valida scripts + confirma seed)? (S/n): "
        read -r _qa_ans
        case "${_qa_ans:-S}" in
          n|N) y "Rode depois: hub.sh qa finalize" ;;
          *) _hub_qa_finalize ;;
        esac
      else
        y "Modo não interativo — rode: hub.sh qa finalize"
      fi
    fi
    echo
    g "install concluído. Próxima sessão: hub.sh boot"
    ;;

  boot)
    sudo_one_password_start
    bash "$PREFLIGHT" "${QA_ARGS[@]}"
    bash "$HAVENO_BOOT" --watch 8 "${QA_ARGS[@]}"
    echo
    g "boot concluído. Confirme o VERDE na janela do Haveno."
    ;;

  backup)
    bash "$HAVENO_BACKUP" "${QA_ARGS[@]}" "${EXTRA_ARGS[@]:-}"
    ;;

  update)
    sudo_one_password_start
    bash "$HAVENO_UPDATE" "${QA_ARGS[@]}" "${EXTRA_ARGS[@]:-}"
    echo
    g "update concluído. Confirme o VERDE na janela do Haveno."
    ;;

  feather)
    bash "$FEATHER_INSTALL" "${QA_ARGS[@]}" "${EXTRA_ARGS[@]:-}"
    ;;

  qa)
    QA_SUBCMD="${EXTRA_ARGS[0]:-}"
    case "$QA_SUBCMD" in
      validate)
        # qa validate sempre grava log — é o artefato de evidência que justifica o subcomando
        export HAVENO_QA_LOG=1
        bash "${HUB_DIR}/system/qa-validate.sh" --qa-log
        ;;
      confirm-seed)   bash "${HUB_DIR}/qa/confirm-seed.sh" ;;
      confirm-step9)  bash "${HUB_DIR}/qa/confirm-step9.sh" ;;
      confirm-step12) bash "${HUB_DIR}/qa/confirm-step12.sh" ;;
      export-logs)    bash "${HUB_DIR}/qa/export-logs.sh" "${EXTRA_ARGS[@]:1}" ;;
      finalize)       _hub_qa_finalize ;;
      *)
        r "hub.sh qa: subcomando desconhecido."
        b "Use: validate | confirm-seed | confirm-step9 | confirm-step12 | export-logs | finalize"
        exit 1
        ;;
    esac
    ;;

  help|--help|-h)
    usage
    ;;

  *)
    r "Subcomando desconhecido: $CMD"
    usage
    ;;
esac
