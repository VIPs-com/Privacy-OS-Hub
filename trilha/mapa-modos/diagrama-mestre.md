# Diagrama mestre — modos do hub (FIG-1)

> **Figura canônica** — outras páginas devem **linkar** aqui, não redesenhar com nomes diferentes.  
> **v2:** cartões → [passos/](../passos/README.md) · comandos → [processos/](../../processos/README.md) · livros → [modulos/](../../modulos/m1-tails-haveno/README.md).

---

## Trilha completa 1–12 (P01–P12)

```mermaid
flowchart TB
  subgraph M1["Modulo 1 — passos 1–7 · Tails + Tor"]
    direction TB
    N1["1 · P01 USB Tor persistencia"]
    N2["2 · P02 Haveno verde"]
    N3["3 · P03 seguranca pre-trade"]
    N4["4 · P04 backup seed papel"]
    N5["5 · P05 Feather"]
    N6["6 · P06 folheto"]
    N7["7 · P07 rotina scripts"]
    N1 --> N2 --> N3 --> N4 --> N5 --> N6 --> N7
  end

  subgraph P89["Passos 8–9 · porteiro + ritual"]
    N8["8 · P08 escolher trilha A ou B"]
    N9["9 · P09 2x copias seed Tor OK"]
    N8 --> N9
  end

  subgraph M2Q["Modulo 2 quente — passos 10–11 · host"]
    N10["10 · P10 Whonix PGP"]
    N11["11 · P11 modelo frio quente"]
    N10 --> N11
  end

  subgraph M2F["Modulo 2 frio — passo 12 · sem rede"]
    N12A["12A · P12A Feather offline"]
    N12B["12B · P12B CLI offline"]
  end

  M1 --> P89 --> M2Q --> M2F

  subgraph OPT["Opcional — outro PC"]
    HL["Home Lab automacao/homelab"]
  end

  N5 -.-> HL
```

---

## Visão por módulo e rede (compacta)

```mermaid
flowchart TB
  subgraph Tor["Tails com Tor — passos 1 a 9"]
    T17["1–7 M1 Haveno Feather scripts"]
    T8["8 decisao A/B"]
    T9["9 ritual seed"]
    T17 --> T8 --> T9
  end

  subgraph Host["Host Linux — passo 10"]
    H10["PGP Whonix verify"]
  end

  subgraph Leitura["Leitura — passo 11"]
    H11["Curso M2 cap 5"]
  end

  subgraph Airgap["Tails sem rede — passo 12"]
    H12["Cold-signing A ou B"]
  end

  Tor --> Host --> Leitura --> Airgap
```

---

## Tabela rede × passo

| Passo | Processo | Onde roda | Rede | Ferramenta principal |
|:-----:|:--------:|-----------|------|----------------------|
| 1 | P01 | Tails | **Tor** | USB · persistência |
| 2 | P02 | Tails | **Tor** | Haveno → verde |
| 3 | P03 | Tails | **Tor** | Leitura Cap. 4 |
| 4 | P04 | Tails | **Tor** | Backup · seed papel |
| 5 | P05 | Tails | **Tor** | Feather |
| 6 | P06 | — | — | Folheto |
| 7 | P07 | Tails | **Tor** | Scripts `automacao/tails/` |
| 8 | P08 | Leitura | Tor OK | Escolha trilha A/B |
| 9 | P09 | Tails | **Tor** (OK) | Ritual 2× seed |
| 10 | P10 | **Host** | Internet | `whonix-verify-image.sh` |
| 11 | P11 | Leitura | — | Curso M2 §5 |
| 12 | P12A/B | Tails | **Sem rede** | Feather **ou** CLI |

Cartões: [passos/](../passos/README.md) · Comandos: [processos/](../../processos/README.md)

---

<a id="fig-3-usb-frio-quente"></a>

## O que cruza por USB (passo 12) — FIG-3

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

- [Glossário online/offline](glossario.md) — FIG-2
- [Cartões por passo](../passos/README.md)
- [Trilhas por modo](../trilhas/README.md)
- [Arquitetura v2 do repo](../../README.md#como-o-hub-esta-organizado-v2) — FIG-4

---

*FIG-1 · trilha/mapa-modos · v2 · mai/2026*
