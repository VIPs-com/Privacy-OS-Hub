# Glossário controlado — Privacy-OS-Hub

Use **sempre** o qualificador. Evite a palavra sozinha “offline” ou “CLI”.

---

## Rede

| Termo | Significado | Passos |
|-------|-------------|:------:|
| **Online (Tor)** | Tails com internet **só** via Tor | 1–9 |
| **Offline (rede)** | Tails **sem** Wi‑Fi/cabo | **12** |
| **Host Linux** | PC com VirtualBox/KVM (não é Tails) | **10** |

---

## Suporte / custódia

| Termo | Significado | Passos |
|-------|-------------|:------:|
| **Offline (papel)** | Seed em papel/metal; sem foto/chat/nuvem | **4**, **9** |
| **Air-gap (fluxo)** | Spend key só no frio; quente view-only | **11–12** |
| **Pendrive trânsito** | USB só para tx/outputs entre frio e quente | **12** |

---

## Trilhas e ferramentas

| Termo | Significado |
|-------|-------------|
| **Trilha linear** | Passos **1–12** do [README](../../README.md#trilha-linear) |
| **Trilha A** | Cold-signing com **Feather GUI** (M2) |
| **Trilha B** | Cold-signing com **monero-wallet-cli** (M2) |
| **M1** | Tails + Haveno (+ Feather install) |
| **M2 quente** | Whonix view-only, online via Tor |
| **M2 frio** | Tails offline + carteira completa |
| **Home Lab** | Debian/Ubuntu, opcional, scripts `00–04` |

---

## QA / validação

| Termo | Significado |
|-------|-------------|
| **`--qa-log`** | Grava `.txt` em `~/Persistent/qa-logs/` |
| **CONFIRMACAO_HUMANA** | Linha no log (SIM/NÃO) — nunca seed |
| **Pendrive QA** | 2º USB para `qa-export-logs.sh` → equipe |

**Como ler logs:** [COMO-LER-SEUS-LOGS.md](../../Tails-OS-Expert/Scripts/COMO-LER-SEUS-LOGS.md)

---

## Termos que NÃO usamos assim

| Evitar | Usar em vez disso |
|--------|-------------------|
| “Offline” (sozinho) | Offline (rede) ou Offline (papel) |
| “CLI” (sozinho) | Trilha B · ou Home Lab |
| “SSH no Tails” | Pendrive + logs (sem SSH) |

---

*Glossário · docs/mapa-modos · jun/2026*
