# Privacy-OS-Hub

Hub de **guias práticos de privacidade** — do pendrive vazio à custódia Monero com Tor, verificação PGP e
segurança operacional.

`tails` · `whonix` · `tor` · `monero` · `haveno` · `privacy` · `cold-wallet` · `pgp`

> **v1.0 canônica** — material consolidado em arquivo único. [docs/CHANGELOG.md](docs/CHANGELOG.md)

> ⚠️ **Uso educacional.** Não é aconselhamento financeiro. **Instalar ≠ tradear.** Verifique sempre PGP e fontes oficiais.

> 🔑 **Fingerprints PGP oficiais** — confira antes de qualquer verificação:
>
> | Projeto | Fingerprint |
> |---------|------------|
> | Haveno / RetoSwap | `DAA2 4D87 8B8D 36C9 0120  A897 CA02 DAC1 2DAE 2D0F` |
> | Feather Wallet | `8185 E158 A333 30C7 FD61  BC0D 1F76 E155 CEFB A71C` |
> | Whonix | `916B 8D99 C38E AF5E 8ADC  7A2A 8D66 066A 2EEA CCDA` |
>
> Em sistemas PT-BR, `gpg` exibe **`Assinatura válida`** no lugar de `Good signature` — ambos significam a mesma coisa.

---

## Comece aqui

**Abra o arquivo canônico e siga os passos:**

### 👉 [`🛡️ Privacy-OS-Hub - Versão 1.0.md`](🛡️%20Privacy-OS-Hub%20-%20Versão%201.0.md)

Tudo em um único arquivo: passos 1–12 completos, comandos, checkpoints, apêndices e glossário.
**Sem precisar navegar entre pastas.**

---

## O que você vai aprender (12 passos)

```text
PARTE 1 (1–7)                         PARTE 2 (8–12)
┌─ Passos 1–3: Haveno 🟢 ─┐         Custódia fria 🔵
│ 1 Tails → 2 Verde → 3   │  ───►   8–12 · Trilha A ou B
└─ Passos 4–7: Pré-M2 🟡 ─┘
  4 seed · 5 Feather · 6–7 rotina
```

| # | Passo | Ferramenta | Resultado |
|:-:|-------|-----------|-----------|
| | **Passos 1–3 — Núcleo Haveno** | | |
| 1 | Bootstrap Tails | Tails Installer | USB pronto · Tor ativo · Persistência |
| 2 | Haveno Verde | Haveno 1.6.0-reto | Indicador ● VERDE |
| 3 | Cautela pré-trade | — | Regras e golpes internalizados |
| | **Passos 4–7 — Pré-M2** | | |
| 4 | Backup Seed | hub.sh backup | Seed em papel + backup cifrado |
| 5 | Feather Wallet | Feather AppImage | Carteira verificada por PGP |
| 6 | Folheto | — | Regras de ouro impressas |
| 7 | Rotina de scripts | hub.sh boot | Boot automatizado em < 5 min |
| | **Passos 8–12 — Custódia fria** | | |
| 8 | Porteiro: Trilha A ou B | — | Trilha escolhida conscientemente |
| 9 | Ritual Seed | qa/confirm-step9.sh | 2 cópias físicas em locais separados |
| 10 | Whonix + PGP | VirtualBox/KVM | "Tor Connected" no Workstation |
| 11 | Modelo frio↔quente | — | Air-gap internalizado |
| 12A | Feather Offline *(Trilha A)* | Feather (air-gap) | Cold-signing completo |
| 12B | CLI Offline *(Trilha B)* | monero-wallet-cli | Cold-signing via terminal |

---

## Estrutura do repositório

```
Privacy-OS-Hub/
│
├── 🛡️ Privacy-OS-Hub - Versão 1.0.md   ← ABRA AQUI (passos 1–12)
├── 🏠 Home-Lab - Versão 1.0.md          ← opcional (nó Monero, P2Pool, XMRig)
├── README.md                            ← você está aqui
│
├── automacao/                           ← scripts .sh para Tails e Whonix
│   ├── tails/                           ·  hub.sh · haveno/ feather/ system/ qa/ lib/ steps/
│   ├── whonix-host/                     ·  whonix-verify-image.sh
│   ├── homelab/                         ·  nó Monero (Debian/Ubuntu — NÃO Tails)
│   └── docs-aluno/                      ·  COMO-LER-SEUS-LOGS.md
│
└── docs/                                ← licenças e documentação de projeto
    ├── LICENSE · LICENSE-DOCS.md
    ├── MANIFESTO.md · CHANGELOG.md
    └── MANUAL.md
```

---

## Atalhos rápidos

| Você quer… | Abra |
|------------|------|
| Começar do zero | [`🛡️ Privacy-OS-Hub - Versão 1.0.md`](🛡️%20Privacy-OS-Hub%20-%20Versão%201.0.md) — Seção 0. ONBOARDING |
| Ir direto a um passo | Mesmo arquivo — busque `PASSO N` |
| Scripts (o que cada .sh faz) | [`docs/MANUAL.md`](docs/MANUAL.md#parte-ii--scripts-para-novato) ou Apêndice A no canônico |
| Mapa compacto para experts | [`docs/MANUAL.md`](docs/MANUAL.md#parte-i--mapa-rápido) |
| Home Lab (nó + mineração) | [`🏠 Home-Lab - Versão 1.0.md`](🏠%20Home-Lab%20-%20Versão%201.0.md) |
| Trilha script-first | Seção "Trilha script-first" no canônico |
| Instalar Whonix por SO | Apêndice E no canônico |
| Fingerprints PGP | Apêndice C no canônico (ou tabela acima) |
| Erros comuns | Apêndice B no canônico |

---

## Como ler "online" e "offline"

| Termo | Significado |
|-------|-------------|
| **Online (Tor)** | Tails com internet via Tor — passos 1–9 |
| **Offline (suporte)** | Seed em papel — passo 4. Nunca foto, chat ou nuvem. |
| **Offline (air-gap)** | Tails sem Wi-Fi/cabo — passo 12 (cold-signing) |
| **Log de validação** | `--qa-log` → `~/Persistent/qa-logs/*.txt` — [como ler](automacao/docs-aluno/COMO-LER-SEUS-LOGS.md) |

---

## Opcional: Home Lab e Zero-Trust-Core

**Só depois dos passos 1–12.**

| Opcional | Para quê | Abrir |
|----------|----------|-------|
| [🏠 Home Lab](🏠%20Home-Lab%20-%20Versão%201.0.md) | Nó Monero + P2Pool + XMRig em Debian/Ubuntu | arquivo canônico |
| [Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core) | Cofres, PGP air-gap, backup off-site, SSH | repo separado |
| [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert) | GPG completo — assinar, cifrar, subchaves | repo separado |

---

## Licença

- **Scripts** (`*.sh`, `*.desktop`): **MIT** — [`docs/LICENSE`](docs/LICENSE)
- **Documentação:** **CC BY-SA 4.0** — [`docs/LICENSE-DOCS.md`](docs/LICENSE-DOCS.md)
