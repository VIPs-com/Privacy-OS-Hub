# hub-aliases — atalhos numerados para `~/Persistent/hub-scripts/aliases/`

> **Opcional.** O comando oficial é `hub.sh <subcomando>`. Estes aliases são
> **wrappers finos** com nome e número — úteis para lembrar ou documentar a ordem
> dos passos sem precisar digitar as flags. Chamam o script real com as flags certas.

## Sync (copia scripts + aliases)

```bash
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
./sync-hub-scripts.sh
```

Resultado:

```text
~/Persistent/hub-scripts/
├── hub.sh               ← único ponto de entrada
├── haveno/              ← install · boot · backup · update · verify-deb · switch-network
├── feather/             ← install · backup
├── system/              ← preflight · post-session · health-check
├── qa/                  ← confirm-seed · confirm-step9 · confirm-step12 · export-logs
├── lib/                 ← config.sh · common.sh · onion-grater.yml
├── steps/               ← fallback atômico 01–08 + run-all.sh
└── aliases/
    ├── 01-check-tails-environment.sh
    ├── 02-haveno-install.sh
    └── …
```

## Uso no Tails

```bash
~/Persistent/hub-scripts/aliases/01-check-tails-environment.sh
~/Persistent/hub-scripts/aliases/02-haveno-install.sh      # = hub.sh install --qa-log
~/Persistent/hub-scripts/aliases/03-haveno-start.sh        # = hub.sh boot --qa-log (cada sessão)
```

Pass-through: flags extras vão para o script alvo (`"$@"`), exceto onde o alias já fixa flags padrão.

## Tabela completa

| Alias | Delega para | Flags fixas | Passo hub |
|-------|-------------|-------------|:---------:|
| `00-tails-install.sh` | *(manual)* | — | 1 |
| `00-bootstrap-tails.sh` | *(manual)* | — | 2–4 |
| `01-check-tails-environment.sh` | `system/preflight.sh` | `--qa-log` | 1–4 |
| `02-haveno-install.sh` | `hub.sh install` | `--qa-log` | 2 |
| `03-haveno-start.sh` | `hub.sh boot` | `--qa-log` | 7 |
| `04-daily-routine.sh` | `hub.sh boot` | `--qa-log` | 7 |
| `05-haveno-network-check.sh` | `system/post-session.sh` | `--qa-log` | pós-upgrade |
| `06-security-check.sh` | `haveno/verify-deb.sh` | — | 5 |
| `07-backup-carteira.sh` | `haveno/backup.sh` | `--qa-log` | 4, 7 |
| `08-backup-cifrado.sh` | `haveno/backup.sh` | `--qa-log` | 4 *(GPG padrão)* |
| `09-feather-install.sh` | `feather/install.sh` | `--qa-log` | 5 |
| `10-feather-pgp-verify.sh` | `feather/install.sh` | `--qa-log --no-launch` | 5 |
| `11-seed-verify.sh` | `qa/confirm-seed.sh` | — | 4 |
| `12-seed-ritual.sh` | `qa/confirm-step9.sh` | — | 9 |
| `13-cold-sign.sh` | `qa/confirm-step12.sh` | — | 12A |
| `14-whonix-cold-sign.sh` | `qa/confirm-step12.sh` | — | 12B |
| `15-full-automation.sh` | `hub.sh install` | `--qa-log --one-password` | 2 |
| `16-qa-check.sh` | `qa/export-logs.sh` | *(passe `--usb`)* | evidências |
| `17-haveno-install-only.sh` | `hub.sh install` | `--install-only --qa-log` | recuperação |
| `18-haveno-update.sh` | `haveno/update.sh` | `--one-password` | release novo |
| `19-health-check.sh` | `system/health-check.sh` | — | mantenedor |
| `20-sync-hub-scripts.sh` | `sync-hub-scripts.sh` | — | sync |

## Fallback atômico (Haveno-only)

Para diagnóstico passo a passo, use `steps/` — não há alias, acesse direto:

```bash
cd ~/Persistent/hub-scripts/steps
./run-all.sh
```

Detalhe: [`steps/README.md`](../steps/README.md) · Matriz: [`tails/README.md`](../README.md)
