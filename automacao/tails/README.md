# Scripts — Tails OS Expert

> **Validar sem adivinhar:** use `--qa-log` e abra os `.txt` em `~/Persistent/qa-logs/`. Guia: [COMO-LER-SEUS-LOGS.md](../docs-aluno/COMO-LER-SEUS-LOGS.md)
>
> **Três passos (ZIP → 1ª vez → reiniciar):** [TRES-PASSOS-HAVENO-TAILS.md](../docs-aluno/TRES-PASSOS-HAVENO-TAILS.md)
>
> **Novato?** Leia o [**MANUAL.md**](../../docs/MANUAL.md) — flags, segurança ao rodar 2×.

Automação do curso. **Dois conjuntos:** Tails (Haveno + Feather) + Home Lab (bônus Debian/Ubuntu).

## Você só usa 1 script: `hub.sh` (comece aqui após passos 1–4 manuais)

**São só 2 situações:**

| Quando | O que digitar |
|--------|---------------|
| 🟢 **Instalar a 1ª vez** (do zero até o **verde**) | `hub.sh install` |
| 🔁 **Toda vez que voltar** (liguei o Tails de novo) | `hub.sh boot` |

O Tails esquece tudo a cada boot (só `~/Persistent` sobrevive) — por isso o `hub.sh boot`
toda vez. Ele é rápido e **não baixa nada de novo**.

```bash
# 1. Sincronizar scripts do ZIP para ~/Persistent/hub-scripts/:
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails && ./sync-hub-scripts.sh

# 2. Usar:
~/Persistent/hub-scripts/hub.sh install              # 1ª vez: preflight → download → instala → abre
~/Persistent/hub-scripts/hub.sh install --install-only  # retoma: .deb já em Install/
~/Persistent/hub-scripts/hub.sh install --qa-log     # 1ª vez + log para suporte
~/Persistent/hub-scripts/hub.sh boot                 # toda sessão (já instalado)
~/Persistent/hub-scripts/hub.sh feather              # Feather Wallet (passo 5)
~/Persistent/hub-scripts/hub.sh backup               # backup cifrado da carteira
~/Persistent/hub-scripts/hub.sh update               # novo release (backup antes)
```

> **Scripts internos não precisam ser rodados diretamente.** `haveno/install.sh`,
> `haveno/boot.sh`, `feather/install.sh` etc. são chamados pelo `hub.sh` automaticamente.
> A tabela abaixo é referência técnica.

> **Passos 1–4** (USB, persistência, Dotfiles, admin) **sempre manuais** — `system/preflight.sh` só valida.

### Senha de admin: digitar uma vez (`--one-password`, opcional)

O Tails, **de propósito**, faz o `sudo` pedir a senha de admin a **cada** comando
(`/etc/sudoers.d/always-ask-password` → `timestamp_timeout=0`). Por isso o fluxo
normal pede a senha várias vezes. Se você preferir digitar **uma vez só**:

```bash
~/Persistent/hub-scripts/hub.sh install --one-password          # 1ª vez
~/Persistent/hub-scripts/hub.sh boot --one-password             # cada sessão
~/Persistent/hub-scripts/hub.sh update --one-password           # novo release
```

A flag instala um ajuste **temporário de sessão** que mantém a senha em cache até o
script terminar, e o **remove ao fim** (e ele some no reboot — o Tails é amnésico).

> ⚠️ **Trade-off:** enquanto o script roda, isso **afrouxa** a proteção do Tails de
> pedir a senha sempre. Por isso é **opt-in** — sem a flag, nada muda (padrão seguro).
> Não há atalho para "rodar como root": os scripts exigem o usuário `amnesia` de
> propósito (rodar como root quebraria permissões da Persistent e abriria a carteira
> como root). Detalhe: **Apêndice B erro 14** no arquivo canônico do curso.

## Matriz script ↔ trilha ↔ Playbook

