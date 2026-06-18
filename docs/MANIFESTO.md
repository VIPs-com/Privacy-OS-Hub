# Manifesto — Privacy-OS-Hub

Princípios que orientam este ecossistema educacional de privacidade e custódia de Monero.

---

## 1. Verificação antes de confiança

Todo binário que entra no fluxo do aluno deve ser **verificável** (PGP, checksums assinados, fingerprints com fonte).
Scripts e playbooks seguem postura **fail-closed** onde possível. Exceções e TOFU são **documentados honestamente** —
nunca escondidos.

## 2. Cold-Tails, Hot-Whonix — trilha principal

A arquitetura central do hub é **custódia fria no Tails** (assinatura **sem rede** no passo 12) e **operação
view-only no Whonix online**, **sem depender de hardware proprietário caro**. Passos 1–9 rodam com **Tor ativo**;
a seed vai para **papel**, não para arquivo. Trezor/Ledger são **alternativa opcional** (custo extra), não pré-requisito.

## 3. Não omitir — o aluno escolhe o caminho

Caminhos avançados existem em **anexos dedicados** (CLI, multisig manual, home lab). O material não esconde
complexidade para parecer "mais seguro". Para trades no Haveno, o que importa está no fluxo principal; para
quem quer ir além, a documentação está lá — com avisos de risco.

## 4. Responsabilidade sua

O curso é **educacional**. Não promete segurança absoluta nem substitui julgamento humano. Seed em papel,
**duas cópias offline**, teste com **valor mínimo**, e migração quando a carteira deixa de ser fria — regras
repetidas nos momentos certos, não como marketing.

## 5. Transparência sobre limites

RetoSwap (TOFU), P2Pool (reproducible builds), relógio no `haveno-auto.sh`, `p2p-bind` no home lab — cada
compromisso de confiança é **nomeado** com mitigação. Golpes, exploit corrigido, KYC agregadores: explícitos
no Volume I e no Folheto.

## 6. Ecossistema

**Tails** guarda o grosso e **assina offline** (passo 12). **Whonix online** vê, monta e transmite. **Haveno** é a ponte para
trades quentes (escrow multisig automático). **[Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core)**
(repositório **separado**) oferece baseline opcional — cofre, PGP, backup, SSH — que **complementa** este hub
sem substituí-lo. Auditoria interna (rodadas documentadas) mantém o material vivo a cada release.

## 7. Documentação em camadas (v1.0)

O hub separa **curso** de **automação** e **documentação de projeto**:

| Camada | Onde | Papel |
|--------|------|-------|
| Porta | [README.md](../README.md) | Orientação inicial |
| Curso | [🛡️ Privacy-OS-Hub - Versão 1.0.md](../🛡️%20Privacy-OS-Hub%20-%20Versão%201.0.md) | Passos 1–12, tudo inline |
| Home Lab | [🏠 Home-Lab - Versão 1.0.md](../🏠%20Home-Lab%20-%20Versão%201.0.md) | Opcional — Debian/Ubuntu |
| Automação | [automacao/](../automacao/README.md) | Scripts → `~/Persistent/hub-scripts/` |
| Projeto | [docs/](README.md) | Manifesto, changelog, [MANUAL.md](MANUAL.md) |

**Regra:** o canônico é a fonte do curso; `docs/MANUAL.md` complementa scripts e mapa do repo. Histórico: [CHANGELOG.md](CHANGELOG.md).

---

*Privacy-OS-Hub · [README.md](../README.md) · [MANIFESTO](MANIFESTO.md) · Licença: [LICENSE-DOCS.md](LICENSE-DOCS.md) (CC BY-SA 4.0)*
