#!/bin/bash
###############################################################################
# haveno-auto.sh  —  Automação Haveno no Tails (rede Reto / turma)
#
# O QUE FAZ (depois de você já ter criado a Persistência + Dotfiles):
#   1. Confere que está no Tails, usuario amnesia, com senha admin ativa
#   2. Confere persistencia e Dotfiles
#   3. Garante fuso horario UTC (privacidade: nao revela localizacao)
#   4. Espera o Tor conectar (IsTor + cross-check 'Bootstrapped 100%' no boot atual)
#   5. (Opcional) Ajusta o relogio pela hora obtida ATRAVES do Tor (sem vazar local)
#   6. Baixa e roda o haveno-install.sh oficial com URL + PGP REAIS da Reto
#   7. Instala/configura via exec.sh (pkexec) e abre o Haveno
#   8. Verifica 'loaded filter: haveno'; se vier 'None', corrige onion-grater sozinho
#   9. Monitora ate o filtro ficar OK e orienta sobre o indicador VERDE
#
# NAO FAZ: nao negocia, nao mexe na carteira, nao toca em fundos.
# SEGURANCA: exploit de 20/05/2026 CORRIGIDO na 1.6.0-reto (24/05/2026, fix #2315).
#            Use 1.6.0-reto+; antes de tradear confirme a retomada nos canais oficiais.
#
# USO:
#   1. Salve este arquivo em ~/Persistent (armazenamento persistente)
#   2. No Terminal:
#        chmod +x ~/Persistent/haveno-auto.sh
#        ~/Persistent/haveno-auto.sh
#   Opcoes:
#        --no-clock   nao tenta ajustar o relogio pelo Tor
#        --watch N    monitora o log por N minutos (padrao 8)
#        --update     forca reinstalar/atualizar o .deb (mesmo se ja instalado)
#
# ATUALIZAR PARA VERSAO NOVA:
#   1. Edite HAVENO_DEB_URL e HAVENO_PGP_FPR abaixo com os valores do NOVO release
#   2. Rode:  ~/Persistent/haveno-auto.sh --update
#   (Os dados em ~/Persistent/haveno/Data/ sao preservados.)
###############################################################################

set -uo pipefail

# ----------------------------- VALORES REAIS (Reto 1.6.0-reto) ---------------
HAVENO_DEB_URL="https://github.com/retoaccess1/haveno-reto/releases/download/1.6.0-reto/haveno-v1.6.0-linux-x86_64-installer.deb"
HAVENO_PGP_FPR="DAA24D878B8D36C90120A897CA02DAC12DAE2D0F"
INSTALL_SCRIPT_URL="https://github.com/haveno-dex/haveno/raw/master/scripts/install_tails/haveno-install.sh"

# ----------------------------- Caminhos Tails --------------------------------
PERSIST="/home/amnesia/Persistent"
HAVENO_DIR="${PERSIST}/haveno"
UTILS_DIR="${HAVENO_DIR}/App/utils"
DOTFILES_DIR="/live/persistence/TailsData_unlocked/dotfiles"
ONION_GRATER_DST="/etc/onion-grater.d/haveno.yml"
TOR_COOKIE="/var/run/tor/control.authcookie"

# ----------------------------- Opcoes ----------------------------------------
DO_CLOCK=1
DO_UPDATE=0
WATCH_MIN=8
while [ $# -gt 0 ]; do
  case "$1" in
    --no-clock) DO_CLOCK=0 ;;
    --update)   DO_UPDATE=1 ;;
    --watch)    shift; [[ "${1:-}" =~ ^[0-9]+$ ]] && WATCH_MIN="$1" ;;  # --watch N (sem N: mantem padrao)
    *)          [[ "$1" =~ ^[0-9]+$ ]] && WATCH_MIN="$1" ;;
  esac
  shift
done

# ----------------------------- Cores -----------------------------------------
b(){ echo -e "\033[1;34m$*\033[0m"; }       # azul
g(){ echo -e "\033[1;32m$*\033[0m"; }       # verde
y(){ echo -e "\033[1;33m$*\033[0m"; }       # amarelo
r(){ echo -e "\033[0;31m$*\033[0m"; }       # vermelho
die(){ r "ERRO: $*"; echo "Abortando. Veja o Capitulo 7 (FAQ) do livro Curso-Tails-OS-Expert.md"; exit 1; }

echo
b "==============================================================="
b "  haveno-auto.sh — Haveno no Tails (Reto 1.6.0-reto)  "
b "  Exploit 20/05 CORRIGIDO na 1.6.0-reto · tradear com cautela"
b "==============================================================="
echo

# ----------------------------- 1. Ambiente Tails -----------------------------
b "[1/9] Conferindo ambiente Tails..."
[ -f /etc/os-release ] && grep -qi "tails" /etc/os-release || y "  Aviso: nao parece Tails (siga so se souber o que faz)."
[ "$(whoami)" = "amnesia" ] || y "  Aviso: usuario nao e 'amnesia' (esperado no Tails)."

