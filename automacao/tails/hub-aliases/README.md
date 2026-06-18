# hub-aliases — atalhos numerados para `~/Persistent/hub-scripts/`

> **Opcional.** Os scripts **oficiais** mantêm os nomes funcionais (`haveno-setup.sh`, etc.).
> Estes aliases são **wrappers finos**: chamam o script real na pasta pai (`hub-scripts/`) com as flags certas.

## Sync (copia scripts + aliases)

```bash
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
./sync-hub-scripts.sh
```

Resultado:

```text
~/Persistent/hub-scripts/
├── haveno-setup.sh          ← scripts reais
├── haveno-auto.sh
├── …
└── aliases/
    ├── 01-check-tails-environment.sh
    ├── 02-haveno-install.sh
    └── …
```

## Uso no Tails

```bash
~/Persistent/hub-scripts/aliases/01-check-tails-environment.sh
~/Persistent/hub-scripts/aliases/02-haveno-install.sh
~/Persistent/hub-scripts/aliases/03-haveno-start.sh    # cada sessao
```

Pass-through: flags extras vão para o script alvo (`"$@"`), exceto onde o alias já fixa flags padrão.

## Tabela completa

| Alias | Delega para | Flags fixas | Passo hub |
|-------|-------------|-------------|:---------:|
| `00-tails-install.sh` | *(manual)* | — | 1 |
| `00-bootstrap-tails.sh` | *(manual)* | — | 2–4 |
| `01-check-tails-environment.sh` | `tails-preflight.sh` | `--qa-log` | 1–4 |
| `02-haveno-install.sh` | `haveno-setup.sh` | `--qa-log` | 2 |
| `03-haveno-start.sh` | `haveno-setup.sh` | `--boot --qa-log` | 7 |
| `04-daily-routine.sh` | `haveno-boot.sh` | `--qa-log` | 7 |
| `05-haveno-network-check.sh` | `post-session-check.sh` | `--qa-log` | pós-upgrade |
| `06-security-check.sh` | `haveno-verify-deb.sh` | — | 5 |
| `07-backup-carteira.sh` | `haveno-backup.sh` | `--qa-log` | 4, 7 |
| `08-backup-cifrado.sh` | `haveno-backup.sh` | `--qa-log` | 4 *(GPG padrao)* |
| `09-feather-install.sh` | `feather-install-verify.sh` | `--qa-log` | 5 |
| `10-feather-pgp-verify.sh` | `feather-install-verify.sh` | `--qa-log --no-launch` | 5 |
| `11-seed-verify.sh` | `qa-confirm-seed-papel.sh` | — | 4 |
| `12-seed-ritual.sh` | `qa-confirm-passo9.sh` | — | 9 |
| `13-cold-sign.sh` | `qa-confirm-passo12.sh` | — | 12A |
| `14-whonix-cold-sign.sh` | `qa-confirm-passo12.sh` | — | 12B |
| `15-full-automation.sh` | `haveno-setup.sh` | `--qa-log --one-password` | 2 |
| `16-qa-check.sh` | `qa-export-logs.sh` | *(passe `--usb`)* | evidências |
| `17-haveno-install-only.sh` | `haveno-setup.sh` | `--install-only --qa-log` | recuperação |
| `18-haveno-update.sh` | `haveno-update.sh` | `--one-password` | release novo |
| `19-health-check.sh` | `health-check.sh` | — | mantenedor |
| `20-sync-hub-scripts.sh` | `sync-hub-scripts.sh` | — | sync |

## Fallback atômico (download .deb)

Não há alias — use direto no ZIP:

```bash
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails/etapas/instalar-haveno
./01-pastas.sh && ./02-baixar-deb.sh
```

Matriz scripts: [tails/README.md](../README.md) · [docs/MANUAL.md](../../../docs/MANUAL.md)
