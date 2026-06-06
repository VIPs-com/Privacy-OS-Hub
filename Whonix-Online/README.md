# Módulo 2 — Whonix Online 🟡 v1 (base)

O **lado em rede** do Privacy-OS-Hub: enquanto o **Tails** (Módulo 1) é o lado **offline / efêmero**
(carteira fria, assinatura air-gapped), o **Whonix** é o lado **online persistente** — duas VMs
(**Gateway** roteia tudo por Tor, **Workstation** é onde você trabalha) para nó, *watch-only* e navegação.

## 🧭 Trilha do aluno — siga nesta ordem

> **Pré-requisito:** [Módulo 1 (Tails + Haveno)](../Tails-OS-Expert/README.md) concluído — Haveno verde + Feather no Tails.

| Passo | O que fazer | Abrir |
|:-----:|-------------|-------|
| **0** | Mapa de decisão + pré-requisitos | 🧭 [**00-Comece-aqui-Escolha-sua-trilha.md**](00-Comece-aqui-Escolha-sua-trilha.md) |
| **1** | Backup air-gap (DUAS cópias da seed) | 🔒 [Playbook-Backup-e-protecao-air-gap.md](Playbook-Backup-e-protecao-air-gap.md) |
| **2** | Instalar e verificar Whonix (PGP) | 💿 [Instalar-Whonix-passo-a-passo-por-SO.md](Instalar-Whonix-passo-a-passo-por-SO.md) |
| **3** | Teoria: modelo de ameaças, nó, cold-signing | 📖 [Curso-Whonix-Online.md](Curso-Whonix-Online.md) |
| **4** | **Escolha UMA trilha** (não misture A e B) | ver abaixo ↓ |
| **5** | Comandos consolidados + **Travou aqui?** | ⚡ [Playbooks/Playbooks.md](Playbooks/Playbooks.md) |

### Passo 4 — Cold-signing (escolha UMA trilha)

| Trilha | Para quem | Abrir |
|--------|-----------|-------|
| ✅ **A — Feather (GUI)** | **Maioria** — interface, cliques | [Trilha-A-Feather/Playbook-Feather-GUI.md](Trilha-A-Feather/Playbook-Feather-GUI.md) |
| ⚙️ **B — `monero-wallet-cli`** | Avançado — terminal, auditoria | [Trilha-B-CLI/Playbook-monero-wallet-cli.md](Trilha-B-CLI/Playbook-monero-wallet-cli.md) |

Cobre (verificado em fonte oficial): o Whonix e seu **modelo de ameaças** · **instalar e verificar a
imagem** (fingerprint `916B8D99…2EEACCDA`) · Monero/Feather **via Tor** (conectar ao seu nó do home lab) ·
**Cold-Tails-Hot-Whonix** — custódia **frio↔quente** (trilha principal, **baixo custo**, sem hardware
proprietário obrigatório): *view-only*, assinar offline pelo **Feather** (Trilha A) ou **`monero-wallet-cli`**
(Trilha B) · [`Playbook-Backup-e-protecao-air-gap.md`](Playbook-Backup-e-protecao-air-gap.md) ·
§5.6 hardware wallet **opcional** (Trezor/Ledger) · Haveno (frio→quente) · quando usar Whonix × Tails × home lab.

> **Sem nó `.onion` próprio?** Use nó remoto confiável — [Curso Cap. 4.2](Curso-Whonix-Online.md#42-alternativa--nó-remoto-público-onion).
> **Status:** auditado **rodada 15** — v1 completo + anti-travamento (`00`, Playbooks §6, install §3.4/§5.4).
> **Prints pendentes** (PI-1): mitigados por texto em [`imagens/screenshots-whonix/README.md`](imagens/screenshots-whonix/README.md) — "enquanto não há print, o aluno deve ver…".
> Os comandos exatos de assinatura offline mudam por versão — confirme sempre nas fontes oficiais
> **antes de mover dinheiro real**, e **comece com valores mínimos**.

---

*Privacy-OS-Hub · Módulo 2. Módulo 1 pronto: [`../Tails-OS-Expert/`](../Tails-OS-Expert/README.md).*
