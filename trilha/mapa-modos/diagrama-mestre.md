# Diagrama mestre — modos do hub (FIG-1)

> **Figura canônica** — outras páginas devem **linkar** aqui, não redesenhar com nomes diferentes.

---

## Visão por módulo e rede

```mermaid
flowchart TB
  subgraph M1["Módulo 1 — Tails + Haveno (passos 1–7)"]
    direction TB
    P1["1–4: USB · Tor · persistência · admin"]
    P2["2: Haveno → verde"]
    P5["5: Feather install + carteira"]
    P7["7: scripts --boot"]
    P1 --> P2 --> P5 --> P7
  end

  subgraph RITUAL["Rituais (passos 8–9)"]
    P8["8: escolher Trilha A ou B"]
    P9["9: 2× cópias físicas seed"]
    P8 --> P9
  end

  subgraph M2H["Módulo 2 — Whonix QUENTE (passos 10–11)"]
    P10["10: PGP + import VMs (host)"]
    P11["11: teoria view-only"]
    P10 --> P11
  end

  subgraph M2F["Módulo 2 — Tails FRIO (passo 12)"]
    P12A["12A: Feather GUI offline"]
    P12B["12B: monero-wallet-cli offline"]
  end

  M1 --> RITUAL --> M2H --> M2F

  subgraph OPT["Opcional — outro PC"]
    HL["Home Lab 00–04"]
  end

  M1 -.-> HL
```

---

## Tabela rede × passo

| Passo | Onde roda | Rede | Ferramenta principal |
|:-----:|-----------|------|----------------------|
| 1–7 | Tails | **Tor** | Haveno · Feather |
| 8 | Leitura | — | Decisão A/B |
| 9 | Tails | **Tor** (OK) | Ritual papel |
| 10 | **Host** Linux | Internet | `whonix-verify-image.sh` |
| 11 | Leitura | — | Curso M2 §5 |
| 12 | Tails | **Sem rede** | Feather **ou** CLI |

---

## O que cruza por USB (passo 12)

```text
  TAILS offline (FRIO)              WHONIX online (QUENTE)
  carteira COMPLETA                 view-only
        │  outputs / tx unsigned ──────►│
        │◄──── tx signed ─────────────────│
   ASSINA aqui                    TRANSMITE via Tor
```

Detalhe: [Trilha A](../../modulos/m2-whonix-custodia/Trilha-A-Feather/Playbook-Feather-GUI.md) · [Trilha B](../../modulos/m2-whonix-custodia/Trilha-B-CLI/Playbook-monero-wallet-cli.md)

---

## Links

- [Glossário](glossario.md)
- [Cartões por passo](../passos/README.md)
- [Trilhas por modo](../trilhas/README.md)

---

*FIG-1 · trilha/mapa-modos · jun/2026*
