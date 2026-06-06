# Privacy-OS-Hub

Hub de **guias práticos de privacidade** sobre sistemas operacionais anônimos — do pendrive vazio à
operação real, com Tor, verificação e segurança. Começa pelo **Tails + Haveno** (DEX de Monero) e
cresce para **Whonix** (lado online) e o baseline **Zero-Trust**.

`tails` · `whonix` · `tor` · `monero` · `haveno` · `privacy` · `cold-wallet` · `2fa` · `pgp`

> ⚠️ **Uso educacional.** Material para aprender software livre de privacidade (Tails, Tor, Monero,
> Haveno, Whonix). Não é aconselhamento financeiro. **Instalar ≠ tradear**: tradear é decisão sua, na
> versão corrigida e com cautela. **Verifique sempre PGP / fontes oficiais.**

**Princípios do hub:** [MANIFESTO.md](MANIFESTO.md) — verificação antes de confiança, Cold-Tails/Hot-Whonix
como trilha principal (baixo custo), não omitir caminhos avançados, responsabilidade sua.

## Módulos

| # | Módulo | Estado | Abrir |
|---|--------|--------|-------|
| 1 | **Tails + Haveno** — do pendrive ao indicador verde; trades P2P, Feather, home lab | ✅ Pronto | [Tails-OS-Expert/](Tails-OS-Expert/README.md) |
| 2 | **Whonix (online)** — instalar+verificar, Monero via Tor, **Cold-Tails-Hot-Whonix** (custódia frio↔quente) | 🟡 v1 | [Whonix-Online/](Whonix-Online/README.md) |
| — | **Zero-Trust-Core** — baseline de segurança (**repo separado**, complementar) | ✅ Publicado | [github.com/VIPs-com/Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core) |

### Arquitetura (visão)

- **Tails (offline / air-gapped)** → geração e **custódia da carteira fria** (assinatura offline) — trilha principal, **sem hardware proprietário obrigatório**.
- **Whonix (online)** → lado em rede: nó Monero, Feather *watch-only*, operações quentes.
- **Hardware wallet (Trezor/Ledger)** → alternativa **opcional** (custo extra) — ver Módulo 2 §5.6.
- **[Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core)** → baseline **opcional** (KeePassXC, VeraCrypt, PGP air-gap, SSH, backup 3-2-1-1-0). **Complementa** M1/M2; não substitui a trilha Haveno nem é pré-requisito.

> Nota: o **trade no Haveno é quente** (o escrow multisig exige o cliente online com a carteira). O split
> frio/quente brilha na **custódia**; o trade roda no lado online.

## 🧭 Trilha completa do aluno (hub)

```text
  MÓDULO 1 — Tails + Haveno                    MÓDULO 2 — Whonix (online)
  ─────────────────────────                    ───────────────────────────
  1. Volume I (verde)          ───────────►   0. Porteiro (escolha trilha)
  2. Volume II (Feather/trades)                1. Backup air-gap
  3. Folheto (imprimir)                        2. Instalar Whonix
  4. Scripts (pós-verde)                       3. Livro + Playbooks
                                               4. Trilha A OU B (cold-signing)
```

### Módulo 1 — [Tails + Haveno](Tails-OS-Expert/README.md) ✅

| Passo | Material | Conteúdo |
|:-----:|----------|----------|
| **1** | [Curso-Tails-OS-Expert.md](Tails-OS-Expert/Curso-Tails-OS-Expert.md) + [Playbooks Vol I](Tails-OS-Expert/Playbooks/Playbooks.md) | Pendrive → Tails → Haveno **verde** |
| **2** | [Expansao-Curso/](Tails-OS-Expert/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md) + [Playbooks Vol II](Tails-OS-Expert/Expansao-Curso/Playbooks-Rede-Descentralizada.md) | Feather, trades, home lab |
| **3** | [Folheto-Regras-e-Golpes.md](Tails-OS-Expert/Folheto-Regras-e-Golpes.md) | 1 página imprimível |
| **4** | [Scripts](Tails-OS-Expert/Scripts/README.md) · [Home Lab](Tails-OS-Expert/Scripts/HomeLab/README.md) | Automação + infra (opcional) |

### Módulo 2 — [Whonix (online)](Whonix-Online/README.md) 🟡

Requer **Módulo 1 concluído**.

| Passo | Material | Conteúdo |
|:-----:|----------|----------|
| **0** | [00-Comece-aqui-Escolha-sua-trilha.md](Whonix-Online/00-Comece-aqui-Escolha-sua-trilha.md) | Mapa + pré-requisitos |
| **1** | [Playbook-Backup-e-protecao-air-gap.md](Whonix-Online/Playbook-Backup-e-protecao-air-gap.md) | DUAS cópias seed offline |
| **2** | [Instalar-Whonix-passo-a-passo-por-SO.md](Whonix-Online/Instalar-Whonix-passo-a-passo-por-SO.md) | VirtualBox/KVM + PGP |
| **3** | [Curso-Whonix-Online.md](Whonix-Online/Curso-Whonix-Online.md) + [Playbooks](Whonix-Online/Playbooks/Playbooks.md) | Teoria + comandos |
| **4** | **Trilha A** [Feather](Whonix-Online/Trilha-A-Feather/Playbook-Feather-GUI.md) **ou** **Trilha B** [CLI](Whonix-Online/Trilha-B-CLI/Playbook-monero-wallet-cli.md) | Cold-Tails-Hot-Whonix |

## Baseline opcional — [Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core)

Repositório **separado** na organização [VIPs-com](https://github.com/VIPs-com). Use **depois** de M1 (e idealmente M2) se quiser endurecer cofres, identidade PGP, backup off-site e SSH além do que este hub já cobre.

| Material | Conteúdo |
|----------|----------|
| **Início** | [INICIE AQUI](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/docs/INICIE-AQUI.md) · livro [Zero-Trust-Core-Expert](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/%F0%9F%8E%93%20Zero-Trust-Core-Expert%20-%20Vers%C3%A3o%201.0.md) |
| **Playbooks** | [playbooks/](https://github.com/VIPs-com/Zero-Trust-Core/tree/main/playbooks) (cofre · PGP · backup) |
| **Tails / Whonix** | Guias próprios no ZTC — ângulo *baseline*; o **M2 deste hub** foca cold-signing e custódia Monero |

> **Ordem sugerida:** M1 → M2 → ZTC (opcional). Integra bem com [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert).

## Licença

- **Scripts** (`*.sh`, `*.desktop`): **MIT** — [`LICENSE`](LICENSE).
- **Documentação/conteúdo** (guias, Playbooks, diagramas, cartaz): **CC BY-SA 4.0** — [`LICENSE-DOCS.md`](LICENSE-DOCS.md).
