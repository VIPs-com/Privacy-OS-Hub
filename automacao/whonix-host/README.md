# Scripts — Whonix Online (host Linux)

> **Novato?** Seção Whonix em [**MANUAL.md**](../../docs/MANUAL.md#whonix-host-linux--não-é-no-tails).

> **Rode no host** (Debian/Ubuntu etc.) — **não** no Tails e **não** dentro das VMs.

| Script | Etapa | Função |
|--------|-------|--------|
| [`whonix-install-virtualbox.sh`](whonix-install-virtualbox.sh) | **1 — install** | Repo Oracle · GPG · pacote · Extension Pack · MOK import |
| *(tela azul)* | **2 — firmware** | Enroll MOK (só se Secure Boot ON) — **manual** |
| [`whonix-sign-virtualbox-modules.sh`](whonix-sign-virtualbox-modules.sh) | **3 — sign** | `vboxconfig` + assinar módulos + `modprobe` (repita após kernel novo) |
| [`whonix-verify-virtualbox-host.sh`](whonix-verify-virtualbox-host.sh) | **4 — verify** | Validação read-only · `--qa-log` · não instala nem assina |
| [`whonix-verify-image.sh`](whonix-verify-image.sh) | **5** | PGP da imagem `.ova` |
| [`whonix-import-ova.sh`](whonix-import-ova.sh) | **6** | Verify + import Whonix |
| [`whonix-verificar-tor.sh`](whonix-verificar-tor.sh) | **7** | Tor na Workstation (dentro da VM) |

**Ainda manual:** Anon Connection Wizard, cold-signing (passos 11–12).

---

## VirtualBox no Linux ≠ `.exe` do Windows

No Windows, o instalador assina tudo sozinho. No **Debian/Ubuntu com Secure Boot ON**, o kernel só aceita o driver `vboxdrv` se ele for assinado com **sua** chave MOK enrolada no firmware.

| Quem faz | O quê |
|----------|--------|
| **`install`** | Repo Oracle · GPG · `apt` · Extension Pack · `mokutil --import` |
| **`sign`** | `vboxconfig` + `sign-file` com chave MOK + `modprobe` |
| **`verify`** | 9 checks read-only + QA log — **não altera o sistema** |
| **Aluno** | Senha MOK · tela azul Enroll MOK |
| **Impossível scriptar** | Tela azul MOK no firmware |

Cada script grava `RESULTADO:` no seu log. Um arquivo de **progresso** evita perder o rumo:

`/root/module-signing/.hub-vbox-progress` — marcas: `INSTALL_OK`, `MOK_IMPORTED`, `MOK_ENROLLED`, `MODULES_SIGNED`, `MODULES_LOADED`

| Log | Caminho |
|-----|---------|
| Instalação | `/var/log/virtualbox-install.log` |
| Assinatura | `/var/log/virtualbox-sign.log` |
| QA (evidência) | `./qa-logs/10-virtualbox-*.txt` |

O instalador detecta a **fase** e retoma (não repete `apt install` se o pacote já existe).

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
chmod +x whonix-install-virtualbox.sh whonix-sign-virtualbox-modules.sh whonix-verify-virtualbox-host.sh whonix-verify-image.sh whonix-import-ova.sh whonix-verificar-tor.sh
```

> **Cole só comandos no terminal** — não cole texto/markdown de análises ou chats.

### Refazer do zero (piloto / perdeu tela azul MOK)

Use quando testes anteriores falharam, `mokutil --list-new` está vazio, ou você **perdeu** a tela azul sem fazer Enroll MOK:

```bash
cd ~/Downloads/Privacy-OS-Hub/automacao/whonix-host
git pull
chmod +x whonix-install-virtualbox.sh

# Limpa enroll pendente + chaves MOK antigas + reinstala fluxo completo
sudo ./whonix-install-virtualbox.sh --reset-mok --new-mok-keys -y
```

O que `--reset-mok --new-mok-keys` faz:

1. `mokutil --reset` — cancela enroll pendente antigo no firmware
2. Apaga `/root/module-signing/MOK.{priv,der}` — gera par novo
3. Continua instalação/retomada normalmente

**Depois do `mokutil --import` OK**, com `-y` o reboot pergunta `[S/n]` — **Enter = reinicia** (`systemctl reboot -i` em 8 s).

**Na tela azul** (logo após reiniciar — reaja rápido):

`Enroll MOK` → `Continue` → `Yes` → senha MOK → `Reboot`

> **View key 0** pode aparecer **vazio** — isso é normal no firmware. Escolha **Continue**, não `key from disk`.

**Após login — ordem recomendada:**

```bash
sudo ./whonix-sign-virtualbox-modules.sh -y --qa-log
sudo ./whonix-verify-virtualbox-host.sh --qa-log
sudo ./whonix-install-virtualbox.sh -y    # Extension Pack se WARN
```

Esperado: verify `RESULTADO: PASS` · `vboxdrv` no `lsmod`.

---

## Fluxo completo — primeira instalação (Secure Boot ON)

```text
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ 1 install│ →  │2 tela azul│ →  │ 3 sign   │ →  │ 4 verify │ →  │ 5 Whonix │
│  script  │    │ (manual) │    │  script  │    │  script  │    │ import   │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
```

```bash
# Etapa 1 — instalar pacote + MOK import
sudo ./whonix-install-virtualbox.sh -y
# → exit 2: reboot + tela azul

# Etapa 2 — tela azul (só neste reboot)
# Enroll MOK → Continue → Yes → senha → Reboot

# Etapa 3 — assinar módulos (kernel atual)
sudo ./whonix-sign-virtualbox-modules.sh -y --qa-log

# Etapa 4 — validar
sudo ./whonix-verify-virtualbox-host.sh --qa-log
```

**Secure Boot OFF:** pule a etapa 2; `sign` faz só `vboxconfig` + `modprobe`.

**Kernel novo** (`apt upgrade` trocou o kernel): repita **só a etapa 3** (`sign`), depois `verify`.

---

### 1) Primeira execução (ou após reset)

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
| `PASS` | `0` | `vboxdrv` carregado | [verify](#3b-só-validar) → [Whonix](#4-importar-whonix) |
| `PASS_PENDING_MOK_REBOOT` | `2` | Falta tela azul | [Passo 2](#2-reboot--enroll-mok-tela-azul) |
| `PASS_NEEDS_SIGN` | `3` | Pacote OK; falta assinar | `whonix-sign-virtualbox-modules.sh -y` |
| `FAIL` | `1` | Erro fatal | `/var/log/virtualbox-install.log` |

Log completo: `/var/log/virtualbox-install.log` (última linha: `RESULTADO:`).

### 2) Reboot + Enroll MOK (tela azul)

Só necessário se o script indicou `PASS_PENDING_MOK_REBOOT` ou pediu reboot.

Com `-y`, ao perguntar reboot use **`[S/n]`** — **Enter = reinicia** em 8 segundos.

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

### 3) Assinar módulos (pós-tela azul ou SB off)

```bash
sudo ./whonix-sign-virtualbox-modules.sh -y --qa-log
lsmod | grep vbox
```

Fase esperada do **install** após MOK enrolada: `needs_sign` — o install pode delegar ao `sign` automaticamente, mas você pode rodar `sign` diretamente.

**Após cada `apt upgrade` que troca o kernel**, repita só este comando.

### 3b) Validar

```bash
sudo ./whonix-verify-virtualbox-host.sh --qa-log
```

Gera `qa-logs/10-virtualbox-host-*.txt` — envie como evidência de campo.

| `RESULTADO` | `exit` | Significado |
|-------------|--------|-------------|
| `PASS` | `0` | Tudo OK — importar Whonix |
| `FAIL_MOK` | `2` | Falta tela azul Enroll MOK |
| `FAIL_SIGN` | `3` | MOK OK; rode `whonix-sign-virtualbox-modules.sh` |
| `FAIL` | `1` | Outro problema |

### 3c) Extension Pack (opcional — WARN no verify)

```bash
sudo ./whonix-install-virtualbox.sh -y
```

Só instala Extension Pack se faltar; não repete passos 1–7.

### 4) Importar Whonix

Com VirtualBox OK:

```bash
# Só verificar PGP (evidência QA)
./whonix-verify-image.sh --qa-log /caminho/Whonix-*.ova /caminho/Whonix-*.ova.asc

# Verificar + importar (+ boot opcional)
sudo ./whonix-import-ova.sh -i /caminho/Whonix-*.ova -s /caminho/Whonix-*.ova.asc --qa-log -b
```

---

## Fases do assistente (`whonix-install-virtualbox.sh`)

| Fase | Quando | O que faz |
|------|--------|-----------|
| `fresh_install` | VB não instalado | Instalação completa |
| `installed_need_mok` | Falta `mokutil --import` | Pede senha MOK |
| `pending_mok_reboot` | Import OK; falta tela azul | Card MOK + reboot |
| `needs_sign` | MOK enrolada ou SB off | Delega ao `sign` (ou rode sign manualmente) |
| `complete` | `vboxdrv` carregado | Verificação rápida |

Assinatura de módulos: sempre **`whonix-sign-virtualbox-modules.sh`** (log em `/var/log/virtualbox-sign.log`).

---

## Opções do script

```bash
sudo ./whonix-install-virtualbox.sh -y              # padrão recomendado (menos prompts)
sudo ./whonix-install-virtualbox.sh                 # pede confirmações + FPR visual Oracle
sudo ./whonix-install-virtualbox.sh -y --no-extpack # sem Extension Pack
sudo ./whonix-install-virtualbox.sh -y --skip-mok   # não tenta MOK (SB deve estar off)
sudo ./whonix-install-virtualbox.sh -h              # ajuda
```

Se a tela azul **não aparecer** ou passar rápido demais, você **não** enrolou — volte à seção [Refazer do zero](#refazer-do-zero-piloto--perdeu-tela-azul-mok).

| Flag | Efeito |
|------|--------|
| `-y` | Menos prompts; licença PUEL auto; reboot pós-MOK **`[S/n]`** (Enter = sim) |
| `--reset-mok` | `mokutil --reset` antes de instalar (limpa enroll pendente) |
| `--new-mok-keys` | Com `--reset-mok`: apaga e regera chaves em `/root/module-signing/` |
| `--no-extpack` | Não instala Oracle Extension Pack |
| `--skip-mok` | Ignora fluxo MOK (use só com Secure Boot desligado na BIOS) |
| `-v VERSAO` | Série VirtualBox (padrão: `7.2`) |

---

## Diagnóstico rápido

```bash
# Validação completa (recomendado)
sudo ./whonix-verify-virtualbox-host.sh --qa-log

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
| `Key was rejected` | MOK OK; kernel novo ou módulos não assinados | `sudo ./whonix-sign-virtualbox-modules.sh -y` |
| `modprobe` sem erro mas `lsmod` vazio | v3.5.1: blacklist/vermagic; **v3.5.2:** MOK em caminho errado | v3.5.2+ sincroniza Hub → `/var/lib/shim-signed/mok/`; se persistir: `dmesg \| grep vbox` |
| `does not provide tools for automatic generation of keys` | `vboxdrv.sh` não acha MOK em `/var/lib/shim-signed/mok/` | **v3.5.2+** — `git pull` e rode `sign` de novo |
| `vboxpci não encontrado` | **Normal** — módulo descontinuado desde VBox 6.1 | Ignorar (v3.5.1+ não avisa mais) |
| `FAIL_SIGN` no verify | Idem | `whonix-sign-virtualbox-modules.sh -y --qa-log` |
| Install pede reboot mas MOK já enrolada | Estado `.mok-import-requested` obsoleto | `sudo rm -f /root/module-signing/.mok-import-requested` + `sign` |
| `already in the enrollment request` | Import OK; falta reboot | `systemctl reboot -i` |
| Perdeu tela azul MOK | Enroll não feito | `--reset-mok --new-mok-keys -y` ou `mokutil --import` + reboot imediato |
| `password doesn't match` no import | Script antigo (senha 1×) | `git pull` (v3.2.1+) |
| Passos 1–7 repetem toda vez | Script antigo (sem assistente) | `git pull` |
| `virtualbox.list` corrompido | Run antigo com bug | Script v3+ remove automaticamente |

---

## O que é automático vs. interativo

```
┌─────────────────────────────────────────────────────────────┐
│  AUTOMÁTICO                                                 │
│  · install: repo · GPG · apt · Extension Pack · MOK import │
│  · sign: vboxconfig + sign-file + modprobe                  │
│  · verify: 9 checks read-only + qa-log                      │
├─────────────────────────────────────────────────────────────┤
│  INTERATIVO (aluno)                                         │
│  · Senha MOK (terminal)                                     │
│  · Tela azul: Enroll MOK → Continue → Yes → senha → Reboot  │
│  · View key 0 vazio = normal → escolha Continue             │
├─────────────────────────────────────────────────────────────┤
│  REPITA sign após apt upgrade que troca o kernel            │
└─────────────────────────────────────────────────────────────┘
```

Fingerprint Oracle oficial: [Linux Downloads](https://www.virtualbox.org/wiki/Linux_Downloads) · chave: `oracle_vbox_2016.asc`

---

## Fluxo completo Whonix (resumo)

```bash
cd automacao/whonix-host
chmod +x *.sh

# A) VirtualBox — fluxo v3.5
sudo ./whonix-install-virtualbox.sh -y          # 1 install
# → tela azul se SB ON
sudo ./whonix-sign-virtualbox-modules.sh -y --qa-log   # 3 sign
sudo ./whonix-verify-virtualbox-host.sh --qa-log       # 4 verify

# B) Whonix
./whonix-verify-image.sh --qa-log /caminho/Whonix-*.ova /caminho/Whonix-*.ova.asc
sudo ./whonix-import-ova.sh -i /caminho/Whonix-*.ova -s /caminho/Whonix-*.ova.asc --qa-log -b
```

---

## Notas técnicas (jul/2026 · v3.5.3)

- **Checagem de módulo via `/proc/modules`:** nunca `lsmod | grep -q` em script com `pipefail` — o `grep -q` fecha o pipe no 1º match e o `lsmod` morre com SIGPIPE (exit 141), gerando falso "não carregado" justamente quando o módulo está no topo do `lsmod` (recém-carregado).
- **MOK em dois caminhos:** Hub gera em `/root/module-signing/`; `vboxdrv.sh` (Oracle) exige `/var/lib/shim-signed/mok/`. v3.5.2+ copia a **mesma** chave enrolada antes de cada `vboxconfig` (`sync_mok_to_shim_signed`).
- **Módulos assinados (VBox 7.2):** `vboxdrv`, `vboxnetflt`, `vboxnetadp` — **`vboxpci` não existe mais** (removido na série 6.1).
- **Três scripts + três logs:** install · sign · verify — não misture responsabilidades.
- **Falha silenciosa:** se `modprobe` não imprime erro mas `vboxdrv` não carrega, o `sign` v3.5.1+ checa blacklist, vermagic e `dmesg`.
- **VirtualBox manual §2.3.2.1:** doc Oracle pode citar `vboxpci` — ignore no 7.2; [docs.virtualbox.org](https://www.virtualbox.org/manual/ch02.html#idm93).
- **Kernel novo:** `sign` roda `vboxconfig` + `sign-file` de novo — **não** precisa re-enrolar MOK.
- **PGP fail-closed:** `whonix-verify-image.sh` usa `VALIDSIG` + fingerprint.
- **`mokutil --test-key`:** parseia mensagem, não só exit code (Debian trixie).
- **Progresso:** `/root/module-signing/.hub-vbox-progress` — consulte se perdeu o rumo.

*Módulo 2 · Privacy-OS-Hub · fluxo VirtualBox v3.5.3 · jul/2026*
