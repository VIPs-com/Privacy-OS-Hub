# Troubleshooting — hub.sh e steps/

> **Para o suporte:** use este documento para orientar alunos quando `hub.sh` falha.  
> **Para o aluno:** você está aqui porque o suporte te mandou. Siga as instruções da seção que se aplica ao seu caso.

---

## 1. Mapa rápido — hub.sh travou, qual step rodar?

| hub.sh parou em... | Mensagem típica | Step a rodar | O que o FAIL indica |
|---|---|---|---|
| Baixando o .deb | `[download] NNB` ou `Failed to download resource` | `steps/02-download-deb.sh` | Rede Tor instável ou URL do release desatualizada |
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

### Erro 2 — "Failed to download resource (exec.sh)"

**Sintoma:**
```
[download] 119B — baixando (retomavel na persistencia)...
Failed to download resource (exec.sh).
ERRO: haveno-install.sh falhou (PGP/URL/rede).
```

**Causa:** O `haveno-install.sh` do upstream tentou baixar um recurso auxiliar via Tor e falhou. Problema de rede ou URL do upstream — não é erro do hub.

**Solução (se o .deb já está completo em `Install/`):**
```bash
hub.sh install --install-only
```

**Solução (se o .deb ainda não foi baixado):**
```bash
cd ~/Persistent/hub-scripts/steps
./02-download-deb.sh   # baixa direto na persistência, com retomada
```
Depois que der PASS:
```bash
./04-import-key.sh
./05-verify-sig.sh
./06-check-deps.sh
./07-install-deb.sh    # ou --force-depends se o 06 indicar libs faltando
./08-open-haveno.sh
```

**Verificar se o .deb está completo:**
```bash
ls -lh ~/Persistent/haveno/Install/
# Deve mostrar ~266 MB para o 1.6.0-reto
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

*docs/TROUBLESHOOTING.md · Privacy-OS-Hub · atualizado 2026-06-19*
