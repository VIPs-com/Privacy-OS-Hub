# Scripts — Whonix Online (host Linux)

> **Rode no host** (Debian/Ubuntu etc.) — **não** no Tails e **não** dentro das VMs.

| Script | Passo hub | Função |
|--------|-----------|--------|
| [`whonix-verify-image.sh`](whonix-verify-image.sh) | **10** | PGP da imagem `.ova` ou `.libvirt.xz` |

**Ainda manual:** importar VM (VirtualBox/KVM), Kleopatra no Windows/macOS, USB passthrough, cold-signing (passos 9/12).

```bash
chmod +x whonix-verify-image.sh
./whonix-verify-image.sh /caminho/Whonix-*.ova /caminho/Whonix-*.ova.asc
./whonix-verify-image.sh --kvm Whonix-*.libvirt.xz Whonix-*.libvirt.xz.asc
```

*Módulo 2 · Privacy-OS-Hub*
