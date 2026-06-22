# Privacy-OS-Hub

Hub de **guias práticos de privacidade** — do pendrive vazio à custódia Monero com Tor, verificação PGP e
segurança operacional.

`tails` · `whonix` · `tor` · `monero` · `haveno` · `privacy` · `cold-wallet` · `pgp`

> **v1.0 canônica** · release [`v1.0.7.2`](https://github.com/VIPs-com/Privacy-OS-Hub/releases/tag/v1.0.7.2) · Nível B+ ✅ APROVADO (Tails 7.8.1 · RetoSwap 1.6.0-reto) · [CHANGELOG](docs/CHANGELOG.md)

> ⚠️ **Uso educacional.** Não é aconselhamento financeiro. **Instalar ≠ tradear.** Verifique sempre PGP e fontes oficiais.

> 🔑 **Fingerprints PGP oficiais** — confira antes de qualquer verificação:
>
> | Projeto | Fingerprint |
> |---------|------------|
> | Haveno / RetoSwap | `DAA2 4D87 8B8D 36C9 0120  A897 CA02 DAC1 2DAE 2D0F` |
> | Feather Wallet | `8185 E158 A333 30C7 FD61  BC0D 1F76 E155 CEFB A71C` |
> | Whonix | `916B 8D99 C38E AF5E 8ADC  7A2A 8D66 066A 2EEA CCDA` |
>
> Em sistemas PT-BR, `gpg` exibe **`Assinatura válida`** no lugar de `Good signature` — ambos significam a mesma coisa.

---

## Comece aqui

**Abra o arquivo canônico e siga os passos:**

### 👉 [`🛡️ Privacy-OS-Hub - Versão 1.0.md`](🛡️%20Privacy-OS-Hub%20-%20Versão%201.0.md)

Tudo em um único arquivo: passos 1–12 completos, comandos, checkpoints, apêndices e glossário.
**Sem precisar navegar entre pastas.**

**Atalho operacional (ZIP → 1ª vez → reiniciar):** [`automacao/docs-aluno/TRES-PASSOS-HAVENO-TAILS.md`](automacao/docs-aluno/TRES-PASSOS-HAVENO-TAILS.md)

---

## O que você vai aprender (12 passos)

```text
PARTE 1 (1–7)                         PARTE 2 (8–12)
┌─ Passos 1–3: Haveno 🟢 ─┐         Custódia fria 🔵
│ 1 Tails → 2 Verde → 3   │  ───►   8–12 · Trilha A ou B
└─ Passos 4–7: Pré-M2 🟡 ─┘
  4 seed · 5 Feather · 6–7 rotina
```

| # | Passo | Ferramenta | Resultado |
|:-:|-------|-----------|-----------|
| | **Passos 1–3 — Núcleo Haveno** | | |
| 1 | Bootstrap Tails | Tails Installer | USB pronto · Tor ativo · Persistência |
| 2 | Haveno Verde | `hub.sh install` | Indicador ● VERDE |
| 3 | Cautela pré-trade | — | Regras e golpes internalizados |
| | **Passos 4–7 — Pré-M2** | | |
| 4 | Backup Seed | `hub.sh backup` → `hub.sh qa confirm-seed` | Seed em papel + backup cifrado |
| 5 | Feather Wallet | `hub.sh feather` | Carteira verificada por PGP |
| 6 | Folheto | — | Regras de ouro impressas |
| 7 | Rotina de scripts | `hub.sh boot` | Boot automatizado em < 5 min |
| | **Passos 8–12 — Custódia fria** | | |
| 8 | Porteiro: Trilha A ou B | — | Trilha escolhida conscientemente |
| 9 | Ritual Seed | `hub.sh qa ritual-seed` | 2 cópias físicas em locais separados |
| 10 | Whonix + PGP | VirtualBox/KVM | "Tor Connected" no Workstation |
| 11 | Modelo frio↔quente | — | Air-gap internalizado |
| 12A | Feather Offline *(Trilha A)* | Feather (air-gap) | Cold-signing completo |
| 12B | CLI Offline *(Trilha B)* | monero-wallet-cli | Cold-signing via terminal |

---

## Estrutura do repositório

```
Privacy-OS-Hub/
│
├── 🛡️ Privacy-OS-Hub - Versão 1.0.md   ← ABRA AQUI (passos 1–12)
├── 🏠 Home-Lab - Versão 1.0.md          ← opcional (nó Monero, P2Pool, XMRig)
├── README.md                            ← você está aqui
│
├── automacao/                           ← scripts .sh para Tails e Whonix
│   ├── tails/                           ·  hub.sh (único ponto de entrada)
│   │                                    ·  haveno/ · feather/ · system/ · qa/ · lib/ · steps/
│   │                                    ·  hub-aliases/ → aliases/ (parte-1/ · parte-2/ · manutencao/)
│   │                                    ·  atalhos GNOME: haveno-boot.desktop · haveno-backup.desktop
│   ├── whonix-host/                     ·  whonix-verify-image.sh
│   ├── homelab/                         ·  nó Monero (Debian/Ubuntu — NÃO Tails)
│   └── docs-aluno/                      ·  COMO-LER-SEUS-LOGS.md · TRES-PASSOS-HAVENO-TAILS.md
│
└── docs/                                ← licenças e documentação de projeto
    ├── LICENSE · LICENSE-DOCS.md
    ├── MANIFESTO.md · CHANGELOG.md
    └── MANUAL.md
```

---

## Scripts — o essencial

Você só precisa de **um comando** para cada situação. O `hub.sh` pede a **senha de admin apenas uma vez por sessão** (padrão ativo — não precisa de `--one-password`).

```bash
# 0. Sincronizar scripts + atalhos GNOME (uma vez, e a cada update do ZIP)
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails && ./sync-hub-scripts.sh
# → copia para ~/Persistent/hub-scripts/ (inclui aliases parte-1/ · parte-2/ · manutencao/)
# → instala "Haveno — Iniciar" e "Haveno — Backup" no menu GNOME
# → se Dotfiles estiver ativo, os atalhos sobrevivem ao reboot

# 1ª vez — instalar até o verde (passo 2)
~/Persistent/hub-scripts/hub.sh install --qa-log
# → ao final: prompts opcionais de backup (S/n), QA finalize (S/n) e Feather (s/N)

# Retomar após download OK ( .deb já em Install/ )
~/Persistent/hub-scripts/hub.sh install --install-only --qa-log

# Cada sessão — abrir o Haveno (passo 7)
~/Persistent/hub-scripts/hub.sh boot --qa-log     # ou clique "Haveno — Iniciar" no menu GNOME

# Feather Wallet (passo 5 — ou aceite o prompt ao final do install)
~/Persistent/hub-scripts/hub.sh feather --qa-log

# Atualizar release (backup automático antes)
~/Persistent/hub-scripts/hub.sh update --qa-log

# Backup (passo 4 e após cada trade)
~/Persistent/hub-scripts/hub.sh backup                  # rápido — só Haveno Data/
~/Persistent/hub-scripts/hub.sh backup --full --usb     # snapshot completo → pendrive (3-2-1-1-0)
```

**Três camadas de backup** (não são “só Haveno vs Feather”):

| Camada | Comando | Quando |
|--------|---------|--------|
| **Operacional** | `hub.sh backup` | Antes do 1º depósito e **antes de cada trade** — histórico, chat e contas para disputas |
| **Periódico** | `hub.sh backup --full --usb` | Semanal — Haveno + Feather + dotfiles + **`my-locker/`** (3-2-1-1-0) |
| **Feather pontual** | `feather/backup.sh` | Opcional — ou deixe o `--full` incluir |

> **`--full` não inclui:** `Backups/`, `qa-logs/`, `hub-scripts/` — copie `Backups/*.gpg` para pendrive B **manual** ou use `--usb` ao gerar.

> **Seed em papel** recupera fundos. **`my-locker/`** criada no sync/install — arquivos pessoais **só ali**.

```bash
# Validação e confirmações QA
~/Persistent/hub-scripts/hub.sh qa validate       # checagem estática dos scripts
~/Persistent/hub-scripts/hub.sh qa finalize       # validate + seed (1ª instalação)
~/Persistent/hub-scripts/hub.sh qa confirm-seed   # passo 4 — seed anotada em papel
~/Persistent/hub-scripts/hub.sh qa ritual-seed    # passo 9 — 2 cópias físicas da seed
~/Persistent/hub-scripts/hub.sh qa cold-sign      # passo 12 — pós cold-signing

# Exportar logs para suporte
~/Persistent/hub-scripts/hub.sh qa export-logs --usb
```

### Flags úteis

| Flag | Quando usar |
|------|-------------|
| `--qa-log` | Sempre que algo der errado — gera `~/Persistent/qa-logs/*.txt` |
| `--install-only` | `.deb` já verificado em `Install/` — pula download |
| `--skip-backup` | Pula o prompt de backup ao final do `install` (raro) |
| `HAVENO_ONE_PASSWORD=0` | Desativa senha admin 1× (avançado) |

> **Algo falhou no install?** Fallback atômico: `~/Persistent/hub-scripts/steps/run-all.sh` (Haveno-only).
>
> **Guia completo de scripts:** [`docs/MANUAL.md`](docs/MANUAL.md) · [`automacao/tails/README.md`](automacao/tails/README.md)

---

## Atalhos rápidos

| Você quer… | Abra |
|------------|------|
| Começar do zero | [`🛡️ Privacy-OS-Hub - Versão 1.0.md`](🛡️%20Privacy-OS-Hub%20-%20Versão%201.0.md) — Seção 0. ONBOARDING |
| Três passos (ZIP → install → boot) | [`TRES-PASSOS-HAVENO-TAILS.md`](automacao/docs-aluno/TRES-PASSOS-HAVENO-TAILS.md) |
| Ir direto a um passo | Mesmo arquivo — busque `PASSO N` |
| Scripts (o que cada .sh faz) | [`docs/MANUAL.md`](docs/MANUAL.md#parte-ii--scripts-para-novato) ou Apêndice A no canônico |
| Mapa compacto para experts | [`docs/MANUAL.md`](docs/MANUAL.md#parte-i--mapa-rápido) |
| Entender os logs de validação | [`automacao/docs-aluno/COMO-LER-SEUS-LOGS.md`](automacao/docs-aluno/COMO-LER-SEUS-LOGS.md) |
| Home Lab (nó + mineração) | [`🏠 Home-Lab - Versão 1.0.md`](🏠%20Home-Lab%20-%20Versão%201.0.md) |
| Fingerprints PGP | Apêndice C no canônico (ou tabela acima) |
| Erros comuns | Apêndice B no canônico · [`automacao/tails/docs/TROUBLESHOOTING.md`](automacao/tails/docs/TROUBLESHOOTING.md) |
| Histórico de releases | [`docs/CHANGELOG.md`](docs/CHANGELOG.md) |

---

## Como ler "online" e "offline"

| Termo | Significado |
|-------|-------------|
| **Online (Tor)** | Tails com internet via Tor — passos 1–9 |
| **Offline (suporte)** | Seed em papel — passo 4. Nunca foto, chat ou nuvem. |
| **Offline (air-gap)** | Tails sem Wi-Fi/cabo — passo 12 (cold-signing) |
| **Log de validação** | `--qa-log` → `~/Persistent/qa-logs/*.txt` — [como ler](automacao/docs-aluno/COMO-LER-SEUS-LOGS.md) |

---

## Opcional: Home Lab e ecossistema

**Só depois dos passos 1–12.**

| Opcional | Para quê | Abrir |
|----------|----------|-------|
| [🏠 Home Lab](🏠%20Home-Lab%20-%20Versão%201.0.md) | Nó Monero + P2Pool + XMRig em Debian/Ubuntu | arquivo canônico |
| [Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core) | Cofres, PGP air-gap, backup off-site, SSH | repo separado |
| [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert) | GPG completo — assinar, cifrar, subchaves | repo separado |

---

## Licença

- **Scripts** (`*.sh`, `*.desktop`): **MIT** — [`docs/LICENSE`](docs/LICENSE)
- **Documentação:** **CC BY-SA 4.0** — [`docs/LICENSE-DOCS.md`](docs/LICENSE-DOCS.md)
