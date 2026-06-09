---
passo_hub: 10
trilha: m2-quente
rede: host_linux
scripts: [whonix-verify-image.sh]
livro: modulos/m2-whonix-custodia/Instalar-Whonix-passo-a-passo-por-SO.md
playbook_legacy: modulos/m2-whonix-custodia/Playbooks/Playbooks.md
---

# P10 — Whonix PGP + import VMs

**Cartão:** [passo-10](../../trilha/passos/passo-10.md) · **Livro:** [Instalar por SO](../../modulos/m2-whonix-custodia/Instalar-Whonix-passo-a-passo-por-SO.md)

**Host Linux (atalho):** [whonix-verify-image.sh](../../automacao/whonix-host/whonix-verify-image.sh)

```bash
./whonix-verify-image.sh --qa-log Whonix-*.ova Whonix-*.ova.asc
```

---

## §1 — Verificar imagem Whonix

**VirtualBox** (`.ova`):

```bash
gpg --import derivative.asc
gpg --fingerprint 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA
gpg --verify-options show-notations --verify Whonix-*.ova.asc Whonix-*.ova
# OK se: Good signature + fingerprint 916B8D99…2EEACCDA
```

**KVM** (`.libvirt.xz`):

```bash
gpg --verify-options show-notations --verify Whonix-*.libvirt.xz.asc Whonix-*.libvirt.xz
```

Windows (Kleopatra) / macOS: [Instalar por SO §5](../../modulos/m2-whonix-custodia/Instalar-Whonix-passo-a-passo-por-SO.md).

```bash
# EXPKEYSIG (chave expirada no keyring antigo):
curl -fsSL https://www.whonix.org/keys/derivative.asc -o derivative.asc
gpg --import derivative.asc
```

---

## §2 — Primeiro boot + snapshot

```bash
# Dentro de Gateway E Workstation (via Tor):
sudo apt update && sudo apt full-upgrade
# VirtualBox: Snapshots -> tirar snapshot inicial de cada VM
# KVM: virsh snapshot-create <nome-vm>
```

**OK se:** `Good signature` / Assinatura válida · Gateway + Workstation importadas e atualizadas.
