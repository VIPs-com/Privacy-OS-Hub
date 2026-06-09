# Scripts — Whonix Online (host Linux)

> **Novato?** Seção Whonix em [**MANUAL-SCRIPTS.md**](../../MANUAL-SCRIPTS.md).

> **Rode no host** (Debian/Ubuntu etc.) — **não** no Tails e **não** dentro das VMs.

| Script | Passo hub | Função |
|--------|-----------|--------|
| [`whonix-verify-image.sh`](whonix-verify-image.sh) | **10** | PGP da imagem `.ova` ou `.libvirt.xz` |

**Ainda manual:** importar VM (VirtualBox/KVM), Kleopatra no Windows/macOS, USB passthrough, cold-signing (passos 9/12).

```bash
chmod +x whonix-verify-image.sh
./whonix-verify-image.sh --qa-log /caminho/Whonix-*.ova /caminho/Whonix-*.ova.asc
./whonix-verify-image.sh --qa-log --kvm Whonix-*.libvirt.xz Whonix-*.libvirt.xz.asc
# Log em: ~/whonix-download/qa-logs/10-whonix-verify-*.txt
```

Validação: [COMO-LER-SEUS-LOGS.md](../../automacao/docs-aluno/COMO-LER-SEUS-LOGS.md) (tabela passo 10).

*Módulo 2 · Privacy-OS-Hub*
