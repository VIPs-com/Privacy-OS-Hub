# hub-aliases — atalhos por passo e serviço

> **Opcional.** O comando oficial é `hub.sh <subcomando>`.
> Estes aliases são **wrappers finos** organizados pela trilha do curso — úteis para
> seguir a ordem dos passos sem memorizar flags.

## Sync (instalar scripts + aliases no Tails)

```bash
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
./sync-hub-scripts.sh
```

Resultado em `~/Persistent/hub-scripts/`:

```text
hub-scripts/
├── hub.sh                   ← único ponto de entrada
├── haveno/ feather/ system/ qa/ lib/ steps/
└── aliases/
    ├── parte-1/             ← Passos 1–7
    ├── parte-2/             ← Passos 9 e 12
    └── manutencao/          ← não é trilha do aluno
```

## PARTE 1 — Passos 1–7 (Bootstrap + Haveno verde + Pré-M2)

| Alias | Delega para | Flags fixas | Passo |
|-------|-------------|:-----------:|:-----:|
| `parte-1/passo-01-tails-usb.sh` | *(manual)* | — | 1–4 |
| `parte-1/passo-02-instalar.sh` | `hub.sh install` | `--qa-log` | 2 |
| `parte-1/passo-04-backup.sh` | `hub.sh backup` | `--qa-log` | 4 |
| `parte-1/passo-04-confirmar-seed.sh` | `hub.sh qa confirm-seed` | — | 4 |
| `parte-1/passo-05-feather.sh` | `hub.sh feather` | `--qa-log` | 5 |
| `parte-1/passo-07-boot-sessao.sh` | `hub.sh boot` | `--qa-log` | 7 |
| `parte-1/passo-07-qa-finalize.sh` | `hub.sh qa finalize` | — | 7 (1ª vez) |

> `passo-04-confirmar-seed.sh` e `passo-07-qa-finalize.sh` não precisam de `--qa-log` externo —
> os scripts de QA ativam o log internamente.

## PARTE 2 — Passos 9 e 12 (Custódia fria)

| Alias | Delega para | Flags fixas | Passo |
|-------|-------------|:-----------:|:-----:|
| `parte-2/passo-09-ritual-seed.sh` | `hub.sh qa confirm-step9` | — | 9 |
| `parte-2/passo-12-cold-sign.sh` | `hub.sh qa confirm-step12` | — | 12 (A e B) |

## MANUTENÇÃO — não é trilha do aluno

| Alias | Delega para | Flags fixas | Quando usar |
|-------|-------------|:-----------:|-------------|
| `manutencao/haveno-update.sh` | `haveno/update.sh` | `--qa-log` | Novo release |
| `manutencao/haveno-install-only.sh` | `hub.sh install` | `--install-only --qa-log` | Recuperação (.deb já em Install/) |
| `manutencao/haveno-verify-deb.sh` | `haveno/verify-deb.sh` | — | AVANÇADO — auditoria do .deb |
| `manutencao/feather-verify-only.sh` | `hub.sh feather` | `--no-launch --qa-log` | Re-verificar PGP sem abrir |
| `manutencao/post-session-check.sh` | `system/post-session.sh` | `--qa-log` | Pós-upgrade Tails |
| `manutencao/qa-validate.sh` | `hub.sh qa validate` | — | Validação estática dos scripts |
| `manutencao/qa-export-logs.sh` | `hub.sh qa export-logs` | `--usb` | Exportar logs para pendrive |
| `manutencao/sync-scripts.sh` | `sync-hub-scripts.sh` | — | Atualizar scripts do repo/ZIP |

## Fluxo completo — do zero ao verde (Parte 1)

```bash
# 1. Instalar scripts (uma vez, e a cada update do ZIP)
~/Persistent/Privacy-OS-Hub-main/automacao/tails/sync-hub-scripts.sh

cd ~/Persistent/hub-scripts/aliases

# 2. Passo 2: instalar Haveno (prompts automáticos de backup + qa finalize ao final)
./parte-1/passo-02-instalar.sh

# 3. Se precisar fazer backup ou qa finalize manualmente:
./parte-1/passo-04-backup.sh
./parte-1/passo-04-confirmar-seed.sh
./parte-1/passo-07-qa-finalize.sh

# 4. Passo 5: Feather Wallet
./parte-1/passo-05-feather.sh

# 5. Cada sessão (passo 7):
./parte-1/passo-07-boot-sessao.sh
```

## Fallback atômico (Haveno-only)

Para diagnóstico passo a passo, use `steps/` — não há alias, acesse direto:

```bash
cd ~/Persistent/hub-scripts/steps && ./run-all.sh
```

Detalhe: [`steps/README.md`](../steps/README.md)
