# Privacy-OS-Hub

Hub de **guias práticos de privacidade** — do pendrive vazio à custódia Monero com Tor, verificação PGP e
segurança operacional.

`tails` · `whonix` · `tor` · `monero` · `haveno` · `privacy` · `cold-wallet` · `2fa` · `pgp`

> ⚠️ **Uso educacional.** Não é aconselhamento financeiro. **Instalar ≠ tradear.** Verifique sempre PGP e
> fontes oficiais.

---

## Comece aqui

**Este README é a única porta de entrada.** Siga a [trilha linear](#trilha-linear) passo a passo — um link
primário por etapa. No mesmo passo, use a coluna **Comandos** para o Playbook (só terminal).

Perdeu o fio? Vá direto ao [plano de contingência](#travou-aqui). Quer todos os capítulos? Abra o
[MANUAL-DO-CURSO.md](MANUAL-DO-CURSO.md) (opcional — novatos podem ignorar).

**Princípios:** [MANIFESTO.md](MANIFESTO.md) · Cold-Tails/Hot-Whonix como trilha principal (baixo custo).

---

## Eu quero…

| Objetivo | Comece no passo | Pasta |
|----------|-----------------|-------|
| **Tails + Haveno verde** no pendrive (portable) | [1](#trilha-linear) | `Tails-OS-Expert/` |
| **Carteira Monero + backup + boas práticas** | [4](#trilha-linear) → [5](#trilha-linear) | `Expansao-Curso/` |
| **Tradear no Haveno** (com cautela) | [5](#trilha-linear) | `Expansao-Curso/` |
| **Whonix online + custódia frio↔quente** | [8](#trilha-linear) (M1: passos 1–4 + Feather) | `Whonix-Online/` |
| **Automação** (instalar / backup / atualizar) | [7](#trilha-linear) · [MANUAL-SCRIPTS](MANUAL-SCRIPTS.md) | `Scripts/` |
| **Índice capítulo a capítulo** | [MANUAL-DO-CURSO.md](MANUAL-DO-CURSO.md) | raiz |

---

## Trilha linear

Do zero ao fluxo completo. **Não pule passos.** Avance só quando o “OK se” do passo atual for verdadeiro.

> **Regra:** livro = teoria e telas · Playbook = comandos no **mesmo** passo.
>
> **Coluna Comandos:** link = terminal ou ritual copiável. `imprimir` / `—` = sem bash (leitura, decisão ou teoria). Avance pelo Livro; abra Comandos no mesmo passo quando houver link.

| Passo | O que fazer | Livro (abrir) | Comandos |
|:-----:|-------------|---------------|----------|
| **1** | Gravar Tails + Tor + persistência | [Curso Vol I — Cap. 2](Tails-OS-Expert/Curso-Tails-OS-Expert.md#2-fundamentos-do-tails) | [Playbooks §1–4](Tails-OS-Expert/Playbooks/Playbooks.md) |
| **2** | Instalar Haveno até o **verde** | [Curso Vol I — Cap. 3](Tails-OS-Expert/Curso-Tails-OS-Expert.md#3-instalação-e-configuração-do-haveno-na-mão) | [haveno-setup.sh](Tails-OS-Expert/Scripts/haveno-setup.sh) · [Playbooks §5–6](Tails-OS-Expert/Playbooks/Playbooks.md) |
| **3** | Segurança (exploit / cautela) | [Curso Vol I — Cap. 4](Tails-OS-Expert/Curso-Tails-OS-Expert.md#4-segurança-exploit-corrigido-na-160-reto) | [Playbooks §3b](Tails-OS-Expert/Playbooks/Playbooks.md#3b--checklist-pré-trade-pós-verde) |
| **4** | Carteira, backup, pós-verde | [Curso Vol I — Cap. 5](Tails-OS-Expert/Curso-Tails-OS-Expert.md#5-próximos-passos-pós-verde) | [Playbooks §9](Tails-OS-Expert/Playbooks/Playbooks.md#9--backup-pós-verde) |
| **5** | Vol II: Feather + seed · **obrigatório p/ M2 (passo 8):** só Caps. 2–3 · **só se for tradear:** Caps. 7–8 | [Vol II — Antes do 1º trade](Tails-OS-Expert/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#antes-do-1º-trade--leia-só-isto-no-volume-ii) | [feather-install-verify.sh](Tails-OS-Expert/Scripts/feather-install-verify.sh) · [Playbooks Vol II](Tails-OS-Expert/Expansao-Curso/Playbooks-Rede-Descentralizada.md) |
| **6** | Regras de ouro + golpes (imprimir) | [Folheto](Tails-OS-Expert/Folheto-Regras-e-Golpes.md) | imprimir |
| **7** | Automação pós-verde | [Scripts — ciclo de uso](Tails-OS-Expert/Scripts/README.md) | [haveno-setup.sh --boot](Tails-OS-Expert/Scripts/haveno-setup.sh) · [Scripts README](Tails-OS-Expert/Scripts/README.md) |
| **8** | **M2** — mapa + escolher trilha A **ou** B | [00-Comece-aqui](Whonix-Online/00-Comece-aqui-Escolha-sua-trilha.md) | [00-Comece-aqui](Whonix-Online/00-Comece-aqui-Escolha-sua-trilha.md) |
| **9** | Backup air-gap (DUAS cópias seed) | [Curso Whonix — Cap. 5](Whonix-Online/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | [Playbook backup air-gap](Whonix-Online/Playbook-Backup-e-protecao-air-gap.md) |
| **10** | Instalar e verificar Whonix (PGP; detalhe por SO no Livro) | [Instalar por SO](Whonix-Online/Instalar-Whonix-passo-a-passo-por-SO.md) | [whonix-verify-image.sh](Whonix-Online/Scripts/whonix-verify-image.sh) · [Playbooks M2](Whonix-Online/Playbooks/Playbooks.md) |
| **11** | Teoria frio↔quente (modelo de ameaças) | [Curso Whonix — Cap. 5](Whonix-Online/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | — |
| **12** | Cold-signing — **escolha UMA** trilha | [Curso Whonix — §5.5](Whonix-Online/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | **A:** [Trilha A](Whonix-Online/Trilha-A-Feather/Playbook-Feather-GUI.md) · **B:** [Trilha B](Whonix-Online/Trilha-B-CLI/Playbook-monero-wallet-cli.md) |

> **Passo 8:** exige passos **1–4** + Feather ([Vol II Cap. 3](Tails-OS-Expert/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#3-feather-no-tails--instalar-e-verificar)) — **não** exige trade.

**Zoom do módulo:** [Tails-OS-Expert/README.md](Tails-OS-Expert/README.md) (passos 1–7) · [Whonix-Online/README.md](Whonix-Online/README.md) (passos 8–12).

---

## Trilha script-first (atalho)

Para quem quer **mão na massa** com o mínimo de teoria — **depois** dos passos 1–4 manuais (Tails no USB, Tor, persistência, admin):

| Objetivo | Comando (em `~/Persistent/`) | Ainda manual |
|----------|------------------------------|--------------|
| Haveno verde (1ª vez) | `haveno-setup.sh` | Passos 1–4 · confirmar **verde** na janela |
| Cada boot Haveno | `haveno-setup.sh --boot` | Indicador verde |
| Backup Haveno | `haveno-backup.sh` | Seed no papel |
| Feather (M2 pré-req) | `feather-install-verify.sh` | Criar carteira + seed |
| Whonix PGP (host Linux) | `whonix-verify-image.sh` | Importar VMs · cold-signing |
| Trades / M2 air-gap | — | Playbooks Vol II §4–8 · passos 9/12 |

> **~35–40%** dos comandos repetíveis têm script; **0%** dos rituais de custódia (seed, USB frio, conferir destino antes de assinar).

**Manual completo (novato):** [MANUAL-SCRIPTS.md](MANUAL-SCRIPTS.md) — o que cada script faz, flags (`--boot`, `--feather`, …), quando rodar e o que acontece se executar 2×.

Detalhe técnico: [Scripts/README.md](Tails-OS-Expert/Scripts/README.md) · [Whonix Scripts](Whonix-Online/Scripts/README.md).

---

## Trilhas opcionais

Só depois da trilha principal. **Não misture** com os passos 1–12.

| Trilha | Quando | Abrir | Pré-requisito |
|--------|--------|-------|---------------|
| Home Lab (nó + mineração) | Quer infra em Debian/Ubuntu | [Scripts/HomeLab](Tails-OS-Expert/Scripts/HomeLab/README.md) | Passo 5+ |
| Multisig 2-de-3 manual (educacional) | Entender escrow além do app | [Anexo CLI](Tails-OS-Expert/Expansao-Curso/Multisig-2-de-3-criacao-manual-CLI.md) | Vol II Cap. 10 |
| Hardware wallet (Trezor/Ledger) | Alternativa com custo extra | [Curso M2 §5.6](Whonix-Online/Curso-Whonix-Online.md#56-hardware-wallet-opcional) | Passo 12 |
| Zero-Trust-Core (baseline) | Cofre, PGP, backup 3-2-1 off-site | [GitHub ZTC](https://github.com/VIPs-com/Zero-Trust-Core) | M1 + idealmente M2 |

---

## Travou aqui?

Perdeu o fio? **Volte ao passo** da [trilha linear](#trilha-linear) — não abra dezenas de links soltos.

| Situação | Volte ao passo | Livro | Comandos |
|----------|----------------|-------|----------|
| Pendrive / Tor / persistência | **1** | [Curso Cap. 2](Tails-OS-Expert/Curso-Tails-OS-Expert.md#2-fundamentos-do-tails) | [Playbooks §1–4](Tails-OS-Expert/Playbooks/Playbooks.md) |
| Haveno não ficou verde | **2** | [Curso Cap. 7 FAQ](Tails-OS-Expert/Curso-Tails-OS-Expert.md#7-faq--erros-possíveis-após-rodar-os-scripts) | [Playbooks §8](Tails-OS-Expert/Playbooks/Playbooks.md) |
| Dúvida se pode tradear | **3** | [Curso Cap. 4](Tails-OS-Expert/Curso-Tails-OS-Expert.md#4-segurança-exploit-corrigido-na-160-reto) | [Playbooks §3b](Tails-OS-Expert/Playbooks/Playbooks.md#3b--checklist-pré-trade-pós-verde) |
| Seed / backup carteira Haveno | **4** | [Curso Cap. 5](Tails-OS-Expert/Curso-Tails-OS-Expert.md#5-próximos-passos-pós-verde) | [Playbooks §9](Tails-OS-Expert/Playbooks/Playbooks.md#9--backup-pós-verde) |
| Backup air-gap M2 | **9** | [Curso Cap. 5](Whonix-Online/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | [Playbook backup](Whonix-Online/Playbook-Backup-e-protecao-air-gap.md) |
| Feather / 1º trade | **5** | [Vol II Cap. 2–3](Tails-OS-Expert/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#2-haveno--primeira-conta-e-proteção-da-seed) | [Playbooks Vol II](Tails-OS-Expert/Expansao-Curso/Playbooks-Rede-Descentralizada.md) |
| Escolher trilha A ou B | **8** | [00-Comece-aqui](Whonix-Online/00-Comece-aqui-Escolha-sua-trilha.md) | [00-Comece-aqui](Whonix-Online/00-Comece-aqui-Escolha-sua-trilha.md) |
| Whonix / verificação PGP falhou | **10** | [Instalar §3.4 / §5.4](Whonix-Online/Instalar-Whonix-passo-a-passo-por-SO.md) | [Playbooks M2 §1](Whonix-Online/Playbooks/Playbooks.md) |
| Cold-signing travou | **12** | [Curso §5.5](Whonix-Online/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | [Trilha A](Whonix-Online/Trilha-A-Feather/Playbook-Feather-GUI.md) ou [Trilha B](Whonix-Online/Trilha-B-CLI/Playbook-monero-wallet-cli.md) |
| Sem nó `.onion` | **11** | [Curso Cap. 4.2](Whonix-Online/Curso-Whonix-Online.md#42-alternativa--nó-remoto-público-onion) | — |
| Mapa geral do hub | — | **Você está aqui** — [trilha linear](#trilha-linear) | — |

---

## Módulos

| # | Módulo | Estado | Índice do módulo |
|---|--------|--------|------------------|
| 1 | **Tails + Haveno** | ✅ Pronto | [Tails-OS-Expert/](Tails-OS-Expert/README.md) |
| 2 | **Whonix (online)** | 🟡 v1 | [Whonix-Online/](Whonix-Online/README.md) |
| — | **Zero-Trust-Core** (repo separado) | ✅ Publicado | [github.com/VIPs-com/Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core) |

### Arquitetura (visão)

- **Tails (offline)** → carteira fria, assinatura air-gap — trilha principal, sem hardware proprietário obrigatório.
- **Whonix (online)** → view-only, nó Monero, operações quentes via Tor.
- **Haveno** → trades quentes (escrow online); custódia frio/quente no passo 12.
- **Zero-Trust-Core** → baseline opcional; complementa M1/M2, não substitui.

---

## Baseline opcional — [Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core)

Use **depois** dos passos 1–12 se quiser cofres, PGP air-gap, backup off-site e SSH além deste hub.

| Material | Link |
|----------|------|
| Início | [INICIE AQUI](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/docs/INICIE-AQUI.md) |
| Livro | [Zero-Trust-Core-Expert](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/%F0%9F%8E%93%20Zero-Trust-Core-Expert%20-%20Vers%C3%A3o%201.0.md) |
| Playbooks | [playbooks/](https://github.com/VIPs-com/Zero-Trust-Core/tree/main/playbooks) |

> **Ordem sugerida:** passos 1–12 → ZTC (opcional). Integra com [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert).

---

## Licença

- **Scripts** (`*.sh`, `*.desktop`): **MIT** — [`LICENSE`](LICENSE).
- **Documentação:** **CC BY-SA 4.0** — [`LICENSE-DOCS.md`](LICENSE-DOCS.md).
