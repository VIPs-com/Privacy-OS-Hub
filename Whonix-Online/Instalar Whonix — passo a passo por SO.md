# Instalar o Whonix — passo a passo por SO (VirtualBox / KVM)

Guia prático de **instalação e verificação da imagem**, separado pelo **seu sistema (host)**. Complementa o livro [`Curso — Whonix Online.md`](Curso%20—%20Whonix%20Online.md) (Cap. 2), que explica o *porquê* (modelo de ameaças, Gateway × Workstation).

> 🔒 **Disciplina inegociável:** **baixe → verifique → só então importe**. Imagem **não verificada = não importe**. Mesmo rigor PGP do Módulo 1.
>
> 🖼️ **Prints:** as capturas de tela deste guia estão **pendentes** (ver [§10 — manifesto](#10-prints-pendentes-manifesto)). Os passos textuais já são suficientes para concluir.

---

## 1. Antes de tudo (host)

- [ ] **Virtualização ligada na BIOS/UEFI** (Intel **VT-x** / AMD **AMD-V**).
- [ ] **Host atualizado e confiável** — o Whonix isola, mas o **host é a raiz de confiança**.
- [ ] **Full-disk encryption** no host **recomendada** (protege o estado persistente das VMs).
- [ ] **Espaço/RAM:** reserve folga (as duas VMs rodam juntas; ~4 GB+ de RAM livre é confortável).
- [ ] Baixe **só** de **https://www.whonix.org/wiki/Download** (nada de espelhos não-oficiais).

| Host | Caminho recomendado |
|------|---------------------|
| **Windows / macOS** | **VirtualBox** (§3) |
| **Linux** | **VirtualBox** (§3, mais fácil) **ou** **KVM** (§4, mais performático/seguro) |
| **Qubes OS** | Qubes-Whonix (avançado — fora do escopo deste guia; ver docs oficiais) |

---

## 2. Baixe os 3 arquivos (qualquer SO)

Na [página de Download](https://www.whonix.org/wiki/Download), baixe **para a mesma pasta**:

1. A **imagem** (escolha o formato do seu caminho):
   - **VirtualBox:** `Whonix-*.ova` (variante **LXQt** = com interface gráfica, recomendada; **CLI** = só terminal, avançado).
   - **KVM:** `Whonix-*.libvirt.xz`.
2. A **assinatura** correspondente: o mesmo nome **+ `.asc`** (ex.: `Whonix-*.ova.asc`).
3. A **chave de assinatura do Whonix**: https://www.whonix.org/keys/derivative.asc

> ⚠️ Baixe a `.asc` da imagem **e** a chave — sem elas você não consegue verificar.
>
> 📁 Os comandos abaixo usam o curinga `Whonix-*`. Se houver **mais de um** arquivo `.ova`/`.libvirt.xz` na pasta (ex.: LXQt e CLI), o curinga fica ambíguo — **digite o nome exato** do arquivo que você vai usar.

---

## 3. VirtualBox (Windows / macOS / Linux)

### 3.1 Verifique a imagem **antes** de importar
Faça a verificação do seu SO na **§5** (Windows / macOS / Linux). **Só prossiga se der "Good signature" com o fingerprint `916B8D99…2EEACCDA`.**

### 3.2 Importe a imagem verificada
1. Abra o **VirtualBox**.
2. **File → Import Appliance…**
3. Selecione o `Whonix-*.ova` **verificado** → **Next**.
4. **Import** (não precisa mudar as configurações) → aceite a licença → aguarde concluir.

### 3.3 Inicie as duas VMs
- Dê **start** em **Whonix-Gateway** → espere conectar ao **Tor** (Tor Connection / ícone).
- Dê **start** em **Whonix-Workstation**.
- Login padrão: usuário `user`, **sem senha** (passwordless). Troque/defina conforme o guia oficial se for usar de verdade.

# OK se: o Gateway conecta ao Tor; a Workstation abre e navega — e **só** consegue via Gateway.

### 3.4 Troubleshooting VirtualBox

| Sintoma | Causa comum | O que fazer |
|---------|---------------|-------------|
| VM não inicia / erro VT-x | Virtualização **desligada** na BIOS | Ative Intel VT-x ou AMD-V; reinicie o host |
| Windows: "VT-x is not available" | **Hyper-V** / WSL2 / Virtual Machine Platform ocupando VT | Desative temporariamente em *Recursos do Windows* ou use KVM no Linux |
| Import falha / disco cheio | Pouco espaço no disco do host | Libere ~30 GB+; importe para SSD |
| Gateway lento / RAM baixa | Host com pouca RAM | Feche apps; aloque 4 GB+ livres; não suba outras VMs pesadas |
| Workstation sem rede | Gateway ainda não conectou ao Tor | Espere o ícone **Tor Connection** no Gateway antes de usar a Workstation |

Fonte: https://www.whonix.org/wiki/VirtualBox

---

## 4. KVM (Linux, avançado)

1. **Verifique a imagem** primeiro (§5 → Linux), agora sobre o arquivo `Whonix-*.libvirt.xz`:
   ```bash
   gpg --verify-options show-notations --verify Whonix-*.libvirt.xz.asc Whonix-*.libvirt.xz
   ```
2. Importe seguindo o guia oficial **KVM** (define as redes `Whonix-External`/`Whonix-Internal`, o Gateway e a Workstation): https://www.whonix.org/wiki/KVM
3. Inicie **Gateway** (espera Tor) e depois **Workstation** pelo `virt-manager`/`virsh`.

# OK se: as redes virtuais sobem; Gateway conecta ao Tor; Workstation só sai via Gateway.

> Os comandos de import do KVM mudam por versão — **siga o guia oficial KVM** acima como fonte de verdade.

### 4.1 Troubleshooting KVM

| Sintoma | Causa comum | O que fazer |
|---------|---------------|-------------|
| Redes `Whonix-Internal` / `Whonix-External` ausentes | Import incompleto | Siga o guia KVM oficial do início — não pule criação de redes |
| `permission denied` no libvirt | Usuário fora do grupo `libvirt` / `kvm` | `sudo usermod -aG libvirt,kvm $USER` — faça logout/login |
| Gateway sem Tor | Relógio do host muito errado ou firewall | Confira hora do host; não bloqueie saída Tor na rede do host |
| `virsh` não lista VMs | Definições não importadas | `virsh list --all`; reimporte conforme wiki KVM |

Fonte: https://www.whonix.org/wiki/KVM

---

## 5. Verificar a imagem — por SO

> Importe a chave **e confira o fingerprint** — **nunca** apenas copie o número de uma página. Após importar, o fingerprint exibido tem de ser exatamente:
>
> **`916B8D99 C38EAF5E 8ADC7A2A 8D66066A 2EEACCDA`**
>
> 🔑 O número impresso aqui e na página do Whonix compartilham a mesma raiz de confiança (o site). Idealmente **cross-cheque numa 2ª fonte independente** (`forum.whonix.org`, um keyserver OpenPGP) — mesma disciplina do Módulo 1 (TOFU).

### 5.1 Linux

```bash
# 1) importe a chave do Whonix:
gpg --import derivative.asc
```
```bash
# 2) confira o fingerprint (tem de bater com 916B8D99…2EEACCDA):
gpg --fingerprint 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA
```
```bash
# 3) verifique a assinatura da imagem (VirtualBox; troque por .libvirt.xz no KVM):
gpg --verify-options show-notations --verify Whonix-*.ova.asc Whonix-*.ova
```

# OK se: aparece `gpg: Good signature` E o fingerprint que assinou é o `916B8D99…2EEACCDA`.
# "Good signature" de uma chave ERRADA não vale.

### 5.2 Windows (Gpg4win / Kleopatra)

1. Instale o **Gpg4win** (https://gpg4win.org) — inclui o **Kleopatra**. (Idealmente verifique também o instalador do Gpg4win.)
2. **Importe a chave:** Kleopatra → **File → Import** → selecione `derivative.asc`.
3. **Confira o fingerprint** da chave importada nas propriedades do certificado: tem de ser **`916B8D99…2EEACCDA`**.
4. **Verifique a imagem:** Kleopatra → **Decrypt/Verify** → selecione `Whonix-*.ova.asc` (com o `.ova` na mesma pasta).

# OK se: o Kleopatra mostra assinatura VÁLIDA emitida pela chave de fingerprint 916B8D99…2EEACCDA.

> O Kleopatra **não** exibe a notation anti-adulteração do nome do arquivo (que a CLI mostra com `show-notations`). Por isso, **confira você mesmo** que o nome do `.ova` é exatamente o da página de Download. Para o mesmo sinal da CLI, use o gpg do Gpg4win no PATH (abaixo).
>
> Alternativa por terminal (PowerShell, se tiver o gpg do Gpg4win no PATH): os **mesmos** comandos da §5.1 funcionam.

### 5.3 macOS (GPGTools / GPG Suite)

1. Instale o **GPG Suite** (https://gpgtools.org).
2. **Importe a chave:** abra `derivative.asc` (GPG Keychain) **ou** `gpg --import derivative.asc` no Terminal.
3. **Confira o fingerprint:** `gpg --fingerprint 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA` (tem de bater).
4. **Verifique a imagem** (Terminal):
   ```bash
   gpg --verify-options show-notations --verify Whonix-*.ova.asc Whonix-*.ova
   ```

# OK se: `gpg: Good signature` com o fingerprint 916B8D99…2EEACCDA.

> Passos oficiais detalhados por SO: **§8 (Links)** → "Verify the images".

### 5.4 EXPKEYSIG (chave Whonix expirada no keyring)

Se `gpg --verify` mostrar **`EXPKEYSIG`** ou assinatura inválida com chave antiga:

```bash
curl -fsSL https://www.whonix.org/keys/derivative.asc -o derivative.asc
gpg --import derivative.asc
gpg --fingerprint 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA
# Reexecute a verificação da imagem (§5.1 / §5.2 / §5.3)
```

O fingerprint **`916B8D99…2EEACCDA` não mudou** após a re-certificação (jan/2026) — só o keyring local estava desatualizado.

---

## 6. Primeiro boot — atualizar e snapshot

- **Atualize** Gateway **e** Workstation no 1º boot, **via Tor**:
  ```bash
  sudo apt update && sudo apt full-upgrade
  ```
- **Tire um snapshot** de cada VM (VirtualBox: *Snapshots*; KVM: `virsh snapshot-create`) — se algo quebrar, você volta.
- **Não ajuste o relógio manualmente** (o Whonix cuida do tempo via Tor).
- **Workstation = um propósito.** Nada de e-mail real, login pessoal ou redes sociais (Módulo 1, Cap. 9).

# OK se: a atualização completa via Tor sem erro; existe um snapshot inicial; Workstation "limpa" (sem identidade clearnet).

---

## 7. E depois? (custódia frio↔quente)

Com o Whonix pronto e atualizado, volte ao livro (Cap. 4–5) e escolha **uma** trilha de cold-signing:

👉 [`00 — Comece aqui — Escolha sua trilha.md`](00%20—%20Comece%20aqui%20—%20Escolha%20sua%20trilha.md) → **Trilha A (Feather)** ou **Trilha B (CLI)**.

---

## 8. Links oficiais

| Tema | Link |
|------|------|
| Download | https://www.whonix.org/wiki/Download |
| **Verificar a imagem** (por SO) | https://www.whonix.org/wiki/Verify_the_images |
| Chave de assinatura (`916B8D99…2EEACCDA`) | https://www.whonix.org/keys/derivative.asc · https://www.whonix.org/wiki/Project_Signing_Key |
| VirtualBox (install) | https://www.whonix.org/wiki/VirtualBox |
| KVM (install) | https://www.whonix.org/wiki/KVM |
| Atualização do sistema | https://www.whonix.org/wiki/Operating_System_Software_Updates |

---

## 9. USB passthrough (pendrive frio↔quente e hardware opcional)

Para as **Trilhas A/B**, o pendrive de trânsito precisa ser visível na **Workstation** (e, se usar hardware wallet opcional, o dispositivo USB também).

**VirtualBox:**

1. Instale o **VirtualBox Extension Pack** (mesma versão do VirtualBox).
2. Com a **Whonix-Workstation** desligada: **Settings → USB** → habilite USB 2.0/3.0.
3. Adicione um **filtro USB** para o pendrive (ou dispositivo) — assim a VM captura o device ao plugar.
4. Inicie a Workstation **depois** de plugar o pendrive (ou use o ícone USB na barra para anexar).

**KVM:** anexe o dispositivo via `virt-manager` (*USB redirection*) ou política do host — ver guia oficial se o passthrough falhar.

Fonte: https://www.whonix.org/wiki/VirtualBox · https://www.whonix.org/wiki/KVM

> O pendrive de trânsito **nunca** deve ser usado na máquina online com carteira **completa** — só arquivos de outputs/tx entre frio e quente ([`Playbook — Backup e proteção (air-gap).md`](Playbook%20—%20Backup%20e%20proteção%20(air-gap).md)).

---

## 10. Prints pendentes (manifesto)

Capturas a fazer no host real (ainda **não** incluídas). Lista detalhada com nomes de arquivo:
[`imagens/screenshots-whonix/README.md`](imagens/screenshots-whonix/README.md).

- [ ] `01-vbox-import-appliance.png` — VirtualBox → **File → Import Appliance** com o `.ova` selecionado.
- [ ] `02-kleopatra-good-signature.png` — Kleopatra (**Windows**) → **Decrypt/Verify** + fingerprint válido.
- [ ] `03-linux-good-signature.png` — Terminal (**Linux/macOS**) → `gpg: Good signature` com `916B8D99…2EEACCDA`.
- [ ] `04-vbox-gateway-workstation.png` — VirtualBox com **Gateway + Workstation** importados.
- [ ] `05-gateway-tor-connected.png` — Gateway com **Tor Connection** conectado.

> Mesmo padrão do manifesto de screenshots do Módulo 1: redija/oculte qualquer dado sensível antes de publicar.

---

*Privacy-OS-Hub · Módulo 2 · Instalação por SO. Comandos e fluxo verificados em fonte oficial (jun/2026).
As versões e telas mudam — confirme na página de Download/Verify acima antes de instalar.*
