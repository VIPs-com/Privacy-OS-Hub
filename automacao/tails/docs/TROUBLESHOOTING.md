# Troubleshooting — hub.sh e steps/

> **Para o suporte:** use este documento para orientar alunos quando `hub.sh` falha.  
> **Para o aluno:** use este documento diretamente quando `hub.sh` falha — sem precisar do suporte. Siga a seção do seu erro.

---

## 1. Mapa rápido — hub.sh travou, qual step rodar?

| hub.sh parou em... | Mensagem típica | Step a rodar | O que o FAIL indica |
|---|---|---|---|
| Baixando a assinatura | `Failed to download Haveno signature` | `steps/02-download-deb.sh` | URL do .sig desatualizada ou circuito Tor instável (ver erro 7) |
| Baixando o .deb | `[download] NNB` ou `Failed to download Haveno binary` | `steps/02-download-deb.sh` | Rede Tor instável ou URL do release (hub tenta curl automaticamente — ver erro 2) |
| Verificando assinatura | `Assinatura invalida` ou `NO_PUBKEY` | `steps/05-verify-sig.sh` | .sig corrompida, chave não importada ou fingerprint errado |
| Instalando dependências | `NAO EXISTE` em vermelho | `steps/06-check-deps.sh` | Libs Ubuntu-only ausentes no Tails/Debian (ver erro 1 abaixo) |
| Instalando o .deb | `dpkg -i falhou` | `steps/07-install-deb.sh --force-depends` | Dependências ausentes no Tails |
| Abrindo o Haveno | Janela não abre ou fecha sozinha | `steps/08-open-haveno.sh` | onion-grater ou cookie do Tor (ver erro 3 abaixo) |

**Como rodar um step:**
```bash
cd ~/Persistent/hub-scripts/steps
./NUMERO-nome-do-step.sh
```

Se o step der PASS, rode o próximo. Se der FAIL, anote a tela e mande para o suporte com `--qa-log`:
```bash
hub.sh install --qa-log
# O log fica em: ~/Persistent/qa-logs/
```

---

## 2. Erros conhecidos — diagnóstico e solução

### Erro 1 — "12 dependências indisponíveis" (DIV-20260610-02)

**Sintoma:**
```
[NAO EXISTE] libavcodec60
[NAO EXISTE] libavformat60
[NAO EXISTE] libavutil58
... (12 no total)
FAIL — 12 dependencia(s) indisponiveis.
```

**Causa:** O `.deb` 1.6.0-reto foi empacotado com nomes de bibliotecas do Ubuntu. O Tails usa Debian — os nomes e versões são diferentes. Problema conhecido do upstream (DIV-20260610-02).

**Solução:**
```bash
cd ~/Persistent/hub-scripts/steps
./07-install-deb.sh --force-depends
./08-open-haveno.sh
```

**Por que funciona:** O Haveno embute o próprio runtime Java. As 12 bibliotecas faltando são de mídia (FFmpeg/libav) que o app não usa para funcionar. Validado em campo jun/2026.

**Se o Haveno não abrir após `--force-depends`:**
```bash
sudo dpkg -r haveno
```
Em seguida, reporte à equipe com o log de `/tmp/haveno-exec.log`.

---

### Erro 2 — Upstream falha no download do .deb (`Failed to download Haveno binary`)

**Sintoma:**
```
[download] 119B — baixando (retomavel na persistencia)...
[download] 119B — baixando (retomavel na persistencia)...
Failed to download Haveno binary.
ERRO: haveno-install.sh falhou (PGP/URL/rede).
```

> **Por que "119B" no monitor?** O monitoramento via versões antigas incluía a assinatura `.sig` (119 B) na contagem do `.deb` — aparecia "119B" estático enquanto o `.deb` real não havia iniciado. Corrigido: versões recentes do hub mostram "conectando ao Tor" em vez de "119B" quando nenhum `.deb` foi baixado ainda.

**Causa:** O `haveno-install.sh` do upstream usa `wget` para baixar o `.deb` (~266 MB) via Tor. Se o circuito Tor foi substituído ou o `wget` expirou, o upstream aborta com `Failed to download Haveno binary`. A fase de recursos (`exec.sh`, `haveno.desktop`) pode ter concluído com sucesso antes da falha.

**Hub tenta automaticamente (versões recentes):**  
Quando o upstream falha e `App/utils/` já existe, o hub faz retry com `curl -L -C -` (mais robusto para grandes downloads via Tor). Se o retry funcionar, o fluxo continua normalmente — **nenhuma ação manual necessária**.

**Se o retry também falhar — solução manual:**
```bash
# Baixar o .deb diretamente (curl com retomada)
cd ~/Persistent/hub-scripts/steps
./02-download-deb.sh
```
Quando der PASS, se `App/utils/` já existe:
```bash
hub.sh install --install-only --qa-log
```
Se `App/utils/` não existe (falha na fase de recursos):
```bash
./05-verify-sig.sh && ./06-check-deps.sh && ./07-install-deb.sh && ./08-open-haveno.sh
```

