# 🛡️ Privacy-OS-Hub – VERSÃO 1.0 (canônica)

**Software de referência:** Tails **7.8.1+** · Haveno / RetoSwap **1.6.0-reto** · Feather Wallet (AppImage Tails, versão atual) · Whonix **18.1.4.2 LXQt**

**Metodologia:** Execute. Veja a mágica. Depois entenda.
- Comandos primeiro, teoria depois
- 🔴 Perigo | 🟡 Atenção | 🟢 Padrão | 🔵 Expert
- Tudo inline — sem links entre arquivos
- Checkpoints obrigatórios ao final de cada parte

**Status:** VERSÃO 1.0 — material canônico único · PT-BR consistente

---

> **Nota editorial:** Este é o arquivo único oficial do Privacy-OS-Hub. Todo o conteúdo de processos, módulos, automação e referência foi consolidado aqui. Não há outros arquivos para "ver mais". Se você está lendo isto, está no lugar certo.

---

## 📐 Para quem mantém este arquivo

Este arquivo é a **fonte única** do curso. Para scripts e mapa do repositório, veja `docs/MANUAL.md`. Para automação, `automacao/tails/README.md`. Links externos permitidos apenas para fontes oficiais (tails.net, haveno.exchange, featherwallet.org, whonix.org, getmonero.org) e fingerprints.

---

## 📌 0. ONBOARDING

### 🎓 Carta do Professor/Mantenedor

Você vai sair do zero — pendrive vazio, nunca ouviu falar de Tails, Haveno ou Feather — e chegar a uma custódia Monero completa, com air-gap, verificação PGP e operação frio↔quente. O método é simples: execute primeiro, entenda depois. Cada passo tem um "OK se" — só avance quando ele for verdadeiro. Não pule passos. Não existe atalho seguro para custódia de dinheiro.

Este material foi auditado em múltiplas rodadas (red team + blue team + equipe pedagógica + equipe técnica) e validado em Tails real. Os comandos funcionam. Se algo der errado, o Apêndice B tem os erros mais comuns.

**Filosofia:** "Execute. Veja a mágica. Depois entenda."

### 🎯 Resultados esperados

| Passo | Habilidade adquirida | Nível |
|:-----:|---------------------|:-----:|
| 1 | Tails gravado, Tor ativo, persistência com Dotfiles | 🟢 |
| 2 | Haveno instalado com indicador verde | 🟢 |
| 3 | Entender exploit corrigido e a diferença instalar vs tradear | 🟢 |
| 4 | Seed em papel + backup cifrado da Data/ | 🟢 |
| 5 | Feather Wallet instalado e verificado por PGP | 🟢 |
| 6 | Regras de ouro e golpes memorizados | 🟢 |
| 7 | Rotina de boot automatizada | 🟢 |
| 8 | Escolha consciente entre Trilha A (Feather GUI) e Trilha B (CLI) | 🔵 |
| 9 | Duas cópias físicas da seed em locais separados | 🔵 |
| 10 | Whonix instalado e verificado por PGP | 🔵 |
| 11 | Modelo frio↔quente internalizado | 🔵 |
| 12 | Cold-signing completo (assinar offline, transmitir via Whonix) | 🔵 |

### 👤 Perfil do aluno e pré-requisitos

**Você não precisa conhecer** Tails, Haveno, Feather, Whonix ou Monero antes de começar. Este curso assume zero experiência e ensina processo + ferramentas na ordem certa.

**Você precisa de:**
- Um PC para gravar o Tails (Windows, macOS ou Linux)
- Um pendrive de **8 GB ou mais** (será completamente apagado)
- Paciência com o Tor na primeira vez (download pode levar 30–90 min)
- **Papel e caneta** para anotar a seed (nunca só no computador)

**O Tails não funciona em celular ou tablet.**

### 🛠️ Checklist de ferramentas necessárias

| Ferramenta | Versão | Onde obter | Obrigatório |
|-----------|:------:|------------|:-----------:|
| Tails | 7.8.1+ | https://tails.net (só aqui) | Sim |
| Haveno / RetoSwap | 1.6.0-reto | GitHub retoaccess1/haveno-reto | Sim |
| Feather Wallet | atual | https://featherwallet.org/download | Sim (M2) |
| Whonix LXQt | 18.1.4.2+ | https://www.whonix.org/wiki/Download | Sim (M2) |
| Pendrive | 8 GB+ | — | Sim |
| Papel e caneta | — | — | Sim |
| PC host (outro PC) | qualquer SO | — | Sim (para gravar Tails) |

### 🎯 Escolha seu caminho

```text
                    TRILHA COMPLETA (passos 1–12)
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
     ┌─────────────────┐           ┌─────────────────┐
     │   PARTE 1       │           │   PARTE 2       │
     │   Passos 1–7    │  ──────►  │   Passos 8–12   │
     │   🟢 Padrão     │           │   🔵 Custódia   │
     └────────┬────────┘           └────────┬────────┘
              │                             │
     ┌────────┴────────┐                    │
     ▼                 ▼                    ▼
┌──────────────┐  ┌──────────────┐   (Trilhas A/B
│ PASSOS 1–3   │  │ PASSOS 4–7   │    passo 12)
│ Haveno       │  │ Pré-M2       │
│ 🟢 Núcleo    │  │ Feather+seed │
└──────┬───────┘  └──────┬───────┘
       │                 │
       │  1 Tails        │  4 Backup seed
       │  2 ● VERDE      │  5 Feather PGP
       │  3 Pré-trade    │  6 Folheto
       │                 │  7 Rotina --boot
       └────────┬────────┘
                ▼
         🏁 CHECKPOINT 1
                │
                ▼
     ┌─────────────────┐
     │  PASSOS 8–12    │
     │  Custódia Fria  │
     │  🔵 Expert      │
     └────────┬────────┘
              │
                          ┌─────────────────┴─────────────────┐
                          ▼                                     ▼
               ┌────────────────────┐               ┌────────────────────┐
               │  TRILHA A — FEATHER │               │  TRILHA B — CLI    │
               │  Interface gráfica │               │  monero-wallet-cli │
               │  ✅ Recomendado    │               │  Avançado/Auditoria│
               └────────────────────┘               └────────────────────┘
                 Passo 12A                             Passo 12B
                 (escolha UMA — nunca misture)
```

| Faixa | Passos | Foco |
|-------|--------|------|
| **Núcleo Haveno** | **1–3** | Tails (1) → Haveno verde (2) → cautela pré-trade (3) |
| **Pré-M2** | **4–7** | Seed · Feather · folheto · rotina `hub.sh boot` |
| **Custódia fria** | **8–12** | Whonix · air-gap · cold-signing (trilha A ou B) |

📎 **Passos 2–3** são o bloco “somente Haveno” (instalar + regras). O **passo 1** é pré-requisito Tails; **4–7** preparam o M2 sem ser só instalação.

### ⚖️ Manifesto (7 princípios)

**1. Verificação antes de confiança**
Todo binário que entra no fluxo deve ser verificável (PGP, checksums assinados, fingerprints com fonte). Scripts seguem postura fail-closed. Exceções e TOFU são documentados honestamente — nunca escondidos.

**2. Cold-Tails, Hot-Whonix — trilha principal**
A arquitetura central é custódia fria no Tails (assinatura sem rede no passo 12) e operação view-only no Whonix online, sem depender de hardware proprietário caro. Passos 1–9 rodam com Tor ativo; a seed vai para papel, não para arquivo. Trezor/Ledger são alternativa opcional (custo extra), não pré-requisito.

**3. Não omitir — o aluno escolhe o caminho**
Caminhos avançados existem em apêndices dedicados (CLI, multisig manual, home lab). O material não esconde complexidade para parecer "mais seguro". Para trades no Haveno, o que importa está no fluxo principal; para quem quer ir além, a documentação está lá — com avisos de risco.

**4. Responsabilidade sua**
O curso é educacional. Não promete segurança absoluta nem substitui julgamento humano. Seed em papel, duas cópias offline, teste com valor mínimo, e migração quando a carteira deixa de ser fria — regras repetidas nos momentos certos, não como marketing.

**5. Transparência sobre limites**
RetoSwap (TOFU), P2Pool (reproducible builds), relógio no hub.sh — cada compromisso de confiança é nomeado com mitigação. Golpes, exploit corrigido, KYC agregadores: explícitos nos passos certos.

**6. Ecossistema**
Tails guarda o grosso e assina offline (passo 12). Whonix online vê, monta e transmite. Haveno é a ponte para trades quentes (escrow multisig automático). Home Lab (nó, mineração) é opcional, em outro PC.

**7. Documentação em camadas**
O hub separa ensino de execução: teoria no módulo, comandos no processo, scripts na automação. Este arquivo canônico consolida tudo num único lugar para quem prefere um único documento.

### 📖 Glossário rápido (1 minuto)

| Termo | Significado |
|-------|-------------|
| **Online (Tor)** | Tails com internet só via Tor — passos 1–9 |
| **Offline (papel)** | Seed em papel/metal; sem foto/chat/nuvem — passo 4, 9 |
| **Offline (rede / air-gap)** | Tails sem Wi-Fi/cabo — passo 12 (cold-signing) |
| **Cold-Tails** | Tails bootado offline; carteira completa com spend key |
| **Hot-Whonix** | Whonix online; carteira view-only (sem spend key) |
| **Seed** | 25 palavras que recuperam seus fundos. Nunca online. |
| **Air-gap** | Máquina fisicamente desconectada da rede |
| **View-only** | Carteira que vê saldo mas não pode gastar (só view key) |
| **Spend key** | Chave que autoriza gastos. Vive só na máquina fria. |
| **Outputs** | Dados da blockchain que a carteira usa para montar transações |
| **Key images** | Prova criptográfica de que outputs não foram gastos duas vezes |
| **Restore height** | Altura de bloco da criação da carteira. Anote na criação. |
| **Unsigned tx** | Transação montada (quente) mas ainda não assinada |
| **Signed tx** | Transação assinada (fria) pronta para transmitir |
| **Trilha A** | Cold-signing com Feather GUI (recomendado) |
| **Trilha B** | Cold-signing com monero-wallet-cli (avançado) |
| **M1** | Módulo 1: Haveno (passos 1–7) — núcleo 1–3 · pré-M2 4–7 |
| **M2** | Módulo 2: Whonix + Custódia fria (passos 8–12) |

### 🚨 12 Regras de Ouro da Custódia Monero

🔴 **1. Seed = seus fundos.** Nunca compartilhe. Nunca fotografe. Nunca envie por chat, e-mail ou nuvem. Anote offline em papel ou metal.

🔴 **2. Duas cópias físicas da seed em locais separados.** Se sua casa pegar fogo, você não perde tudo.

🔴 **3. Seed nunca toca máquina online.** Se aconteceu uma vez, a carteira deixou de ser fria. Migre os fundos imediatamente.

🔴 **4. Verifique o PGP de todo binário.** "Good signature" sozinho não basta — o fingerprint tem de bater com a fonte oficial. User ID igual ≠ chave igual.

🔴 **5. URL e PGP da mesma rede, mesmo release.** Não misture. Nunca instale `.deb` de uma rede com assinatura de outra.

🟡 **6. Instalar ≠ tradear.** Haveno verde = instalação OK. Tradear é decisão sua, com cautela, valores pequenos, canais oficiais.

🟡 **7. "Suporte" no privado pedindo seed/senha/tela = golpe.** Ninguém legítimo pede. Ignore e bloqueie.

🟡 **8. Tudo dentro do app.** Negociar "por fora" do Haveno desativa o escrow multisig. É sempre golpe.

🟡 **9. Seed ≠ backup completo.** A seed recupera fundos. O histórico, contas de pagamento e trades ficam na pasta Data/. Faça backup cifrado de Data/ separadamente.

🟢 **10. Confira o endereço de destino na máquina FRIA antes de assinar.** Malware no lado quente pode trocar o destino. A fria é a fonte de verdade.

🟢 **11. Re-sincronize key images após cada envio.** Sem isso, a view-only não vê o troco e mostra saldo errado.

🟢 **12. Teste com valor mínimo antes do grosso.** Faça o fluxo completo (criar view-only → montar → assinar → transmitir) com poucos XMR antes de mover tudo.

---

