# 00 — Porta de entrada — qual trilha é a sua?

> Você **não** precisa ler tudo. Escolha **uma** linha abaixo e siga só ela.

---

## Fluxo principal (quase todo mundo)

```text
  Pendrive vazio
       │
       ▼
  ┌─────────────────────────────────────┐
  │  M1 — Tails + Tor + Haveno          │  passos 1–7
  │  (online via Tor)                   │
  └─────────────────────────────────────┘
       │
       ▼
  ┌─────────────────────────────────────┐
  │  Escolher trilha cold-signing       │  passo 8
  └─────────────────────────────────────┘
       │
       ▼
  ┌─────────────────────────────────────┐
  │  Confirmar 2× seed em papel         │  passo 9 (Tor OK)
  └─────────────────────────────────────┘
       │
       ▼
  ┌─────────────────────────────────────┐
  │  Whonix no host (PGP + VMs)         │  passo 10
  └─────────────────────────────────────┘
       │
       ▼
  ┌─────────────────────────────────────┐
  │  Teoria frio↔quente                 │  passo 11
  └─────────────────────────────────────┘
       │
       ▼
  ┌─────────────────────────────────────┐
  │  Tails SEM rede + assinar           │  passo 12
  │  Trilha A (Feather) ou B (CLI)      │
  └─────────────────────────────────────┘
```

**Mapa completo:** [mapa-modos/diagrama-mestre.md](mapa-modos/diagrama-mestre.md)

---

## Escolha rápida

| Situação | Trilha | Documento |
|----------|--------|-----------|
| Ainda não tenho Tails/Haveno verde | **M1** | [m1-tails-haveno-tor.md](trilhas/m1-tails-haveno-tor.md) |
| Já tenho M1 + Feather; vou instalar Whonix | **M2 quente** | [m2-whonix-quente.md](trilhas/m2-whonix-quente.md) |
| Vou assinar com Feather (recomendado) | **M2 frio A** | [m2-tails-frio-feather-a.md](trilhas/m2-tails-frio-feather-a.md) |
| Prefiro terminal / auditoria | **M2 frio B** | [m2-tails-frio-cli-b.md](trilhas/m2-tails-frio-cli-b.md) |
| Só confirmar cópias da seed | **Passo 9** | [ritual-seed-passo-9.md](trilhas/ritual-seed-passo-9.md) |
| Nó Monero em casa (opcional) | **Home Lab** | [opcionais-home-lab.md](trilhas/opcionais-home-lab.md) |

---

## Três palavras que não misturar

| Termo | Significado |
|-------|-------------|
| **Online (Tor)** | Tails com internet só via Tor |
| **Offline (papel)** | Seed em papel — pode ser com Tor (passo 4) |
| **Offline (rede)** | Tails sem Wi‑Fi/cabo — passo **12** |

Detalhe: [mapa-modos/glossario.md](mapa-modos/glossario.md)

---

## Próximo clique

1. [passos/README.md](passos/README.md) — tabela 1–12 com cartão de cada passo  
2. [README.md — trilha linear](../README.md#trilha-linear) — fonte oficial (não pule ordem)

---

*Porta de entrada · docs/ · Privacy-OS-Hub*
