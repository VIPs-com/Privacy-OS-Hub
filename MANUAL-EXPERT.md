# Manual Expert — mapa do Privacy-OS-Hub

> **Para quem?** Já conhece Tails, Monero, Tor ou Whonix — quer **orientação em 5 minutos**: o que há no repo, ordem das trilhas e atalhos.
>
> **Novato?** Use [README — Primeira visita?](README.md#primeira-visita) e [MANUAL-SCRIPTS.md](MANUAL-SCRIPTS.md). **Capítulos:** [MANUAL-DO-CURSO.md](MANUAL-DO-CURSO.md).

**Porta única da ordem:** [README.md#trilha-linear](README.md#trilha-linear) · **Princípios:** [MANIFESTO.md](MANIFESTO.md) · **v2:** [CHANGELOG-V2.md](CHANGELOG-V2.md)

---

<a id="arquitetura-do-repositorio"></a>

## Arquitetura do repositório

> **Diagrama visual (FIG-4):** [README — Como o hub está organizado](README.md#como-o-hub-esta-organizado-v2) · Índice: [FIG-1…4](trilha/referencia/diagramas-indice.md)

```text
Privacy-OS-Hub/
├── README.md                 # Trilha 1–12 (fonte da verdade)
├── MANUAL-EXPERT.md          # Este arquivo
├── MANUAL-SCRIPTS.md         # Automação (tom novato)
├── MANUAL-DO-CURSO.md        # Índice capítulo a capítulo
├── MANIFESTO.md
├── CHANGELOG-V2.md             # Migração v1→v2 · tag beta
├── trilha/                     # Navegação L0/L1 · cartões passo · glossário
│   ├── passos/ · mapa-modos/ · trilhas/ · referencia/
│
├── processos/                  # C — comandos canônicos P01–P12 (v2)
│   ├── m1-tor/ · porteiro/ · rituais/ · m2-quente/ · m2-frio/
│
├── modulos/                    # B — livros · índices playbook · assets
│   ├── m1-tails-haveno/        (passos 1–7)
│   └── m2-whonix-custodia/     (passos 8–12)
│
└── automacao/                  # D — todos os scripts
    ├── tails/                  (Tails + qa)
    ├── whonix-host/
    ├── homelab/                (Debian — NÃO Tails)
    └── docs-aluno/
```

**Fora deste repo (opcional):** [Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core) · [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert)

---

## Tipos de documento

| Tipo | Onde | Quando abrir |
|------|------|--------------|
| **Trilha** | [README.md#trilha-linear](README.md#trilha-linear) | Sempre — ordem 1–12 |
| **Livro** | `Curso-*.md` | Teoria, telas, modelo de ameaças |
| **Processo** | `processos/P0x-*.md` | Comandos canônicos por passo (v2) |
| **Playbook** | `Playbooks/*.md` (índice), trilhas A/B (detalhe) | Legado v1 / cold-signing expandido |
| **Script** | `automacao/tails/*.sh`, `whonix-host/` | Cópia para `~/Persistent/` |
| **Folheto** | `Folheto-Regras-e-Golpes.md` | Impressão (passo 6) |

Regra do hub: **Livro + processo no mesmo passo** — abra `processos/P0x` para comandos; playbooks nos módulos = índice ou detalhe expandido (trilhas A/B).

---

## Trilha linear — visão compacta

Ordem fixa. Detalhe completo: [README — tabela](README.md#trilha-linear).

| Passo | Foco | Processo | Módulo |
|:-----:|------|----------|--------|
| **1** | Tails USB · Tor · persistência | [P01](processos/m1-tor/P01-bootstrap-tails.md) | M1 |
| **2** | Haveno → **verde** | [P02](processos/m1-tor/P02-haveno-verde.md) | M1 |
| **3** | Cautela pré-trade | [P03](processos/m1-tor/P03-pre-trade.md) | M1 |
| **4** | Backup · seed papel | [P04](processos/m1-tor/P04-backup-seed.md) | M1 |
| **5** | Feather · trades opcional | [P05](processos/m1-tor/P05-feather.md) | M1 / Vol II |
| **6** | Folheto golpes | [P06](processos/m1-tor/P06-folheto.md) | M1 |
| **7** | Rotina scripts | [P07](processos/m1-tor/P07-rotina-scripts.md) | M1 |
| **8** | Escolher trilha **A ou B** | [P08](processos/porteiro/P08-porteiro-trilha-ab.md) | M2 |
| **9** | Ritual 2× seed (Tor OK) | [P09](processos/rituais/P09-ritual-seed.md) | M2 |
| **10** | Whonix PGP + VMs | [P10](processos/m2-quente/P10-whonix-pgp.md) | M2 |
| **11** | Modelo frio↔quente | [P11](processos/m2-quente/P11-modelo-frio-quente.md) | M2 |
| **12** | Cold-signing air-gap | [P12A](processos/m2-frio/P12a-feather-offline.md) / [P12B](processos/m2-frio/P12b-cli-offline.md) | M2 |

**Pré-req passo 8:** M1 passos **1–7** concluídos (Feather no passo **5**) — **não** exige trade.

**Online × offline:** [README — glossário](README.md#trilha-linear) · **Logs QA:** `--qa-log` → `~/Persistent/qa-logs/` · [COMO-LER-SEUS-LOGS.md](automacao/docs-aluno/COMO-LER-SEUS-LOGS.md)

**Contingência:** [README#travou-aqui](README.md#travou-aqui) · **Mapa repo:** [FIG-4](README.md#como-o-hub-esta-organizado-v2)

---

## Trilhas opcionais (depois de 1–12)

Não misturar com a trilha principal. [README — opcionais](README.md#trilhas-opcionais).

| Quer… | Abrir |
|-------|--------|
| Nó Monero + `.onion` + P2Pool / xmrig | [automacao/homelab/](automacao/homelab/README.md) |
| Multisig 2-de-3 manual (educacional) | [Multisig CLI](modulos/m1-tails-haveno/Expansao-Curso/Multisig-2-de-3-criacao-manual-CLI.md) |
| Hardware wallet | [Curso M2 §5.6](modulos/m2-whonix-custodia/Curso-Whonix-Online.md#56-hardware-wallet-opcional) |
| Baseline cofre / PGP / backup 3-2-1 | [Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core) |

### Cold-signing (passo 12) — escolha UMA

| Trilha | Processo | Detalhe |
|--------|----------|---------|
| **A — Feather GUI** | [P12A](processos/m2-frio/P12a-feather-offline.md) | [Playbook-Feather-GUI](modulos/m2-whonix-custodia/Trilha-A-Feather/Playbook-Feather-GUI.md) |
| **B — CLI** | [P12B](processos/m2-frio/P12b-cli-offline.md) | [Playbook CLI](modulos/m2-whonix-custodia/Trilha-B-CLI/Playbook-monero-wallet-cli.md) |

---

## Scripts — superfície expert

Orquestrador novato: `haveno-setup.sh`. Expert pode chamar **direto**:

| Script | Uso típico |
|--------|------------|
| `tails-preflight.sh` | Checagem 1–4 |
| `haveno-auto.sh` | 1ª install / `--update` |
| `haveno-boot.sh` | Cada sessão (§7) |
| `haveno-backup.sh` | `Data/` cifrado |
| `haveno-update.sh` | Novo `.deb` + PGP |
| `feather-install-verify.sh` | PGP Feather |
| `haveno-switch-network.sh` | Troca de rede Haveno |
| `whonix-verify-image.sh` | PGP imagem (host Linux) · `--qa-log` |
| `qa-confirm-seed-papel.sh` | Confirmações passo 4 (sem seed no log) |
| `qa-confirm-passo9.sh` | Ritual 2× cópias físicas |
| `qa-confirm-passo12.sh` | Pós cold-signing offline |
| `qa-export-logs.sh` | Copia `qa-logs/` → pendrive USB |

Copiar no Tails: `cp automacao/tails/*.sh automacao/tails/hub-aliases/*.sh ~/Persistent/` · Matriz: [automacao/tails/README.md](automacao/tails/README.md) · Novato: [MANUAL-SCRIPTS.md](MANUAL-SCRIPTS.md) · Logs: [COMO-LER-SEUS-LOGS.md](automacao/docs-aluno/COMO-LER-SEUS-LOGS.md)

**Dados persistentes:** `~/Persistent/haveno/Data/` · Feather: `~/Persistent/feather/wallets/` · **Seed ≠ backup automático.**

---

## Constantes rápidas (turma RetoSwap — conferir releases)

| Item | Valor / onde |
|------|----------------|
| Tails mínimo | **7.8.1+** |
| Haveno (turma) | Reto **`1.6.0-reto`**+ |
| PGP Reto | `DAA24D878B8D36C90120A897CA02DAC12DAE2D0F` |
| Feather PGP | `8185E158A33330C7FD61BC0D1F76E155CEFBA71C` |
| Whonix PGP | `916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA` |
| Tor SOCKS (Tails) | **9050** |
| Monero proxy Haveno | **9062** (não trocar por 9050) |
| Links Vol I | [Cap. 8](modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#8-todos-os-links-referência-única) |

---

## O que este hub **não** cobre

- Atualização do **SO Tails** por script (só Tails Upgrader)
- Trades / disputas / fiat como automação
- Assinatura cold no lado **frio** por script (air-gap humano)
- Import automático de VM Whonix no VirtualBox/KVM
- Documentação de **mantenedor** (`CLAUDE.md`, `Auditoria/` — camada local do projeto)

---

## Atalhos por objetivo

| Objetivo | Vá direto a |
|----------|-------------|
| Ordem oficial | [Trilha linear](README.md#trilha-linear) |
| Comandos por passo | [processos/](processos/README.md) |
| Rede / Feather / trade | [P05](processos/m1-tor/P05-feather.md) · [Vol II](modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md) |
| Whonix + cold-signing | [P08–P12](processos/README.md) · [Curso M2](modulos/m2-whonix-custodia/Curso-Whonix-Online.md) |
| FAQ erros Haveno | [Vol I Cap. 7](modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#7-faq--erros-possíveis-após-rodar-os-scripts) |
| Índice todos capítulos | [MANUAL-DO-CURSO](MANUAL-DO-CURSO.md) |

---

*Manual Expert · Privacy-OS-Hub · jun/2026. Ordem de estudo: sempre [trilha linear](README.md#trilha-linear).*
