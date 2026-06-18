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
# Do clone no pendrive persistente:
cp automacao/tails/*.sh automacao/tails/hub-aliases/*.sh ~/Persistent/
cp automacao/tails/haveno-backup.desktop ~/Persistent/
chmod +x ~/Persistent/hub-scripts/*.sh
```

---

*automacao/ · Privacy-OS-Hub v1.0 · jun/2026*