| Script / comando | Passo hub | Playbook § | Função |
|------------------|-----------|------------|--------|
| **`hub.sh install`** | **2** | §5–7 | **1ª vez: preflight → download → instala → abre** |
| **`hub.sh boot`** | **7** | §7 | **Cada sessão: deps → filtro Tor → abre** |
| `hub.sh backup` | 4, 7 | §9 | Backup cifrado `Data/` |
| `hub.sh update` | 7 | §10 | Novo release (backup automático antes) |
| `hub.sh feather` | 5 | Vol II §2 | Feather PGP + AppImage |
| `hub.sh qa validate` | — | — | `qa-validate.sh` — tela + log simultâneos |
| `hub.sh qa confirm-seed` | 4 | — | seed confirmada em papel (sem gravar palavras) |
| `hub.sh qa ritual-seed` | 9 | — | ritual 2× cópias físicas |
| `hub.sh qa cold-sign` | 12 | — | pós cold-signing (Tails offline) |
| `hub.sh qa export-logs` | — | — | copia `qa-logs/` → pendrive USB |
| `hub.sh qa finalize` | 2 | — | validate + confirm-seed na 1ª instalação |
| `haveno/verify-deb.sh` | 5 | Vol II §3 | Auditar `.deb` em `Install/` (AVANÇADO) |
| `haveno/switch-network.sh` | 5 | Vol II §8 | Trocar rede (backup + update) (AVANÇADO) |
| `system/preflight.sh` | 1–4 | §1–4 | Valida ambiente antes de automatizar |
| `system/post-session.sh` | 7 | §11 pós-Tails | Tor + onion-grater pós-upgrade |
| `qa/confirm-seed.sh` | 4 | — | Confirmações humanas seed (sem gravar palavras) |
| `qa/confirm-step9.sh` | 9 | Playbook backup | Ritual 2× cópias físicas |
| `qa/confirm-step12.sh` | 12 | Trilha A | Cold-signing offline (confirmações) |
| `qa/export-logs.sh` | — | — | Copia `qa-logs/` → pendrive USB |
| `haveno-boot.desktop` | 7 | §7 | Atalho GNOME "Iniciar" — chama `hub.sh boot` cada sessão |
| `haveno-backup.desktop` | 4, 7 | §9 | Atalho GNOME "Backup" — chama `hub.sh backup` |
| `steps/run-all.sh` | 2 | §5–6 | **Fallback Haveno-only** (1 processo = 1 script) — ver abaixo |

**Home Lab** ([`HomeLab/`](../homelab/README.md)) — Debian/Ubuntu, **não** Tails.

**Aliases opcionais** ([`hub-aliases/`](hub-aliases/README.md)) — atalhos numerados em `hub-scripts/aliases/` (ex. `02-haveno-install.sh` → `hub.sh install`).

## Ciclo de uso

```mermaid
flowchart LR
  M["Passos 1–4 manual"] --> P["system/preflight"]
  P --> S["hub.sh install  (1ª vez)"]
  S --> B["hub.sh boot  (cada sessão)"]
  B --> BK["hub.sh backup"]
  BK --> U["hub.sh update"]
```

| Quando | Rode |
|--------|------|
| Antes de qualquer coisa (valida ambiente) | `hub.sh install` já roda o preflight |
| **1ª vez** Haveno | `hub.sh install` |
| **Cada sessão** | `hub.sh boot` |
| Backup / restore | `hub.sh backup` |
| Release novo | `hub.sh update` |
| Feather (M2 pré-req) | `hub.sh feather` |

---

## Instalar scripts (uma vez — e a cada update do ZIP)

### Método A — `sync-hub-scripts.sh` (recomendado)

```bash
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
./sync-hub-scripts.sh
```

Cria/atualiza **`~/Persistent/hub-scripts/`** com todos os scripts organizados por produto
(`haveno/`, `feather/`, `system/`, `qa/`, `steps/`, `aliases/`) + biblioteca `lib/`
(inclui o filtro Tor `onion-grater.yml`) + dois atalhos `.desktop`.

Instala os atalhos automaticamente no menu GNOME:
- **`~/.local/share/applications/`** — funciona nessa sessão imediatamente
- **`~/Persistent/dotfiles/.local/share/applications/`** — persiste nos reboots (se Dotfiles ativo)

Oferece limpar scripts do layout antigo soltos na raiz (sem tocar nos seus dados).

**Validação de qualidade (aluno/equipe):** `system/qa-validate.sh` — sintaxe `bash -n` + checks estáticos (não substitui teste no Tails real).

### Método B — manual

A estrutura tem subpastas por produto. Use o `sync-hub-scripts.sh` — é muito mais
fácil do que copiar manualmente. Em caso de emergência absoluta:

```bash
# copia a estrutura toda para ~/Persistent/hub-scripts/
cp -r ~/Persistent/Privacy-OS-Hub-main/automacao/tails/ ~/Persistent/hub-scripts/
chmod +x ~/Persistent/hub-scripts/**/*.sh ~/Persistent/hub-scripts/*.sh
```

---

## Scripts em detalhe

### `hub.sh install` — 1ª vez até o verde

