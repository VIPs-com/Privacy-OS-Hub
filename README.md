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
| 1 | **Tails + Haveno** — do pendrive ao indicador verde; trades P2P, Feather, home lab | ✅ Pronto | [Tails OS Expert/](Tails%20OS%20Expert/README.md) |
| 2 | **Whonix (online)** — instalar+verificar, Monero via Tor, **Cold-Tails-Hot-Whonix** (custódia frio↔quente) | 🟡 v1 | [Whonix-Online/](Whonix-Online/README.md) |
| — | **Zero-Trust-Core** — baseline de segurança (repo separado) | 🔗 Em breve | *Ainda não publicado — acompanhe este repositório.* |

### Arquitetura (visão)

- **Tails (offline / air-gapped)** → geração e **custódia da carteira fria** (assinatura offline) — trilha principal, **sem hardware proprietário obrigatório**.
- **Whonix (online)** → lado em rede: nó Monero, Feather *watch-only*, operações quentes.
- **Hardware wallet (Trezor/Ledger)** → alternativa **opcional** (custo extra) — ver Módulo 2 §5.6.
- **Zero-Trust-Core** → baseline comum de segurança ligando os módulos (*repositório ainda não publicado*).

> Nota: o **trade no Haveno é quente** (o escrow multisig exige o cliente online com a carteira). O split
> frio/quente brilha na **custódia**; o trade roda no lado online.

## Comece pelo Módulo 1 — [Tails + Haveno](Tails%20OS%20Expert/README.md)

| Material | Conteúdo |
|----------|----------|
| **Volume I** — [Curso — Tails OS Expert.md](Tails%20OS%20Expert/Curso%20—%20Tails%20OS%20Expert.md) | Tails + Haveno **verde** + fundamentos + segurança (exploit) + FAQ |
| **Volume II** — [Expansão Curso/](Tails%20OS%20Expert/Expansão%20Curso/Curso%20—%20Rede%20Descentralizada%20(Extensão).md) | Trades P2P, carteira Feather, home lab, ecossistema Monero |
| **Playbooks** — [Vol I](Tails%20OS%20Expert/Playbooks/Playbooks.md) · [Vol II](Tails%20OS%20Expert/Expansão%20Curso/Playbooks%20—%20Rede%20Descentralizada.md) | Só comandos, direto ao ponto |
| **Folheto** — [Regras e Golpes](Tails%20OS%20Expert/Folheto%20—%20Regras%20e%20Golpes.md) | 1 página imprimível (regras de ouro + golpes) |
| **Scripts** — [Tails](Tails%20OS%20Expert/Scripts/README.md) · [Home Lab](Tails%20OS%20Expert/Scripts/HomeLab/README.md) | Automação (instalar/backup/atualizar) + infraestrutura |

## Módulo 2 — [Whonix (online)](Whonix-Online/README.md)

Requer **Módulo 1 concluído** (Haveno verde + Feather no Tails + verificação PGP).

| Material | Conteúdo |
|----------|----------|
| **Porteiro** — [`00 — Comece aqui…`](Whonix-Online/00%20—%20Comece%20aqui%20—%20Escolha%20sua%20trilha.md) | Pré-requisitos, backup air-gap, escolha Trilha A ou B |
| **Livro** — [Curso — Whonix Online.md](Whonix-Online/Curso%20—%20Whonix%20Online.md) | Instalar, Tor, nó Monero, cold-signing, Haveno quente |
| **Instalação por SO** — [Instalar Whonix…](Whonix-Online/Instalar%20Whonix%20—%20passo%20a%20passo%20por%20SO.md) | VirtualBox / KVM + verificação PGP + troubleshooting |
| **Playbooks M2** — [Playbooks/Playbooks.md](Whonix-Online/Playbooks/Playbooks.md) | Só comandos + tabela **Travou aqui?** |
| **Backup air-gap** — [Playbook — Backup…](Whonix-Online/Playbook%20—%20Backup%20e%20proteção%20(air-gap).md) | DUAS cópias seed offline (trilha principal, sem HW obrigatório) |
| **Trilha A (GUI)** / **Trilha B (CLI)** | Feather view-only ↔ Tails offline · ou `monero-wallet-cli` |

## Licença

- **Scripts** (`*.sh`, `*.desktop`): **MIT** — [`LICENSE`](LICENSE).
- **Documentação/conteúdo** (guias, Playbooks, diagramas, cartaz): **CC BY-SA 4.0** — [`LICENSE-DOCS.md`](LICENSE-DOCS.md).
