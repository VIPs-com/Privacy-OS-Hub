# Privacy-OS-Hub

Hub de **guias práticos de privacidade** — do pendrive vazio à custódia Monero com Tor, verificação PGP e
segurança operacional.

`tails` · `whonix` · `tor` · `monero` · `haveno` · `privacy` · `cold-wallet` · `2fa` · `pgp`

> **v2.0.0-beta** — reorganização em `trilha/` · `modulos/` · `processos/` · `automacao/`. [CHANGELOG-V2.md](CHANGELOG-V2.md)

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
| **4** | (Opcional) Valide com **log**: `haveno-setup.sh --qa-log` → leia `~/Persistent/qa-logs/*.txt` | [COMO-LER-SEUS-LOGS.md](automacao/docs-aluno/COMO-LER-SEUS-LOGS.md) — sem expor seed |

**O que você sai sabendo fazer (trilha completa):** Tails no pendrive · Haveno **verde** · backup cifrado ·
Feather (pré-requisito M2) · Whonix verificado · cold-signing (trilha A ou B). **Montar um lab em casa**
(nó, Tor, mineração) é **opcional** — [Home Lab](automacao/homelab/README.md) depois dos passos 1–12.

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

**Mapa de navegação (opcional):** a pasta [trilha/](trilha/README.md) organiza trilhas por modo, glossário online/offline e [cartões por passo](trilha/passos/README.md) — só links; a ordem oficial continua na [trilha linear](#trilha-linear) abaixo.

---

## Eu quero…

| Objetivo | Comece no passo | Pasta |
|----------|-----------------|-------|
| **Primeira vez no hub** (não conheço as ferramentas) | [Primeira visita?](#primeira-visita) → [1](#trilha-linear) | este README |
| **Já expert** (mapa do hub em 5 min) | [MANUAL-EXPERT.md](MANUAL-EXPERT.md) | raiz |
| **Tails + Haveno verde** no pendrive (portable) | [1](#trilha-linear) | `modulos/m1-tails-haveno/` |
| **Montar lab** (nó Monero, Tor, mineração) | [Trilhas opcionais](#trilhas-opcionais) · passo 5+ | `automacao/homelab/` |
| **Carteira Monero + backup + boas práticas** | [4](#trilha-linear) → [5](#trilha-linear) | `modulos/m1-tails-haveno/Expansao-Curso/` |
| **Tradear no Haveno** (com cautela) | [5](#trilha-linear) | `modulos/m1-tails-haveno/Expansao-Curso/` |
| **Whonix online + custódia frio↔quente** | [8](#trilha-linear) (M1: passos 1–4 + Feather) | `modulos/m2-whonix-custodia/` |
| **Automação** (instalar / backup / atualizar) | [7](#trilha-linear) · [MANUAL-SCRIPTS](MANUAL-SCRIPTS.md) | [automacao/](automacao/README.md) |
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
| **Validação por log** | Scripts com `--qa-log` gravam `.txt` em `~/Persistent/qa-logs/` — [como ler](automacao/docs-aluno/COMO-LER-SEUS-LOGS.md). |

> **Passo 9:** confirme que as **duas cópias físicas** da seed (passo 4) estão em locais separados — `qa-confirm-passo9.sh`. Não exige segundo boot offline no Mínimo M2.

> **Regra:** livro = teoria e telas · **[processos/](processos/README.md) = comandos canônicos** (P01–P12) · Playbooks nos módulos = índice legado.
>
> **Coluna Comandos:** abra o **processo** do passo; `imprimir` / `—` = sem bash. Cartões com OK se: [trilha/passos/](trilha/passos/README.md).

| Passo | O que fazer | Livro (abrir) | Comandos |
|:-----:|-------------|---------------|----------|
| **1** | Gravar Tails + Tor + persistência | [Curso Vol I — Cap. 2](modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#2-fundamentos-do-tails) | [P01](processos/m1-tor/P01-bootstrap-tails.md) |
| **2** | Instalar Haveno até o **verde** | [Curso Vol I — Cap. 3](modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#3-instalação-e-configuração-do-haveno-na-mão) | [P02](processos/m1-tor/P02-haveno-verde.md) |
| **3** | Segurança (exploit / cautela) | [Curso Vol I — Cap. 4](modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#4-segurança-exploit-corrigido-na-160-reto) | [P03](processos/m1-tor/P03-pre-trade.md) |
| **4** | Carteira, backup, pós-verde | [Curso Vol I — Cap. 5](modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#5-próximos-passos-pós-verde) | [P04](processos/m1-tor/P04-backup-seed.md) |
| **5** | Vol II: Feather + seed · **obrigatório p/ M2 (passo 8):** só Caps. 2–3 · **só se for tradear:** Caps. 7–8 | [Vol II — Antes do 1º trade](modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#antes-do-1º-trade--leia-só-isto-no-volume-ii) | [P05](processos/m1-tor/P05-feather.md) |
| **6** | Regras de ouro + golpes (imprimir) | [Folheto](modulos/m1-tails-haveno/Folheto-Regras-e-Golpes.md) | [P06](processos/m1-tor/P06-folheto.md) |
| **7** | Automação pós-verde | [Scripts — ciclo de uso](automacao/tails/README.md) | [P07](processos/m1-tor/P07-rotina-scripts.md) |
| **8** | **M2** — mapa + escolher trilha A **ou** B | [00-Comece-aqui](modulos/m2-whonix-custodia/00-Comece-aqui-Escolha-sua-trilha.md) | [P08](processos/porteiro/P08-porteiro-trilha-ab.md) |
| **9** | Confirmar **2× cópias físicas** da seed (ritual pós passo 4) | [Curso Whonix — Cap. 5](modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | [P09](processos/rituais/P09-ritual-seed.md) |
| **10** | Instalar e verificar Whonix (PGP; detalhe por SO no Livro) | [Instalar por SO](modulos/m2-whonix-custodia/Instalar-Whonix-passo-a-passo-por-SO.md) | [P10](processos/m2-quente/P10-whonix-pgp.md) |
| **11** | Teoria frio↔quente (modelo de ameaças) | [Curso Whonix — Cap. 5](modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | [P11](processos/m2-quente/P11-modelo-frio-quente.md) |
| **12** | Cold-signing — **escolha UMA** trilha | [Curso Whonix — §5.5](modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | [P12A](processos/m2-frio/P12a-feather-offline.md) · [P12B](processos/m2-frio/P12b-cli-offline.md) |

> **Passo 8:** exige passos **1–4** + Feather ([Vol II Cap. 3](modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#3-feather-no-tails--instalar-e-verificar)) — **não** exige trade.

**Zoom do módulo:** [modulos/m1-tails-haveno/README.md](modulos/m1-tails-haveno/README.md) (passos 1–7) · [modulos/m2-whonix-custodia/README.md](modulos/m2-whonix-custodia/README.md) (passos 8–12).

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

Detalhe técnico: [Scripts/README.md](automacao/tails/README.md) · [Whonix Scripts](automacao/whonix-host/README.md).

---

## Trilhas opcionais

Só depois da trilha principal. **Não misture** com os passos 1–12.

| Trilha | Quando | Abrir | Pré-requisito |
|--------|--------|-------|---------------|
| Home Lab (nó + mineração) | Quer infra em Debian/Ubuntu | [Scripts/HomeLab](automacao/homelab/README.md) | Passo 5+ |
| Multisig 2-de-3 manual (educacional) | Entender escrow além do app | [Anexo CLI](modulos/m1-tails-haveno/Expansao-Curso/Multisig-2-de-3-criacao-manual-CLI.md) | Vol II Cap. 10 |
| Hardware wallet (Trezor/Ledger) | Alternativa com custo extra | [Curso M2 §5.6](modulos/m2-whonix-custodia/Curso-Whonix-Online.md#56-hardware-wallet-opcional) | Passo 12 |
| Zero-Trust-Core (baseline) | Cofre, PGP, backup 3-2-1 off-site | [GitHub ZTC](https://github.com/VIPs-com/Zero-Trust-Core) | M1 + idealmente M2 |

---

## Travou aqui?

Perdeu o fio? **Volte ao passo** da [trilha linear](#trilha-linear) — não abra dezenas de links soltos.

| Situação | Volte ao passo | Livro | Comandos |
|----------|----------------|-------|----------|
| Pendrive / Tor / persistência | **1** | [Curso Cap. 2](modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#2-fundamentos-do-tails) | [P01](processos/m1-tor/P01-bootstrap-tails.md) |
| Haveno não ficou verde | **2** | [Curso Cap. 7 FAQ](modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#7-faq--erros-possíveis-após-rodar-os-scripts) | [P02 §8](processos/m1-tor/P02-haveno-verde.md) |
| Dúvida se pode tradear | **3** | [Curso Cap. 4](modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#4-segurança-exploit-corrigido-na-160-reto) | [P03](processos/m1-tor/P03-pre-trade.md) |
| Seed / backup carteira Haveno | **4** | [Curso Cap. 5](modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#5-próximos-passos-pós-verde) | [P04](processos/m1-tor/P04-backup-seed.md) |
| 2× cópias físicas da seed | **9** | [Curso Cap. 5](modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | [P09](processos/rituais/P09-ritual-seed.md) |
| Feather / 1º trade | **5** | [Vol II Cap. 2–3](modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#2-haveno--primeira-conta-e-proteção-da-seed) | [Playbooks Vol II](modulos/m1-tails-haveno/Expansao-Curso/Playbooks-Rede-Descentralizada.md) |
| Escolher trilha A ou B | **8** | [00-Comece-aqui](modulos/m2-whonix-custodia/00-Comece-aqui-Escolha-sua-trilha.md) | [P08](processos/porteiro/P08-porteiro-trilha-ab.md) |
| Whonix / verificação PGP falhou | **10** | [Instalar §3.4 / §5.4](modulos/m2-whonix-custodia/Instalar-Whonix-passo-a-passo-por-SO.md) | [P10](processos/m2-quente/P10-whonix-pgp.md) |
| Cold-signing travou | **12** | [Curso §5.5](modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | [P12A](processos/m2-frio/P12a-feather-offline.md) ou [P12B](processos/m2-frio/P12b-cli-offline.md) |
| Sem nó `.onion` | **11** | [Curso Cap. 4.2](modulos/m2-whonix-custodia/Curso-Whonix-Online.md#42-alternativa--nó-remoto-público-onion) | — |
| Mapa geral do hub | — | **Você está aqui** — [trilha linear](#trilha-linear) | — |

---

## Módulos

| # | Módulo | Estado | Índice do módulo |
|---|--------|--------|------------------|
| 1 | **Tails + Haveno** | ✅ Pronto | [modulos/m1-tails-haveno/](modulos/m1-tails-haveno/README.md) |
| 2 | **Whonix (online)** | 🟡 v1 | [modulos/m2-whonix-custodia/](modulos/m2-whonix-custodia/README.md) |
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
| Início | [INICIE AQUI](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/trilha/INICIE-AQUI.md) |
| Livro | [Zero-Trust-Core-Expert](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/%F0%9F%8E%93%20Zero-Trust-Core-Expert%20-%20Vers%C3%A3o%201.0.md) |
| Playbooks | [playbooks/](https://github.com/VIPs-com/Zero-Trust-Core/tree/main/playbooks) |

> **Ordem sugerida:** passos 1–12 → ZTC (opcional). Integra com [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert).

---

## Licença

- **Scripts** (`*.sh`, `*.desktop`): **MIT** — [`LICENSE`](LICENSE).
- **Documentação:** **CC BY-SA 4.0** — [`LICENSE-DOCS.md`](LICENSE-DOCS.md).
