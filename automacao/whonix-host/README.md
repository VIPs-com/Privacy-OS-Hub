# Scripts — Whonix Online (host Linux)

> **Novato?** Seção Whonix em [**MANUAL.md**](../../docs/MANUAL.md#whonix-host-linux--não-é-no-tails).

> **Rode no host** (Debian/Ubuntu etc.) — **não** no Tails e **não** dentro das VMs.

| Script | Passo hub | Função |
|--------|-----------|--------|
| [`whonix-install-virtualbox.sh`](whonix-install-virtualbox.sh) | **10** (prep) | Oracle VirtualBox + GPG + DKMS (+ Extension Pack com `-e`) |
| [`whonix-verify-image.sh`](whonix-verify-image.sh) | **10** | PGP da imagem `.ova` ou `.libvirt.xz` (só verificação) |
| [`whonix-import-ova.sh`](whonix-import-ova.sh) | **10** | Verify + `VBoxManage import` (+ boot opcional `-b`) |
| [`whonix-verificar-tor.sh`](whonix-verificar-tor.sh) | **10** (pós-boot) | `systemcheck` + check.torproject.org na Workstation |

**Ainda manual:** Anon Connection Wizard, cold-signing (passos 11–12).

### Fluxo recomendado (Linux)

```bash
cd automacao/whonix-host
chmod +x whonix-install-virtualbox.sh whonix-verify-image.sh whonix-import-ova.sh whonix-verificar-tor.sh

# 1) VirtualBox verificado
sudo ./whonix-install-virtualbox.sh -e -y

# 2a) Só verificar PGP (evidência QA)
./whonix-verify-image.sh --qa-log /caminho/Whonix-*.ova /caminho/Whonix-*.ova.asc

# 2b) Verificar + importar (fingerprint Hub padrão; override com -f)
sudo ./whonix-import-ova.sh -i /caminho/Whonix-*.ova -s /caminho/Whonix-*.ova.asc --qa-log -b
```

Validação: [COMO-LER-SEUS-LOGS.md](../docs-aluno/COMO-LER-SEUS-LOGS.md) (tabela passo 10).

*Módulo 2 · Privacy-OS-Hub*
