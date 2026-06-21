#!/bin/bash
###############################################################################
# 08-open-haveno.sh — Configura o filtro Tor (onion-grater) e abre o Haveno.
#
# FAZ:    copia o perfil haveno.yml para o onion-grater, reinicia o serviço,
#         e abre o Haveno. Depois é com você: esperar o indicador VERDE.
# NAO FAZ: instalar (07), tradear (nunca).
# OK SE:  janela do Haveno abrir; VERDE no canto inferior = sucesso.
#         Na 1ª vez, AMARELO por 5-20 min é NORMAL (sincronizando via Tor).
###############################################################################
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; source "${DIR}/_config.sh"
g(){ echo -e "\033[1;32m$*\033[0m"; }; y(){ echo -e "\033[1;33m$*\033[0m"; }
r(){ echo -e "\033[0;31m$*\033[0m"; }
pass(){ g "PASS — $*"; exit 0; }
fail(){ r "FAIL — $*"; exit 1; }

ST="$(dpkg-query -W -f='${Status}' haveno 2>/dev/null || true)"
[ "$ST" = "install ok installed" ] || fail "haveno não está instalado — rode ./07-install-deb.sh antes."

if [ -f "${UTILS_DIR}/haveno.yml" ]; then
  y "Aplicando perfil onion-grater..."
  HUB_ONION_YML="${DIR}/../lib/onion-grater.yml"
  YML_SRC="${UTILS_DIR}/haveno.yml"
  if [ -f "$HUB_ONION_YML" ]; then
    YML_SRC="$HUB_ONION_YML"
    y "  Usando filtro corrigido do hub (com PoW do Haveno 1.6.0)."
  else
    y "  AVISO: lib/onion-grater.yml ausente — usando haveno.yml do upstream (SEM fix PoW)."
    y "  Se o Haveno nao conectar: rode sync-hub-scripts.sh e tente de novo."
  fi
  sudo cp "$YML_SRC" "$ONION_GRATER_DST" || fail "Não copiei o filtro onion-grater (senha admin ativa?)."
  sudo systemctl restart onion-grater || y "Não reiniciei o onion-grater — pode já estar ativo."
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
    y "Filtro não confirmado após 30s — siga; se o Haveno não conectar, veja Apêndice B do canônico."
  fi
else
  y "Sem ${UTILS_DIR}/haveno.yml — o Haveno pode não conectar ao Tor. (Esse arquivo vem do instalador upstream.)"
fi

if [ -x "${UTILS_DIR}/exec.sh" ] || [ -f "${UTILS_DIR}/exec.sh" ]; then
  chmod +x "${UTILS_DIR}/exec.sh" 2>/dev/null || true
  y "Abrindo o Haveno via exec.sh (log: /tmp/haveno-exec.log)..."
  nohup "${UTILS_DIR}/exec.sh" >/tmp/haveno-exec.log 2>&1 &
elif [ -x /opt/haveno/bin/Haveno ]; then
  y "Abrindo o Haveno (binário /opt/haveno/bin/Haveno)..."
  nohup /opt/haveno/bin/Haveno >/tmp/haveno-exec.log 2>&1 &
else
  fail "Não achei exec.sh nem /opt/haveno/bin/Haveno. Copie esta tela para a equipe."
fi
sleep 8
pgrep -f -i haveno >/dev/null 2>&1 || y "Processo ainda não visível — aguarde a janela; se não abrir, veja /tmp/haveno-exec.log"

echo
g "Agora é na TELA:"
g "  - janela do Haveno aberta"
g "  - indicador no canto inferior: AMARELO 5-20 min na 1ª vez = normal"
g "  - VERDE = processo concluído (tire print para o checklist!)"
y "Se fechar e quiser reabrir: Aplicações → Outros → Haveno"
pass "Haveno lançado. O gate final (VERDE) é confirmação humana."
