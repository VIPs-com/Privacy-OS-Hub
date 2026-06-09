# Trilha — M1 · Tails + Tor + Haveno

> **Passos hub:** 1–7 · **Rede:** online (Tor) · **Módulo:** [Tails-OS-Expert](../../Tails-OS-Expert/README.md)

---

## Ordem

| Passo | Cartão | Foco |
|:-----:|--------|------|
| 1 | [passo-01.md](../passos/passo-01.md) | USB · Tor · persistência |
| 2 | [passo-02.md](../passos/passo-02.md) | Haveno verde |
| 3 | [passo-03.md](../passos/passo-03.md) | Cautela pré-trade |
| 4 | [passo-04.md](../passos/passo-04.md) | Carteira · backup · seed **papel** |
| 5 | [passo-05.md](../passos/passo-05.md) | Feather (obrig. M2) |
| 6 | [passo-06.md](../passos/passo-06.md) | Folheto golpes |
| 7 | [passo-07.md](../passos/passo-07.md) | Scripts `--boot` |

---

## Comando porta (novato)

```bash
chmod +x ~/Persistent/*.sh
~/Persistent/haveno-setup.sh --qa-log              # 1ª vez
~/Persistent/haveno-setup.sh --boot --qa-log       # cada sessão
~/Persistent/haveno-setup.sh --feather --qa-log    # + Feather
```

Manual: [MANUAL-SCRIPTS.md](../../MANUAL-SCRIPTS.md)

---

## Não confundir com

| Isto | Aquilo |
|------|--------|
| M1 (Tor) | Passo **12** (Tails **sem** rede) |
| Seed em **papel** (passo 4) | Desligar Wi‑Fi no passo 4 |

---

*Trilha M1 · docs/trilhas*
