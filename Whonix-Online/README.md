# Módulo 2 — Whonix (online) 🛠️ em construção

> **Status: esqueleto / roadmap.** Este módulo ainda está sendo escrito. O que está aqui é o **plano**
> (arquitetura + sumário), **não** um passo a passo completo. Até a versão final, siga as **fontes
> oficiais** linkadas no fim. O **Módulo 1 (Tails + Haveno) está pronto**:
> [`../Tails OS Expert/`](../Tails%20OS%20Expert/README.md).

## Por que Whonix — e o par com o Tails

O **Tails** é **amnésico**, ideal para o lado **offline / efêmero**: gerar e custodiar a **carteira
fria** e assinar transações *air-gapped*. O **Whonix** é o lado **online persistente** — duas VMs:
**Gateway** (roteia **tudo** por Tor) e **Workstation** (onde você trabalha) — para o que precisa
ficar **ligado e em rede**.

```text
Tails (offline)  ──gera / custodia / assina──►   carteira FRIA (air-gapped)
       ▲                                              │
       │  key images / transação assinada             ▼
Whonix (online)  ──nó Monero · watch-only · navegação (via Tor)──►  rede
```

> Lembrete do Módulo 1: o **trade no Haveno é quente** (o escrow multisig exige o cliente online com a
> carteira). O split frio/quente brilha na **custódia**; o trade roda no lado **online**.

## Sumário planejado

1. O que é Whonix (Gateway × Workstation) e modelo de ameaças
2. Instalar Whonix (host: VirtualBox / KVM / Qubes-Whonix) — com verificação da imagem
3. Persistência e atualizações (modelo diferente do Tails)
4. Nó Monero no Whonix **ou** conectar ao nó do home lab (Módulo 1, Cap. 6) via Tor
5. **Feather watch-only** no Whonix ligado à carteira fria gerada no Tails
6. Fluxo frio ↔ quente: gerar no Tails → *watch-only* no Whonix → **assinar no Tails**
7. Navegação e higiene de privacidade (Tor Browser no Whonix)
8. Tabela de decisão: quando usar **Whonix × Tails × home lab**

## Pré-requisitos (previstos)

- Host com virtualização (≥ 8 GB RAM recomendado), VirtualBox ou KVM.
- **Módulo 1 concluído** (entender seed, carteira, escrow, verificação de binários).
- Conforto com máquinas virtuais.

## Fontes oficiais (use até este módulo ficar pronto)

- Whonix: https://www.whonix.org/ · Documentação: https://www.whonix.org/wiki/Documentation
- Download + verificação: https://www.whonix.org/wiki/Download
- Monero no Whonix: https://www.whonix.org/wiki/Monero
- Feather (Tor): https://docs.featherwallet.org/guides/tor-support
- Guias do Monero (inclui *cold storage* / carteira offline): https://www.getmonero.org/resources/user-guides/

---

*Privacy-OS-Hub · Módulo 2 (roadmap). Módulo 1 pronto: [`../Tails OS Expert/`](../Tails%20OS%20Expert/README.md).*
