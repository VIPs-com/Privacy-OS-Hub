# Scripts — Tails OS Expert

> **Validar sem adivinhar:** [COMO-LER-SEUS-LOGS.md](../docs-aluno/COMO-LER-SEUS-LOGS.md) — use `--qa-log` e abra os `.txt` em `~/Persistent/qa-logs/`.
>
> **Novato?** Leia o [**MANUAL-SCRIPTS.md**](../../MANUAL-SCRIPTS.md) — [Apêndice A (cada arquivo)](../../MANUAL-SCRIPTS.md#apêndice-a--catálogo-de-cada-arquivo-iniciante) · flags · segurança ao rodar 2×.

Automação do curso. **Dois conjuntos** no Tails + Home Lab (bônus).

## Você só usa 1 script: `haveno-setup.sh` (comece aqui após passos 1–4 manuais)

**São só 2 situações:**

| Quando | O que digitar |
|--------|---------------|
| 🟢 **Instalar a 1ª vez** (do zero até o **verde**) | `haveno-setup.sh` |
| 🔁 **Toda vez que voltar** (liguei o Tails de novo) | `haveno-setup.sh --boot` |

O Tails esquece tudo a cada boot (só `~/Persistent` sobrevive) — por isso o `--boot`
toda vez. Ele é rápido e **não baixa nada de novo**.

```bash
# instalar/atualizar os scripts (cria ~/Persistent/hub-scripts/ — raiz da Persistent fica limpa):
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails && ./sync-hub-scripts.sh

~/Persistent/hub-scripts/haveno-setup.sh              # 1ª vez: install → verde → backup?
~/Persistent/hub-scripts/haveno-setup.sh --install-only  # retoma [7-9] (.deb ja em Install/)
~/Persistent/hub-scripts/haveno-setup.sh --boot       # toda vez que voltar (já instalado)
~/Persistent/hub-scripts/haveno-setup.sh --feather    # + Feather (passo 5 / M2)
~/Persistent/hub-scripts/haveno-setup.sh --qa-log     # grava 01-preflight + 02-haveno-auto em qa-logs/
```

> **`haveno-auto.sh` e `haveno-boot.sh` são internos** — o `haveno-setup.sh` chama
> eles sozinho. Você não precisa rodá-los direto (a tabela abaixo é referência técnica).

> **Layout (jun/2026):** os scripts vivem em **`~/Persistent/hub-scripts/`** — uma
> pasta só, fácil de achar e de apagar/recriar no update. Seus **dados** ficam fora
> dela: `haveno/` (carteira), `Backups/`, `feather/`, `qa-logs/`. O `haveno-setup`
> sincroniza scripts novos do ZIP para `hub-scripts/` (use `--no-sync` para desligar).

> **Passos 1–4** (USB, persistência, Dotfiles, admin) **sempre manuais** — `tails-preflight.sh` só valida.

### Senha de admin: digitar uma vez (`--one-password`, opcional)

O Tails, **de propósito**, faz o `sudo` pedir a senha de admin a **cada** comando
(`/etc/sudoers.d/always-ask-password` → `timestamp_timeout=0`). Por isso o fluxo
normal pede a senha várias vezes. Se você preferir digitar **uma vez só**:

```bash
~/Persistent/hub-scripts/haveno-setup.sh --one-password          # 1ª vez
~/Persistent/hub-scripts/haveno-setup.sh --boot --one-password   # cada sessão
```

A flag instala um ajuste **temporário de sessão** que mantém a senha em cache até o
script terminar, e o **remove ao fim** (e ele some no reboot — o Tails é amnésico).
Vale também em `haveno-auto.sh`, `haveno-boot.sh` e `haveno-update.sh`.

> ⚠️ **Trade-off:** enquanto o script roda, isso **afrouxa** a proteção do Tails de
> pedir a senha sempre. Por isso é **opt-in** — sem a flag, nada muda (padrão seguro).
> Não há atalho para "rodar como root": os scripts exigem o usuário `amnesia` de
> propósito (rodar como root quebraria permissões da Persistent e abriria a carteira
> como root). Detalhe: FAQ Cap. 7.

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
| `haveno-onion-grater.yml` | 2, 7 | §8 | **Filtro Tor corrigido** p/ Haveno 1.6.0 (PoW) — ver abaixo |

**Home Lab** ([`HomeLab/`](../homelab/README.md)) — Debian/Ubuntu, **não** Tails.

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

## Instalar scripts (uma vez — e a cada update do ZIP)

### Método A — `sync-hub-scripts.sh` (recomendado)

```bash
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
./sync-hub-scripts.sh
```

Cria/atualiza **`~/Persistent/hub-scripts/`** com todos os `.sh` + o filtro
`haveno-onion-grater.yml` + o atalho `.desktop`, e oferece limpar scripts do
layout antigo soltos na raiz (sem tocar nos seus dados).

### Método B — manual

1. Copie **todos** os `*.sh` + `haveno-onion-grater.yml` + `haveno-backup.desktop` desta pasta → `~/Persistent/hub-scripts/`.
2. `chmod +x ~/Persistent/hub-scripts/*.sh`

---

## Scripts principais

### `haveno-setup.sh` — um comando

- **1ª vez:** preflight → `haveno-auto.sh` → pergunta backup
- **`--boot`:** preflight → `haveno-boot.sh`
- **`--feather`:** encadeia `feather-install-verify.sh`
- **`--skip-backup`:** pula prompt de backup

### `haveno-auto.sh` — install até verde

```bash
~/Persistent/hub-scripts/haveno-auto.sh
~/Persistent/hub-scripts/haveno-auto.sh --boot-only   # delega a haveno-boot.sh
~/Persistent/hub-scripts/haveno-auto.sh --update
~/Persistent/hub-scripts/haveno-auto.sh --no-clock
~/Persistent/hub-scripts/haveno-auto.sh --install-only   # recuperacao: deps + install (sem download)
```

**Atualizar scripts do ZIP para `~/Persistent/`:** `./sync-hub-scripts.sh` (nesta pasta).

Roda `install.sh` + `exec.sh` (Playbook §7). **Verde na janela = você confirma.**

No **[6/9]** (1ª vez), o `.deb` baixa pelo Tor (**30–90 min**) **direto na persistência** (`~/Persistent/haveno/.download/`), não em `/tmp`. A linha `Downloading Haveno from URL...` do script upstream fica parada — o hub imprime `[download] tamanho (~%)` a cada 30s. Se a rede cair ou você reiniciar, o download **retoma de onde parou** no próximo boot (antes, em `/tmp` = RAM, perdia tudo — corrigido em jun/2026).

No **[7/9]**, o hub instala dependências `apt` do `.deb` (FFmpeg, ICU, …) **antes** do `install.sh` upstream — idempotente a cada boot. FAQ Cap. **7.11**.

### `haveno-onion-grater.yml` — filtro Tor corrigido (1.6.0)

O `haveno.yml` que vem **dentro do instalador upstream** não autoriza o `ADD_ONION`
com os parâmetros PoW que o Haveno **1.6.0** passou a enviar — o onion-grater
bloqueia (`Command filtered`) e o app cai com *"A conexão com a rede do Haveno
falhou"*. Este arquivo é a versão corrigida (validada em campo 2026-06-11);
os scripts usam-no automaticamente se ele estiver junto em `~/Persistent/`.
**Copie-o junto com os `.sh`.** Detalhe do erro: FAQ Cap. **7.12–7.13**.

### Como ler os logs (depurar sem adivinhar)

| Log | Onde | O que mostra |
|-----|------|--------------|
| Saída do script | terminal | `PASS`/`FAIL` por etapa, em verde/vermelho |
| `--qa-log` | `~/Persistent/qa-logs/*.txt` | Evidência por execução — [COMO-LER-SEUS-LOGS.md](../docs-aluno/COMO-LER-SEUS-LOGS.md) |
| Haveno (app) | `/tmp/haveno-exec.log` | Erros de partida (ex.: cookie do Tor, `Command filtered`) |
| onion-grater | `sudo journalctl -u onion-grater -b` | Filtro carregado? Comando bloqueado aparece como `command filtered: ...` |

### `haveno-boot.sh` — cada sessão (Playbook §7)

```bash
~/Persistent/hub-scripts/haveno-boot.sh
~/Persistent/hub-scripts/haveno-boot.sh --watch 8
```

### `feather-install-verify.sh`

Baixa (via Tor) + verifica PGP fail-closed + **abre** o Feather (como o Haveno após install):

```bash
~/Persistent/hub-scripts/feather-install-verify.sh --qa-log
~/Persistent/hub-scripts/feather-install-verify.sh --no-launch   # so re-auditar PGP
```

Atalho gerado em `~/Persistent/feather/feather.desktop` (e `~/Desktop/` se existir).

### `haveno-backup.sh` / `feather-backup.sh`

Mesma interface: `--usb`, `--dest`, `--restore`, GPG. **Seed não entra no arquivo.**

---

## Segurança (resumo)

- **Nunca** scriptar: upgrade do **Tails SO**, trades, disputas, seed no arquivo, cold-signing frio.
- Use **1.6.0-reto+** · **Instalar ≠ tradear** · scripts **não** movem fundos.

*Scripts Tails OS Expert · Reto 1.6.0-reto · jun/2026.*
