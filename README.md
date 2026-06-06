# Privacy-OS-Hub

Hub de **guias práticos de privacidade** sobre sistemas operacionais anônimos — do pendrive vazio à
operação real, com Tor, verificação e segurança. Começa pelo **Tails + Haveno** (DEX de Monero) e
cresce para **Whonix** (lado online) e o baseline **Zero-Trust**.

`tails` · `whonix` · `tor` · `monero` · `haveno` · `privacy` · `cold-wallet` · `2fa` · `pgp`

> ⚠️ **Uso educacional.** Material para aprender software livre de privacidade (Tails, Tor, Monero,
> Haveno, Whonix). Não é aconselhamento financeiro. **Instalar ≠ tradear**: tradear é decisão sua, na
> versão corrigida e com cautela. **Verifique sempre PGP / fontes oficiais.**

## Módulos

| # | Módulo | Estado | Abrir |
|---|--------|--------|-------|
| 1 | **Tails + Haveno** — do pendrive ao indicador verde; trades P2P, Feather, home lab | ✅ Pronto | [Tails OS Expert/](Tails%20OS%20Expert/README.md) |
| 2 | **Whonix (online)** — lado em rede: nó Monero, navegação, *hot wallet* | 🛠️ Planejado | — |
| — | **Zero-Trust-Core** — baseline de segurança (repo separado) | 🔗 Externo | — |

### Arquitetura (visão)

- **Tails (offline / air-gapped)** → geração e **custódia da carteira fria** (assinatura offline).
- **Whonix (online)** → lado em rede: nó Monero, Feather *watch-only*, operações quentes.
- **Zero-Trust-Core** → baseline comum de segurança ligando os módulos.

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

## Licença

- **Scripts** (`*.sh`, `*.desktop`): **MIT** — [`LICENSE`](LICENSE).
- **Documentação/conteúdo** (guias, Playbooks, diagramas, cartaz): **CC BY-SA 4.0** — [`LICENSE-DOCS.md`](LICENSE-DOCS.md).
