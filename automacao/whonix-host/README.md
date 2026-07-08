# Scripts — Whonix Online (host Linux)

> **Novato?** Seção Whonix em [**MANUAL.md**](../../docs/MANUAL.md#whonix-host-linux--não-é-no-tails).

> **Rode no host** (Debian/Ubuntu etc.) — **não** no Tails e **não** dentro das VMs.

| Script | Passo hub | Função |
|--------|-----------|--------|
| [`whonix-install-virtualbox.sh`](whonix-install-virtualbox.sh) | **10** (prep) | Oracle VirtualBox + GPG + DKMS + Extension Pack (padrão) + MOK se Secure Boot |
| [`whonix-verify-image.sh`](whonix-verify-image.sh) | **10** | PGP da imagem `.ova` ou `.libvirt.xz` (só verificação) |
| [`whonix-import-ova.sh`](whonix-import-ova.sh) | **10** | Verify + `VBoxManage import` (+ boot opcional `-b`) |
| [`whonix-verificar-tor.sh`](whonix-verificar-tor.sh) | **10** (pós-boot) | `systemcheck` + check.torproject.org na Workstation |

**Ainda manual:** Anon Connection Wizard, cold-signing (passos 11–12).

### Fluxo recomendado (Linux)

```bash
cd automacao/whonix-host
chmod +x whonix-install-virtualbox.sh whonix-verify-image.sh whonix-import-ova.sh whonix-verificar-tor.sh

# 1) VirtualBox verificado (Debian 13/trixie; Extension Pack incluso; MOK auto se Secure Boot)
sudo ./whonix-install-virtualbox.sh -y
# exit 2 = pacote OK, falta reboot + Enroll MOK na tela azul → rode de novo após reboot

# 2a) Só verificar PGP (evidência QA)
./whonix-verify-image.sh --qa-log /caminho/Whonix-*.ova /caminho/Whonix-*.ova.asc

# 2b) Verificar + importar (fingerprint Hub padrão; override com -f)
sudo ./whonix-import-ova.sh -i /caminho/Whonix-*.ova -s /caminho/Whonix-*.ova.asc --qa-log -b
```

### Notas (jul/2026)

- **PGP fail-closed:** `whonix-verify-image.sh` e `whonix-import-ova.sh` usam `VALIDSIG` + fingerprint — não dependem de `Good signature` / locale PT-BR.
- **`whonix-verificar-tor.sh`:** copie para a Workstation com finais de linha **LF** (Unix). CRLF (`\r\n`) quebra o shebang no Linux (`bad interpreter`). O repositório força `*.sh eol=lf` via `.gitattributes`.
- **`whonix-install-virtualbox.sh`:** Extension Pack **ligado por padrão** (`--no-extpack` para pular). Com **Secure Boot ON**: gera chave MOK, `mokutil --import`, assina módulos após enroll — **tela azul no reboot é manual**. Exit `0` = VMs podem ligar; exit `2` = falta reboot MOK (não é erro fatal). Log: `RESULTADO:` em `/var/log/virtualbox-install.log`.
- **`whonix-install-virtualbox.sh`:** se uma execução **anterior** deixou `/etc/apt/sources.list.d/virtualbox.list` corrompido, o script remove antes do primeiro `apt-get update`.
- **Debian 13 (trixie):** se `whonix-install-virtualbox.sh` falhar com módulos vbox, verifique conflito KVM + Secure Boot no log `/var/log/virtualbox-install.log`.

Validação: [COMO-LER-SEUS-LOGS.md](../docs-aluno/COMO-LER-SEUS-LOGS.md) (tabela passo 10).

*Módulo 2 · Privacy-OS-Hub · atualizado jul/2026*
