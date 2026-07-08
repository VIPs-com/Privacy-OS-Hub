# Scripts — Whonix Online (host Linux)

> **Novato?** Seção Whonix em [**MANUAL.md**](../../docs/MANUAL.md#whonix-host-linux--não-é-no-tails).

> **Rode no host** (Debian/Ubuntu etc.) — **não** no Tails e **não** dentro das VMs.

| Script | Passo hub | Função |
|--------|-----------|--------|
| [`whonix-install-virtualbox.sh`](whonix-install-virtualbox.sh) | **10** (prep) | Assistente: Oracle VirtualBox + GPG + DKMS + Extension Pack + MOK (Secure Boot) |
| [`whonix-verify-image.sh`](whonix-verify-image.sh) | **10** | PGP da imagem `.ova` ou `.libvirt.xz` (só verificação) |
| [`whonix-import-ova.sh`](whonix-import-ova.sh) | **10** | Verify + `VBoxManage import` (+ boot opcional `-b`) |
| [`whonix-verificar-tor.sh`](whonix-verificar-tor.sh) | **10** (pós-boot) | `systemcheck` + check.torproject.org na Workstation |

**Ainda manual:** Anon Connection Wizard, cold-signing (passos 11–12).

---

## VirtualBox no Linux ≠ `.exe` do Windows

No Windows, o instalador assina tudo sozinho. No **Debian/Ubuntu com Secure Boot ON**, o kernel só aceita o driver `vboxdrv` se ele for assinado com **sua** chave MOK enrolada no firmware.

| Quem faz | O quê |
|----------|--------|
| **Script (automático)** | Repo Oracle · chave GPG (fail-closed) · `apt` · DKMS · Extension Pack · `mokutil --import` · assinar módulos **após** enroll |
| **Aluno (interativo)** | Senha MOK (1×) · **tela azul** no boot (Enroll MOK) · opcional: conferir fingerprint Oracle visualmente |
| **Impossível scriptar** | Tela azul **MOK Management** no firmware — proteção do Secure Boot |

O script detecta em qual **fase** você está e retoma sozinho (não repete `apt install` se o pacote já existe).

---

## Passo a passo — `whonix-install-virtualbox.sh`

### Pré-requisitos

- Host **Debian 12/13** ou Ubuntu (codenames suportados: `bookworm`, `trixie`, `bullseye`)
- Arquitetura **amd64**
- Conexão à internet (downloads Oracle)
- Usuário com `sudo`
- **Secure Boot ON** (padrão do curso) — fluxo MOK abaixo; alternativa avançada: `--skip-mok` + desligar SB na BIOS

### 0) Obter scripts atualizados

```bash
cd ~/Downloads/Privacy-OS-Hub   # ou seu clone do repo
git pull
cd automacao/whonix-host
chmod +x whonix-install-virtualbox.sh whonix-verify-image.sh whonix-import-ova.sh whonix-verificar-tor.sh
```

> **Cole só comandos no terminal** — não cole texto/markdown de análises ou chats.

### 1) Primeira execução

```bash
sudo ./whonix-install-virtualbox.sh -y
```

O assistente mostra a **fase** no início. Na 1ª vez costuma ser **INSTALAÇÃO** (`fresh_install`).

**O script faz sozinho (passos 1–11):**

1. `apt` + headers do kernel + DKMS + `mokutil`
2. Baixa chave Oracle de `virtualbox.org` e valida fingerprint (`VALIDSIG` / fail-closed)
3. Configura repositório Oracle assinado
4. Instala `virtualbox-7.2` + Extension Pack (com `-y`, licença PUEL sem prompt)
5. Adiciona seu usuário ao grupo `vboxusers`
6. Se **Secure Boot ON**: gera chave MOK, pede **senha MOK** (2× no terminal)

**Possíveis resultados da 1ª execução:**

| `RESULTADO` no log | `exit` | Significado | Próximo passo |
|--------------------|--------|-------------|---------------|
| `PASS` | `0` | `vboxdrv` carregado — VMs podem ligar | Ir para [passo 4](#4-importar-whonix) |
| `PASS_PENDING_MOK_REBOOT` | `2` | Pacote OK; falta reboot + tela azul | [Passo 2](#2-reboot--enroll-mok-tela-azul) |
| `PASS_MODULES_MISSING` | `2` | Pacote OK; módulos ainda não carregaram | Ver [Diagnóstico](#diagnóstico-rápido) |
| `FAIL` | `1` | Erro fatal | Log: `/var/log/virtualbox-install.log` |

Log completo: `/var/log/virtualbox-install.log` (última linha: `RESULTADO:`).

### 2) Reboot + Enroll MOK (tela azul)

Só necessário se o script indicou `PASS_PENDING_MOK_REBOOT` ou pediu reboot.

```bash
sudo systemctl reboot -i
```

> **Atenção:** o comando correto é `systemctl **reboot** -i`.  
> `sudo systemctl -i` **sozinho** só lista serviços — **não reinicia**.

Se o GNOME bloquear reboot simples (`Operation inhibited`), use `systemctl reboot -i` ou feche apps e tente `sudo reboot`.

**No boot — tela AZUL "MOK Management"** (aparece só neste reboot):

1. **Enroll MOK**
2. **Continue**
3. **Yes**
4. Digite a **mesma senha MOK** que definiu no script
5. **Reboot**

Se a tela azul **não aparecer**, o enroll não foi feito — o `vboxdrv` continuará bloqueado.

### 3) Segunda execução (pós-reboot)

```bash
cd ~/Downloads/Privacy-OS-Hub/automacao/whonix-host
git pull
sudo ./whonix-install-virtualbox.sh -y
```

Fase esperada: **PÓS-REBOOT** (`post_reboot_sign`). O script **pula** passos 1–7, assina módulos com a chave enrolada e carrega `vboxdrv`.

**Confirme:**

```bash
lsmod | grep vbox
echo "exit=$?"
```

Esperado: `vboxdrv` (e possivelmente `vboxnetflt`, `vboxnetadp`) listados · `RESULTADO: PASS` · `exit=0`.

### 4) Importar Whonix

Com VirtualBox OK:

```bash
# Só verificar PGP (evidência QA)
./whonix-verify-image.sh --qa-log /caminho/Whonix-*.ova /caminho/Whonix-*.ova.asc

# Verificar + importar (+ boot opcional)
sudo ./whonix-import-ova.sh -i /caminho/Whonix-*.ova -s /caminho/Whonix-*.ova.asc --qa-log -b
```

---

## Fases do assistente (detecção automática)

| Fase | Quando | O que o script faz |
|------|--------|-------------------|
| `fresh_install` | VirtualBox não instalado | Instalação completa (passos 1–11) |
| `installed_need_mok` | VB instalado; chave MOK não registrada | Pede senha MOK + `mokutil --import` |
| `pending_mok_reboot` | Import OK; falta reboot | Mostra card MOK + oferece `systemctl reboot -i` |
| `post_reboot_sign` | Chave enrolada no firmware | Assina módulos + `modprobe` |
| `installed_no_modules` | SB off ou `--skip-mok` | `vboxconfig` + carregar módulos |
| `complete` | `vboxdrv` já carregado | Verificação rápida → `PASS` |

---

## Opções do script

```bash
sudo ./whonix-install-virtualbox.sh -y              # padrão recomendado (menos prompts)
sudo ./whonix-install-virtualbox.sh                 # pede confirmações + FPR visual Oracle
sudo ./whonix-install-virtualbox.sh -y --no-extpack # sem Extension Pack
sudo ./whonix-install-virtualbox.sh -y --skip-mok   # não tenta MOK (SB deve estar off)
sudo ./whonix-install-virtualbox.sh -h              # ajuda
```

| Flag | Efeito |
|------|--------|
| `-y` | Aceita instalação, licença PUEL e fingerprint Oracle sem prompt extra |
| `--no-extpack` | Não instala Oracle Extension Pack |
| `--skip-mok` | Ignora fluxo MOK (use só com Secure Boot desligado na BIOS) |
| `-v VERSAO` | Série VirtualBox (padrão: `7.2`) |

---

## Diagnóstico rápido

```bash
# Chave MOK enrolada no firmware?
sudo mokutil --test-key /root/module-signing/MOK.der

# Secure Boot
mokutil --sb-state

# Módulos carregados?
lsmod | grep vbox

# Por que modprobe falhou?
sudo modprobe vboxdrv
sudo dmesg | tail -10

# Status do serviço
systemctl status vboxdrv.service

# Log do assistente
sudo tail -30 /var/log/virtualbox-install.log
```

| Sintoma | Causa provável | Ação |
|---------|----------------|------|
| `is not enrolled` no `test-key` | Tela azul não feita | `systemctl reboot -i` → Enroll MOK |
| `Key was rejected by service` | Chave não enrolada ou kernel novo | Reboot MOK ou rodar script de novo |
| `already in the enrollment request` | Import OK; falta reboot | `systemctl reboot -i` |
| Extension Pack pede `y/n` com `-y` | Script desatualizado | `git pull` no repo |
| Passos 1–7 repetem toda vez | Script antigo (sem assistente) | `git pull` |
| `virtualbox.list` corrompido | Run antigo com bug | Script v3+ remove automaticamente |

---

## O que é automático vs. interativo

```
┌─────────────────────────────────────────────────────────────┐
│  AUTOMÁTICO (script)                                        │
│  · HTTP 200 no repo Oracle trixie/bookworm                  │
│  · GPG fingerprint B9F8D658297AF3EFC18D5CDFA2F683C52980AECF │
│  · apt install virtualbox-7.2 + DKMS build                  │
│  · Extension Pack (download oracle + install)               │
│  · Retomada por fase (não reinstala se já instalado)       │
│  · Assinar módulos APÓS chave MOK enrolada                  │
├─────────────────────────────────────────────────────────────┤
│  INTERATIVO (aluno) — obrigatório                           │
│  · Senha MOK (terminal, 2×)                                 │
│  · Tela azul: Enroll MOK → Continue → Yes → senha → Reboot  │
├─────────────────────────────────────────────────────────────┤
│  INTERATIVO (aluno) — opcional com -y                       │
│  · Confirmar fingerprint Oracle visualmente no site oficial │
└─────────────────────────────────────────────────────────────┘
```

Fingerprint Oracle oficial: [Linux Downloads](https://www.virtualbox.org/wiki/Linux_Downloads) · chave: `oracle_vbox_2016.asc`

---

## Fluxo completo Whonix (resumo)

```bash
cd automacao/whonix-host
chmod +x *.sh

# A) VirtualBox (este README)
sudo ./whonix-install-virtualbox.sh -y
# → se exit 2: reboot MOK → rodar de novo até PASS

# B) Whonix
./whonix-verify-image.sh --qa-log /caminho/Whonix-*.ova /caminho/Whonix-*.ova.asc
sudo ./whonix-import-ova.sh -i /caminho/Whonix-*.ova -s /caminho/Whonix-*.ova.asc --qa-log -b
```

---

## Notas técnicas (jul/2026 · v3.2)

- **PGP fail-closed:** `whonix-verify-image.sh` e `whonix-import-ova.sh` usam `VALIDSIG` + fingerprint — não dependem de `Good signature` / locale PT-BR.
- **`whonix-verificar-tor.sh`:** finais de linha **LF** (Unix). CRLF quebra o shebang. O repo força `*.sh eol=lf` via `.gitattributes`.
- **`mokutil --test-key` no Debian trixie:** pode imprimir `is not enrolled` e ainda sair com exit `0` — o script v3.1+ parseia a **mensagem**, não só o exit code.
- **Debian 13 + KVM:** se `kvm` estiver carregado, pode conflitar com VirtualBox — aviso no log.
- **`sanitize_stale_repo_file`:** remove `virtualbox.list` corrompido antes do primeiro `apt-get update`.

Validação: [COMO-LER-SEUS-LOGS.md](../docs-aluno/COMO-LER-SEUS-LOGS.md) (tabela passo 10).

*Módulo 2 · Privacy-OS-Hub · assistente VirtualBox v3.2 · jul/2026*