# senha admin ativa? (sudo configurado)
if ! sudo -v 2>/dev/null; then
  die "Senha de administrador nao esta ativa. Reinicie e use '+ Mais opcoes' na tela de boas-vindas."
fi
g "  Admin OK."

# ----------------------------- 2. Persistencia + Dotfiles --------------------
b "[2/9] Conferindo Persistencia e Dotfiles..."
[ -d "$PERSIST" ] || die "Persistencia nao encontrada ($PERSIST). Crie o Armazenamento Persistente."
if [ ! -d "$DOTFILES_DIR" ]; then
  die "Dotfiles nao ativado. Abra 'Armazenamento persistente' e marque Dotfiles, depois reinicie."
fi
g "  Persistencia + Dotfiles OK."

# ----------------------------- 3. Fuso UTC (privacidade) ---------------------
b "[3/9] Garantindo fuso horario UTC (sem revelar localizacao)..."
sudo timedatectl set-timezone UTC 2>/dev/null || true
TZNOW="$(timedatectl show -p Timezone --value 2>/dev/null || echo '?')"
g "  Fuso: $TZNOW (UTC = padrao privado do Tails)."

# ----------------------------- 4. Esperar Tor --------------------------------
b "[4/9] Esperando o Tor conectar (ate 3 min)..."
TOR_MAX=180        # segundos
tor_ok=0
elapsed=0
while [ "$elapsed" -lt "$TOR_MAX" ]; do
  if curl -s --socks5-hostname 127.0.0.1:9050 --max-time 12 https://check.torproject.org/api/ip 2>/dev/null | grep -q '"IsTor":true'; then
    tor_ok=1; break
  fi
  printf "  ... aguardando Tor (%ss/%ss)\r" "$elapsed" "$TOR_MAX"
  sleep 10; elapsed=$((elapsed + 10))
done
echo
[ "$tor_ok" = "1" ] || die "Tor nao conectou em ${TOR_MAX}s. Abra o assistente 'Conexao a rede Tor' e tente de novo."
g "  Tor conectado (IsTor: true)."

# Cross-check (herdado do script v2): confirma bootstrap 100% no boot ATUAL.
if sudo journalctl -u tor@default -b --no-pager 2>/dev/null | grep -q "Bootstrapped 100%"; then
  g "  Tor bootstrap 100% confirmado no log."
else
  y "  Sem 'Bootstrapped 100%' no log ainda — IsTor ja respondeu true, seguindo."
fi

# ----------------------------- 5. Relogio via Tor ----------------------------
if [ "$DO_CLOCK" = "1" ]; then
  b "[5/9] Ajustando relogio pela hora obtida ATRAVES do Tor (sem vazar local)..."
  y "  (Opcional/fallback: o Tails ja sincroniza o tempo via Tor. Use --no-clock para pular.)"
  HTTPDATE="$(curl -sI --socks5-hostname 127.0.0.1:9050 --max-time 30 https://check.torproject.org/ 2>/dev/null \
             | grep -i '^date:' | sed -E 's/^[Dd]ate:[[:space:]]*//' | tr -d '\r')"
  if [ -n "${HTTPDATE:-}" ]; then
    if sudo date -s "$HTTPDATE" >/dev/null 2>&1; then
      g "  Relogio ajustado (UTC): $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    else
      y "  Nao consegui aplicar a hora; o Tor ja corrige sozinho. Seguindo."
    fi
  else
    y "  Sem cabecalho Date pelo Tor; o relogio do Tails ja deve estar OK. Seguindo."
  fi
else
  y "[5/9] Pulando ajuste de relogio (--no-clock)."
fi

# ----------------------------- 6. Instalar Haveno (script oficial) -----------
b "[6/9] Baixando e verificando Haveno (script oficial + PGP da Reto)..."
WORK="$(mktemp -d)"; cd "$WORK" || die "mktemp falhou."

dl_ok=0
if curl -fsSLO "$INSTALL_SCRIPT_URL" 2>/dev/null; then dl_ok=1; fi
if [ "$dl_ok" = "0" ]; then
  y "  Tentando baixar o script via Tor..."
  curl -x socks5h://127.0.0.1:9050 -fsSLO "$INSTALL_SCRIPT_URL" 2>/dev/null && dl_ok=1
fi
[ "$dl_ok" = "1" ] || die "Nao baixei haveno-install.sh (rede/Tor)."

