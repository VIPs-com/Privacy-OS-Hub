# Manual do curso — índice completo (opcional)

> **Novato?** Ignore este arquivo. Comece em [README — Primeira visita?](../README.md#primeira-visita) e na [trilha linear](../README.md#trilha-linear).
>
> **Expert?** [MANUAL-EXPERT.md](MANUAL-EXPERT.md) — mapa do repo; este arquivo é só índice de capítulos.
>
> Na trilha linear, **Comandos** = [`processos/`](../processos/README.md) (P01–P12); este MANUAL lista **capítulos** do livro, não substitui os processos.
>
> **Scripts de automação:** use [MANUAL-SCRIPTS.md](MANUAL-SCRIPTS.md) (novato) — não este índice de capítulos.
>
> Este manual lista **todos os capítulos** para consulta ou aprofundamento. A ordem de estudo continua
> sendo a do README — não leia capítulo a capítulo fora de ordem.

**Mapa principal:** [README.md#trilha-linear](../README.md#trilha-linear) · **Repo (FIG-4):** [README § 4 camadas](../README.md#como-o-hub-esta-organizado-v2) · **Comandos:** [processos/](../processos/README.md) · **Travou?** [README.md#travou-aqui](../README.md#travou-aqui) · **Cartões:** [trilha/passos/](../trilha/passos/README.md) · **v2:** [CHANGELOG-V2.md](CHANGELOG-V2.md)

**Validar um passo (opcional):** scripts com `--qa-log` gravam `.txt` em `~/Persistent/qa-logs/` — [COMO-LER-SEUS-LOGS.md](../automacao/docs-aluno/COMO-LER-SEUS-LOGS.md). Glossário online/offline: [README — trilha linear](../README.md#trilha-linear).

### Processos por passo (comandos canônicos)

| Passo | Processo |
|:-----:|----------|
| 1–7 | [P01](../processos/m1-tor/P01-bootstrap-tails.md) … [P07](../processos/m1-tor/P07-rotina-scripts.md) |
| 8–12 | [P08](../processos/porteiro/P08-porteiro-trilha-ab.md) … [P12A](../processos/m2-frio/P12a-feather-offline.md) / [P12B](../processos/m2-frio/P12b-cli-offline.md) |

Matriz completa: [processos/README.md](../processos/README.md).

---

## Volume I — Tails + Haveno verde

Livro: [Curso-Tails-OS-Expert.md](../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md) · Comandos: [P01–P07](../processos/README.md) · Índice legado: [Playbooks](../modulos/m1-tails-haveno/Playbooks/Playbooks.md)

| Cap. | Título | Trilha README |
|------|--------|---------------|
| 1 | [Mapa do curso](../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#1-mapa-do-curso-visão-geral) | visão geral |
| 2 | [Fundamentos do Tails](../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#2-fundamentos-do-tails) | passo **1** |
| 3 | [Instalação do Haveno](../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#3-instalação-e-configuração-do-haveno-na-mão) | passo **2** |
| 4 | [Segurança (exploit)](../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#4-segurança-exploit-corrigido-na-160-reto) | passo **3** |
| 5 | [Pós-verde (carteira, backup)](../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#5-próximos-passos-pós-verde) | passo **4** |
| 6 | [Ecossistema Monero (apêndice)](../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#6-ecossistema-monero--tails-apêndice) | opcional |
| 7 | [FAQ — erros](../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#7-faq--erros-possíveis-após-rodar-os-scripts) | contingência |
| 8 | [Todos os links](../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#8-todos-os-links-referência-única) | referência |
| 9 | [Dicas e alertas finais](../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#9-dicas-e-alertas-finais--não-cair-em-roubadas) | passo **6** (com Folheto) |

---

## Volume II — Rede descentralizada (mão na massa)

> **Mínimo M2 (passo 8+):** caps. **2–3** obrigatórios · caps. **7–8** só se for **tradear** · resto = opcional.

Livro: [Curso-Rede-Descentralizada-Extensao.md](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md) · Feather (obrig.): [P05](../processos/m1-tor/P05-feather.md) · Trades (opcional): [Playbooks Vol II](../modulos/m1-tails-haveno/Expansao-Curso/Playbooks-Rede-Descentralizada.md)

| Cap. | Título | Obrigatório? | Trilha README |
|------|--------|--------------|---------------|
| 1 | [O que é rede descentralizada](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#1-o-que-é-rede-descentralizada-na-prática) | Contexto | passo **5** |
| 2 | [Primeira conta + seed](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#2-haveno--primeira-conta-e-proteção-da-seed) | **Sim** — antes do 1º depósito | passo **5** |
| 3 | [Feather no Tails](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#3-feather-no-tails--instalar-e-verificar) | **Sim** (M2 passo 8+) | passo **5** |
| 4 | [PGP na mão](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#4-pgp-na-mão--quando-o-script-falha-ou-você-quer-conferir) | Se script falhar | passo **5** |
| 5 | [Feather ↔ Haveno](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#5-feather--haveno--fluxo-de-xmr) | Antes de mover XMR | passo **5** |
| 6 | [Primeiro XMR](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#6-conseguir-o-primeiro-xmr-3-caminhos) | Se ainda não tem XMR | passo **5** |
| 7 | [Trade — comprar](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#7-trade-na-prática--comprar-xmr) | **Só se for tradear** | passo **5** |
| 8 | [Trade — vender](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#8-trade-na-prática--vender-xmr) | **Só se for tradear** | passo **5** |
| 9 | [Disputa](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#9-disputa--passo-a-passo) | Se precisar | passo **5** |
| 10 | [Multisig 2-de-3 (app vs você)](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#10-multisig-2-de-3--o-que-você-faz-vs-o-que-o-app-faz) | Opcional | opcional |
| 11 | [Métodos de pagamento](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#11-métodos-de-pagamento--riscos-reais) | Antes de tradear | passo **5** |
| 12 | [Outra rede Haveno](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#12-outra-rede-haveno-ex-aloha) | Opcional | opcional |
| 13 | [Home Lab integrado](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#13-home-lab-integrado--lab-completo) | Opcional | opcional · [HomeLab scripts](../automacao/homelab/README.md) |
| 14 | [Bisq no Tor](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#14-bisq-no-tor--introdução-prática) | Opcional | opcional |
| 15 | [Trocador](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#15-trocador--swap-passo-a-passo) | Opcional | opcional |
| 16 | [Atomic swaps](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#16-atomic-swaps--eigenwallet-e-basicswap) | Opcional | opcional |
| 17 | [Infra Haveno](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#17-infra-haveno--seednode-e-árbitro-panorama) | Opcional | opcional |
| 18 | [Atualizar Tails (SO)](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#18-atualizar-o-tails-sistema) | Manutenção | manutenção |
| 19 | [Links da extensão](../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#19-links-da-extensão) | Referência | referência |

**Anexo educacional:** [Multisig 2-de-3 criação manual CLI](../modulos/m1-tails-haveno/Expansao-Curso/Multisig-2-de-3-criacao-manual-CLI.md) · [Playbooks Multisig CLI](../modulos/m1-tails-haveno/Expansao-Curso/Playbooks-Multisig-CLI.md)

---

## Módulo 2 — Whonix Online

Livro: [Curso-Whonix-Online.md](../modulos/m2-whonix-custodia/Curso-Whonix-Online.md) · Comandos: [P08–P12](../processos/README.md) · Índice: [Playbooks M2](../modulos/m2-whonix-custodia/Playbooks/Playbooks.md)

| Cap. | Título | Trilha README | Comandos |
|------|--------|---------------|----------|
| — | [Porteiro — escolha trilha A ou B](../modulos/m2-whonix-custodia/00-Comece-aqui-Escolha-sua-trilha.md) | passo **8** | [P08](../processos/porteiro/P08-porteiro-trilha-ab.md) |
| — | [Confirmar 2× cópias seed](../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | passo **9** | [P09](../processos/rituais/P09-ritual-seed.md) |
| — | [Instalar por SO](../modulos/m2-whonix-custodia/Instalar-Whonix-passo-a-passo-por-SO.md) | passo **10** | [P10](../processos/m2-quente/P10-whonix-pgp.md) |
| 1 | [O que é Whonix](../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#1-o-que-é-o-whonix-e-o-modelo-de-ameaças) | passo **10–11** | — |
| 2 | [Instalar e verificar imagem](../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#2-instalar-e-verificar-a-imagem) | passo **10** | [P10](../processos/m2-quente/P10-whonix-pgp.md) |
| 3 | [Primeiros passos / snapshots](../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#3-primeiros-passos-atualização-e-snapshots) | passo **10** | [P10](../processos/m2-quente/P10-whonix-pgp.md) |
| 4 | [Monero via Tor](../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#4-monero-no-whonix--conectar-via-tor) | passo **11** | — |
| 5 | [Cold-Tails-Hot-Whonix](../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) | passo **11–12** | — |
| 5.6 | [Hardware wallet (opcional)](../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#56-hardware-wallet-opcional) | opcional | — |
| 6 | [Haveno na narrativa](../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#6-onde-o-haveno-entra) | passo **12** | [P12A](../processos/m2-frio/P12a-feather-offline.md) · [P12B](../processos/m2-frio/P12b-cli-offline.md) |
| 7 | [Whonix × Tails × home lab](../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#7-quando-usar) | referência | — |
| 8 | [Links oficiais](../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#8-links-oficiais) | referência | — |

**Cold-signing (escolha UMA):**

| Trilha | Processo | Detalhe (telas) |
|--------|----------|-----------------|
| A — Feather GUI | [P12A](../processos/m2-frio/P12a-feather-offline.md) | [Playbook-Feather-GUI](../modulos/m2-whonix-custodia/Trilha-A-Feather/Playbook-Feather-GUI.md) |
| B — monero-wallet-cli | [P12B](../processos/m2-frio/P12b-cli-offline.md) | [Playbook CLI](../modulos/m2-whonix-custodia/Trilha-B-CLI/Playbook-monero-wallet-cli.md) |

---

## Automação e folhetos

| Material | Arquivo | Trilha README |
|----------|---------|---------------|
| Scripts Tails (auto / backup / update) | [automacao/tails/README.md](../automacao/tails/README.md) · [P07](../processos/m1-tor/P07-rotina-scripts.md) | passo **7** |
| Validar com logs (`--qa-log`) | [COMO-LER-SEUS-LOGS.md](../automacao/docs-aluno/COMO-LER-SEUS-LOGS.md) | passos **2–12** |
| Home Lab (nó, P2Pool, xmrig) | [automacao/homelab/README.md](../automacao/homelab/README.md) | opcional |
| Proteção: cofre · PGP · backup 3-2-1 | [Baseline de proteção](../trilha/trilhas/opcionais-zero-trust-baseline.md) | opcional |
| Folheto regras + golpes | [Folheto-Regras-e-Golpes.md](../modulos/m1-tails-haveno/Folheto-Regras-e-Golpes.md) | passo **6** |

---

## Ecossistema externo (opcional)

| Material | Link |
|----------|------|
| Zero-Trust-Core | [github.com/VIPs-com/Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core) |
| OpenPGP-GPG do Zero ao Expert | [github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert) |

---

*Manual de índice · Privacy-OS-Hub · jun/2026. Ordem de estudo: sempre [README.md#trilha-linear](../README.md#trilha-linear).*
