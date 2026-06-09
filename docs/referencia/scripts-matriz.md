# Matriz scripts ↔ passo ↔ playbook

Espelho navegável de [Scripts/README.md](../../Tails-OS-Expert/Scripts/README.md). **Nomes funcionais** não mudam.

---

## Tails (`~/Persistent/`)

| Script | Passo | `--qa-log` | Função |
|--------|:-----:|:----------:|--------|
| `tails-preflight.sh` | 1–4 | ✅ | Valida Tor, persistência, admin |
| `haveno-setup.sh` | 2, 7 | ✅ | Orquestrador (1ª vez / `--boot` / `--feather`) |
| `haveno-auto.sh` | 2 | — | Install → verde (1ª vez) |
| `haveno-boot.sh` | 7 | — | Cada sessão |
| `haveno-backup.sh` | 4, 7 | ✅ | Backup cifrado `Data/` |
| `haveno-update.sh` | 7 | — | Atualizar `.deb` |
| `feather-install-verify.sh` | 5 | ✅ | Feather PGP + AppImage |
| `feather-backup.sh` | 5 | — | Backup `feather/wallets/` |
| `post-session-check.sh` | 7 | ✅ | Pós-upgrade Tails |
| `qa-confirm-seed-papel.sh` | 4 | — | Confirmações seed (sem gravar palavras) |
| `qa-confirm-passo9.sh` | 9 | — | Ritual 2× cópias físicas |
| `qa-confirm-passo12.sh` | 12 | — | Cold-signing offline |
| `qa-export-logs.sh` | — | — | Copia `qa-logs/` → USB |

---

## Host Linux (Whonix)

| Script | Passo | `--qa-log` | Função |
|--------|:-----:|:----------:|--------|
| `whonix-verify-image.sh` | 10 | ✅ | PGP imagem + checksum |

---

## Logs esperados

| Prefixo | Passo | PASS quando |
|---------|:-----:|-------------|
| `01-preflight-*` | 1 | `RESULTADO: PASS` |
| `04-haveno-backup-*` | 4 | `Backup concluido` + PASS |
| `04-seed-papel-*` | 4 | 3× `=SIM` |
| `09-seed-confirmacao-*` | 9 | 3× `=SIM` |
| `12-cold-signing-*` | 12 | `tails_offline_airgap=SIM` |

Detalhe: [COMO-LER-SEUS-LOGS.md](../../Tails-OS-Expert/Scripts/COMO-LER-SEUS-LOGS.md)

---

## Aliases opcionais (hub-NN)

Wrappers numerados por passo: [hub-aliases/README.md](../../Tails-OS-Expert/Scripts/hub-aliases/README.md)

---

*docs/referencia · jun/2026*
