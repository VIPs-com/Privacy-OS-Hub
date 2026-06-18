#!/bin/bash
###############################################################################
# 08-abrir-haveno.sh — Configura o filtro Tor (onion-grater) e abre o Haveno.
#
# FAZ:    copia o perfil haveno.yml para o onion-grater, reinicia o servico,
#         e abre o Haveno. Depois e com voce: esperar o indicador VERDE.
# NAO FAZ: instalar (07), tradear (nunca).
# OK SE:  janela do Haveno abrir; VERDE no canto inferior = sucesso.
#         Na 1a vez, AMARELO por 5-20 min e NORMAL (sincronizando via Tor).
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

ST="$(dpkg-query -W -f='${Status}' haveno 2>/dev/null || true)"
[ "$ST" = "install ok installed" ] || fail "haveno nao esta instalado — rode ./07-instalar-deb.sh antes."

# --- Filtro onion-grater (controle do Tor para o Haveno) -----------------------
if [ -f "${UTILS_DIR}/haveno.yml" ]; then
  y "Aplicando perfil onion-grater..."
  sudo cp "${UTILS_DIR}/haveno.yml" "$ONION_GRATER_DST" || fail "Nao copiei haveno.yml (senha admin ativa?)."
  sudo systemctl restart onion-grater || y "Nao reiniciei o onion-grater — pode ja estar ativo."
  _wait_filter=0
  for _i in $(seq 1 30); do
    if sudo journalctl -u onion-grater -b --no-pager 2>/dev/null | tail -20 | grep -q "loaded filter: haveno"; then
      g "loaded filter: haveno (OK)."
      _wait_filter=1
      break
    fi
    sleep 1
  done
  if [ "$_wait_filter" -eq 0 ]; then
    y "Filtro nao confirmado apos 30s — siga; se o Haveno nao conectar, veja Apendice B do canonico."
  fi
else
  y "Sem ${UTILS_DIR}/haveno.yml — o Haveno pode nao conectar ao Tor. (Esse arquivo vem do instalador upstream.)"
fi

# --- Abrir ---------------------------------------------------------------------
if [ -x "${UTILS_DIR}/exec.sh" ] || [ -f "${UTILS_DIR}/exec.sh" ]; then
  chmod +x "${UTILS_DIR}/exec.sh" 2>/dev/null || true
  y "Abrindo o Haveno via exec.sh (log: /tmp/haveno-exec.log)..."
  nohup "${UTILS_DIR}/exec.sh" >/tmp/haveno-exec.log 2>&1 &
elif [ -x /opt/haveno/bin/Haveno ]; then
  y "Abrindo o Haveno (binario /opt/haveno/bin/Haveno)..."
  nohup /opt/haveno/bin/Haveno >/tmp/haveno-exec.log 2>&1 &
else
  fail "Nao achei exec.sh nem /opt/haveno/bin/Haveno. Copie esta tela para a equipe."
fi
sleep 8
pgrep -f -i haveno >/dev/null 2>&1 || y "Processo ainda nao visivel — aguarde a janela; se nao abrir, veja /tmp/haveno-exec.log"

echo
g "Agora e na TELA:"
g "  - janela do Haveno aberta"
g "  - indicador no canto inferior: AMARELO 5-20 min na 1a vez = normal"
g "  - VERDE = processo concluido (tire print para o checklist!)"
y "Se fechar e quiser reabrir: Aplicacoes -> Outros -> Haveno"
pass "Haveno lancado. O gate final (VERDE) e confirmacao humana."
