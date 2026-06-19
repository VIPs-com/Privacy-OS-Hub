#!/bin/bash
###############################################################################
# run-all.sh — Roda os passos 01 → 08 em sequência, parando no primeiro FAIL.
#
# USE ESTE SCRIPT SOMENTE SE hub.sh install falhou.
# Cada passo faz UMA coisa e para com PASS ou FAIL claro.
# Se um passo falhar: leia o FAIL, corrija, rode o passo sozinho:
#   ./06-check-deps.sh        (exemplo)
# Depois rode ./run-all.sh de novo — os passos já feitos pulam sozinhos.
#
# O passo 03 (rescue-tmp) NÃO entra na sequência: é ferramenta de socorro.
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
g(){ echo -e "\033[1;32m$*\033[0m"; }; r(){ echo -e "\033[0;31m$*\033[0m"; }
b(){ echo -e "\033[1;34m$*\033[0m"; }

STEPS=(
  01-setup-dirs.sh
  02-download-deb.sh
  04-import-key.sh
  05-verify-sig.sh
  06-check-deps.sh
  07-install-deb.sh
  08-open-haveno.sh
)

for s in "${STEPS[@]}"; do
  echo
  b "==============================================="
  b "  PASSO: $s"
  b "==============================================="
  if ! bash "${DIR}/${s}"; then
    r ""
    r "PAROU em: $s"
    r "Leia o FAIL acima (ele diz o que fazer), corrija e rode:"
    r "  ./${s}"
    r "Quando der PASS, rode ./run-all.sh de novo para continuar dali."
    exit 1
  fi
done

echo
g "==============================================="
g "  Sequência completa. Confirme o VERDE na tela."
g "==============================================="
