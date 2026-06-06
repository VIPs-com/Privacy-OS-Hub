# Instalar o Whonix — passo a passo por SO (VirtualBox / KVM)

Guia prático de **instalação e verificação da imagem**, separado pelo **seu sistema (host)**. Complementa o livro [`Curso — Whonix Online.md`](Curso%20—%20Whonix%20Online.md) (Cap. 2), que explica o *porquê* (modelo de ameaças, Gateway × Workstation).

> 🔒 **Disciplina inegociável:** **baixe → verifique → só então importe**. Imagem **não verificada = não importe**. Mesmo rigor PGP do Módulo 1.
>
> 🖼️ **Prints:** as capturas de tela deste guia estão **pendentes** (ver [§9 — manifesto](#9-prints-pendentes-manifesto)). Os passos textuais já são suficientes para concluir.

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

## 9. Prints pendentes (manifesto)

Capturas a fazer no host real (ainda **não** incluídas):

- [ ] VirtualBox → **File → Import Appliance** com o `.ova` selecionado.
- [ ] Kleopatra (**Windows**) → resultado de **Decrypt/Verify** mostrando assinatura válida + fingerprint.
- [ ] Terminal (**Linux/macOS**) → saída `gpg: Good signature` com o fingerprint `916B8D99…2EEACCDA`.
- [ ] VirtualBox com **Gateway + Workstation** importados (lista de VMs).
- [ ] Gateway conectado ao **Tor** (Tor Connection).

> Mesmo padrão do manifesto de screenshots do Módulo 1: redija/oculte qualquer dado sensível antes de publicar.

---

*Privacy-OS-Hub · Módulo 2 · Instalação por SO. Comandos e fluxo verificados em fonte oficial (jun/2026).
As versões e telas mudam — confirme na página de Download/Verify acima antes de instalar.*
