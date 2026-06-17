# Automação — scripts do hub (Camada D)

> **Todos** os `.sh` do curso vivem aqui — separados do livro e dos playbooks.  
> Copie para `~/Persistent/` no Tails (tails + qa) ou rode no host (whonix, homelab).

| Pasta | Ambiente | Passos hub |
|-------|----------|:----------:|
| [tails/](tails/README.md) | Tails USB | 1–9, 12 (confirmações) |
| [whonix-host/](whonix-host/README.md) | Linux host | 10 |
| [homelab/](homelab/README.md) | Debian/Ubuntu | opcional |
| [docs-aluno/](docs-aluno/COMO-LER-SEUS-LOGS.md) | Leitura | logs `--qa-log` · [3 passos Haveno](docs-aluno/TRES-PASSOS-HAVENO-TAILS.md) |

**Matriz passo ↔ script:** [trilha/referencia/scripts-matriz.md](../trilha/referencia/scripts-matriz.md)  
**Novato:** [MANUAL-SCRIPTS.md](../MANUAL-SCRIPTS.md)

---

## Copiar para o Tails (uma vez)

```bash
# Do clone no pendrive persistente:
cp automacao/tails/*.sh automacao/tails/hub-aliases/*.sh ~/Persistent/
cp automacao/tails/haveno-backup.desktop ~/Persistent/
chmod +x ~/Persistent/hub-scripts/*.sh
```

---

*automacao/ · Privacy-OS-Hub v2 · jun/2026*
