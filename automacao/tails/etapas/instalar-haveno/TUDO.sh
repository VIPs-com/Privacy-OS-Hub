#!/bin/bash
###############################################################################
# TUDO.sh — Roda as etapas 01 -> 08 em sequencia, parando no primeiro FAIL.
#
# REGRA DA CASA: este orquestrador so existe porque cada etapa ja roda (e ja
# foi validada) SOZINHA. Se algo falhar, rode a etapa que falhou direto:
#   ./06-deps-apt.sh        (exemplo)
# corrija, e so entao rode ./TUDO.sh de novo (as etapas ja feitas pulam
# sozinhas — todas sao re-rodaveis sem estragar nada).
#
# A etapa 03 (resgate de /tmp) NAO entra na sequencia: e ferramenta de socorro.
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
g(){ echo -e "\033[1;32m$*\033[0m"; }; r(){ echo -e "\033[0;31m$*\033[0m"; }
b(){ echo -e "\033[1;34m$*\033[0m"; }

ETAPAS=(
  01-pastas.sh
  02-baixar-deb.sh
  04-importar-chave.sh
  05-verificar-assinatura.sh
  06-deps-apt.sh
  07-instalar-deb.sh
  08-abrir-haveno.sh
)

for s in "${ETAPAS[@]}"; do
  echo
  b "==============================================="
  b "  ETAPA: $s"
  b "==============================================="
  if ! bash "${DIR}/${s}"; then
    r ""
    r "PAROU em: $s"
    r "Leia o FAIL acima (ele diz o que fazer), corrija e rode:"
    r "  ./${s}"
    r "Quando der PASS, rode ./TUDO.sh de novo para continuar dali."
    exit 1
  fi
done

echo
g "==============================================="
g "  Sequencia completa. Confirme o VERDE na tela."
g "==============================================="
