# Privacy-OS-Hub

Hub de **guias práticos de privacidade** — do pendrive vazio à custódia Monero com Tor, verificação PGP e
segurança operacional.

`tails` · `whonix` · `tor` · `monero` · `haveno` · `privacy` · `cold-wallet` · `2fa` · `pgp`

> ⚠️ **Uso educacional.** Não é aconselhamento financeiro. **Instalar ≠ tradear.** Verifique sempre PGP e
> fontes oficiais.

> 🔑 **Fingerprints PGP oficiais** — confira com seus próprios olhos antes de qualquer verificação:
>
> | Projeto | Fingerprint |
> |---------|------------|
> | Haveno / RetoSwap | `DAA2 4D87 8B8D 36C9 0120  A897 CA02 DAC1 2DAE 2D0F` |
> | Feather Wallet | `8185 E158 A333 30C7 FD61  BC0D 1F76 E155 CEFB A71C` |
> | Whonix | `916B 8D99 C38E AF5E 8ADC  7A2A 8D66 066A 2EEA CCDA` |
>
> Em sistemas PT-BR, `gpg` exibe **`Assinatura válida`** no lugar de `Good signature` — ambos significam a mesma coisa.

---

## Primeira visita?

Você **não precisa** conhecer Tails, Haveno, Feather ou Whonix antes de começar. Este hub assume **zero**
experiência e ensina **processo + ferramentas** na ordem certa.

