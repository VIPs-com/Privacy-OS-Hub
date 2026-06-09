---
passo_hub: 8
trilha: porteiro
rede: leitura
scripts: []
livro: modulos/m2-whonix-custodia/00-Comece-aqui-Escolha-sua-trilha.md
---

# P08 — Porteiro · escolher trilha A ou B

**Cartão:** [passo-08](../../trilha/passos/passo-08.md) · **Livro:** [Curso Whonix Cap. 5](../../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix)

Você vai montar **custódia frio↔quente**: seed **só no Tails offline**; Whonix **view-only**. Escolha **UMA** trilha e siga **só ela**.

---

## Qual trilha é a sua?

```text
                  ┌─────────────────────────────────────────────┐
                  │   Mesma custódia frio↔quente, MESMO resultado │
                  └─────────────────────────────────────────────┘
                                      │
              ┌───────────────────────┴───────────────────────┐
              ▼                                                 ▼
   ┌────────────────────────┐                      ┌────────────────────────┐
   │  TRILHA A — FEATHER     │   ✅ recomendado     │  TRILHA B — CLI          │
   │  (interface / cliques)  │                      │  (monero-wallet-cli)     │
   └────────────────────────┘                      └────────────────────────┘
```

| | **Trilha A** | **Trilha B** |
|---|---|---|
| Como opera | GUI (cliques) | Terminal |
| **Para quem** | **Maioria** (recomendado) | Avançado / auditoria |
| **Processo** | [P12A](../m2-frio/P12a-feather-offline.md) | [P12B](../m2-frio/P12b-cli-offline.md) |

> **NÃO misture as trilhas.** Na dúvida: **Trilha A**.

---

## Pré-requisitos (DUAS trilhas)

- [ ] [Playbook backup](../../modulos/m2-whonix-custodia/Playbook-Backup-e-protecao-air-gap.md) — 2× seed offline
- [ ] M1 concluído — Haveno verde, PGP, [Feather P05](../m1-tor/P05-feather.md)
- [ ] Whonix verificado — [P10](../m2-quente/P10-whonix-pgp.md)
- [ ] Pendrive dedicado frio↔quente
- [ ] Em mãos: endereço primário (`4…`), **view key**, **restore height**

Mapa completo: [00-Comece-aqui](../../modulos/m2-whonix-custodia/00-Comece-aqui-Escolha-sua-trilha.md)

---

## OK se

- Escolheu **uma** trilha: P12A ou P12B
- Pré-requisitos acima marcados