```bash
hub.sh install                        # padrão
hub.sh install --install-only         # .deb já em Install/ — pula download
hub.sh install --one-password         # senha admin só 1 vez
hub.sh install --skip-backup          # pula backup pós-instalação
hub.sh install --qa-log               # + log em qa-logs/
```

No **[6/9]** (1ª vez), o `.deb` baixa pelo Tor (**30–90 min**) **direto na persistência**
(`~/Persistent/haveno/.download/`), não em `/tmp`. A linha `Downloading Haveno from URL...`
fica parada — o hub imprime barra **`[########----] NN%`** a cada **10s** (upstream)
ou barra **curl** (quando `App/utils/` já existe). Se a rede cair ou você reiniciar,
o download **retoma de onde parou** no próximo boot.

| Pasta | Papel |
|-------|--------|
| `.download/` | Staging — download em andamento (apagada só no sucesso) |
| `Install/` | `.deb` + `.sig` verificados; `haveno.deb` → nome longo |

A `.sig` do release 1.6.0-reto é uma assinatura Ed25519 **binária** legítima (119 B);
o hub a aceita via `haveno_sig_valid_format` (magic byte `0x88`).

No **[7/9]**, o hub instala dependências `apt` do `.deb` (FFmpeg, ICU, …) **antes** do
`install.sh` upstream — idempotente a cada boot. **Apêndice B erro 11** no canônico.

### `hub.sh boot` — cada sessão (Playbook §7)

```bash
hub.sh boot                 # padrão
hub.sh boot --one-password  # senha admin só 1 vez
hub.sh boot --qa-log        # + log para diagnóstico
```

Roda `install.sh` + `exec.sh`. **Verde na janela = você confirma.**

### `hub.sh feather` — Feather Wallet (passo 5)

```bash
hub.sh feather              # baixa (Tor) + verifica PGP + abre
hub.sh feather --qa-log     # + log
```

Atalho gerado em `~/Persistent/feather/feather.desktop`.

### `hub.sh backup` / Feather backup

```bash
hub.sh backup               # backup cifrado da carteira Haveno (Data/)
hub.sh backup --usb         # salva direto no USB
hub.sh backup --restore     # restaura
```

Para Feather: `feather/backup.sh` (mesma interface: `--usb`, `--dest`, `--restore`). **Seed não entra no arquivo.**

### lib/onion-grater.yml — filtro Tor (interno, automático)

O `haveno.yml` que vem **dentro do instalador upstream** não autoriza o `ADD_ONION`
com os parâmetros PoW que o Haveno **1.6.0** passou a enviar — o onion-grater
bloqueia e o app cai com *"A conexão com a rede do Haveno falhou"*.

O filtro corrigido fica em `lib/onion-grater.yml` e é **copiado automaticamente**
pelo `sync-hub-scripts.sh` para `hub-scripts/lib/`. Os scripts o usam sem intervenção.
Detalhe do erro: **Apêndice B erros 12–13** no canônico.

### Fallback atômico — se `hub.sh install` falhar

Use `steps/` — 8 scripts atômicos, um passo de cada vez. **Haveno-only** (não Feather).

```bash
cd ~/Persistent/hub-scripts/steps
./run-all.sh          # roda 01→08, para no 1º FAIL com a causa exata
```

Ou passo isolado para diagnóstico: `./steps/02-download-deb.sh`, `./steps/05-verify-sig.sh`, etc.

Detalhe completo: [`steps/README.md`](steps/README.md).

### Como ler os logs (depurar sem adivinhar)

| Log | Onde | O que mostra |
|-----|------|--------------|
| Saída do script | terminal | `PASS`/`FAIL` por etapa, em verde/vermelho |
| `--qa-log` | `~/Persistent/qa-logs/*.txt` | Evidência por execução — [COMO-LER-SEUS-LOGS.md](../docs-aluno/COMO-LER-SEUS-LOGS.md) |
| Haveno (app) | `/tmp/haveno-exec.log` | Erros de partida (ex.: cookie do Tor, `Command filtered`) |
| onion-grater | `sudo journalctl -u onion-grater -b` | Filtro carregado? Bloqueio aparece como `command filtered: ...` |

---

## Segurança (resumo)

- **Nunca** scriptar: upgrade do **Tails SO**, trades, disputas, seed no arquivo, cold-signing frio.
- Use **1.6.0-reto+** · **Instalar ≠ tradear** · scripts **não** movem fundos.

*Scripts Tails OS Expert · Reto 1.6.0-reto · jun/2026.*
