# Playbooks — Whonix Online (só comandos)

**Teoria:** [`Curso — Whonix Online.md`](../Curso%20—%20Whonix%20Online.md) · **Instalação detalhada:** [`Instalar Whonix — passo a passo por SO.md`](../Instalar%20Whonix%20—%20passo%20a%20passo%20por%20SO.md)

**Pré-requisito:** [Módulo 1 (Tails + Haveno)](../../Tails%20OS%20Expert/README.md) concluído.

---

## §1 — Verificar imagem Whonix (resumo Linux)

```bash
gpg --import derivative.asc
gpg --fingerprint 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA
gpg --verify-options show-notations --verify Whonix-*.ova.asc Whonix-*.ova
# OK se: Good signature + fingerprint 916B8D99…2EEACCDA
```

Windows (Kleopatra) / macOS: ver [`Instalar Whonix — passo a passo por SO.md`](../Instalar%20Whonix%20—%20passo%20a%20passo%20por%20SO.md) §5.

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

```text
Porteiro:     00 — Comece aqui — Escolha sua trilha.md
Trilha A:     Trilha-A-Feather/Playbook — Feather (GUI).md
Trilha B:     Trilha-B-CLI/Playbook — monero-wallet-cli.md
```

---

## §5 — Backup air-gap (sem hardware wallet)

```text
Playbook — Backup e proteção (air-gap).md
# DUAS cópias seed offline + teste restauração + pendrive dedicado
```

---

## §6 — Troubleshooting rápido

| Problema | Ação |
|----------|------|
| Gateway sem Tor | Aguarde; reinicie Gateway; confira relógio do host |
| `EXPKEYSIG` na verificação | Reimporte `derivative.asc` (§1) |
| VirtualBox: VM não inicia | VT-x/AMD-V na BIOS; desative Hyper-V (Windows) |
| USB não visto na Workstation | Extension Pack + filtro USB (Instalar §9) |
| Workstation "sem internet" | Normal se Gateway não conectou ao Tor |

Detalhe: [`Instalar Whonix — passo a passo por SO.md`](../Instalar%20Whonix%20—%20passo%20a%20passo%20por%20SO.md) §3.4, §4.1.

---

## Links

```text
Livro M2           Curso — Whonix Online.md
Install por SO     Instalar Whonix — passo a passo por SO.md
Backup air-gap     Playbook — Backup e proteção (air-gap).md
HW opcional        Curso — Whonix Online.md §5.6
Verify images      https://www.whonix.org/wiki/Verify_the_images
```

*Playbooks Módulo 2 · Privacy-OS-Hub. Confirme nas fontes oficiais antes de mover dinheiro real.*