## 🗺️ 1. MAPA DO CURSO (VISÃO GERAL)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│          🛡️ Privacy-OS-Hub – VERSÃO 1.0 (canônica)                         │
└─────────────────────────────────────────────────────────────────────────────┘
│
├── 📌 0. ONBOARDING (O que você vê antes de começar)
│   ├── 🎓 Carta do Professor/Mantenedor
│   ├── 🎯 Resultados Esperados (12 passos → habilidade + nível)
│   ├── 👤 Perfil do Aluno & Pré-requisitos
│   ├── 🛠️ Checklist de Ferramentas (Tails · Haveno · Feather · Whonix)
│   ├── 🎯 Escolha seu Caminho (Trilha A: Feather GUI × Trilha B: CLI)
│   ├── ⚖️ Manifesto (7 princípios)
│   ├── 📖 Glossário Rápido (1 minuto)
│   └── 🚨 12 Regras de Ouro da Custódia Monero
│
├── 🗺️ 1. MAPA DO CURSO (Você está aqui)
│
├── 🔴🟡🟢🔵 LEGENDA DE CORES
│
├── 🟢 PARTE 1 — TAILS + HAVENO (Passos 1–7) · 3–6h total
│   │
│   ├── 📋 PASSO 1 — Bootstrap Tails (USB · Tor · Persistência · Admin)
│   │   ├── ▸ COMANDO 1.1: verificar hash do Tails ISO
│   │   ├── ▸ COMANDO 1.2: gravar USB (balenaEtcher / dd)
│   │   ├── ▸ COMANDO 1.3: boot Tails + conectar ao Tor
│   │   ├── ▸ COMANDO 1.4: ativar Persistência + Dotfiles
│   │   ├── ▸ COMANDO 1.5: habilitar senha de Admin
│   │   └── ✅ OK SE: Tails iniciado · Tor ativo · Persistência verde
│   │
│   ├── 📋 PASSO 2 — Haveno Verde
│   │   ├── ▸ COMANDO 2.1: baixar .deb + .sig via Tor
│   │   ├── ▸ COMANDO 2.2: verificar PGP (fail-closed · FPR inline)
│   │   ├── ▸ COMANDO 2.3: instalar via hub.sh install
│   │   ├── ▸ COMANDO 2.4: iniciar Haveno e aguardar sincronização
│   │   └── ✅ OK SE: indicador de rede ● VERDE
│   │
│   ├── 📋 PASSO 3 — Cautela Pré-trade
│   │   ├── 📎 Exploit corrigido na 1.6.0-reto (PR #2315)
│   │   ├── 📎 Regras: instalar ≠ tradear · valores mínimos · sem KYC/agregadores
│   │   ├── 📎 TOP golpes no Haveno (11 tipos documentados)
│   │   └── ✅ OK SE: regras lidas + compreendidas
│   │
│   ├── 📋 PASSO 4 — Backup Seed
│   │   ├── ▸ COMANDO 4.1: backup cifrado da Data/ (hub.sh backup)
│   │   ├── ▸ COMANDO 4.2: seed em papel (qa/confirm-seed.sh)
│   │   ├── 🔴 NUNCA: seed em arquivo digital, foto, nuvem ou e-mail
│   │   └── ✅ OK SE: seed física legível + backup cifrado em pendrive separado
│   │
│   ├── 📋 PASSO 5 — Feather Wallet (obrigatório para M2)
│   │   ├── ▸ COMANDO 5.1: baixar AppImage + assinatura via Tor
│   │   ├── ▸ COMANDO 5.2: hub.sh feather (PGP fail-closed)
│   │   ├── ▸ COMANDO 5.3: primeira execução + backup wallets/
│   │   └── ✅ OK SE: Feather abre · "Good signature" · backup feito
│   │
│   ├── 📋 PASSO 6 — Folheto: Regras de Ouro e Golpes
│   │   ├── 📎 Regras de ouro impressas (ou lidas integralmente)
│   │   ├── 📎 Golpes mais comuns: chargeback, mediação falsa, phishing
│   │   └── ✅ OK SE: folheto impresso ou lido + em local acessível
│   │
│   ├── 📋 PASSO 7 — Rotina de Scripts (cada sessão)
│   │   ├── ▸ COMANDO 7.1: hub.sh boot (a cada boot)
│   │   ├── ▸ COMANDO 7.2: hub.sh feather (Feather Wallet)
│   │   ├── ▸ COMANDO 7.3: hub.sh update (atualizar versão)
│   │   ├── 📎 sync-hub-scripts.sh: sincronizar scripts para ~/Persistent/
│   │   ├── 📎 system/preflight.sh: validar ambiente antes de automatizar
│   │   └── ✅ OK SE: Haveno verde em < 5 min após boot
│   │
│   └── 🏁 CHECKPOINT 1 — Haveno Verde + Seed Salva
│       ├── ✅ Tails 7.8.1+ · Tor ativo · Persistência configurada
│       ├── ✅ Haveno ● VERDE · .deb verificado por PGP
│       ├── ✅ Seed em papel (2 vias) · backup cifrado em pendrive
│       └── ✅ Feather instalado e verificado · scripts em ~/Persistent/
│
├── 🔵 PARTE 2 — CUSTÓDIA FRIA (Passos 8–12) · 3–5h total
│   │
│   ├── 📋 PASSO 8 — Porteiro: Trilha A ou B?
│   │   ├── 🟢 TRILHA A — Feather GUI (padrão · recomendado para maioria)
│   │   ├── 🔵 TRILHA B — monero-wallet-cli (avançado · mais controle)
│   │   ├── 📎 Diferença: GUI vs terminal · mesma segurança air-gap
│   │   └── ✅ OK SE: trilha escolhida conscientemente (pode trocar depois)
│   │
│   ├── 📋 PASSO 9 — Ritual Seed (2× Cópias Físicas)
│   │   ├── ▸ COMANDO 9.1: qa/confirm-step9.sh (validação ritual completa)
│   │   ├── 📎 Regra inviolável: 2 cópias · 2 locais físicos separados
│   │   ├── 📎 Tor OK neste passo (ainda online)
│   │   └── ✅ OK SE: qa/confirm-step9.sh → PASS
│   │
│   ├── 📋 PASSO 10 — Whonix PGP + Import VMs
│   │   ├── ▸ COMANDO 10.1: baixar Whonix-LXQt-18.1.4.2.ova + .asc
│   │   ├── ▸ COMANDO 10.2: whonix-verify-image.sh --qa-log (fail-closed)
│   │   ├── ▸ COMANDO 10.3: import .ova no VirtualBox ou KVM
│   │   ├── ▸ COMANDO 10.4: iniciar Gateway → Workstation
│   │   ├── 📎 FPR Whonix: 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA
│   │   └── ✅ OK SE: "Tor Connected" no Whonix Workstation
│   │
│   ├── 📋 PASSO 11 — Modelo Frio-Quente (teoria)
│   │   ├── 📎 Cold = Tails sem rede (assinar) · Hot = Whonix online (transmitir)
│   │   ├── 📎 Fluxo: criar tx offline → exportar → importar → transmitir
│   │   ├── 📎 Air-gap é o padrão · hardware wallet = opcional/custo extra
│   │   └── ✅ OK SE: diagrama frio↔quente internalizado
│   │
│   ├── 📋 PASSO 12A — Feather Offline (Trilha A — padrão)
│   │   ├── ▸ COMANDO 12A.1: Tails sem rede + abrir Feather (modo frio)
│   │   ├── ▸ COMANDO 12A.2: criar ou importar carteira offline
│   │   ├── ▸ COMANDO 12A.3: construir + assinar transação (TXID pendente)
│   │   ├── ▸ COMANDO 12A.4: exportar tx assinada → pendrive USB
│   │   ├── ▸ COMANDO 12A.5: importar pendrive no Whonix (hot) + broadcast
│   │   └── ✅ OK SE: qa/confirm-step12.sh PASS · tx confirmada na rede
│   │
│   ├── 📋 PASSO 12B — CLI Offline (Trilha B — avançado)
│   │   ├── ▸ COMANDO 12B.1: monero-wallet-cli --offline (Tails sem rede)
│   │   ├── ▸ COMANDO 12B.2: gerar tx + export_outputs + sign_transfer
│   │   ├── ▸ COMANDO 12B.3: exportar arquivo assinado → pendrive
│   │   ├── ▸ COMANDO 12B.4: submit_transfer via Whonix (hot)
│   │   └── ✅ OK SE: tx submetida · saldo atualizado no Whonix
│   │
│   └── 🏁 CHECKPOINT 2 — Cold-Signing ao Vivo
│       ├── ✅ Tails offline (sem rede) · carteira aberta · tx assinada
│       ├── ✅ Transmissão confirmada via Whonix (hot)
│       ├── ✅ qa/confirm-step12.sh → PASS
│       └── ✅ Modelo frio↔quente executado do início ao fim
│
└── 📚 APÊNDICES
    │
    ├── APÊNDICE A — Scripts: Catálogo Completo (15+ scripts)
    │   └── hub.sh · haveno/ · feather/ · system/ · qa/ · lib/ · steps/ · …
    │
    ├── APÊNDICE B — Erros Comuns (TOP 10)
    │
    ├── APÊNDICE C — Fingerprints Oficiais (inline · sem links externos)
    │   ├── RetoSwap : DAA24D878B8D36C90120A897CA02DAC12DAE2D0F
    │   ├── Feather  : 8185E158A33330C7FD61BC0D1F76E155CEFBA71C
    │   └── Whonix   : 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA
    │
    ├── APÊNDICE D — Glossário Completo
    ├── APÊNDICE E — Instalar Whonix por SO (Windows · macOS · Linux)
    ├── APÊNDICE F — Trades Hands-on (Rede Descentralizada — resumo)
    ├── Anexo (mantenedor): orientações editoriais
    └── 🏁 CONCLUSÃO

┌─────────────────────────────────────────────────────────────────────────────┐
│                        ROADMAP 2025–2030                                    │
│             (Cronograma de Evolução do Privacy-OS-Hub)                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔴🟡🟢🔵 LEGENDA DE CORES

| Cor | Significado |
|:---:|-------------|
| 🔴 | **Perigo** — erro aqui causa perda de fundos ou compromete segurança |
| 🟡 | **Atenção** — cuidado extra necessário, risco moderado |
| 🟢 | **Padrão** — operação normal, segura para novatos |
| 🔵 | **Expert** — requer conhecimento anterior ou cuidado adicional |

---

## 🟢 PARTE 1 — TAILS + HAVENO (Passos 1–7)

---

### 📋 PASSO 1 — Bootstrap Tails (USB · Tor · Persistência · Admin)

**Rede:** Online (Tor) | **Ferramenta:** Tails 7.8.1+ | **Tempo:** 1–2h

**Contexto:** O Tails é um sistema operacional amnésico — esquece tudo ao desligar. Só o Armazenamento Persistente (no USB, criptografado) guarda dados entre sessões. O Haveno precisa de persistência (carteira) e senha admin (instalar e configurar).

---

#### 1.1 — Gravar o Tails no pendrive (outro PC)

```bash
# Baixe SOMENTE de: https://tails.net/install/
# Use o Tails Installer (Windows/macOS/Linux) — não use imagens de fóruns ou Telegram
# Pendrive 8GB+ será completamente apagado
# Tails Installer -> Instalar no USB -> aguarde 100%
```

Tecla de boot por fabricante: Dell/Lenovo/Acer = **F12 ou F11** · HP = **Esc depois F9** · ASUS = **Esc ou F8**

**Você deve ver:** tela "Bem-vindo ao Tails" (cadeado dourado).

🔴 **Erro comum:** Windows inicia normalmente → o pendrive não foi escolhido como boot. Acesse a BIOS, desative Fast Boot, coloque USB como primeiro na ordem de boot.

---

#### 1.2 — Primeiro boot + Tor

```text
Boas-vindas → escolha idioma/teclado → Iniciar Tails
Assistente "Conexão à rede Tor" → aguarde "Conectado"
O Navegador Tor abre automaticamente
```

```bash
curl -s --max-time 30 https://check.torproject.org/api/ip | grep IsTor
```

**Você deve ver:** `"IsTor":true`

🟡 **Se o Tor não conectar:** tente puentes (bridges). Menu Tor → "Usar uma ponte". Se estiver em país com censura, selecione "obfs4" ou "snowflake".

---

#### 1.3 — Armazenamento Persistente com Dotfiles

```text
Aplicações → Tails → Armazenamento persistente → Criar
Defina uma senha FORTE (anote — sem ela, perde tudo)
Marque OBRIGATORIAMENTE:
  ✓ Arquivos pessoais
  ✓ Dotfiles          ← OBRIGATÓRIO (guarda o atalho do Haveno)
Salvar → Reiniciar
Após reboot: desbloqueie a persistência + reconecte Tor
```

```bash
ls /home/amnesia/Persistent
```

**Você deve ver:** a pasta Persistent acessível e não vazia.

🔴 **Por que Dotfiles é obrigatório:** sem ele, o ícone do Haveno some do menu a cada reinício. Com Dotfiles, o atalho sobrevive.

---

#### 1.4 — Senha de administrador (a cada sessão)

```text
Toda sessão (antes de entrar no Tails):
Boas-vindas → + Mais opções → Senha de administrador → defina → Iniciar Tails
```

```bash
sudo echo ok
```

**Você deve ver:** imprime `ok` após digitar a senha.

🟡 **Atenção:** são duas senhas diferentes. A senha de persistência abre o USB (sempre a mesma). A senha admin é nova a cada sessão.

---

#### 1.5 — Validação com script (após instalar os scripts no Passo 2)

```bash
~/Persistent/hub-scripts/system/preflight.sh --qa-log
```

Log salvo em: `~/Persistent/qa-logs/01-preflight-*.txt`

**OK se:** tela "Bem-vindo ao Tails" · `"IsTor":true` · pasta Persistent existe · `sudo echo ok` funciona.

---

### 📋 PASSO 2 — Haveno até o Verde

**Rede:** Online (Tor) | **Ferramenta:** Haveno 1.6.0-reto | **Tempo:** 30–90 min (download pelo Tor)

**Contexto:** Você vai instalar o Haveno no Tails. O download pelo Tor demora — seja paciente. O script faz tudo: baixa, verifica PGP e configura o onion-grater (o filtro que permite ao Haveno falar com o Tor).

> **Segurança:** o exploit do protocolo de trades (20/05/2026) foi **corrigido** na versão `1.6.0-reto` (24/05/2026). Instalar: seguro. Para **tradear**: leia o Passo 3 primeiro.

---

#### 2.1 — Instalar os scripts (uma vez por pendrive)

```bash
# No Tor Browser, baixe o ZIP do repositório:
# https://github.com/VIPs-com/Privacy-OS-Hub/archive/refs/heads/main.zip
# Extraia em ~/Persistent/Privacy-OS-Hub-main/
# No Terminal:
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
chmod +x sync-hub-scripts.sh
./sync-hub-scripts.sh
```

**Resultado:** scripts em `~/Persistent/hub-scripts/` (seus dados ficam em `~/Persistent/haveno/`, separado).

---

#### 2.2 — Instalar Haveno (primeira vez)

```bash
# Método recomendado (orquestrador):
~/Persistent/hub-scripts/hub.sh install --qa-log
```

O script faz automaticamente (passos 1–7 sem interação):
1. Valida ambiente (preflight)
2. Aguarda Tor
3. Baixa o `.deb` com PGP verificado
4. Instala dependências apt
5. Instala o Haveno
6. Configura onion-grater
7. Abre o Haveno

Depois do Haveno abrir, dois prompts interativos (pressione Enter ou responda):

8. **Backup:** "Rodar backup agora? (S/n)" — padrão **Enter = sim** (recomendado antes do 1º depósito)
9. **Finalizar QA (1ª vez):** "Finalizar QA agora? (S/n)" — padrão **Enter = sim**
   - Antes de pressionar Enter aqui: **sua seed deve estar anotada em papel**.
   - O script vai pedir que você confirme cada uma das 3 perguntas sobre a seed (sem digitar as palavras).

🟡 **Durante o passo [6/9] (download):** pode levar 30–90 min pelo Tor. A linha `Downloading...` do script upstream fica parada — normal. O hub imprime **barra de progresso** (`[########----] NN%` a cada 10s na 1ª vez, ou barra **curl** se `App/utils/` já existir). **Não interrompa** com Ctrl+C no meio do download. Os prompts **8 e 9** aparecem em seguida — fique por perto.

📎 **Onde ficam os arquivos:** o `.deb` baixa em `~/Persistent/haveno/.download/` (retomável). Depois da verificação PGP, vai para `~/Persistent/haveno/Install/` — com symlink `haveno.deb` se preciso. A pasta `.download/` só é apagada no **sucesso**; em falha, fica para retomar.

📎 **Recuperação:** `.deb` completo só em `.download/` → `sync-hub-scripts.sh` + `hub.sh install --qa-log`. Já em `Install/` → `hub.sh install --install-only --qa-log`.

📎 **Erro ou mensagem inesperada?** Consulte `automacao/tails/docs/TROUBLESHOOTING.md` — tabela de diagnóstico por mensagem. Em último caso: `steps/run-all.sh` (fallback atômico, seção 2.5).

---

#### 2.2-A — Instalação manual (se preferir sem script)

```bash
# Rede Reto (turma — pronto para usar):
curl -fsSLO https://github.com/haveno-dex/haveno/raw/master/scripts/install_tails/haveno-install.sh \
  && bash haveno-install.sh \
  "https://github.com/retoaccess1/haveno-reto/releases/download/1.6.0-reto/haveno-v1.6.0-linux-x86_64-installer.deb" \
  "DAA24D878B8D36C90120A897CA02DAC12DAE2D0F"
```

```bash
# Se curl falhar (proxy Tor explícito):
curl -x socks5h://127.0.0.1:9050 -fsSLO \
  https://github.com/haveno-dex/haveno/raw/master/scripts/install_tails/haveno-install.sh
bash haveno-install.sh "URL_DO_DEB" "FINGERPRINT_PGP"
```

🔴 **Regra de ouro:** URL do `.deb` e fingerprint PGP devem ser da **mesma rede** e do **mesmo release**. Nunca misture.

---

#### 2.3 — Verificar instalação e abrir

```bash
ls ~/Persistent/haveno/
ls ~/Persistent/haveno/Install/
ls ~/Persistent/haveno/App/utils/
```

```text
Aplicações → Outros → Haveno
→ aceite a senha admin (pkexec)
→ aguarde — indicador AMARELO é normal nos primeiros 5–20 min da 1ª vez
→ aguarde indicador VERDE
```

```bash
sudo journalctl -u onion-grater --no-pager | tail -20
```

**Você deve ver:** indicador verde · log mostra `loaded filter: haveno` · sem pop-up "No default Tor Instance configured".

---

#### 2.4 — Se NÃO ficou verde (correção manual)

```bash
# Feche o Haveno antes destes comandos
sudo cp /home/amnesia/Persistent/haveno/App/utils/haveno.yml /etc/onion-grater.d/haveno.yml
sudo chmod o+r /var/run/tor/control.authcookie
python3 -c "import yaml; yaml.safe_load(open('/etc/onion-grater.d/haveno.yml')); print('YAML OK')"
sudo systemctl restart onion-grater
```

**Você deve ver:** imprime `YAML OK` · reabra o Haveno pelo menu → verde · log `loaded filter: haveno`.

🔴 **Pop-up "No default Tor Instance configured":** o onion-grater não está configurado. Execute os comandos acima.

---

#### 2.5 — Fallback atômico (se o script travar no [6/9])

```bash
# Caminho validado em Tails real (piloto jun/2026):
cd ~/Persistent/hub-scripts/steps
chmod +x *.sh
./01-setup-dirs.sh
./02-download-deb.sh
./04-import-key.sh
./05-verify-sig.sh
./06-check-deps.sh
./07-install-deb.sh
./08-open-haveno.sh
```

Se o `.deb` já está completo mas a `.sig` foi rejeitada (script desatualizado):

```bash
# Atualize os scripts (corrige validação da .sig Ed25519 binária):
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
./sync-hub-scripts.sh
~/Persistent/hub-scripts/hub.sh install --qa-log
```

**OK se:** "Haveno installation setup completed successfully." · pastas App Data Install criadas · ícone em Aplicações → Outros · indicador verde.

---

### 📋 PASSO 3 — Cautela Pré-trade

**Rede:** Online (Tor) | **Tempo:** 15 min (leitura)

**Contexto:** Instalar o Haveno é seguro. Tradear com dinheiro real é uma decisão diferente. Este passo garante que você sabe o que está fazendo antes de depositar XMR.

```bash
ls ~/Persistent/haveno/Install/
```

**Você deve ver:** `haveno.deb` (ou equivalente da sua rede).

**Leia e responda antes de continuar:**
- Sei a diferença entre **instalar** e **tradear**?
- Entendo que o exploit de trades foi corrigido na **1.6.0-reto**?
- Vou começar com **valores pequenos**?
- Vou usar **apenas canais oficiais** da rede (retoswap.com, GitHub)?

🔴 **Regra:** só use a versão `1.6.0-reto` ou superior para tradear. Confirme nos canais oficiais que o trading foi retomado para a sua rede.

🟡 **KYC e swaps:** Haveno é no-KYC por desenho (P2P). Trocadores e agregadores podem rotear para parceiros que pedem KYC. Filtre "No-KYC", valores pequenos, subendereço novo, via Tor.

**OK se:** leu as regras acima e entende instalar vs tradear.

---

### 📋 PASSO 4 — Backup e Seed em Papel

**Rede:** Online (Tor) | **Ferramentas:** hub.sh backup, qa/confirm-seed.sh | **Tempo:** 20 min

**Contexto:** A seed (25 palavras) recupera os fundos. O backup cifrado de Data/ recupera histórico, contas e trades. São coisas diferentes — você precisa dos dois.

```bash
# FECHE o Haveno antes do backup
~/Persistent/hub-scripts/hub.sh backup --qa-log
```

```bash
# Variações úteis:
~/Persistent/hub-scripts/hub.sh backup --usb              # salvar em pendrive separado
~/Persistent/hub-scripts/hub.sh backup --dest /caminho/   # pasta específica
~/Persistent/hub-scripts/hub.sh backup --full --usb       # snapshot completo → 3-2-1
```

#### 4.A — O que cada backup cobre

| Backup | O que salva | Quando rodar |
|--------|-------------|--------------|
| `hub.sh backup` | Haveno `Data/` (trades, contas, contratos) | Antes de cada trade |
| `feather/backup.sh` | Feather `wallets/` | Após criar ou alterar carteira Feather |
| `hub.sh backup --full` | Data/ + wallets/ + Dotfiles — **snapshot completo** | Semanal ou após mudanças |
| **Seed em papel** | Fundos XMR (a mais importante) | SEMPRE — 2 vias físicas |

> **Seed ≠ backup.** A seed recupera os **fundos**. O `Data/` recupera **histórico, trades e contas de pagamento**. Você precisa dos dois, em locais diferentes.

#### 4.B — Regra 3-2-1 adaptada ao Tails

| Cópia | Mídia | Onde fica |
|-------|-------|-----------|
| **1ª** (automática) | Persistent do USB Tails | Em uso, no seu bolso/mochila |
| **2ª** | Pendrive USB separado (cifrado) | Gaveta / cofre pessoal |
| **3ª** | Segundo pendrive USB (cifrado) | Fora de casa — cofre, familiar confiável |

```bash
# Criar a 2ª e 3ª cópias (rodar no pendrive conectado):
~/Persistent/hub-scripts/hub.sh backup --full --usb
# → gera tails-persist-full-TIMESTAMP.tar.gz.gpg no pendrive
# → repita com o 2º pendrive para ter a 3ª cópia
```

🔴 **A seed em papel é a Cópia 0** — sem ela, nenhum arquivo `.gpg` recupera os fundos.
Guarde-a em local físico **diferente** dos pendrives e do USB Tails.

#### 4.C — Restaurar (depois de um problema)

```bash
# Restaurar snapshot completo (Data/ + wallets/ + Dotfiles):
~/Persistent/hub-scripts/hub.sh backup --restore /caminho/tails-persist-full-TIMESTAMP.tar.gz.gpg

# Restaurar só o Haveno (backup --usb anterior):
~/Persistent/hub-scripts/hub.sh backup --restore /caminho/haveno-data-TIMESTAMP.tar.gz.gpg
```

Após restaurar: rode `hub.sh boot` → confirme o verde → abra o Feather → confirme saldo.

```bash
# Após anotar a seed no papel (Account → Wallet seed no Haveno):
~/Persistent/hub-scripts/qa/confirm-seed.sh
```

**Ritual da seed:**
```text
1. Haveno → Account → Wallet seed
2. Anote as 25 palavras em PAPEL ou METAL
3. NUNCA: foto, chat, e-mail, nuvem, arquivo de texto
4. Feche a tela de seed
5. Faça uma SEGUNDA cópia e guarde em local FÍSICO SEPARADO
6. Anote também o RESTORE HEIGHT (altura de bloco da criação)
```

| Item | Seed sozinha recupera? | Backup Data/ recupera? |
|------|:---------------------:|:---------------------:|
| Saldo XMR | Sim | Sim |
| Histórico de trades | Não | Sim |
| Contas de pagamento (PIX etc) | Não | Sim |
| Reputação / contratos | Não | Sim |

**OK se:** `04-haveno-backup-*.txt` → PASS · `04-seed-papel-*.txt` → 3× SIM · seed em papel · backup em mídia separada.

🔴 **Não continue sem este passo.** Sem backup e seed, uma falha no pendrive = perda total.

---

### 📋 PASSO 5 — Feather Wallet (obrigatório para M2)

**Rede:** Online (Tor) | **Ferramenta:** Feather AppImage | **Tempo:** 30 min

**Contexto:** O Feather é a carteira Monero recomendada para guardar XMR fora do Haveno. É também o pré-requisito obrigatório para o Módulo 2 (Trilha A de cold-signing). Instalação alinhada à documentação oficial Feather/Tails.

**Pré-requisito:** Haveno verde + backup cifrado feito (Passo 4).

---

#### 5.1 — Download pelo Tor Browser

```text
Tor Browser → https://featherwallet.org/download
Baixe TODOS estes arquivos (mesma versão):
  - featherwallet.asc          (chave de assinatura)
  - feather-x.x.x.AppImage    (o aplicativo)
  - feather-x.x.x.AppImage.asc (assinatura do aplicativo)
```

```bash
mkdir -p ~/Persistent/feather/wallets
mv ~/Tor\ Browser/Browser/Downloads/feather-* ~/Persistent/feather/ 2>/dev/null || true
mv ~/Tor\ Browser/Browser/Downloads/featherwallet.asc ~/Persistent/feather/ 2>/dev/null || true
cd ~/Persistent/feather
ls -la
```

---

#### 5.2 — Verificação PGP (obrigatória)

```bash
cd ~/Persistent/feather
gpg --import featherwallet.asc
gpg --list-keys dev@featherwallet.org
```

**Fingerprint oficial Feather Wallet:**
```text
8185 E158 A333 30C7 FD61  BC0D 1F76 E155 CEFB A71C
```

```bash
# Verifique o par (SUBSTITUA pelo nome exato do seu arquivo):
gpg --verify feather-*AppImage.asc feather-*AppImage
```

**Você deve ver DUAS condições:**
1. `gpg: Good signature from "FeatherWallet <dev@featherwallet.org>"`
2. `Primary key fingerprint: 8185 E158 A333 30C7 FD61  BC0D 1F76 E155 CEFB A71C`

🔴 **"Good signature" sozinho NÃO basta.** Qualquer um pode criar uma chave com o nome "FeatherWallet". O fingerprint tem de bater com o oficial acima. Em PT-BR, o gpg exibe `Assinatura válida` — é a mesma coisa.

---

#### 5.3 — Executar e criar carteira

```bash
chmod +x feather-*.AppImage
./feather-*.AppImage
```

```text
UI do Feather:
  Create new wallet → anote a seed em PAPEL (carteira SEPARADA do Haveno)
  Salvar .keys em ~/Persistent/feather/wallets/
  Settings → Network → Always over Tor
```

```bash
# Automatizado (faz tudo: download + PGP + abre UI):
~/Persistent/hub-scripts/hub.sh feather --qa-log
```

```bash
# Backup da carteira Feather após criar:
~/Persistent/hub-scripts/feather/backup.sh
```

**OK se:** Feather abre, sincroniza, saldo visível (0 XMR no início é normal) · PGP OK com fingerprint correto · seed em papel separado do Haveno.

🟡 **Trades (opcional):** para usar o Haveno para comprar/vender XMR, leia o Passo 6 (folheto) antes. Começe com valores pequenos.

---

### 📋 PASSO 6 — Folheto: Regras de Ouro e Golpes

**Rede:** Leitura | **Tempo:** 10 min

**Contexto:** Este é o resumo de tudo que evita 99% dos prejuízos. Leia, imprima e cole em local visível.

---

#### Regras de Ouro (decore)

- **Baixe só de fontes oficiais:** `tails.net`, `getmonero.org`, GitHub da sua rede.
- **Verifique o PGP** de todo `.deb` — URL e PGP da **mesma** rede, **mesmo** release.
- **Use 1.6.0-reto+** — ou o release atual da sua rede; confirme em retoswap.com/GitHub.
- **Instalar ≠ tradear.** Comece com **valores pequenos**.
- **Seed = seus fundos.** Nunca compartilhe. Anote **offline** (papel/metal).
- **Seed ≠ backup completo** → faça backup da pasta `Data/` (cifrada).
- **Abra o Haveno sempre pelo menu** (senão a carteira não persiste).
- **Senha admin** a cada sessão; a **persistência** guarda os dados.
- **Backup cifrado e offline**, em mídia separada do pendrive.

---

#### Golpes — como NÃO cair

| Armadilha | Sua defesa |
|-----------|-----------|
| Instalador "modificado" / link de fórum/Telegram | Só oficial + **verificar PGP** |
| "Suporte" no privado pedindo seed/senha/tela | **Ninguém** legítimo pede. Ignore e bloqueie |
| Site clone (phishing) | Confira o domínio; use favoritos; via Tor |
| "Vamos negociar **por fora** do app" | **Tudo** dentro do Haveno (escrow/multisig) |
| Preço bom demais + **pressa** | Desconfie; siga o fluxo normal |
| Pedem **enviar fundos antes** do escrow | Nunca antecipe; siga o passo a passo |
| "Mixer / privacidade extra" por uma taxa | **Desnecessário** no Monero; geralmente é scam |
| "Sou o **árbitro**, me passe a chave" | Árbitro age **dentro** do app, nunca por fora |

> **Regra única:** se envolve sua **seed**, sua **senha**, ou enviar fundos **"por fora" do app** → **é golpe.**

---

#### Trade seguro (resumo)

**Comprando** (paga fiat, recebe XMR): pague pelo app, **guarde comprovante**, só então marque "pago"; sumiu? **abra disputa**.

**Vendendo** (recebe fiat, entrega XMR): **só libere** o XMR quando o dinheiro estiver **na sua conta e irreversível** (prefira PIX/dinheiro; cuidado com estorno de cartão/PayPal).

**Sempre:** tudo dentro do app (escrow multisig + chat); valores pequenos; na dúvida, **disputa** (nunca "por fora").

**OK se:** folheto lido ou impresso · regras memorizadas.

---

### 📋 PASSO 7 — Rotina de Scripts (cada sessão)

**Rede:** Online (Tor) | **Ferramenta:** hub.sh | **Tempo:** 5 min por sessão

**Contexto:** O Tails é amnésico — esquece tudo ao desligar. A cada boot, é preciso re-ligar o Haveno na sessão. O `hub.sh boot` faz isso: é rápido e não baixa nada de novo.

---

#### 7.1 — Cada novo boot (Haveno já instalado)

```bash
# O comando de toda sessão:
~/Persistent/hub-scripts/hub.sh boot --qa-log
```

Manual (equivalente):
```bash
sudo /home/amnesia/Persistent/haveno/App/utils/install.sh
/home/amnesia/Persistent/haveno/App/utils/exec.sh
```

```bash
# Verificação pós-sessão:
~/Persistent/hub-scripts/system/post-session.sh --qa-log
```

**OK se:** Haveno abre e fica verde. Indicador amarelo por 5–20 min no primeiro boot da sessão é normal.

> **Atalho rápido no menu GNOME (após `sync-hub-scripts.sh`):**
> Clique em **"Haveno — Iniciar"** nas aplicações — equivalente ao comando acima.
> Para backup: clique em **"Haveno — Backup da carteira"** → salva sem abrir terminal.
> Os atalhos ficam salvos no Dotfiles e sobrevivem ao reboot.

---

#### 7.2 — Com Feather também (passo 5 + boot)

```bash
~/Persistent/hub-scripts/hub.sh boot --qa-log
~/Persistent/hub-scripts/hub.sh feather --qa-log
```

---

#### 7.3 — Atualizar Haveno (release novo)

```bash
# Sempre faça backup antes:
~/Persistent/hub-scripts/hub.sh backup

# Atualizar (lê versão e fingerprint de lib/config.sh — atualizado pelo mantenedor):
~/Persistent/hub-scripts/hub.sh update
```

```bash
# Avançado — forçar URL e fingerprint manualmente (edita lib/config.sh antes):
~/Persistent/hub-scripts/haveno/update.sh \
  --url "https://github.com/retoaccess1/haveno-reto/releases/download/VERSAO-NOVA/haveno-vVERSAO-linux-x86_64-installer.deb" \
  --pgp "FINGERPRINT_DA_MESMA_REDE"
```

🔴 **Nunca** use `--no-backup` no `haveno/update.sh`. Se o backup falhar, a atualização aborta — isso é intencional.

---

#### 7.4 — Tabela de scripts (referência rápida)

| Comando | Quando usar | Seguro rodar 2×? |
|---------|-------------|:----------------:|
| `hub.sh install` | 1ª vez (instalar Haveno) | Sim |
| `hub.sh install --qa-log` | 1ª vez com log de evidência | Sim |
| `hub.sh install --install-only` | .deb já em Install/ (sem download) | Sim |
| `hub.sh boot` | Cada sessão após instalação | Sim |
| `hub.sh boot --qa-log` | Cada sessão com log | Sim |
| `hub.sh backup` | Antes do 1º depósito; periodicamente | Sim (cria arquivo novo com timestamp) |
| `hub.sh backup --usb` | Salvar em pendrive separado | Sim |
| `hub.sh update` | Release novo da rede | Sim (backup automático antes) |
| `hub.sh feather` | Passo 5 (instala + verifica PGP) | Sim (re-verifica) |
| `hub.sh feather --qa-log` | Passo 5 com log | Sim |
| `hub.sh qa validate` | Valida scripts — tela + log simultâneos | Sim |
| `hub.sh qa finalize` | validate + confirm-seed (1ª instalação, 1 vez) | Sim |
| `hub.sh qa confirm-seed` | Confirma seed em papel (passo 4) | Sim |
| `hub.sh qa ritual-seed` | Ritual 2× cópias físicas (passo 9) | Sim |
| `hub.sh qa cold-sign` | Pós cold-signing (passo 12) | Sim |
| `hub.sh qa export-logs --usb` | Exporta qa-logs/ para pendrive | Sim |
| `system/preflight.sh` | Antes de qualquer script | Sim (só leitura) |
| `system/post-session.sh` | Após atualizar o Tails (SO) | Sim |

**Resumo de bolso:**
- **Primeira vez na vida** → `hub.sh install`
- **Já instalei antes, voltei ao Tails** → `hub.sh boot`

---

### 🏁 CHECKPOINT 1 — Haveno Verde + Seed Salva

Antes de continuar para a Parte 2, confirme cada item:

- [ ] Tails 7.8.1+ gravado e bootando corretamente
- [ ] Armazenamento persistente criado com **Dotfiles** ativado
- [ ] Haveno instalado — ícone no menu e indicador **verde**
- [ ] `loaded filter: haveno` nos logs do onion-grater
- [ ] Seed das **25 palavras** anotada em **papel** (offline, nunca digital)
- [ ] **Segunda cópia** da seed em local físico separado
- [ ] **Restore height** anotado junto com a seed
- [ ] Backup cifrado de `Data/` feito (`04-haveno-backup-*.txt` → PASS)
- [ ] `qa/confirm-seed.sh` → 3× SIM
- [ ] Feather Wallet instalado, PGP verificado (`8185E158…CEFBA71C`)
- [ ] Folheto lido — regras de ouro e golpes memorizados
- [ ] `hub.sh boot` funciona em nova sessão

🔴 **Não continue para a Parte 2 sem todos os itens acima.** O Módulo 2 exige M1 completo.

---

## 🔵 PARTE 2 — CUSTÓDIA FRIA (Passos 8–12)

---

### 📋 PASSO 8 — Porteiro: Trilha A ou B?

**Rede:** Leitura | **Tempo:** 10 min

**Contexto:** Você vai montar custódia frio↔quente. A seed fica só no Tails offline; o Whonix online apenas vê o saldo, monta a transação e transmite. Antes de qualquer comando, escolha UMA trilha e siga só ela do início ao fim.

```text
            Mesma custódia frio↔quente, MESMO resultado
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
   ┌────────────────────────┐     ┌────────────────────────┐
   │   TRILHA A — FEATHER   │     │   TRILHA B — CLI       │
   │   Interface gráfica    │     │   monero-wallet-cli    │
   │   ✅ Recomendado       │     │   Avançado/Auditoria   │
   └────────────────────────┘     └────────────────────────┘
         Passo 12A                      Passo 12B
```

| | Trilha A | Trilha B |
|---|---|---|
| Como opera | GUI (cliques e botões) | Terminal (comandos) |
| Para quem | **Maioria** (recomendado) | Avançado / quer auditar |
| Processo | Passo 12A | Passo 12B |

> 🔴 **NÃO misture as trilhas.** A carteira nasce e morre na mesma ferramenta. **Na dúvida: Trilha A.**

---

**Pré-requisitos para prosseguir:**

- [ ] M1 passos 1–4 concluídos (Haveno verde + backup + seed em papel)
- [ ] Feather instalado e verificado (Passo 5)
- [ ] Escolheu **uma** trilha: _____ (A ou B)

**O que você vai precisar antes do Passo 12:**
- Duas cópias físicas da seed em locais separados (Passo 9)
- Whonix instalado e verificado (Passo 10)
- Teoria frio↔quente internalizada (Passo 11)
- Pendrive dedicado ao trânsito frio↔quente
- Da carteira fria: endereço primário (`4…`), secret view key, restore height

**OK se:** escolheu uma trilha e pré-requisitos marcados.

---

### 📋 PASSO 9 — Ritual Seed (2× Cópias Físicas)

**Rede:** Tails com Tor (OK — não é air-gap de rede) | **Tempo:** 20 min

**Contexto:** Este passo confirma o ritual físico do Passo 4. Tails com Tor ativo é suficiente — não é necessário desligar a rede aqui. O que importa é garantir duas cópias físicas em locais separados antes de mover qualquer valor relevante.

---

#### 9.1 — Checklist obrigatório

```text
Ao criar a conta (já feito no Passo 4):
  Account → Wallet seed → anote as 25 palavras em papel/metal
  NUNCA: foto, nuvem, e-mail, arquivo de texto
  Faça a 2ª cópia em OUTRO local físico
```

- [ ] **DUAS cópias offline** da seed (papel/metal, **locais separados**)
- [ ] **Restore height** anotado na criação da carteira
- [ ] **Pendrive dedicado** ao trânsito frio↔quente (rotulado, limpo)
- [ ] (Opcional avançado) Teste de restauração numa sessão Tails offline

---

#### 9.2 — Confirmação com script

```bash
~/Persistent/hub-scripts/qa/confirm-step9.sh
```

**OK se:** `09-seed-confirmacao-*.txt` → 3× SIM · duas cópias em locais separados.

🔴 **Não mova valor relevante** sem este checkpoint. Duas cópias em locais separados = proteção contra incêndio, roubo, inundação.

---

### 📋 PASSO 10 — Whonix PGP + Import VMs

**Rede:** Host Linux (internet normal) | **Ferramenta:** VirtualBox ou KVM | **Tempo:** 1–2h

**Contexto:** O Whonix roda no seu PC normal (host), não no pendrive Tails. São duas VMs: Gateway (força todo tráfego por Tor) e Workstation (onde você trabalha). Verifique a imagem ANTES de importar — mesma disciplina do Módulo 1.

---

#### 10.1 — Pré-requisitos do host

- [ ] Virtualização ligada na BIOS/UEFI (Intel VT-x / AMD AMD-V)
- [ ] Host atualizado e confiável
- [ ] Full-disk encryption no host recomendada
- [ ] ~4 GB+ de RAM livre para as duas VMs
- [ ] Baixe SOMENTE de: https://www.whonix.org/wiki/Download

| Host | Recomendação |
|------|-------------|
| Windows / macOS | VirtualBox |
| Linux | VirtualBox (mais fácil) ou KVM (mais seguro) |

---

#### 10.2 — Baixar 3 arquivos (qualquer SO)

Em https://www.whonix.org/wiki/Download, baixe para a **mesma pasta**:
1. Imagem: `Whonix-*.ova` (variante LXQt recomendada para iniciantes)
2. Assinatura: `Whonix-*.ova.asc`
3. Chave: https://www.whonix.org/keys/derivative.asc

---

#### 10.3 — Verificar a imagem (Linux — atalho com script)

```bash
chmod +x whonix-verify-image.sh
./whonix-verify-image.sh /caminho/Whonix-*.ova /caminho/Whonix-*.ova.asc
# KVM: ./whonix-verify-image.sh --kvm Whonix-*.libvirt.xz Whonix-*.libvirt.xz.asc
# Com log de evidência:
./whonix-verify-image.sh --qa-log /caminho/Whonix-*.ova /caminho/Whonix-*.ova.asc
```

Manualmente (Linux):

```bash
# 1) Importe a chave do Whonix:
gpg --import derivative.asc

# 2) Confira o fingerprint (TEM DE BATER com 916B8D99…2EEACCDA):
gpg --fingerprint 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA

# 3) Verifique a assinatura da imagem:
gpg --verify-options show-notations --verify Whonix-*.ova.asc Whonix-*.ova
```

**Fingerprint oficial Whonix:**
```text
916B 8D99 C38E AF5E 8ADC  7A2A 8D66 066A 2EEA CCDA
```

🔴 **"Good signature" de uma chave ERRADA não vale.** Sempre confirme que o fingerprint bate. Em PT-BR: `Assinatura válida` = `Good signature`.

---

#### 10.4 — Se aparecer EXPKEYSIG (chave expirada)

```bash
curl -fsSL https://www.whonix.org/keys/derivative.asc -o derivative.asc
gpg --import derivative.asc
gpg --fingerprint 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA
# Reexecute a verificação
```

O fingerprint `916B8D99…2EEACCDA` não mudou após a re-certificação (jan/2026) — só o keyring local estava desatualizado.

---

#### 10.5 — Verificar (Windows — Kleopatra/Gpg4win)

```text
1. Instale Gpg4win: https://gpg4win.org
2. Kleopatra → File → Import → selecione derivative.asc
3. Confira o fingerprint nas propriedades: 916B8D99…2EEACCDA
4. Kleopatra → Decrypt/Verify → selecione Whonix-*.ova.asc (com .ova na mesma pasta)
OK se: assinatura VÁLIDA emitida por 916B8D99…2EEACCDA
```

---

#### 10.6 — Verificar (macOS — GPG Suite)

```bash
# Instale GPG Suite: https://gpgtools.org
gpg --import derivative.asc
gpg --fingerprint 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA
gpg --verify-options show-notations --verify Whonix-*.ova.asc Whonix-*.ova
```

---

#### 10.7 — Importar e iniciar (VirtualBox)

```text
1. Abra o VirtualBox
2. File → Import Appliance → selecione Whonix-*.ova verificado → Next → Import
3. Aguarde a importação completa
4. Inicie Whonix-Gateway → espere Tor conectar (ícone "Tor Connection")
5. SÓ ENTÃO inicie Whonix-Workstation
Login padrão: usuário 'user', sem senha (passwordless)
```

---

#### 10.8 — Primeiro boot — atualizar e snapshot

```bash
# Dentro de Gateway E Workstation (via Tor):
sudo apt update && sudo apt full-upgrade
```

```text
VirtualBox: Snapshots → tirar snapshot inicial de cada VM
KVM: virsh snapshot-create <nome-vm>
```

---

#### 10.9 — Troubleshooting VirtualBox

| Sintoma | Causa | Solução |
|---------|-------|---------|
| VM não inicia / erro VT-x | Virtualização desligada na BIOS | Ative Intel VT-x ou AMD-V; reinicie |
| "VT-x is not available" (Windows) | Hyper-V / WSL2 ocupando VT | Desative em Recursos do Windows |
| Import falha / disco cheio | Pouco espaço | Libere ~30 GB+; importe para SSD |
| Gateway lento / RAM baixa | Host com pouca RAM | Feche apps; aloque 4 GB+ livres |
| Workstation sem rede | Gateway ainda não conectou ao Tor | Espere ícone "Tor Connection" no Gateway |

Fonte oficial: https://www.whonix.org/wiki/VirtualBox

**OK se:** `Good signature` / `Assinatura válida` com fingerprint `916B8D99…2EEACCDA` · Gateway conecta ao Tor · Workstation abre e navega só via Gateway · atualização completa · snapshot tirado.

---

### 📋 PASSO 11 — Modelo Frio-Quente (teoria)

**Rede:** Leitura | **Tempo:** 20 min

**Contexto:** Este passo é só leitura — internalizar o princípio antes de executar o cold-signing. Responda as perguntas abaixo sem consultar. Se não souber, releia.

---

#### O princípio inegociável

> A **chave de gasto (spend key) / seed** vive numa máquina que **NUNCA** se conecta à rede. O lado online só **vê** o saldo e **monta** transações — ele **não consegue assinar** (não tem a spend key).

| Carteira | Onde | Tem o quê | Pode |
|----------|------|-----------|------|
| **Fria (full)** | Tails, bootado offline | seed + view key + **spend key** | **Assinar** (gastar) |
| **Quente (view-only)** | Whonix, online via Tor | endereço + secret view key + restore height | **Ver** saldo, **montar** tx, **transmitir** |

#### O que cruza por USB (nunca por rede)

```text
  TAILS offline (FRIO)              WHONIX online (QUENTE)
  carteira COMPLETA                 carteira VIEW-ONLY
        │  (0) address + viewkey + restore height ──────►│
        │◄──── (1) outputs ──────────────────────────────│
        │───── (2) key images ───────────────────────────►│
        │◄──── (3) transação NÃO-ASSINADA ───────────────│
        │───── (4) transação ASSINADA ──────────────────►│
   ASSINA aqui                              TRANSMITE via Tor
```

#### Perguntas de verificação (responda antes do Passo 12)

1. **Quente vê · frio assina:** o Whonix (quente) é view-only; a spend key nunca sai do Tails (frio). Verdadeiro?
2. **O Whonix assina a transação?** → Não. Ele monta e transmite; quem **assina** é o Tails offline.
3. **O que viaja no pendrive USB entre quente e frio?** → o unsigned tx (quente → frio) e o signed tx (frio → quente). Nunca a seed nem a spend key.
4. **Por que isso protege?** → mesmo que a máquina online (quente) seja comprometida, sem a spend key ela não gasta seus fundos.

**OK se:** respondeu as 4 perguntas sem consultar.

---

### 📋 PASSO 12A — Feather Offline (Trilha A — padrão)

**Rede:** Tails air-gap (sem Wi-Fi/cabo) | **Ferramenta:** Feather GUI | **Tempo:** 30–60 min

> Siga **só** este processo se escolheu Trilha A. Não misture com Trilha B.

**Pré-requisitos:**
- Passo 8 (escolheu Trilha A)
- Passo 9 (duas cópias físicas da seed)
- Passo 10 (Whonix verificado, Gateway + Workstation atualizados)
- Feather completo no Tails (Passo 5) — carteira completa com spend key
- Pendrive dedicado ao trânsito frio↔quente
- Da carteira fria: endereço primário (`4…`), secret VIEW key, restore height

---

#### Mapa do fluxo (o que cruza por USB, nunca por rede)

```text
  TAILS offline (FRIO)                      WHONIX online (QUENTE)
  Feather COMPLETO                          Feather VIEW-ONLY
  seed + view key + SPEND key               endereço + view key + restore height
        │ (0) address + viewkey + restore height ──────►│ cria view-only
        │◄──── (1) outputs ──────────────────────────────│ exporta outputs
        │───── (2) key images ──────────────────────────►│ importa key images
        │◄──── (3) transação NÃO-ASSINADA ───────────────│ monta a tx
        │───── (4) transação ASSINADA ─────────────────►│ transmite
   ASSINA offline                              BROADCAST via Tor/seu nó
```

---

#### A — Preparar (antes de começar)

```text
LADO FRIO (Tails): boot OFFLINE
  → DESCONECTE Wi-Fi/cabo ANTES de ligar o Tails
  → Só então abra o Feather com a carteira COMPLETA
  → Spend key nunca em rede

LADO QUENTE (Whonix):
  → Imagem verificada (916B8D99…2EEACCDA)
  → Gateway/Workstation atualizados
  → Feather verificado por PGP (8185E158…CEFBA71C)
  → Settings → Network → Always over Tor
```

**OK se:** Workstation só via Gateway · Feather sincroniza via Tor.

---

#### A1 — Criar a view-only no Whonix

Na carteira **FRIA** (Feather/Tails), anote três informações:
- Endereço primário (começa com `4`)
- Secret **VIEW** key (de VISÃO — nunca a spend key/seed!)
- Restore height

No Whonix (Feather):
```text
Create new wallet → View only
→ cole: endereço + secret view key + restore height
→ Always over Tor
→ conecte ao seu nó .onion:18089 (ou nó remoto .onion confiável)
```

**OK se:** view-only mostra o **mesmo** saldo da fria.

Saldo antigo não aparece? Restore height muito alto — recrie com a altura correta (não é perda de fundos).

---

#### A2 — Sincronizar (1º envio e quando saldo parecer velho)

> Os rótulos de menu variam por versão do Feather — se não bater com os nomes abaixo, consulte: https://docs.featherwallet.org/guides/offline-tx-signing

```text
(Quente / Whonix):
  view-only → exportar OUTPUTS → arquivo no USB
  (aceite o nome padrão gerado pelo Feather)

(Frio / Tails offline):
  carteira completa → importar outputs
  → exportar KEY IMAGES → USB

(Quente / Whonix):
  importar key images
  → saldo e gastos ficam corretos
```

---

#### A3 — Gastar (montar quente · assinar frio · transmitir quente)

```text
(Quente / Whonix):
  Send (ou criar transação)
  → Export unsigned transaction → USB

(Frio / Tails offline):
  importar a não-assinada
  → CONFIRA destino e valor NA TELA DA FRIA (fonte de verdade)
  → Sign → exportar assinada → USB

(Quente / Whonix):
  importar a assinada
  → transmitir (broadcast) via Tor/seu nó
```

🔴 **A máquina FRIA é a fonte de verdade.** Malware no lado quente pode trocar o endereço de destino. Sempre confirme na tela fria antes de assinar.

---

#### Após assinar offline

```bash
~/Persistent/hub-scripts/qa/confirm-step12.sh
```

**OK se:** Tails sem rede antes de abrir carteira · `12-cold-signing-*.txt` → `tails_offline_airgap=SIM`.

**Fontes oficiais:**
- Feather offline signing: https://docs.featherwallet.org/guides/offline-tx-signing
- Whonix Monero: https://www.whonix.org/wiki/Monero

---

### 📋 PASSO 12B — CLI Offline (Trilha B — avançado)

**Rede:** Tails air-gap (sem Wi-Fi/cabo) | **Ferramenta:** monero-wallet-cli | **Tempo:** 30–60 min

> Siga **só** este processo se escolheu Trilha B. Não misture com Trilha A. Quer mais simples? Use o Passo 12A.

**Pré-requisitos:** mesmos do Passo 12A.

> Comandos do lado QUENTE são na **Workstation Whonix**. Assinatura acontece no **Tails offline** (frio).

---

#### Mapa do fluxo

```text
  TAILS offline (FRIO)                      WHONIX online (QUENTE)
  carteira COMPLETA                         carteira VIEW-ONLY
        │◄──── (1) export_outputs ──────────│
        │───── (2) export_key_images ──────►│
        │◄──── (3) unsigned_monero_tx ──────│ transfer
        │───── (4) signed_monero_tx ───────►│ submit_transfer
```

---

#### B1 — Criar a view-only (no Whonix/QUENTE)

```bash
# O comando PERGUNTA endereço + view key (não passe na linha de comando)
# Pegue address + viewkey da carteira FRIA, depois:
monero-wallet-cli --generate-from-view-key NOME-VIEW \
  --daemon-address SEU_NO.onion:18089
```

```bash
# Defina a altura (anterior à 1ª recepção) — sem ela, sincroniza do bloco 0 (lento):
set refresh-from-block-height N
```

**OK se:** view-only mostra o mesmo saldo da fria.

---

#### B2 — Sincronizar (repita após CADA envio)

🟡 **Passo mais esquecido.** Sem re-sincronizar as key images, a view-only não enxerga o troco e mostra saldo errado.

```bash
# QUENTE (view-only):
export_outputs outputs_file
```

```bash
# FRIO (carteira completa, Tails offline):
import_outputs outputs_file
export_key_images ki_file
```

```bash
# QUENTE (view-only):
import_key_images ki_file
```

---

#### B3 — Gastar

```bash
# QUENTE: monta a tx → gera 'unsigned_monero_tx'
transfer ENDERECO VALOR
```

```bash
# FRIO: confira destino/valor na tela → assina → gera 'signed_monero_tx'
sign_transfer
```

```bash
# QUENTE: transmite via Tor/seu nó
submit_transfer
```

🔴 **Confira o endereço na máquina FRIA antes de assinar.** Malware no lado quente pode trocar o destino.

---

#### Após assinar offline

```bash
~/Persistent/hub-scripts/qa/confirm-step12.sh
```

**OK se:** mesmo critério do 12A — air-gap real · `12-cold-signing-*.txt` → `tails_offline_airgap=SIM`.

**Fontes oficiais:**
- Monero cold signing: https://docs.getmonero.org/cold-storage/offline-transaction-signing/
- Monero view-only: https://www.getmonero.org/resources/user-guides/view_only.html
- Whonix Monero: https://www.whonix.org/wiki/Monero

---

### 🏁 CHECKPOINT 2 — Cold-Signing ao Vivo

Antes de considerar a trilha principal concluída:

- [ ] Passo 8: trilha escolhida (A ou B) e anotada
- [ ] Passo 9: duas cópias físicas da seed em locais separados · `09-seed-confirmacao-*.txt` → 3× SIM
- [ ] Passo 10: Whonix verificado com PGP (`916B8D99…2EEACCDA`) · Gateway conecta ao Tor · Workstation só via Gateway · snapshot tirado
- [ ] Passo 11: respondeu as 4 perguntas do modelo frio↔quente
- [ ] Passo 12A ou 12B: cold-signing ao vivo com **valor mínimo** · `12-cold-signing-*.txt` → `tails_offline_airgap=SIM`
- [ ] Tails estava **sem Wi-Fi/cabo** durante o passo 12
- [ ] Endereço de destino confirmado na **máquina FRIA** antes de assinar
- [ ] Key images re-sincronizadas após o envio
- [ ] Transação apareceu confirmada no explorador Monero (via Tor)

🔵 **Parabéns.** Você concluiu a trilha principal. Sua seed nunca tocou a internet. Seu XMR foi assinado em máquina air-gap. Você tem custódia real.

---

## 📚 APÊNDICES

---

### APÊNDICE A — Scripts: Catálogo Completo

#### Estrutura da pasta (após sync-hub-scripts.sh)

```text
~/Persistent/hub-scripts/
│
├── hub.sh                   ★ COMECE AQUI (único ponto de entrada do aluno)
│
├── lib/                     (biblioteca interna — NÃO execute diretamente)
│   ├── config.sh            (HAVENO_VERSION + HAVENO_PGP_FPR — fonte única)
│   ├── common.sh            (funções compartilhadas, qa_log_*, sig validation)
│   └── onion-grater.yml     (filtro Tor corrigido p/ 1.6.0)
│
├── haveno/                  (Haveno — carteira / app)
│   ├── install.sh           (Download + PGP + install + verde)
│   ├── boot.sh              (install.sh + exec.sh + onion-grater)
│   ├── backup.sh            (backup cifrado Data/ com GPG)
│   ├── update.sh            (atualizar .deb com PGP — backup obrigatório)
│   ├── verify-deb.sh        (verificar assinatura GPG do .deb — avançado)
│   └── switch-network.sh    (trocar rede Haveno — avançado)
│
├── feather/                 (Feather — passo 5 / M2)
│   ├── install.sh           (PGP fail-closed + abre UI)
│   └── backup.sh            (backup cifrado wallets/)
│
├── system/                  (Tails — ambiente)
│   ├── preflight.sh         (valida Tails/Tor/persistência/admin)
│   ├── post-session.sh      (Tor + onion-grater pós-upgrade Tails)
│   └── qa-validate.sh       (validação de qualidade — tela + log · hub.sh qa validate)
│
├── qa/                      (Validação / QA)
│   ├── confirm-seed.sh      (confirma seed no papel — sem gravar palavras)
│   ├── confirm-step9.sh     (confirma 2 cópias físicas separadas)
│   ├── confirm-step12.sh    (confirma cold-signing offline)
│   └── export-logs.sh       (copia qa-logs/ para pendrive)
│
├── steps/                   ★ FALLBACK atômico (passo 2 em pedaços — avançado)
│   ├── 01-setup-dirs.sh
│   ├── 02-download-deb.sh
│   ├── 04-import-key.sh
│   ├── 05-verify-sig.sh
│   ├── 06-check-deps.sh
│   ├── 07-install-deb.sh
│   ├── 08-open-haveno.sh
│   └── run-all.sh           (executa 01→08, para no 1º FAIL)
│
└── sync-hub-scripts.sh      (instala/atualiza esta pasta)
```

#### Fichas dos scripts principais

| Comando / Script | Passo hub | O que faz | Quando usar | Rodar 2×? |
|-----------------|:---------:|-----------|-------------|:---------:|
| `hub.sh install` | 2 | Orquestrador: preflight → download + PGP + install + verde | 1ª vez | Seguro |
| `hub.sh install --qa-log` | 2 | Idem com log de evidência | 1ª vez (recomendado) | Seguro |
| `hub.sh install --install-only` | 2 | .deb já em Install/ — deps + install.sh (sem download) | Retomar após download OK | Seguro |
| `hub.sh install --one-password` | 2 | Senha admin uma vez só no fluxo | Conforto (opt-in) | Seguro |
| `hub.sh boot` | 7 | Preflight → boot Haveno na sessão | Cada sessão após instalar | Seguro |
| `hub.sh boot --qa-log` | 7 | Idem com log | Cada sessão (recomendado) | Seguro |
| `hub.sh backup` | 4, 7 | Backup cifrado Data/ com GPG | Antes do 1º depósito; periodicamente | Seguro (timestamp) |
| `hub.sh backup --usb` | 4 | Salvar backup em pendrive separado | Mídia extra | Seguro |
| `hub.sh backup --dest /caminho` | 4 | Pasta específica | Destino personalizado | Seguro |
| `hub.sh backup --restore ARQUIVO` | — | Restaura Data/ (pede confirmação) | Recuperação | Cuidado — sobrescreve |
| `hub.sh update` | 7 | Atualizar .deb com PGP (backup automático antes) | Release novo da rede | Seguro |
| `hub.sh feather` | 5 | Feather: PGP fail-closed + abre UI | Passo 5 | Seguro (não mexe em wallets/) |
| `hub.sh feather --qa-log` | 5 | Idem com log | Passo 5 (recomendado) | Seguro |
| `hub.sh qa validate` | — | Valida scripts (sintaxe + PGP + YAML) — tela + log | A qualquer momento | Seguro |
| `hub.sh qa finalize` | 2 | validate + confirm-seed (1ª instalação) | Ao final do install, 1 vez | Seguro |
| `hub.sh qa confirm-seed` | 4 | Confirma seed no papel (sem gravar palavras) | Após anotar seed | Seguro |
| `hub.sh qa ritual-seed` | 9 | Confirma 2 cópias físicas separadas | Passo 9 | Seguro |
| `hub.sh qa cold-sign` | 12 | Confirma cold-signing offline | Após passo 12 | Seguro |
| `hub.sh qa export-logs` | — | Copia qa-logs/ para pendrive | Entregar evidências | Seguro |
| `haveno/verify-deb.sh` | — | Verificar assinatura GPG do .deb | Dúvida sobre autenticidade | Seguro (só leitura) |
| `haveno/switch-network.sh` | — | Trocar rede Haveno (backup + update) | Mudar para outra rede | Cuidado — feche trades antes |
| `system/preflight.sh` | 1–4 | Valida Tails/Tor/persistência/admin | Antes de qualquer script | Seguro (só leitura) |
| `system/post-session.sh` | 7 | Tor + onion-grater pós-upgrade Tails | Após atualizar o SO Tails | Seguro |
| `qa/confirm-seed.sh` | 4 | Confirma seed no papel (sem gravar palavras) | Após passo 4 | Seguro |
| `qa/confirm-step9.sh` | 9 | Confirma 2 cópias físicas separadas | Passo 9 | Seguro |
| `qa/confirm-step12.sh` | 12 | Confirma cold-signing offline | Após passo 12 | Seguro |
| `qa/export-logs.sh --usb` | — | Copia qa-logs/ para pendrive | Entregar evidências | Seguro |

#### Flags do hub.sh install

```bash
~/Persistent/hub-scripts/hub.sh install              # padrão: download + PGP + install + abrir
~/Persistent/hub-scripts/hub.sh install --qa-log     # grava log em ~/Persistent/qa-logs/
~/Persistent/hub-scripts/hub.sh install --one-password # senha admin uma vez só no fluxo
~/Persistent/hub-scripts/hub.sh install --install-only # .deb já em Install/ — deps + install.sh (sem download)
```

#### Flags do hub.sh backup

```bash
~/Persistent/hub-scripts/hub.sh backup                    # cifrado em ~/Persistent/Backups/
~/Persistent/hub-scripts/hub.sh backup --usb              # escolhe USB montado
~/Persistent/hub-scripts/hub.sh backup --dest /caminho    # pasta específica
~/Persistent/hub-scripts/hub.sh backup --no-encrypt       # NÃO recomendado
~/Persistent/hub-scripts/hub.sh backup --restore ARQUIVO  # SOBRESCREVE Data/ — pede confirmação
```

#### O que NÃO tem script (e por quê — sempre manual)

| Tarefa | Por quê manual |
|--------|----------------|
| Seed no papel / metal | Segurança física — humano anota |
| Trades, disputas, fiat | Julgamento e risco financeiro |
| Passo 9 (ritual 2× seed) | Cópias físicas em locais separados |
| Passo 12 (cold-signing, sem rede) | Air-gap, USB entre máquinas, confirmar destino antes de assinar |
| Upgrade do Tails (SO) | Só via Tails Upgrader oficial |
| BIOS, Kleopatra (Windows), USB passthrough | GUI / hardware |

---

### APÊNDICE B — Erros Comuns (TOP 10)

#### 1. Pop-up "No default Tor Instance configured"

**Causa:** onion-grater não está configurado ou o `haveno.yml` não foi copiado.

```bash
sudo cp /home/amnesia/Persistent/haveno/App/utils/haveno.yml /etc/onion-grater.d/haveno.yml
sudo chmod o+r /var/run/tor/control.authcookie
sudo systemctl restart onion-grater
```

---

#### 2. Log mostra `loaded filter: None` ou `command filtered: AUTHCHALLENGE`

**Causa:** mesma do erro 1.

```bash
python3 -c "import yaml; yaml.safe_load(open('/etc/onion-grater.d/haveno.yml')); print('YAML OK')"
sudo systemctl restart onion-grater
```

---

#### 3. `.sig` rejeitada com ~119 bytes (versão antiga do script)

**Causa:** a `.sig` do release 1.6.0-reto é uma assinatura **Ed25519 binária legítima** (119 B, magic byte `0x88`). Versões antigas do script esperavam ASCII-armored (`>= 400 B` + `BEGIN PGP SIGNATURE`) e descartavam a sig válida após 3 tentativas. A versão corrigida usa verificação de bytes OpenPGP (`0x88`/`0x89`/`0xC2`).

```bash
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
./sync-hub-scripts.sh
~/Persistent/hub-scripts/hub.sh install --qa-log
```

O `sync-hub-scripts.sh` distribui a versão corrigida (`haveno_sig_valid_format`). Se o `.deb` já estiver completo em `Install/`, use `hub.sh install --install-only --qa-log`.

---

#### 4. `$'\r': comando não encontrado`

**Causa:** scripts copiados do Windows têm CRLF em vez de LF.

```bash
dos2unix ~/Persistent/hub-scripts/*.sh
```

---

#### 5. `sudo echo ok` falha — admin não configurado

**Causa:** a senha de administrador não foi definida no boot.

**Solução:** reinicie o Tails e na tela de boas-vindas, clique "+ Mais opções" e defina a senha admin.

---

#### 6. Haveno abre mas fica amarelo por muito tempo (>30 min)

**Causa:** 1ª sincronização P2P/Monero, Tor lento, ou onion-grater com problema.

```bash
sudo journalctl -u onion-grater --no-pager | tail -20
```

Se `loaded filter: haveno` → aguarde mais (pode demorar 20–30 min na 1ª vez).
Se `loaded filter: None` → erro 1 acima.

---

#### 7. `EXPKEYSIG` ao verificar Whonix

**Causa:** chave Whonix expirada no keyring local.

```bash
curl -fsSL https://www.whonix.org/keys/derivative.asc -o derivative.asc
gpg --import derivative.asc
```

O fingerprint `916B8D99…2EEACCDA` não mudou — só reimporte.

---

#### 8. View-only mostra saldo errado após envio

**Causa:** key images não re-sincronizadas após o último envio.

**Solução:** execute o ciclo B2 (export_outputs → import_outputs → export_key_images → import_key_images) completo.

---

#### 9. Feather: `Good signature` mas fingerprint diferente

**Causa:** chave falsa com o mesmo nome "FeatherWallet" — isso é um ataque real.

🔴 **Não use.** Baixe novamente do site oficial e verifique que o fingerprint é exatamente `8185 E158 A333 30C7 FD61  BC0D 1F76 E155 CEFB A71C`.

---

#### 10. VirtualBox: "VT-x is not available" (Windows)

**Causa:** Hyper-V, WSL2 ou Virtual Machine Platform ocupando VT.

**Solução:** Painel de Controle → Programas → Recursos do Windows → desmarque: Hyper-V, Virtual Machine Platform, Windows Hypervisor Platform. Reinicie.

---

#### 11. `install.sh` falhou — dependências do `.deb` (`não tem candidato para instalação`)

**Causa (validada em campo jun/2026):** o `.deb` do haveno-reto **1.6.0** declara dependências com **nomes de bibliotecas do Ubuntu** — no Debian 13 do Tails esses pacotes não existem com esses nomes (`libicu74`, `libavcodec60`, `libjpeg-turbo8`...). Não adianta tentar `apt-get install libicu74` — vai falhar sempre. Não é problema do seu Tor nem do Tails.

**Por que funciona mesmo assim:** o app embute o próprio runtime (Java/JavaFX); as libs declaradas não fazem falta na prática.

**Correção automática (scripts atualizados):** o hub instala só o que existe no Tails e aplica `--force-depends` para os nomes Ubuntu-only. Você não precisa fazer nada — rode `./sync-hub-scripts.sh` se ainda não fez.

**Recuperação manual** (apenas se os scripts não estiverem disponíveis):

```bash
sudo apt-get update
sudo dpkg -i --force-depends ~/Persistent/haveno/Install/haveno.deb
sudo ~/Persistent/haveno/App/utils/install.sh
```

🔴 **NUNCA rode `sudo apt-get install -f` com o Haveno desconfigurado** — propõe remover o Haveno em vez de consertar.

📎 Cada sessão re-registra o `.deb` (rápido, sem novo download — o `.deb` de 264 MB fica em `Install/`). A carteira em `Data/` nunca é reinstalada.

---

#### 12. `torControlCookieFile ... is not readable` (Haveno fecha na hora)

**Causa:** o `chmod o+r` no cookie do Tor se perde a **cada boot** (Tails é amnésico). Sem leitura no cookie, o Haveno aborta antes de abrir a janela.

Sintoma em `/tmp/haveno-exec.log`:
```text
haveno.common.config.ConfigException: problem parsing option 'torControlCookieFile':
File [/var/run/tor/control.authcookie] is not readable
```

**Correção:**

```bash
sudo chmod o+r /var/run/tor/control.authcookie
```

📎 Os scripts do hub (atualizados em jun/2026) reaplicam esse `chmod` automaticamente em toda sessão, antes de abrir o Haveno.

---

#### 13. `Command filtered` — "A conexão com a rede do Haveno falhou" (1.6.0)

**Causa (bug do instalador upstream 1.6.0):** o Haveno 1.6.0 passou a publicar o hidden service com parâmetros **PoW** (anti-DoS) no `ADD_ONION`, mas o `haveno.yml` que vem dentro do instalador só autoriza o comando sem esses parâmetros — o onion-grater (corretamente fail-closed) bloqueia.

Sintoma em `journalctl -u onion-grater -b`:
```text
command filtered: ADD_ONION NEW:BEST PoWQueueBurst=100 PoWDefensesEnabled=1 PoWQueueRate=10 Port=9999,...
```

**Correção:**

```bash
sudo cp ~/Persistent/hub-scripts/lib/onion-grater.yml /etc/onion-grater.d/haveno.yml
sudo systemctl restart onion-grater
```

Confirme `loaded filter: haveno` no journalctl e reabra o Haveno. O `sync-hub-scripts.sh` copia o filtro corrigido automaticamente.

✅ OK SE: Haveno mostra *"Conectado a Mainnet de Monero (via Tor)"* + *"Nó da rede Tor criado"*.

---

#### 14. O Tails pede a senha de admin a cada comando — dá para digitar uma vez?

**Não é bug — é proposital.** O Tails embarca `Defaults timestamp_timeout=0`, ou seja, o `sudo` nunca guarda a senha em cache. É uma proteção do Tails.

🔴 **Não rode tudo como root:** criaria arquivos de root na persistência e abriria a carteira Haveno como root — perigoso.

**Se quiser digitar a senha uma vez só**, todos os scripts aceitam a flag opcional **`--one-password`**:

```bash
~/Persistent/hub-scripts/hub.sh install --one-password   # 1ª vez
~/Persistent/hub-scripts/hub.sh boot --one-password      # cada sessão
```

Ela instala um ajuste **temporário de sessão** (o `sudo` guarda a senha até o script terminar) e o **remove automaticamente no fim**. O Tails é amnésico — o ajuste some ao reiniciar.

> ⚠️ **Trade-off:** enquanto o script roda, a proteção de pedir senha sempre fica afrouxada. É **opt-in** — sem a flag, o comportamento seguro padrão continua.

---

#### 15. Instalação aborta na verificação PGP (`No such file or directory` ou `Verification failed`)

**Duas causas** (ambas no instalador upstream, corrigidas no hub em jun/2026):

1. **Assinatura ausente:** o upstream baixa a `.sig` sem checar erro; se ela não chega, o gpg não tem o arquivo. **Correção:** scripts agora pré-baixam a `.sig` (fail-closed, pelo Tor) antes de chamar o instalador.

2. **Locale:** o upstream procura `Good signature from` em inglês; num Tails em português o gpg responde *"Assinatura correta de…"* e o script diz `Verification failed` mesmo com assinatura boa. **Correção:** o hub roda o instalador com `LC_ALL=C`.

**Solução:** rode `./sync-hub-scripts.sh` para ter os scripts atualizados. Se ainda assim falhar, confira a URL do release e o Tor — o `.deb` já baixado é retomado sem recomeçar.

🔴 Nunca instale um `.deb` cujo `.sig` não foi verificado. O fluxo aborta de propósito (fail-closed).

---

### APÊNDICE C — Fingerprints Oficiais

🔴 **Confira com os seus próprios olhos antes de qualquer verificação.** Não copie de lugares não confiáveis.

| Projeto | Fingerprint | Fonte |
|---------|------------|-------|
| **Haveno / RetoSwap** | `DAA2 4D87 8B8D 36C9 0120  A897 CA02 DAC1 2DAE 2D0F` | https://retoswap.com/reto_public.asc (TOFU) |
| **Feather Wallet** | `8185 E158 A333 30C7 FD61  BC0D 1F76 E155 CEFB A71C` | https://docs.featherwallet.org |
| **Whonix** | `916B 8D99 C38E AF5E 8ADC  7A2A 8D66 066A 2EEA CCDA` | https://www.whonix.org/wiki/Main/Project_Signing_Key |
| **Monero (binaryfate)** | `81AC 591F E9C4 B65C 5806  AFC3 F0AF 4D46 2A0B DF92` | https://www.getmonero.org |
| **P2Pool (SChernykh)** | `1FCA AB4D 3DC3 310D 16CB  D508 C47F 82B5 4DA8 7ADF` | https://p2pool.io + monero-project/gitian.sigs |
| **xmrig** | `9AC4 CEA8 E66E 35A5 C7CD  DC1B 446A 5363 8BE9 4409` | https://xmrig.com/docs/gpg-key |

> Em sistemas PT-BR, `gpg` exibe **`Assinatura válida`** no lugar de `Good signature` — ambos significam a mesma coisa.

> **RetoSwap (TOFU):** importe a chave de https://retoswap.com/reto_public.asc e confira o fingerprint importando — não apenas copiando. Não há Web of Trust para esta chave.

---

### APÊNDICE D — Glossário Completo

| Termo | Significado | Passos |
|-------|-------------|:------:|
| **Online (Tor)** | Tails com internet só via Tor | 1–9 |
| **Offline (rede)** | Tails sem Wi-Fi/cabo | 12 |
| **Offline (papel)** | Seed em papel/metal; sem foto/chat/nuvem | 4, 9 |
| **Air-gap (fluxo)** | Spend key só no frio; quente view-only | 11–12 |
| **Pendrive trânsito** | USB só para tx/outputs entre frio e quente | 12 |
| **Host Linux** | PC com VirtualBox/KVM (não é Tails) | 10 |
| **Cold-Tails** | Tails bootado offline; carteira completa com spend key | 12 |
| **Hot-Whonix** | Whonix online via Tor; carteira view-only | 10–12 |
| **Seed** | 25 palavras que recuperam os fundos | 4, 9 |
| **Spend key** | Chave que autoriza gastos. Vive só na máquina fria | 12 |
| **Secret view key** | Chave de visualização. Copiada para o Whonix. Não move fundos | 12 |
| **View-only** | Carteira que vê saldo e histórico mas não gasta | 12 |
| **Restore height** | Altura de bloco da criação. Anote na criação | 4, 12 |
| **Outputs** | Dados da blockchain para montar transações | 12 |
| **Key images** | Prova criptográfica de que outputs não foram gastos | 12 |
| **Unsigned tx** | Transação montada (quente) mas não assinada | 12 |
| **Signed tx** | Transação assinada (fria) pronta para transmitir | 12 |
| **TOFU** | Trust On First Use — confiança no primeiro uso, sem Web of Trust | — |
| **Onion-grater** | Filtro do Tails que controla o que o Haveno pode fazer no Tor | 2 |
| **Dotfiles** | Opção da persistência que guarda atalhos do menu | 1 |
| **Persistência** | Armazenamento criptografado no USB do Tails | 1 |
| **Trilha A** | Cold-signing com Feather GUI (recomendado) | 12 |
| **Trilha B** | Cold-signing com monero-wallet-cli (avançado) | 12 |
| **M1** | Módulo 1: Haveno (passos 1–7) — núcleo 1–3 · pré-M2 4–7 | 1–7 |
| **M2** | Módulo 2: Whonix + Custódia fria (passos 8–12) | 8–12 |
| **home lab** | Infraestrutura opcional em Debian/Ubuntu (nó, mineração) | Opcional |
| **KYC** | Know Your Customer — verificação de identidade (evitar) | 6 |
| **Escrow multisig** | Carteira 2-de-3 automática por trade no Haveno | 6 |
| **P2P** | Peer-to-peer — sem servidor central | — |
| **onion** | Endereço `.onion` da rede Tor — mais privado que clearnet | — |
| **qa-log** | Flag que grava evidências em ~/Persistent/qa-logs/*.txt | — |
| **CONFIRMACAO_HUMANA** | Linha no log (SIM/NÃO) — nunca grava seed | — |

---

### APÊNDICE E — Instalar Whonix por SO (referência completa)

#### Windows — Gpg4win + VirtualBox

**Passo 1: Instalar Gpg4win**
```text
Baixe: https://gpg4win.org
Instale (inclui Kleopatra)
```

**Passo 2: Importar chave Whonix**
```text
Kleopatra → File → Import → selecione derivative.asc
Confirme fingerprint nas propriedades: 916B8D99…2EEACCDA
```

**Passo 3: Verificar imagem**
```text
Kleopatra → Decrypt/Verify → selecione Whonix-*.ova.asc
(com .ova na mesma pasta)
OK se: assinatura VÁLIDA emitida por 916B8D99…2EEACCDA
```

**Passo 4: Instalar VirtualBox**
```text
https://www.virtualbox.org/wiki/Downloads
Aceite os prompts de instalação de drivers de rede
```

**Passo 5: Importar VMs**
```text
VirtualBox → File → Import Appliance → Whonix-*.ova verificado
→ Next → Import → aguarde
Inicie Gateway PRIMEIRO → espere Tor Connection
SÓ ENTÃO inicie Workstation
```

**Troubleshooting Windows:**
- "VT-x not available": desative Hyper-V/WSL2 em Recursos do Windows → reinicie
- Import lento: SSD recomendado; libere 30 GB+

---

#### macOS — GPG Suite + VirtualBox

```bash
# Instale GPG Suite: https://gpgtools.org
# Baixe VirtualBox: https://www.virtualbox.org/wiki/Downloads

# Verificação:
gpg --import derivative.asc
gpg --fingerprint 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA
gpg --verify-options show-notations --verify Whonix-*.ova.asc Whonix-*.ova
```

```text
VirtualBox → File → Import Appliance → Whonix-*.ova verificado
→ mesma ordem: Gateway primeiro, depois Workstation
```

---

#### Linux — Script automático ou manual

**Atalho (recomendado):**
```bash
chmod +x whonix-verify-image.sh
./whonix-verify-image.sh /caminho/Whonix-*.ova /caminho/Whonix-*.ova.asc
```

**Manual:**
```bash
gpg --import derivative.asc
gpg --fingerprint 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA
gpg --verify-options show-notations --verify Whonix-*.ova.asc Whonix-*.ova
```

**VirtualBox (Linux):**
```bash
# Instale: sudo apt install virtualbox
# Importe:
VBoxManage import Whonix-*.ova
# Ou pela GUI: File → Import Appliance
```

**KVM (Linux avançado):**
```bash
# Verifique primeiro:
gpg --verify-options show-notations --verify Whonix-*.libvirt.xz.asc Whonix-*.libvirt.xz

# Importe seguindo o guia oficial KVM:
# https://www.whonix.org/wiki/KVM
# (os comandos virsh mudam por versão — sempre use a fonte oficial)
```

**Troubleshooting KVM:**
- Redes ausentes: siga o guia KVM oficial do início
- `permission denied`: `sudo usermod -aG libvirt,kvm $USER` → logout/login
- Gateway sem Tor: confira hora do host; não bloqueie saída Tor

---

### USB passthrough — pendrive de trânsito frio↔quente

Para as **Trilhas A/B** (cold-signing, passos 12A/12B), o pendrive de trânsito precisa ser visível na **Whonix-Workstation**. Se usar hardware wallet opcional, o dispositivo USB também.

**VirtualBox:**

1. Instale o **VirtualBox Extension Pack** (mesma versão do VirtualBox instalado).
2. Com a **Whonix-Workstation desligada**: Settings → USB → habilite USB 2.0/3.0.
3. Adicione um **filtro USB** para o pendrive (ou dispositivo) — assim a VM captura o device ao plugar.
4. Inicie a Workstation **depois** de plugar o pendrive (ou use o ícone USB na barra lateral para anexar em tempo real).

**KVM:** anexe o dispositivo via `virt-manager` (*USB redirection*) ou configure política do host — ver guia oficial do Whonix se o passthrough falhar: https://www.whonix.org/wiki/KVM

📎 O pendrive de trânsito **nunca** deve ser usado na máquina quente com carteira **completa** — só arquivos de outputs/tx entre frio e quente.

---

### APÊNDICE F — Trades Hands-on (Rede Descentralizada — Resumo)

> **Lembre:** Instalar ≠ tradear. Este apêndice é para quem já concluiu os passos 1–7 e quer usar o Haveno para comprar/vender XMR. Comece sempre com **valores pequenos**.

#### O que é a rede descentralizada

```text
Seu Tails (Haveno cliente + Feather carteira)
  ↓ Tor P2P
Rede de terceiros (Reto):
  - Seed nodes (entrada P2P)
  - Árbitros (resolvem disputas)
  - Outros traders (P2P)
```

**Regra:** Haveno não é Binance. Sem conta central. Negocia P2P com outra pessoa; a rede fornece infraestrutura e árbitros.

#### Antes do 1º trade — checklist mínimo

| # | Faça |
|---|------|
| 1 | Cap. 2 seed: Account → Wallet seed → anote 25 palavras em papel **antes** de depositar |
| 2 | Cap. 5 Feather: saber mover XMR entre custódia e Haveno |
| 3 | Ler folheto golpes (Passo 6) — memorizar regras |
| 4 | Confirmar nos canais oficiais que trading está ativo para a sua versão |
| 5 | Valor pequeno de teste primeiro |

#### Fluxo de compra (paga fiat, recebe XMR)

```text
1. Haveno → Buy → selecione oferta ou crie nova
2. Trade aberto → escrow multisig 2-de-3 criado automaticamente
3. Pague pelo método acordado (PIX, TED, etc.)
4. Guarde comprovante de pagamento
5. Marque "Pago" no Haveno (só após pagar de fato)
6. Contraparte confirma → XMR liberado automaticamente
7. Se demorar: abra DISPUTA dentro do app (nunca por fora)
```

#### Fluxo de venda (recebe fiat, entrega XMR)

```text
1. Haveno → Sell → crie oferta ou aceite uma
2. Aguarde o comprador marcar "Pago"
3. Confirme que o dinheiro chegou NA SUA CONTA e é IRREVERSÍVEL
4. Cuidado com: estorno de cartão, PayPal, transferências TED que podem ser revertidas
5. Prefira PIX ou dinheiro presencial (irreversíveis)
6. SÓ ENTÃO confirme recebimento → XMR liberado
7. Se houver problema: DISPUTA dentro do app
```

#### Multisig 2-de-3 (o que o app faz por você)

- Trade cria automaticamente uma carteira 2-de-3: você + contraparte + árbitro
- Para liberar: 2 das 3 chaves precisam concordar
- Em trade normal: você + contraparte (árbitro não entra)
- Em disputa: você ou contraparte + árbitro decide
- O árbitro **nunca** pede sua seed — age apenas dentro do app

---

### Multisig 2-de-3 manual via CLI (educacional — laboratório)

> **Para trades no Haveno:** o app cria o escrow 2-de-3 **automaticamente** — você não precisa deste fluxo. Este bloco é para quem quer **entender o protocolo** ou criar uma carteira multisig Monero manual fora do Haveno.
>
> 🔴 **Use stagenet/testnet para praticar.** Mainnet só após dominar o fluxo completo.

#### Quando usar vs. quando NÃO

| Situação | Precisa deste fluxo? |
|----------|----------------------|
| Tradear no Haveno (escrow por trade) | **Não** — o protocolo cria 2-de-3 sozinho |
| Entender como 2-de-3 funciona na prática | **Sim** — leitura + exercício em testnet/stagenet |
| Carteira multisig Monero fora do Haveno (2-of-3 entre pessoas) | **Sim** — fluxo completo abaixo |

#### Avisos load-bearing (leia antes)

- Multisig no Monero é **experimental** no CLI. Antes de qualquer comando: `set enable-multisig-experimental 1`
- A doc oficial lista riscos: fundos podem ficar **irrecuperáveis**, gastos duplos ou roubo por participante malicioso se o setup falhar.
- `prepare_multisig` **inclui a view key privada** na string `MultisigV1…` — troque só por **canal seguro** entre os participantes da **mesma** carteira multisig.
- Nunca misture strings de participantes de **outras** carteiras ou em ordens erradas.

#### Onde rodar no hub (Cold-Tails / Hot-Whonix)

| Papel | Máquina | Por quê |
|-------|---------|---------|
| Participante que **assina** gastos | **Tails offline** | Spend keys não tocam rede |
| Sincronizar / montar tx (opcional) | **Whonix Workstation** | Tor + nó `.onion` — só se view-only ou participante quente acordado |

#### Fluxo completo 2-de-3 (três participantes, threshold 2)

**Passo A — `prepare_multisig` (cada participante):**

```bash
monero-wallet-cli --stagenet --daemon-address <URL_DO_DAEMON>
```

Dentro do CLI, cada um executa:

```text
set enable-multisig-experimental 1
set inactivity-lock-timeout 0
prepare_multisig
```

Saída: string longa começando com `MultisigV1…` — **copie e troque com os outros 2 participantes por canal seguro.**

**Passo B — `make_multisig` (cada participante):**

```text
make_multisig 2 <MultisigV1_participante_B> <MultisigV1_participante_C>
```

(substitua pelos dados dos **outros dois** — não a sua string)

Saída: nova string para troca.

**Passo C — `exchange_multisig_keys` (cada participante — duas rodadas em 2-de-3):**

Rodada 1:
```text
exchange_multisig_keys <nova_string_B> <nova_string_C>
```

Troque as novas strings de saída. Rodada 2:
```text
exchange_multisig_keys <string_rodada2_B> <string_rodada2_C>
```

Repita até o CLI indicar que a troca está completa para os três.

✅ OK SE: `wallet info` mostra multisig **2/3** e mesmo endereço nos três CLIs.

**Receber fundos:**

```text
address
```

Envie teste mínimo antes do grosso.

**Gastar (2 assinaturas necessárias):**

```text
# Participante que monta a transação:
transfer <ENDERECO> <VALOR>

# Cada co-signatário exporta e troca por canal seguro:
export_multisig_info multisig_info.txt
import_multisig_info multisig_info_do_outro.txt

# Assinar:
sign_multisig multisig_monero_tx

# Transmitir (quando threshold atingido):
submit_multisig multisig_monero_tx
```

✅ OK SE: tx confirmada on-chain; saldo atualizado nos três CLIs.

**Referências:**
- Doc oficial: https://docs.getmonero.org/multisignature/
- Whonix + multisig: https://www.whonix.org/wiki/Monero_Multisig

---

## 📅 ROADMAP 2025–2030

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ROADMAP 2025–2030                                    │
│             (Cronograma de Evolução do Privacy-OS-Hub)                      │
└─────────────────────────────────────────────────────────────────────────────┘

  2025                2026                2027–2028           2029–2030
   │                   │                   │                   │
   ▼                   ▼                   ▼                   ▼
┌──────────┐      ┌──────────┐      ┌──────────┐      ┌──────────────┐
│  v1 base │      │ v2 beta  │      │   v2.1   │      │     v3.0     │
│          │      │          │      │          │      │              │
│ • M1     │  →   │ • M1+M2  │  →   │ • Serenó │  →   │ • Haveno 2.x │
│   Tails  │      │ • trilha │      │   funds  │      │ • Post-      │
│   Haveno │      │   1–12   │      │ • HW     │      │   quantum    │
│          │      │ • scripts│      │   wallet │      │   Monero     │
│          │      │   QA     │      │   docs   │      │ • Tails next │
└──────────┘      └──────────┘      └──────────┘      └──────────────┘
                       ↑
               [VOCÊ ESTÁ AQUI]
               Versão 1.0 · jun/2026
```

| Horizonte | Item | Status | Impacto |
|-----------|------|:------:|:-------:|
| **2026 Q3** | Screenshots reais PI-8 (Haveno UI no Tails) | 🟡 Pendente | Didático |
| **2026 Q3** | Screenshots reais PI-1 (Whonix no repo público) | 🟡 Pendente | Didático |
| **2026 Q3** | Piloto campo Nível B+ (trilha 1–12 + HW wallet) | 🟡 Em andamento | Validação |
| **2026 Q4** | v2.0.0 estável (tag após B+ PASS) | 🔵 Planejado | Release |
| **2027** | Serenó Funds (custódia institucional Monero) | 🔵 Acompanhar | Expansão |
| **2027** | Hardware wallet — YubiKey / Ledger docs | 🔵 Planejado | Opcional |
| **2028** | Haveno 2.x (nova versão upstream) | ⚫ Horizonte | Upgrade |
| **2028–2030** | Monero pós-quântico (FCMP++, Seraphis) | ⚫ Horizonte | Protocolo |
| **2030** | Privacy-OS-Hub v3.0 (novo baseline) | ⚫ Horizonte | Reescrita |

> **⚫ Horizonte:** planejado para longo prazo ou dependente de upstream — não bloqueia o curso atual.

---

## Anexo (mantenedor): orientações editoriais

**Regras de manutenção deste arquivo:**

1. **NUNCA** use links relativos entre arquivos (`../../algo.md`) — tudo inline.
2. Links externos permitidos apenas para fontes oficiais (tails.net, haveno.exchange, featherwallet.org, whonix.org, getmonero.org, github.com/retoaccess1, github.com/xmrig, p2pool.io) e fingerprints.
3. Cada PASSO deve ter: contexto (2-3 linhas), comandos em bloco de código, verificação ("Você deve ver:"), aviso de erro comum.
4. Blocos de código sempre com linguagem: ```bash, ```text, etc.
5. Use tabelas para comparações e checklists.
6. Diagramas ASCII para fluxos (não mermaid — o arquivo deve ser portátil).
7. PT-BR consistente.
8. Não crie seções "ver mais em outro lugar" — tudo inline.
9. Versões de software: verificar CLAUDE.md antes de afirmar versão.
10. Fingerprints: verificar sempre as fontes oficiais antes de publicar.

**Fontes para atualização:**
- Curso: este arquivo (canônico)
- Scripts: `docs/MANUAL.md` · `automacao/tails/README.md` · `automacao/docs-aluno/TRES-PASSOS-HAVENO-TAILS.md`
- Fingerprints e versões: `CLAUDE.md` (camada local)

---

## 🏁 CONCLUSÃO

Você concluiu o Privacy-OS-Hub – Versão 1.0.

**O que você conquistou:**
- Tails no pendrive com persistência e Dotfiles
- Haveno com indicador verde + onion-grater configurado
- Seed das 25 palavras em duas cópias físicas separadas
- Backup cifrado da pasta Data/
- Feather Wallet instalado e verificado por PGP
- Whonix verificado por PGP, Gateway + Workstation funcionando
- Cold-signing ao vivo com air-gap real
- A spend key nunca tocou a internet

**O que fazer a seguir (opcional):**
- Home Lab (nó Monero + Tor + mineração): veja o arquivo "Home-Lab – Versão 1.0"
- Baseline de segurança adicional: Zero-Trust-Core (https://github.com/VIPs-com/Zero-Trust-Core)
- Aprofundar trades no Haveno: Apêndice F + canais oficiais da rede

**Lembre-se sempre:**
- Instalar ≠ tradear
- Seed em papel, nunca digital
- Verificar PGP antes de executar qualquer binário
- Começar com valores mínimos

---

*Privacy-OS-Hub · Versão 1.0 · jun/2026 · Licença documentação: CC BY-SA 4.0*