**Verificar o que já foi baixado:**
```bash
ls -lh ~/Persistent/haveno/Install/    # .deb completo → ~266 MB
ls -lh ~/Persistent/haveno/.download/  # parcial (retomável)
ls -lh ~/Persistent/haveno/App/utils/  # existe = fase de recursos ok
```

---

### Erro 3 — Haveno abre mas não fica verde (onion-grater)

**Sintoma:** A janela do Haveno abre, mas o indicador no canto inferior fica vermelho ou amarelo indefinidamente (mais de 20 minutos).

**Diagnóstico:**
```bash
sudo journalctl -u onion-grater -b --no-pager | tail -20
```

Se aparecer `command filtered: ADD_ONION` → o filtro corrigido não foi aplicado.  
Se aparecer `loaded filter: haveno` → o filtro está ok; o problema é outro (ver abaixo).

**Solução — filtro não aplicado:**
```bash
hub.sh boot
# O hub.sh reaplicará o filtro onion-grater corrigido automaticamente
```

**Solução — filtro ok mas ainda sem verde:**
```bash
# Verificar o cookie do Tor
ls -la /var/run/tor/control.authcookie
# Se aparecer: deve ter permissão de leitura para o usuário amnesia
sudo chmod o+r /var/run/tor/control.authcookie

# Ver o log do Haveno
cat /tmp/haveno-exec.log | tail -30
```

**Se aparecer `torControlCookieFile ... is not readable` no log:**
```bash
sudo chmod o+r /var/run/tor/control.authcookie
# Fechar o Haveno e reabrir:
hub.sh boot
```

---

### Erro 4 — Download interrompido / .deb parcial

**Sintoma:** O download parou no meio (queda de rede, reboot, etc.).

**O download é retomável — não comece do zero:**
```bash
cd ~/Persistent/hub-scripts/steps
./02-download-deb.sh
# Ele detecta o arquivo parcial e continua de onde parou
```

**Verificar o que já foi baixado:**
```bash
ls -lh ~/Persistent/haveno/.download/
ls -lh ~/Persistent/haveno/Install/
```

---

### Erro 5 — Preflight falha (Tor não conectou)

**Sintoma:**
```
FAIL — Tor nao conectou em 120s
```

**Soluções em ordem:**
1. Aguardar 2–3 minutos e rodar novamente — o Tor pode estar em bootstrap
2. Abrir o assistente "Conexão à rede Tor" no Tails e tentar uma bridge
3. Verificar se a senha de admin está ativa (reiniciar com `+ Mais opções`)
4. Verificar conectividade de rede básica

---

### Erro 6 — Haveno já instalado, boot falha

**Sintoma:** O Haveno estava funcionando, reiniciou o Tails, e agora o `hub.sh boot` falha.

O Tails é amnésico — dependências e configurações somem a cada boot. O `hub.sh boot` reaplicada tudo automaticamente. Se falhar:

```bash
# Verificar estado da instalação
dpkg-query -W -f='${Status}' haveno
# Deve retornar: install ok installed

# Se retornar algo diferente (config-files, half-configured):
sudo dpkg --purge haveno
# Em seguida:
hub.sh install --install-only
```

---

### Erro 7 — "Failed to download Haveno signature" (`.sig` não baixou)

**Sintoma:**
```
Tentativa 1/3 da .sig (aguarde Tor/GitHub)...
Tentativa 2/3 da .sig (aguarde Tor/GitHub)...
Tentativa 3/3 da .sig (aguarde Tor/GitHub)...
ERRO: Assinatura .sig invalida (0 bytes) — provavel erro de rede/GitHub, nao PGP.
```

**Causa:** O hub tenta baixar a `.sig` (119 B) 3 vezes via Tor antes de abortar. Se as 3 tentativas falharem, o problema é de rede/Tor ou a URL do release está desatualizada em `lib/config.sh`.

**Diagnóstico:**
```bash
# Verificar se a URL do .sig resolve (fora do Tails, na máquina de dev):
source automacao/tails/lib/config.sh
curl -sI "$HAVENO_SIG_URL" | grep -i content-length
# Esperado: Content-Length: 119
```

**Solução — problema de rede (transiente):**
```bash
# Aguardar 2-3 min e tentar novamente:
hub.sh install --qa-log
```

**Solução — URL desatualizada (release novo não atualizado em config.sh):**
```bash
# Verificar o nome exato do .deb no GitHub e atualizar config.sh (equipe)
# Ver docs/RELEASE-UPDATE.md
```

**Fallback manual (se a URL está correta mas o Tor não coopera):**
```bash
cd ~/Persistent/hub-scripts/steps
./02-download-deb.sh   # inclui download da .sig com retomada
```

---

## 3. Logs úteis para enviar ao suporte

