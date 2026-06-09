# Manual Expert — mapa do Privacy-OS-Hub

> **Para quem?** Já conhece Tails, Monero, Tor ou Whonix — quer **orientação em 5 minutos**: o que há no repo, ordem das trilhas e atalhos.
>
> **Novato?** Use [README — Primeira visita?](README.md#primeira-visita) e [MANUAL-SCRIPTS.md](MANUAL-SCRIPTS.md). **Capítulos:** [MANUAL-DO-CURSO.md](MANUAL-DO-CURSO.md).

**Porta única da ordem:** [README.md#trilha-linear](README.md#trilha-linear) · **Princípios:** [MANIFESTO.md](MANIFESTO.md)

---

## Arquitetura do repositório

```text
Privacy-OS-Hub/
├── README.md                 # Trilha 1–12 (fonte da verdade)
├── MANUAL-EXPERT.md          # Este arquivo
├── MANUAL-SCRIPTS.md         # Automação (tom novato)
├── MANUAL-DO-CURSO.md        # Índice capítulo a capítulo
├── MANIFESTO.md
├── trilha/                     # A — ordem passos 1–12 · mapas · cartões
│   ├── 00-PORTA-ENTRADA.md
│   ├── mapa-modos/ · trilhas/ · passos/ · referencia/
│
├── modulos/                    # B — livros · playbooks · assets
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
| **Playbook** | `Playbooks/*.md`, trilhas A/B | Terminal / ritual copiável |
| **Script** | `Scripts/*.sh` | Automação (PGP fail-closed, ciclo Haveno) |
| **Folheto** | `Folheto-Regras-e-Golpes.md` | Impressão (passo 6) |

Regra do hub: **Livro + Comandos no mesmo passo** — não pule só para Playbook sem contexto de risco quando for a 1ª vez no passo.

---

## Trilha linear — visão compacta

Ordem fixa. Detalhe completo: [README — tabela](README.md#trilha-linear).

| Passo | Foco | Módulo |
|:-----:|------|--------|
| **1** | Tails USB · Tor · persistência · Dotfiles | M1 |
| **2** | Haveno install → **verde** | M1 |
| **3** | Exploit / cautela pré-trade | M1 |
| **4** | Carteira · backup `Data/` · seed papel | M1 |
| **5** | Vol II: Feather (obrig. M2) · trades opcional | M1 / Vol II |
| **6** | Folheto golpes | M1 |
| **7** | Scripts: boot / backup / update | M1 |
| **8** | Escolher trilha cold-signing **A ou B** | M2 |
| **9** | Confirmar 2× cópias físicas da seed | M2 |
| **10** | Whonix install + PGP imagem | M2 |
| **11** | Teoria frio↔quente | M2 |
| **12** | Cold-signing (Feather GUI **ou** CLI) | M2 |

**Pré-req passo 8:** M1 passos **1–4** + Feather ([Vol II Cap. 3](modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#3-feather-no-tails--instalar-e-verificar)) — **não** exige trade.

**Online × offline:** [README — glossário](README.md#trilha-linear) · **Logs QA:** `--qa-log` → `~/Persistent/qa-logs/` · [COMO-LER-SEUS-LOGS.md](automacao/docs-aluno/COMO-LER-SEUS-LOGS.md)

**Contingência:** [README#travou-aqui](README.md#travou-aqui)

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

| Trilha | Playbook |
|--------|----------|
| **A — Feather GUI** (padrão hub) | [Playbook-Feather-GUI.md](modulos/m2-whonix-custodia/Trilha-A-Feather/Playbook-Feather-GUI.md) |
| **B — monero-wallet-cli** | [Playbook-monero-wallet-cli.md](modulos/m2-whonix-custodia/Trilha-B-CLI/Playbook-monero-wallet-cli.md) |

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

Matriz completa: [Scripts/README.md](automacao/tails/README.md) · Novato detalhado: [MANUAL-SCRIPTS.md](MANUAL-SCRIPTS.md) · **Ler logs:** [COMO-LER-SEUS-LOGS.md](automacao/docs-aluno/COMO-LER-SEUS-LOGS.md)

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
| Só comandos Haveno M1 | [Playbooks M1](modulos/m1-tails-haveno/Playbooks/Playbooks.md) |
| Rede / Feather / trade | [Vol II](modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md) · [Playbooks Vol II](modulos/m1-tails-haveno/Expansao-Curso/Playbooks-Rede-Descentralizada.md) |
| Whonix + cold-signing | [Curso M2](modulos/m2-whonix-custodia/Curso-Whonix-Online.md) · [00-Comece-aqui](modulos/m2-whonix-custodia/00-Comece-aqui-Escolha-sua-trilha.md) |
| FAQ erros Haveno | [Vol I Cap. 7](modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#7-faq--erros-possíveis-após-rodar-os-scripts) |
| Índice todos capítulos | [MANUAL-DO-CURSO](MANUAL-DO-CURSO.md) |

---

*Manual Expert · Privacy-OS-Hub · jun/2026. Ordem de estudo: sempre [trilha linear](README.md#trilha-linear).*
