# hub-aliases — wrappers opcionais por passo

> **Opcional.** Os scripts **oficiais** continuam com os nomes funcionais (`haveno-setup.sh`, etc.).
> Estes aliases só ajudam quem prefere prefixo `hubNN-` alinhado ao passo do README.

Copie para `~/Persistent/` junto com os scripts principais:

```bash
chmod +x ~/Persistent/hub*.sh
```

| Alias | Delega para | Passo |
|-------|-------------|:-----:|
| `hub01-preflight.sh` | `tails-preflight.sh --qa-log` | 1 |
| `hub04-backup.sh` | `haveno-backup.sh --qa-log` | 4 |
| `hub04-seed-papel.sh` | `qa-confirm-seed-papel.sh` | 4 |
| `hub09-seed-ritual.sh` | `qa-confirm-passo9.sh` | 9 |
| `hub12-cold-signing.sh` | `qa-confirm-passo12.sh` | 12 |

Matriz completa: [trilha/referencia/scripts-matriz.md](../../../trilha/referencia/scripts-matriz.md)