if [ "$DO_UPDATE" = "1" ] || [ ! -d "$UTILS_DIR" ] || [ ! -f "${HAVENO_DIR}/Install/haveno.deb" ]; then
  [ "$DO_UPDATE" = "1" ] && y "  Modo --update: reinstalando/atualizando o .deb (dados preservados)."
  b "  Rodando haveno-install.sh (verifica assinatura PGP)..."
  if ! bash haveno-install.sh "$HAVENO_DEB_URL" "$HAVENO_PGP_FPR"; then
    die "haveno-install.sh falhou (PGP/URL/rede). Confira release atual da Reto."
  fi
  g "  Haveno preparado na persistencia."
else
  g "  Haveno ja estava preparado (pulando download). Use --update para forcar nova versao."
fi

[ -f "${UTILS_DIR}/exec.sh" ] || die "exec.sh nao encontrado em ${UTILS_DIR}."
[ -f "${UTILS_DIR}/install.sh" ] || die "install.sh nao encontrado em ${UTILS_DIR}."
[ -f "${UTILS_DIR}/haveno.yml" ] || die "haveno.yml nao encontrado em ${UTILS_DIR}."

# ----------------------------- 7. Abrir Haveno (exec.sh) ---------------------
b "[7/9] Abrindo o Haveno (pode pedir senha admin via pkexec)..."
chmod +x "${UTILS_DIR}/exec.sh" 2>/dev/null || true
nohup "${UTILS_DIR}/exec.sh" >/tmp/haveno-exec.log 2>&1 &
HAVENO_BG=$!
sleep 8
g "  exec.sh iniciado (log: /tmp/haveno-exec.log)."

# ----------------------------- 8. Verificar/corrigir filtro ------------------
b "[8/9] Verificando perfil onion-grater (loaded filter)..."
sleep 4
# Checagem por boot atual (-b) para nao pegar logs de sessoes antigas.
check_filter(){ sudo journalctl -u onion-grater -b --no-pager 2>/dev/null | tail -40; }

if check_filter | grep -q "loaded filter: haveno"; then
  g "  loaded filter: haveno (OK)."
else
  y "  Filtro ainda nao carregou. Aplicando correcao automatica..."
  sudo cp "${UTILS_DIR}/haveno.yml" "$ONION_GRATER_DST" 2>/dev/null || y "  (cp haveno.yml falhou)"
  [ -e "$TOR_COOKIE" ] && sudo chmod o+r "$TOR_COOKIE" 2>/dev/null || y "  (cookie Tor ainda nao existe)"
  if python3 -c "import yaml; yaml.safe_load(open('${ONION_GRATER_DST}')); print('YAML OK')" 2>/dev/null; then
    g "  YAML OK."
  else
    y "  YAML nao validou — recopiando do oficial."
    sudo cp "${UTILS_DIR}/haveno.yml" "$ONION_GRATER_DST"
  fi
  sudo systemctl restart onion-grater 2>/dev/null || y "  (restart onion-grater falhou)"
  sleep 4
  # Cross-check de erro de sintaxe / perfil (herdado do v2), so como AVISO.
  if check_filter | grep -qiE "bad yaml|invalid|traceback|profile" ; then
    y "  Log do onion-grater menciona possivel erro de YAML/perfil — confira o Capitulo 7 (FAQ) do livro"
  fi
  if check_filter | grep -q "loaded filter: haveno"; then
    g "  Corrigido: loaded filter: haveno."
  else
    y "  Ainda 'None'. Feche o Haveno e rode de novo, ou veja o Capitulo 7 (FAQ) do livro"
  fi
fi

# ----------------------------- 9. Monitorar verde ----------------------------
b "[9/9] Monitorando por ${WATCH_MIN} min (Ctrl+C para sair)..."
y "  O indicador VERDE aparece na JANELA do Haveno (canto inferior)."
y "  Na 1a vez, amarelo por 5-20 min e NORMAL."
deadline=$(( $(date +%s) + WATCH_MIN*60 ))
last=""
while [ "$(date +%s)" -lt "$deadline" ]; do
  line="$(check_filter | grep -E 'loaded filter|AUTHCHALLENGE|bad YAML' | tail -1)"
  if [ -n "$line" ] && [ "$line" != "$last" ]; then echo "  log> $line"; last="$line"; fi
  if ! kill -0 "$HAVENO_BG" 2>/dev/null && ! pgrep -f "/opt/haveno/bin/Haveno" >/dev/null 2>&1; then
    y "  Processo Haveno encerrou. Reabra por: Aplicacoes -> Outros -> Haveno"
    break
  fi
  sleep 15
done

echo
g "==============================================================="
g "  Concluido o que da para automatizar."
g "  CONFIRME o indicador VERDE na janela do Haveno."
g "  Dados: ${HAVENO_DIR}/Data/"
g "  ANTES DE TRADEAR: confirme a retomada nos canais oficiais da Reto"
g "  e comece com valores pequenos (fix #2315 ja incluso na 1.6.0-reto)."
g "==============================================================="
cd / ; rm -rf "$WORK" 2>/dev/null || true
