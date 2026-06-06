# Módulo 2 — Whonix Online 🟡 v1 (base)

O **lado em rede** do Privacy-OS-Hub: enquanto o **Tails** (Módulo 1) é o lado **offline / efêmero**
(carteira fria, assinatura air-gapped), o **Whonix** é o lado **online persistente** — duas VMs
(**Gateway** roteia tudo por Tor, **Workstation** é onde você trabalha) para nó, *watch-only* e navegação.

## 👉 Abra o guia — [Curso — Whonix Online.md](Curso%20—%20Whonix%20Online.md)

Cobre (verificado em fonte oficial): o Whonix e seu **modelo de ameaças** · **instalar e verificar a
imagem** (fingerprint `916B8D99…2EEACCDA`) · Monero/Feather **via Tor** (conectar ao seu nó do home lab) ·
**Cold-Tails-Hot-Whonix** — custódia **frio↔quente** detalhada (criar *view-only*, assinar offline pelo
**Feather** e pelo **`monero-wallet-cli`**, com o aviso honesto sobre **carteira de hardware**) · onde o
**Haveno** entra (frio→quente) · quando usar Whonix × Tails × home lab.

> **Pré-requisito:** [Módulo 1 (Tails + Haveno)](../Tails%20OS%20Expert/README.md) concluído.
> **Status:** v1 (aprofundado). Faltam ainda: passo a passo **por SO** (prints) e um **Playbook** de
> comandos só. Os comandos exatos de assinatura offline mudam por versão — confirme sempre nas fontes
> oficiais do guia **antes de mover dinheiro real**, e **comece com valores mínimos**.

---

*Privacy-OS-Hub · Módulo 2. Módulo 1 pronto: [`../Tails OS Expert/`](../Tails%20OS%20Expert/README.md).*