| Log | Localização | Como coletar |
|---|---|---|
| QA log completo | `~/Persistent/qa-logs/` | `hub.sh install --qa-log` |
| Log do Haveno | `/tmp/haveno-exec.log` | `cat /tmp/haveno-exec.log` |
| Log do onion-grater | journalctl | `sudo journalctl -u onion-grater -b --no-pager` |
| Estado dpkg | terminal | `dpkg-query -W -f='${Status}' haveno` |

**Sempre enviar ao suporte:**
1. Print da tela com o erro
2. Qual step/comando foi rodado
3. Conteúdo de `~/Persistent/qa-logs/` (se `--qa-log` foi usado)

---

### Erro 8 — Backup: "Espaco insuficiente" ou falha no `--full`

**Sintoma:**
```
ERRO: Espaco insuficiente em /media/amnesia/MEU_USB (dados ~450MiB, livre 120MiB)...
```

**Causa:** O destino (`--usb`, `--dest` ou `~/Persistent/Backups/`) não tem espaço livre para o `.gpg` final. O hub grava **direto no disco do destino** (`tar | gpg`) — não usa mais `/tmp`/RAM como gargalo principal.

**Solução:**
```bash
# Ver tamanho das pastas que entram no --full:
du -sh ~/Persistent/haveno/Data ~/Persistent/feather/wallets ~/Persistent/dotfiles ~/Persistent/my-locker 2>/dev/null

# Reduzir my-locker/ (KeePass + comprovantes — alvo < ~500 MB):
# Remover vídeos, ISOs, duplicatas em Backups/

# Usar pendrive com mais espaço livre:
hub.sh backup --full --usb
```

**Pasta `my-locker/`:** crie `~/Persistent/my-locker/` para KeePass e comprovantes de trade. **Nunca** guarde seed em arquivo.

---

### Erro 9 — `.sig` com 0 bytes ou HTTP 404 (tag `HAVENO_VERSION` errada)

**Sintoma:**
```
ERRO: Assinatura .sig invalida (0 bytes) — rede/Tor ou URL incorreta
# ou
ERRO: Assinatura .sig nao encontrada (HTTP 404) — tag HAVENO_VERSION incorreta
URL: .../download/1.8.0-reto/haveno-v1.8.0-...deb.sig
```

**Causa:** A tag do GitHub **não segue um padrão fixo** entre releases. Ex.: `1.6.0-reto` (sem `v`) vs `v1.8.0-reto` (com `v`). URL com tag inexistente → 404 → `.sig` vazia.

**Solução:**
```bash
# 1. Checar tag Latest e URL da .sig ANTES do download grande:
hub.sh check-release

# 2. Confirmar no Tails qual config está em uso:
source ~/Persistent/hub-scripts/lib/common.sh
echo "$HAVENO_VERSION"
echo "$HAVENO_SIG_URL"

# 3. Sync após editar config no repo:
~/Persistent/hub-scripts/sync-hub-scripts.sh

# 4. Retomar install:
hub.sh install --qa-log
```

**Checkpoint:** se o log já mostrou `Assinatura .sig pronta (..., 119 bytes)` e `Haveno binaries have been successfully verified`, **não** é problema de `config.sh` — veja Erro 10.

---

### Erro 10 — `install.sh falhou` com `GDBus` / Notifications (pacote já instalado)

**Sintoma:**
```
GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.Notifications was not provided...
Setting up haveno (1.8.0-1) ...
install.sh falhou.
RESULTADO: FAIL
```

**Causa:** O `install.sh` upstream tenta notificar a UI (D-Bus) num contexto sem serviço de notificações (`pkexec`/automação). O `dpkg` pode ter **concluído** mesmo assim.

**Solução:**
```bash
# Verificar se o pacote está instalado:
dpkg-query -W -f='${Status}' haveno

# Se "install ok installed":
hub.sh install --install-only --qa-log
# ou
hub.sh boot --qa-log
```

**Não** reeditar `HAVENO_VERSION` se o log já passou por verificação PGP do `.deb`.

---

## 4. Referência rápida — steps/ e quando usar cada um

| Step | Arquivo | Quando usar |
|---|---|---|
| 1 | `01-setup-dirs.sh` | Pastas `Install/`, `Data/`, `App/utils/` não existem |
| 2 | `02-download-deb.sh` | Baixar ou retomar o .deb (com barra de progresso e retomada) |
| 3 | `03-rescue-tmp.sh` | .deb ficou em `/tmp` de uma rodada antiga (antes de reiniciar) |
| 4 | `04-import-key.sh` | Chave PGP da Reto não está no chaveiro |
| 5 | `05-verify-sig.sh` | Verificar se o .deb baixado é autêntico |
| 6 | `06-check-deps.sh` | Ver quais dependências existem/não existem no Tails |
| 7 | `07-install-deb.sh` | Instalar o .deb (use `--force-depends` se o 06 indicar libs faltando) |
| 8 | `08-open-haveno.sh` | Configurar onion-grater e abrir o Haveno |
| — | `run-all.sh` | Rodar todos os steps em sequência (fallback completo) |

---

*docs/TROUBLESHOOTING.md · Privacy-OS-Hub · atualizado 2026-07-02*
