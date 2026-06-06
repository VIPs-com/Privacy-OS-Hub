# Playbooks — Whonix Online (só comandos)

**Teoria:** [`Curso-Whonix-Online.md`](../Curso-Whonix-Online.md) · **Instalação detalhada:** [`Instalar-Whonix-passo-a-passo-por-SO.md`](../Instalar-Whonix-passo-a-passo-por-SO.md)

**Pré-requisito:** [Módulo 1 (Tails + Haveno)](../../Tails-OS-Expert/README.md) concluído.

---

## §1 — Verificar imagem Whonix (resumo)

**Host Linux (atalho):** [`Scripts/whonix-verify-image.sh`](../Scripts/whonix-verify-image.sh)

**VirtualBox** (`.ova`):

```bash
gpg --import derivative.asc
gpg --fingerprint 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA
gpg --verify-options show-notations --verify Whonix-*.ova.asc Whonix-*.ova
# OK se: Good signature + fingerprint 916B8D99…2EEACCDA
```

**KVM** (`.libvirt.xz` — troque a extensão nos comandos acima):

```bash
gpg --verify-options show-notations --verify Whonix-*.libvirt.xz.asc Whonix-*.libvirt.xz
```

Windows (Kleopatra) / macOS: ver [`Instalar-Whonix-passo-a-passo-por-SO.md`](../Instalar-Whonix-passo-a-passo-por-SO.md) §5.

```bash
# EXPKEYSIG (chave expirada no keyring antigo):
curl -fsSL https://www.whonix.org/keys/derivative.asc -o derivative.asc
gpg --import derivative.asc
# Fingerprint NÃO mudou após re-certificação (jan/2026)
```

---

## §2 — Primeiro boot + snapshot

```bash
# Dentro de Gateway E Workstation (via Tor):
sudo apt update && sudo apt full-upgrade
# VirtualBox: Snapshots -> tirar snapshot inicial de cada VM
# KVM: virsh snapshot-create <nome-vm>
```

---

## §3 — Feather no Whonix (PGP + nó Tor)

```bash
# Baixar Feather do site oficial; verificar PGP (fingerprint Módulo 1):
# 8185E158A33330C7FD61BC0D1F76E155CEFBA71C

# Conectar ao seu nó Monero via Tor (exemplo):
# Settings -> Node -> Remote node: SEU_NO.onion:18089
```

Doc: https://docs.featherwallet.org/guides/tor-support

---

## §4 — Cold-signing (escolha UMA trilha)

**Passo hub 8** — escolha A ou B aqui; comandos cold-signing nos playbooks das trilhas.

```text
Porteiro:     00-Comece-aqui-Escolha-sua-trilha.md
Trilha A:     Trilha-A-Feather/Playbook-Feather-GUI.md
Trilha B:     Trilha-B-CLI/Playbook-monero-wallet-cli.md
```

---

## §5 — Backup air-gap (sem hardware wallet)

**Passo hub 9** — [`Playbook-Backup-e-protecao-air-gap.md`](../Playbook-Backup-e-protecao-air-gap.md)

```text
# DUAS cópias seed offline + teste restauração + pendrive dedicado
```

---

## §6 — Travou aqui? (troubleshooting)

| Sintoma | O que fazer | Onde |
|---------|-------------|------|
| Gateway sem Tor | Aguarde; reinicie Gateway; confira relógio do host | Curso Cap. 3 |
| `EXPKEYSIG` na verificação | Reimporte `derivative.asc` (§1) | Instalar §5.4 |
| VirtualBox: VM não inicia | VT-x/AMD-V na BIOS; desative Hyper-V (Windows) | Instalar §3.4 |
| KVM: redes ausentes | Reimporte conforme guia oficial KVM | Instalar §4.1 |
| USB não visto na Workstation | Extension Pack + filtro USB | Instalar §9 |
| Workstation "sem internet" | Normal se Gateway não conectou ao Tor | Curso Cap. 3 |
| Sem nó `.onion` próprio | Use nó remoto confiável | Curso Cap. 4.2 |
| Pré-requisitos incompletos | Volte ao porteiro `00` | `00-Comece-aqui-Escolha-sua-trilha.md` |

Detalhe: [`Instalar-Whonix-passo-a-passo-por-SO.md`](../Instalar-Whonix-passo-a-passo-por-SO.md) §3.4, §4.1, §5.4.

---

## Links

```text
Livro M2           Curso-Whonix-Online.md
Install por SO     Instalar-Whonix-passo-a-passo-por-SO.md
Backup air-gap     Playbook-Backup-e-protecao-air-gap.md
HW opcional        Curso-Whonix-Online.md §5.6
Verify images      https://www.whonix.org/wiki/Verify_the_images
```

*Playbooks Módulo 2 · Privacy-OS-Hub. Confirme nas fontes oficiais antes de mover dinheiro real.*
