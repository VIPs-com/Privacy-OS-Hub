# Automação — scripts do hub

> **Todos** os `.sh` do curso vivem aqui. Copie para `~/Persistent/hub-scripts/` no Tails (`sync-hub-scripts.sh`) ou rode no host (whonix, homelab).

| Pasta | Ambiente | Passos hub |
|-------|----------|:----------:|
| [tails/](tails/README.md) | Tails USB | 1–9, 12 (confirmações) |
| [whonix-host/](whonix-host/README.md) | Linux host | 10 |
| [homelab/](homelab/README.md) | Debian/Ubuntu | opcional |
| [docs-aluno/](docs-aluno/COMO-LER-SEUS-LOGS.md) | Leitura | logs `--qa-log` · [3 passos Haveno](docs-aluno/TRES-PASSOS-HAVENO-TAILS.md) |

**Matriz passo ↔ script:** [tails/README.md](tails/README.md) · **Manual:** [docs/MANUAL.md](../docs/MANUAL.md)

---

## Copiar para o Tails (uma vez)

```bash
# Do clone/ZIP no pendrive persistente:
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
./sync-hub-scripts.sh
# Cria ~/Persistent/hub-scripts/ com haveno/ feather/ system/ qa/ lib/ steps/ aliases/
```

---

*automacao/ · Privacy-OS-Hub v1.0 · jun/2026*