| # | Faça isto | Para quê |
|:-:|-----------|----------|
| **1** | Abra a [trilha linear](#trilha-linear) e comece no **passo 1** | Um passo de cada vez — Livro (teoria/telas) + Comandos (mão na massa) |
| **2** | Nos passos **2** e **7**, se quiser automação: [MANUAL-SCRIPTS.md](MANUAL-SCRIPTS.md) | Dois comandos bastam (`haveno-setup.sh` e `--boot`); [Apêndice A](MANUAL-SCRIPTS.md#apêndice-a--catálogo-de-cada-arquivo-iniciante) explica cada `.sh` |
| **3** | Só avance quando o **OK se** do passo atual for verdadeiro | Evita pular backup, seed ou pré-requisito do Módulo 2 |
| **4** | (Opcional) Valide com **log**: `haveno-setup.sh --qa-log` → leia `~/Persistent/qa-logs/*.txt` | [COMO-LER-SEUS-LOGS.md](Tails-OS-Expert/Scripts/COMO-LER-SEUS-LOGS.md) — sem expor seed |

**O que você sai sabendo fazer (trilha completa):** Tails no pendrive · Haveno **verde** · backup cifrado ·
Feather (pré-requisito M2) · Whonix verificado · cold-signing (trilha A ou B). **Montar um lab em casa**
(nó, Tor, mineração) é **opcional** — [Home Lab](Tails-OS-Expert/Scripts/HomeLab/README.md) depois dos passos 1–12.

| Pode **ignorar** no início | Por quê |
|-----------------------------|---------|
| [MANUAL-DO-CURSO.md](MANUAL-DO-CURSO.md) | Índice de **todos** os capítulos — use só se quiser aprofundar |
| Trades (Vol II Caps. 7–8) | **Instalar ≠ tradear** — só se for usar a rede de troca |
| [Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core) | Baseline extra — depois da trilha principal |
| Pasta `HomeLab/` nos Scripts | Roda em **outro PC** (Debian/Ubuntu), não no Tails |

**Precisa de:** um PC para gravar o Tails, um pendrive, paciência no Tor (1ª vez pode demorar), e **papel**
para anotar a seed (nunca só no computador).

Perdeu o fio? [Travou aqui](#travou-aqui) · Quer só scripts? [Trilha script-first](#trilha-script-first) ·
Princípios do hub: [MANIFESTO.md](MANIFESTO.md).

---

## Já conhece o ecossistema?

Tails, Monero, Tor ou Whonix — **sem hand-holding:** mapa do repo, trilha compacta, opcionais e scripts diretos.

→ **[MANUAL-EXPERT.md](MANUAL-EXPERT.md)** (5 min)

| Novato | Expert |
|--------|--------|
| [Primeira visita?](#primeira-visita) · [MANUAL-SCRIPTS](MANUAL-SCRIPTS.md) | [MANUAL-EXPERT](MANUAL-EXPERT.md) · [trilha linear](#trilha-linear) |

---

## Comece aqui

**Este README é a única porta de entrada.** [Primeira visita?](#primeira-visita) → [trilha linear](#trilha-linear)
passo a passo. No mesmo passo: coluna **Livro** + coluna **Comandos**.

**Mapa de navegação (opcional):** a pasta [docs/](docs/README.md) organiza trilhas por modo, glossário online/offline e [cartões por passo](docs/passos/README.md) — só links; a ordem oficial continua na [trilha linear](#trilha-linear) abaixo.

---

## Eu quero…

| Objetivo | Comece no passo | Pasta |
|----------|-----------------|-------|
| **Primeira vez no hub** (não conheço as ferramentas) | [Primeira visita?](#primeira-visita) → [1](#trilha-linear) | este README |
| **Já expert** (mapa do hub em 5 min) | [MANUAL-EXPERT.md](MANUAL-EXPERT.md) | raiz |
| **Tails + Haveno verde** no pendrive (portable) | [1](#trilha-linear) | `Tails-OS-Expert/` |
| **Montar lab** (nó Monero, Tor, mineração) | [Trilhas opcionais](#trilhas-opcionais) · passo 5+ | `Scripts/HomeLab/` |
| **Carteira Monero + backup + boas práticas** | [4](#trilha-linear) → [5](#trilha-linear) | `Expansao-Curso/` |
| **Tradear no Haveno** (com cautela) | [5](#trilha-linear) | `Expansao-Curso/` |
| **Whonix online + custódia frio↔quente** | [8](#trilha-linear) (M1: passos 1–4 + Feather) | `Whonix-Online/` |
| **Automação** (instalar / backup / atualizar) | [7](#trilha-linear) · [MANUAL-SCRIPTS](MANUAL-SCRIPTS.md) | `Scripts/` |
| **Índice capítulo a capítulo** | [MANUAL-DO-CURSO.md](MANUAL-DO-CURSO.md) | raiz |

---

## Trilha linear

Do zero ao fluxo completo. **Não pule passos.** Avance só quando o “OK se” do passo atual for verdadeiro.

### Como lemos “online” e “offline” neste hub

| Termo | Significado |
|-------|-------------|
| **Online (Tor)** | Tails **com** internet só via Tor — passos **1–8** (Haveno, Feather, scripts). |
| **Offline (suporte)** | Seed em **papel/metal** — pode anotar com Tor ativo (passo **4**). Nunca foto, chat ou nuvem. |
| **Offline (rede / air-gap)** | Tails **sem** Wi‑Fi/cabo — passo **12** (cold-signing). Teste de restauração só com seed: **opcional**. |
| **Validação por log** | Scripts com `--qa-log` gravam `.txt` em `~/Persistent/qa-logs/` — [como ler](Tails-OS-Expert/Scripts/COMO-LER-SEUS-LOGS.md). |

> **Passo 9:** confirme que as **duas cópias físicas** da seed (passo 4) estão em locais separados — `qa-confirm-passo9.sh`. Não exige segundo boot offline no Mínimo M2.

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
| **9** | Confirmar **2× cópias físicas** da seed (ritual pós passo 4) | [Curso Whonix — Cap. 5](Whonix-Online/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | [qa-confirm-passo9.sh](Tails-OS-Expert/Scripts/qa-confirm-passo9.sh) · [Playbook backup](Whonix-Online/Playbook-Backup-e-protecao-air-gap.md) |
| **10** | Instalar e verificar Whonix (PGP; detalhe por SO no Livro) | [Instalar por SO](Whonix-Online/Instalar-Whonix-passo-a-passo-por-SO.md) | [whonix-verify-image.sh](Whonix-Online/Scripts/whonix-verify-image.sh) · [Playbooks M2](Whonix-Online/Playbooks/Playbooks.md) |
| **11** | Teoria frio↔quente (modelo de ameaças) | [Curso Whonix — Cap. 5](Whonix-Online/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | — |
| **12** | Cold-signing — **escolha UMA** trilha | [Curso Whonix — §5.5](Whonix-Online/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | **A:** [Trilha A](Whonix-Online/Trilha-A-Feather/Playbook-Feather-GUI.md) · **B:** [Trilha B](Whonix-Online/Trilha-B-CLI/Playbook-monero-wallet-cli.md) |

> **Passo 8:** exige passos **1–4** + Feather ([Vol II Cap. 3](Tails-OS-Expert/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#3-feather-no-tails--instalar-e-verificar)) — **não** exige trade.

**Zoom do módulo:** [Tails-OS-Expert/README.md](Tails-OS-Expert/README.md) (passos 1–7) · [Whonix-Online/README.md](Whonix-Online/README.md) (passos 8–12).

---

## Trilha script-first (atalho)

Para quem quer **mão na massa** com o mínimo de teoria — **depois** dos passos 1–4 manuais (Tails no USB, Tor, persistência, admin):

| Objetivo | Comando (em `~/Persistent/` ou host) | Ainda manual |
|----------|--------------------------------------|--------------|
| Haveno verde (1ª vez) | `haveno-setup.sh` · `--qa-log` | Passos 1–4 · confirmar **verde** na janela |
| Cada boot Haveno | `haveno-setup.sh --boot` · `--qa-log` | Indicador verde |
| Backup Haveno | `haveno-backup.sh` · `--qa-log` | Seed no papel → `qa-confirm-seed-papel.sh` |
| Feather (M2 pré-req) | `feather-install-verify.sh` · `--qa-log` | Criar carteira + seed |
| Passo 9 (2× cópias seed) | `qa-confirm-passo9.sh` | Ritual físico (Tails **com** Tor OK) |
| Passo 12 (cold-signing) | `qa-confirm-passo12.sh` | Air-gap real · Tails **sem** rede |
| Exportar logs (equipe) | `qa-export-logs.sh --usb` | 2º pendrive transitório |
| Whonix PGP (host Linux) | `whonix-verify-image.sh --qa-log` | Importar VMs |

> **~35–40%** dos comandos repetíveis têm script; rituais de custódia (seed em papel, USB frio, assinar offline) são **humanos** — os scripts `qa-confirm-*` só registram confirmações **sem** gravar segredos.

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
| 2× cópias físicas da seed | **9** | [Curso Cap. 5](Whonix-Online/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | [qa-confirm-passo9.sh](Tails-OS-Expert/Scripts/qa-confirm-passo9.sh) |
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

- **Tails (com Tor)** → passos 1–9: Haveno, Feather, backups, confirmações em papel.
- **Tails (sem rede)** → passo **12**: assinatura air-gap (único offline de rede obrigatório no Mínimo M2).
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
