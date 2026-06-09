# Scripts — Tails OS Expert

> **Validar sem adivinhar:** [COMO-LER-SEUS-LOGS.md](COMO-LER-SEUS-LOGS.md) — use `--qa-log` e abra os `.txt` em `~/Persistent/qa-logs/`.
>
> **Novato?** Leia o [**MANUAL-SCRIPTS.md**](../../MANUAL-SCRIPTS.md) — [Apêndice A (cada arquivo)](../../MANUAL-SCRIPTS.md#apêndice-a--catálogo-de-cada-arquivo-iniciante) · flags · segurança ao rodar 2×.

Automação do curso. **Dois conjuntos** no Tails + Home Lab (bônus).

## Orquestrador (comece aqui após passos 1–4 manuais)

```bash
chmod +x ~/Persistent/*.sh
~/Persistent/haveno-setup.sh           # 1ª vez: install → verde → backup?
~/Persistent/haveno-setup.sh --boot    # cada sessão
~/Persistent/haveno-setup.sh --feather # + Feather (passo 5 / M2)
~/Persistent/haveno-setup.sh --qa-log    # grava evidencias em ~/Persistent/qa-logs/
```

> **Passos 1–4** (USB, persistência, Dotfiles, admin) **sempre manuais** — `tails-preflight.sh` só valida.

## Matriz script ↔ trilha ↔ Playbook

| Script | Passo hub | Playbook § | Função |
|--------|-----------|------------|--------|
| `tails-preflight.sh` | 1–4 | §1–4 | Valida ambiente antes de automatizar |
| **`haveno-setup.sh`** | **2, 7** | §5–7 | **Orquestrador** (1ª vez / `--boot`) |
| `haveno-auto.sh` | 2 | §5–6 | Install → verde (1ª vez) |
| `haveno-boot.sh` | 7 | §7 | `install.sh` + `exec.sh` cada sessão |
| `haveno-backup.sh` | 4, 7 | §9 | Backup cifrado `Data/` |
| `haveno-update.sh` | 7 | §10 | Atualizar `.deb` (backup antes) |
| `feather-install-verify.sh` | 5 | Vol II §2 | Feather PGP + AppImage |
| `feather-backup.sh` | 5 | Vol II §2 | Backup `feather/wallets/` |
| `haveno-verify-deb.sh` | 5 | Vol II §3 | Auditar `.deb` em `Install/` |
| `haveno-switch-network.sh` | 5 | Vol II §8 | Trocar rede (backup + update) |
| `post-session-check.sh` | 7 | §11 pós-Tails | Tor + onion-grater pós-upgrade |
| `qa-confirm-seed-papel.sh` | 4 | — | Confirmações humanas seed (sem gravar palavras) |
| `qa-confirm-passo9.sh` | 9 | Playbook backup | Ritual 2× cópias físicas |
| `qa-confirm-passo12.sh` | 12 | Trilha A | Cold-signing offline (confirmações) |
| `qa-export-logs.sh` | — | — | Copia `qa-logs/` → pendrive USB |
| `haveno-backup.desktop` | 4, 7 | §9 | Atalho de menu (backup) |
| `haveno-common.sh` | — | — | Biblioteca (source interno + `qa_log_*`) |

**Home Lab** ([`HomeLab/`](HomeLab/README.md)) — Debian/Ubuntu, **não** Tails.

**Aliases opcionais** ([`hub-aliases/`](hub-aliases/README.md)) — wrappers `hubNN-*.sh` por passo do hub.

## Ciclo de uso

```mermaid
flowchart LR
  M["Passos 1–4 manual"] --> P["tails-preflight"]
  P --> S["haveno-setup 1a vez"]
  S --> B["haveno-setup --boot"]
  B --> BK["haveno-backup"]
  BK --> U["haveno-update"]
```

| Quando | Rode |
|--------|------|
| Antes de qualquer script | `tails-preflight.sh` (ou via `haveno-setup.sh`) |
| **1ª vez** Haveno | `haveno-setup.sh` ou `haveno-auto.sh` |
| **Cada sessão** | `haveno-setup.sh --boot` ou `haveno-boot.sh` |
| Backup / restore | `haveno-backup.sh` |
| Release novo | `haveno-update.sh` |
| Feather (M2 pré-req) | `feather-install-verify.sh` → UI carteira |

---

## Instalar scripts em `~/Persistent` (uma vez)

### Método A — Arquivos (recomendado)

1. Copie **todos** os `*.sh` desta pasta + `haveno-backup.desktop` → `~/Persistent/`.
2. `chmod +x ~/Persistent/*.sh`

### Método B — find

```bash
find ~/Persistent -path '*/Tails-OS-Expert/Scripts/*.sh' -exec cp -t ~/Persistent {} +
find ~/Persistent -name 'haveno-backup.desktop' -exec cp -t ~/Persistent {} +
chmod +x ~/Persistent/*.sh
```

---

## Scripts principais

### `haveno-setup.sh` — um comando

- **1ª vez:** preflight → `haveno-auto.sh` → pergunta backup
- **`--boot`:** preflight → `haveno-boot.sh`
- **`--feather`:** encadeia `feather-install-verify.sh`
- **`--skip-backup`:** pula prompt de backup

### `haveno-auto.sh` — install até verde

```bash
~/Persistent/haveno-auto.sh
~/Persistent/haveno-auto.sh --boot-only   # delega a haveno-boot.sh
~/Persistent/haveno-auto.sh --update
~/Persistent/haveno-auto.sh --no-clock
```

Roda `install.sh` + `exec.sh` (Playbook §7). **Verde na janela = você confirma.**

### `haveno-boot.sh` — cada sessão (Playbook §7)

```bash
~/Persistent/haveno-boot.sh
~/Persistent/haveno-boot.sh --watch 8
```

### `feather-install-verify.sh`

Baixe AppImage + `.asc` pelo **Tor Browser** primeiro, depois:

```bash
~/Persistent/feather-install-verify.sh
```

### `haveno-backup.sh` / `feather-backup.sh`

Mesma interface: `--usb`, `--dest`, `--restore`, GPG. **Seed não entra no arquivo.**

---

## Segurança (resumo)

- **Nunca** scriptar: upgrade do **Tails SO**, trades, disputas, seed no arquivo, cold-signing frio.
- Use **1.6.0-reto+** · **Instalar ≠ tradear** · scripts **não** movem fundos.

*Scripts Tails OS Expert · Reto 1.6.0-reto · jun/2026.*
