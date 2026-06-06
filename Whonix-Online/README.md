# Módulo 2 — Whonix Online 🟡 v1 (base)

O **lado em rede** do Privacy-OS-Hub: enquanto o **Tails** (Módulo 1) é o lado **offline / efêmero**
(carteira fria, assinatura air-gapped), o **Whonix** é o lado **online persistente** — duas VMs
(**Gateway** roteia tudo por Tor, **Workstation** é onde você trabalha) para nó, *watch-only* e navegação.

## 👉 Abra o guia — [Curso — Whonix Online.md](Curso%20—%20Whonix%20Online.md)
## 💿 Instalar por SO — [Instalar Whonix — passo a passo por SO.md](Instalar%20Whonix%20—%20passo%20a%20passo%20por%20SO.md)
## 🧭 Antes dos comandos — [00 — Comece aqui — Escolha sua trilha.md](00%20—%20Comece%20aqui%20—%20Escolha%20sua%20trilha.md)
## ⚡ Só comandos (escolha UMA trilha):
- ✅ **Trilha A — Feather (GUI, recomendado):** [`Trilha-A-Feather/Playbook — Feather (GUI).md`](Trilha-A-Feather/Playbook%20—%20Feather%20%28GUI%29.md)
- ⚙️ **Trilha B — `monero-wallet-cli` (avançado):** [`Trilha-B-CLI/Playbook — monero-wallet-cli.md`](Trilha-B-CLI/Playbook%20—%20monero-wallet-cli.md)

Cobre (verificado em fonte oficial): o Whonix e seu **modelo de ameaças** · **instalar e verificar a
imagem** (fingerprint `916B8D99…2EEACCDA`) · Monero/Feather **via Tor** (conectar ao seu nó do home lab) ·
**Cold-Tails-Hot-Whonix** — custódia **frio↔quente** detalhada (criar *view-only*, assinar offline pelo
**Feather** e pelo **`monero-wallet-cli`**) · **§5.6 — hardware wallet (Trezor/Ledger) + Feather**, o
caminho **recomendado para o grosso** · onde o **Haveno** entra (frio→quente) · quando usar Whonix × Tails × home lab.

> **Pré-requisito:** [Módulo 1 (Tails + Haveno)](../Tails%20OS%20Expert/README.md) concluído.
> **Status:** v1 (aprofundado) + **Playbooks por trilha** (Feather/CLI) + **instalação por SO**. Pendente: **prints** (capturas de tela).
> Os comandos exatos de assinatura offline mudam por versão — confirme sempre nas fontes oficiais
> **antes de mover dinheiro real**, e **comece com valores mínimos**.

---

*Privacy-OS-Hub · Módulo 2. Módulo 1 pronto: [`../Tails OS Expert/`](../Tails%20OS%20Expert/README.md).*
