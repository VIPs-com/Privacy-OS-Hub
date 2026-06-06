# Módulo 2 — Whonix Online (lado em rede)

> **v1 — base verificada.** Cobre o essencial: o que é o Whonix, **instalar e verificar** a imagem,
> conectar Monero/Feather **via Tor**, e o **fluxo frio↔quente** com o Tails (Módulo 1). Onde os comandos
> exatos mudam por versão/SO, aponto a **fonte oficial** — confira sempre antes de executar.
>
> **Pré-requisito:** [Módulo 1](../Tails%20OS%20Expert/README.md) concluído (seed, carteira, escrow,
> verificação de binários). Este módulo é **complementar** ao Tails, não o substitui.

## Sumário

1. [O que é o Whonix (Gateway × Workstation)](#1-o-que-é-o-whonix)
2. [Instalar e verificar a imagem](#2-instalar-e-verificar-a-imagem)
3. [Primeiros passos e atualização](#3-primeiros-passos-e-atualização)
4. [Monero no Whonix — conectar via Tor](#4-monero-no-whonix--conectar-via-tor)
5. [Frio↔quente — carteira fria no Tails + watch-only no Whonix](#5-frioquente)
6. [Quando usar Whonix × Tails × home lab](#6-quando-usar-whonix--tails--home-lab)
7. [Links oficiais](#7-links-oficiais)

---

## 1. O que é o Whonix

Duas máquinas virtuais que trabalham juntas:

| VM | Papel |
|----|-------|
| **Whonix-Gateway** | Força **todo** o tráfego por **Tor**. É a única que fala com a rede. |
| **Whonix-Workstation** | Onde você trabalha (carteira, navegação). **Não** tem acesso direto à rede — só pelo Gateway. |

Consequência: mesmo um app comprometido na Workstation **não enxerga o seu IP real** — ele só alcança o Gateway, que só sai por Tor.

**Whonix × Tails (Módulo 1):** o Tails é **amnésico/efêmero** (esquece ao desligar) — ideal para o lado **offline/frio**. O Whonix é **persistente** (instalado numa VM no seu host) — ideal para o que precisa ficar **online e guardado**: carteira *watch-only*, navegação, conectar ao seu nó.

**OK se:** você sabe explicar Gateway (roteia tudo por Tor) × Workstation (trabalho isolado), e por que isso protege o seu IP.

---

## 2. Instalar e verificar a imagem

Baixe **só** de **whonix.org** ([Download](https://www.whonix.org/wiki/Download)). Plataformas (host):
**VirtualBox** (mais fácil), **KVM** (avançado, Linux) ou **Qubes-Whonix** (avançado).

> 🔒 **Verifique a imagem antes de importar** — mesma disciplina do Módulo 1 (binário não verificado = não roda).

1. Importe a **chave de assinatura do Whonix** (Patrick Schleizer / *derivative*):
   - Fingerprint: **`916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA`**
   - Chave pública: https://www.whonix.org/keys/derivative.asc
   - **Confira o fingerprint importando a chave** (`gpg --show-keys` / `--fingerprint`) — não apenas copiando.
2. Verifique a assinatura da imagem baixada:
   ```bash
   gpg --verify Whonix-*.asc Whonix-*   # deve dizer "Good signature"
   ```
3. Os **passos exatos por SO** (Linux/Windows/macOS) estão no guia oficial — ver §7.
4. Importe a imagem verificada no VirtualBox/KVM e inicie **Gateway + Workstation**.

**OK se:** `gpg --verify` diz **"Good signature"** com o fingerprint acima; o Gateway conecta ao Tor; a Workstation navega (e só consegue via Gateway).

> O Whonix **isola**, mas o **host** é a base de confiança: mantenha o host atualizado e não importe imagem não verificada.

---

## 3. Primeiros passos e atualização

- **Atualize** o Whonix (Gateway e Workstation) pelo gerenciador de pacotes, **via Tor** (já é o padrão) — siga o guia oficial de *Operating System Software Updates* (§7). Em geral: `sudo apt update && sudo apt full-upgrade`.
- **Não misture identidades:** não use e-mail real / logins pessoais na Workstation que você usa para privacidade (mesma regra do Módulo 1, Cap. 9).
- Faça **snapshots** da VM antes de mudanças grandes (recurso do host).

**OK se:** a atualização completa via Tor sem erro; você sabe que a Workstation é "limpa" (sem identidade clearnet).

---

## 4. Monero no Whonix — conectar via Tor

A orientação oficial do Whonix é usar **nó remoto via Tor** (não rodar um nó pesado dentro da Workstation). Carteiras: **Feather** ou Monero GUI.

**Melhor opção (fecha com o Módulo 1):** conecte ao **seu próprio nó** do home lab, publicado via Tor (`.onion:18089` — Módulo 1, Cap. 6). Assim você não depende de nó de terceiros.

- Na carteira → nó remoto: `SEU_ENDERECO.onion`, porta **18089**, marcar como **confiável**.

**Alternativa — nó remoto público (.onion).** Ressalva oficial do Whonix: o nó **não** pode gastar seu XMR (você tem as chaves), **não** vê seu IP (você conecta por Tor), **não** sabe seu endereço nem saldo. **Mas:** se a carteira avisar **"node misbehaving"**, **saia e troque de nó**.

**Feather no Whonix:** instale e **verifique o PGP** (fingerprint `8185E158A33330C7FD61BC0D1F76E155CEFBA71C` — ver Módulo 1, Playbook Vol II §2). Em Settings → Network: **"Always over Tor"**.

**OK se:** a carteira sincroniza via Tor pelo seu `.onion` (ou por um nó remoto), com saldo visível (0 XMR no início é normal).

---

## 5. Frio↔quente

Esta é a razão de o hub juntar **Tails + Whonix**: custódia com a chave **fria** no Tails e operação **quente** no Whonix.

```text
Tails (offline / FRIO)              Whonix (online / QUENTE)
 carteira completa     ──chave de visão / key images──►  carteira WATCH-ONLY
 (seed + chave gasto)                                     (vê saldo, MONTA tx)
        ▲                                                        │
        └────────────── transação para ASSINAR ◄────────────────┘
                 (assina OFFLINE no Tails, volta p/ transmitir no Whonix)
```

- **Frio (Tails):** a carteira completa (**seed + chave de gasto**) vive no Tails air-gapped (Módulo 1). **Nunca** vai para a internet.
- **Watch-only (Whonix):** uma carteira **view-only** (só a **chave de visão**) no Whonix vê o saldo e **monta** transações — mas **não assina** (não tem a chave de gasto).
- **Assinar (Tails):** a transação não-assinada vai para o Tails, é **assinada offline** e volta ao Whonix para **transmitir**.
- **Comandos oficiais** (não decore versões antigas): guias getmonero *"How to make a view-only wallet"* e *"How to make an offline backup (advanced)"* (§7); no `monero-wallet-cli` o fluxo usa `export_outputs` / `import_key_images` / `sign_transfer` / `submit_transfer`.

> ⚠️ **A seed / chave de gasto NUNCA entra no Whonix.** Se entrar, deixou de ser "fria". O par correto: **vê/monta no quente, assina no frio**.

> **Haveno é exceção:** o trade no Haveno é **quente** (o cliente precisa da carteira durante o escrow multisig). Este fluxo frio↔quente é para **custódia** (Feather/Monero), **não** para tradear no Haveno — para tradear, use o Módulo 1.

**OK se:** o Whonix mostra o saldo **sem** ter a chave de gasto; transações são assinadas **no Tails** e transmitidas pelo Whonix.

---

## 6. Quando usar Whonix × Tails × home lab

| Você quer… | Use |
|------------|-----|
| Operar/guardar **online e persistente** (watch-only, navegação, carteira leve) | **Whonix** (este módulo) |
| **Gerar/custodiar** a chave fria, **assinar offline**, uso efêmero | **Tails** (Módulo 1) |
| **Infra 24/7** (nó Monero, mineração) | **Home lab** (Módulo 1, Cap. 6) |
| **Tradear no Haveno** (quente) | **Tails** (Módulo 1) |

---

## 7. Links oficiais

| Tema | Link |
|------|------|
| Whonix (site) | https://www.whonix.org/ |
| Download | https://www.whonix.org/wiki/Download |
| **Verificar a imagem** | https://www.whonix.org/wiki/Verify_the_images |
| Chave de assinatura (`916B8D99…2EEACCDA`) | https://www.whonix.org/keys/derivative.asc |
| Atualização do sistema | https://www.whonix.org/wiki/Operating_System_Software_Updates |
| Monero no Whonix | https://www.whonix.org/wiki/Monero |
| Carteira view-only (getmonero) | https://www.getmonero.org/resources/user-guides/view_only.html |
| Backup offline / avançado (getmonero) | https://www.getmonero.org/resources/user-guides/Offline_Backup.html |
| Feather (Tor) | https://docs.featherwallet.org/guides/tor-support |
| **Módulo 1 — Tails + Haveno** | [`../Tails OS Expert/README.md`](../Tails%20OS%20Expert/README.md) |

---

*Privacy-OS-Hub · Módulo 2 (Whonix Online) — v1 base verificada (jun/2026). Aprofundamentos (passo a passo
por SO, Playbook de comandos) entram nas próximas versões. Sempre confirme os passos exatos nas fontes oficiais acima.*
