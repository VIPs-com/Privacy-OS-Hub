# Módulo 2 — Whonix Online (lado em rede) + Cold-Tails-Hot-Whonix

> **Guia aprofundado.** O lado **online persistente** do hub — e, sobretudo, a **custódia frio↔quente**
> que protege os seus fundos: a **chave de gasto (seed) nunca toca a internet**. Onde os comandos exatos
> mudam por versão/SO, aponto a **fonte oficial** — confira sempre antes de executar dinheiro real.
>
> **Pré-requisito:** [Módulo 1 (Tails + Haveno)](../Tails%20OS%20Expert/README.md) concluído — seed, carteira,
> escrow, verificação de binários, Feather no Tails.

## Sumário

1. [O que é o Whonix (e o modelo de ameaças)](#1-o-que-é-o-whonix-e-o-modelo-de-ameaças)
2. [Instalar e verificar a imagem](#2-instalar-e-verificar-a-imagem)
3. [Primeiros passos, atualização e snapshots](#3-primeiros-passos-atualização-e-snapshots)
4. [Monero no Whonix — conectar via Tor](#4-monero-no-whonix--conectar-via-tor)
5. [**Cold-Tails-Hot-Whonix** — custódia frio↔quente (o coração)](#5-cold-tails-hot-whonix)
6. [Onde o Haveno entra (a narrativa frio→quente)](#6-onde-o-haveno-entra)
7. [Quando usar Whonix × Tails × home lab](#7-quando-usar)
8. [Links oficiais](#8-links-oficiais)

---

## 1. O que é o Whonix (e o modelo de ameaças)

Duas máquinas virtuais que trabalham juntas no seu **host** (seu PC normal):

| VM | Papel | Vê a rede? |
|----|-------|------------|
| **Whonix-Gateway** | Força **todo** o tráfego por **Tor**. | Sim — e só por Tor. |
| **Whonix-Workstation** | Onde você trabalha (carteira, navegação). | **Não** diretamente — só através do Gateway. |

Consequência prática: mesmo um programa **comprometido** na Workstation **não enxerga o seu IP real** — ele só alcança o Gateway, que só sai por Tor. É um isolamento de rede que o Tails sozinho não dá (no Tails, um vazamento depende do app respeitar o Tor; no Whonix, a separação é **arquitetural**).

### Modelo de ameaças (entenda o que está protegendo)

| O que protege | Contra o quê | Como |
|---------------|--------------|------|
| **Gateway/Workstation** | Vazamento de **IP** por app malicioso/bugado | Workstation não tem rota direta à internet |
| **Tor por padrão** | Correlação de rede, ISP, vigilância | Todo tráfego sai por Tor |
| **Persistência (VM)** | — | Diferente do Tails (amnésico): o Whonix **guarda** estado entre boots |
| **Cold/hot (Cap. 5)** | **Roubo dos fundos** | A **chave de gasto** nunca fica numa máquina online |

> **Whonix × Tails (papéis no hub):** o **Tails** é **amnésico/efêmero** — perfeito para o lado **frio/offline**
> (gerar e custodiar a chave, assinar air-gapped). O **Whonix** é **persistente/online** — perfeito para o
> que precisa ficar ligado e em rede (carteira *watch-only*, navegação, conectar ao seu nó). Eles **se completam**.

**OK se:** você sabe explicar Gateway (roteia tudo por Tor) × Workstation (trabalho isolado), e **por que** isso protege o IP de forma arquitetural.

---

## 2. Instalar e verificar a imagem

Baixe **só** de **whonix.org** ([Download](https://www.whonix.org/wiki/Download)). Host suportado:

| Plataforma | Quando |
|-----------|--------|
| **VirtualBox** | Mais fácil (Windows/Linux/macOS). Recomendado para começar. |
| **KVM** | Avançado (Linux). Mais performático/seguro. |
| **Qubes-Whonix** | Avançado. Whonix integrado ao Qubes OS (isolamento por compartimentos). |

> 🔒 **Verifique a imagem antes de importar** — mesma disciplina do Módulo 1: o que não foi verificado, não roda.

1. **Importe a chave de assinatura do Whonix** (Patrick Schleizer / *derivative*):
   - Fingerprint: **`916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA`**
   - Chave pública: https://www.whonix.org/keys/derivative.asc
   - **Confira o fingerprint importando a chave** (`gpg --show-keys derivative.asc` ou `gpg --fingerprint` após importar) — **nunca** apenas copie o número de uma página.
2. **Verifique a assinatura** do arquivo baixado:
   ```bash
   gpg --verify Whonix-*.asc Whonix-*    # precisa dizer: Good signature
   ```
   Procure por **"Good signature"** **e** confirme que o **fingerprint** que assinou é o `916B8D99…2EEACCDA`. "Good signature" de uma chave **errada** não vale.
3. **Passos exatos por SO** (Linux/Windows/macOS — o `gpg` e o nome dos arquivos variam): siga o guia oficial **"Verify the images"** (§8). Não pule esta etapa por preguiça de ler o guia do seu SO.
4. Importe a imagem **verificada** no VirtualBox/KVM e inicie **Gateway + Workstation**.

**OK se:** `gpg --verify` diz **"Good signature"** com o fingerprint `916B8D99…2EEACCDA`; o Gateway conecta ao Tor (ícone/Tor Connection); a Workstation navega — e **só** consegue via Gateway.

> O Whonix **isola**, mas o **host** é a raiz de confiança. Use um host atualizado e confiável; full-disk
> encryption no host é recomendado. Imagem não verificada = **não importe**.

---

## 3. Primeiros passos, atualização e snapshots

- **Atualize** Gateway **e** Workstation logo no 1º boot, **via Tor** (padrão) — siga o guia oficial *Operating System Software Updates* (§8). Em geral, dentro de cada VM:
  ```bash
  sudo apt update && sudo apt full-upgrade
  ```
- **Snapshots:** antes de mudanças grandes, tire um **snapshot** da VM no host (VirtualBox/KVM). Se algo quebrar, você volta.
- **Não misture identidades:** **nunca** use e-mail real, login pessoal ou redes sociais na Workstation que você usa para privacidade (mesma regra do Módulo 1, Cap. 9). Uma Workstation = um propósito.
- **Hora:** o Whonix cuida do tempo via Tor; não ajuste o relógio manualmente (como no Tails).

**OK se:** a atualização completa via Tor sem erro; você tem um snapshot inicial; a Workstation está "limpa" (sem identidade clearnet).

---

## 4. Monero no Whonix — conectar via Tor

A orientação **oficial do Whonix** é usar **nó remoto via Tor** (não rodar um nó pesado dentro da Workstation). Carteira recomendada: **Feather** (leve; o curso já a usa).

### 4.1 Melhor opção — o seu próprio nó (fecha com o Módulo 1)
Conecte ao **seu nó do home lab**, publicado via Tor (`.onion:18089` — Módulo 1, Cap. 6). Você não depende de terceiros e ninguém vê o que você consulta.

- Feather → Settings → Network: **"Always over Tor"**.
- Nó remoto: `SEU_ENDERECO.onion`, porta **18089**, marcar como **confiável** (*trusted*).

### 4.2 Alternativa — nó remoto público (.onion)
Ressalva **oficial do Whonix** sobre nó remoto: o nó **não** pode gastar seu XMR (você tem as chaves), **não** vê seu IP (você conecta por Tor), **não** sabe seu endereço nem saldo. **Porém:** se a carteira avisar **"node is not responding / misbehaving"**, **saia e troque de nó**. Prefira nós `.onion` conhecidos.

### 4.3 Feather no Whonix — verificar antes de usar
Instale o Feather e **verifique o PGP** (fingerprint `8185E158A33330C7FD61BC0D1F76E155CEFBA71C` — ver Módulo 1, Playbook Vol II §2). Binário não verificado, não roda.

**OK se:** o Feather sincroniza via Tor pelo seu `.onion` (ou nó remoto), saldo visível (0 XMR no início é normal).

---

## 5. Cold-Tails-Hot-Whonix

**O coração do hub.** Aqui você separa **quem pode gastar** de **quem fica online** — para que **roubar os seus fundos exija a máquina que nunca toca a internet**.

### 5.1 Por que separar (o princípio)

Quem tem a **chave de gasto** (derivada da **seed**) pode **mover** o seu XMR. Então a regra é simples e inegociável:

> **A chave de gasto / seed vive numa máquina que NUNCA se conecta à rede.** O lado online só **vê** o saldo e **monta** transações — ele **não consegue assinar** (não tem a chave de gasto).

| Carteira | Onde | Tem o quê | Pode |
|----------|------|-----------|------|
| **Fria (full)** | **Tails**, bootado **offline** (air-gap) | seed + view key + **spend key** | **Assinar** (gastar) |
| **Quente (view-only)** | **Whonix**, online via Tor | endereço + **secret view key** + restore height | **Ver** saldo, **montar** tx, **transmitir** |

O que **cruza** entre as duas (por **USB**, nunca por rede): *outputs*, *key images*, transação **não-assinada**, transação **assinada**.

```text
  TAILS (offline / FRIO)                         WHONIX (online / QUENTE)
  Feather COMPLETA                               Feather VIEW-ONLY
  seed + spend key                               endereço + view key + restore height
        │                                                 │
        │  (1) endereço + view key + restore height ─────►│  cria a view-only
        │◄──── (2) outputs (export_outputs) ──────────────│  vê o saldo
        │───── (3) key images (export_key_images) ───────►│  saldo/gastos corretos
        │◄──── (4) unsigned_monero_tx ────────────────────│  você monta a transacao
        │───── (5) signed_monero_tx (sign_transfer) ─────►│  transmite (submit)
        ▼                                                 ▼
  ASSINA offline                                    BROADCAST via Tor/seu nó
```

### 5.2 Criar a carteira **view-only** no Whonix

Na carteira **fria** (Feather no Tails), pegue **três** coisas (Feather: ver [view-only docs](https://docs.featherwallet.org/guides/create-view-only-wallet)):
- **Endereço primário** (começa com `4`),
- **Secret view key** (chave de **visão** — *não* a de gasto!),
- **Restore height** (altura de criação da carteira — sem ela, a view-only não enxerga os fundos).

No **Whonix**, no Feather: **Create new wallet → View only** → cole **endereço + secret view key + restore height** → "Always over Tor" → conecte ao seu nó (4.1).

> ⚠️ É a **secret view key**, **nunca** a *spend key*/seed. A view key só **vê**; não gasta.

**OK se:** a view-only no Whonix sincroniza e mostra **o mesmo saldo** da carteira fria — **sem** ter a chave de gasto.

### 5.3 Gastar com assinatura offline — fluxo **Feather** (recomendado)

O Feather faz airgapped por **(a) QR animado (UR) via webcam** ou **(b) arquivos via USB/SD**. No par Tails↔Whonix, use **arquivos via USB**. Passo a passo (siga a UI atual em [offline-tx-signing](https://docs.featherwallet.org/guides/offline-tx-signing)):

1. **(Quente/Whonix)** sincronize a view-only → **exporte os outputs** para um arquivo (USB).
2. **(Frio/Tails)** abra a carteira **completa** (Tails **offline**), **importe os outputs**, **exporte as key images** (USB).
3. **(Quente/Whonix)** **importe as key images** → agora a view-only mostra saldo e gastos **corretos**.
4. **(Quente/Whonix)** **monte a transação** (destino + valor) → o Feather gera uma **transação não-assinada** (arquivo).
5. **(Frio/Tails)** **importe a não-assinada** na carteira completa → **confira o destino e o valor na tela da carteira FRIA** → **assine** → gera a **transação assinada** (arquivo).
6. **(Quente/Whonix)** **importe a assinada** e **transmita** (broadcast) via Tor/seu nó.

> 🔎 **Confira o endereço de destino na máquina FRIA** antes de assinar — a fria é a **fonte de verdade**.
> Malware na máquina quente poderia trocar o endereço na hora de montar; a sua última checagem é no Tails.

**OK se:** a view-only no Whonix transmite uma transação que foi **assinada no Tails offline**; a chave de gasto **nunca** esteve numa máquina em rede.

### 5.4 O mesmo fluxo no **CLI** (`monero-wallet-cli`, avançado)

Fonte oficial: [Monero — Offline Transaction Signing](https://docs.getmonero.org/cold-storage/offline-transaction-signing/) e [view-only](https://www.getmonero.org/resources/user-guides/view_only.html).

- **Criar a view-only** (na quente): pegue `address` e `viewkey` da fria, depois:
  ```bash
  monero-wallet-cli --generate-from-view-key NOME-VIEW
  ```
- **Sincronizar gastos** (a view-only não conhece key images):
  ```bash
  # quente:  export_outputs outputs_file
  # fria:    import_outputs outputs_file   →   export_key_images ki_file
  # quente:  import_key_images ki_file
  ```
- **Gastar:**
  ```bash
  # quente:  transfer ENDERECO VALOR   →   gera 'unsigned_monero_tx'
  # fria:    sign_transfer unsigned_monero_tx   →   gera 'signed_monero_tx'
  # quente:  submit_transfer signed_monero_tx
  ```

### 5.5 Aviso honesto — **informe-se antes de custodiar o grosso**

A **própria documentação do Monero** diz que o cold storage manual (CLI) é **complexo e com grande margem de erro**, publicado **para fins educacionais** — e que, para muita gente, uma **carteira de hardware** (Trezor/Ledger) usada **dentro do Feather** é **mais simples e mais segura**: a chave de gasto **nunca sai do dispositivo** e você dispensa o malabarismo de arquivos. Considere isto seriamente antes de mover quantias relevantes.

| Caminho | Complexidade | Para quem |
|---------|--------------|-----------|
| **Hardware wallet + Feather** | Baixa | Maioria — recomendado para o "grosso" |
| **Feather frio↔quente (arquivos)** | Média | Quem quer air-gap sem hardware |
| **monero-wallet-cli frio↔quente** | Alta | Avançado / auditoria |

**Regras de ouro do frio↔quente:**
- **Teste com valor mínimo** o fluxo **inteiro** (criar view-only → montar → assinar → transmitir) **antes** de mover o grosso.
- **Backups:** a **fria** precisa de backup (seed em papel/metal **offline** + pasta de dados cifrada — Módulo 1 §5.2). A **view-only** é **descartável** (recria-se a partir de endereço+view key+restore height).
- **Restore height** correto — anote-o quando criar a carteira.
- A **seed/spend key nunca** é digitada, fotografada ou colada numa máquina online. Se isso acontecer uma vez, a carteira deixou de ser fria — **migre os fundos** para uma nova.

---

## 6. Onde o Haveno entra (a narrativa frio→quente)

O **Haveno é exceção**: tradear é **quente** (o cliente precisa da carteira durante o **escrow multisig** — não dá para assinar offline um trade ao vivo). A narrativa do hub:

```text
  TAILS offline (FRIO)            "quente" só o necessário            de volta ao FRIO
  guarda o GROSSO   ──transfere o valor do trade──►  Haveno (Tails) negocia  ──saca o XMR──►  carteira fria
  (cold custody)                                     ou Feather watch-only opera
```

Na prática:
- **Guarde o grosso frio** (Cap. 5). Não deixe a sua reserva inteira na carteira quente do Haveno.
- Para um trade, mantenha na carteira do Haveno **só o necessário** (valor + depósito de segurança).
- **Depois do trade, saque o XMR para a carteira fria** (ou Feather de custódia) — não deixe saldo parado quente além do preciso (Módulo 1 §5.5).
- Métodos de pagamento, disputas e golpes: **Módulo 1** (Vol I Cap. 9, Vol II Caps. 7–9). Nada muda aqui.

**OK se:** você só expõe ao "quente" o valor de cada operação; o restante fica frio; após operar, o excedente volta ao frio.

---

## 7. Quando usar Whonix × Tails × home lab

| Você quer… | Use |
|------------|-----|
| **Ver/operar online e persistente** (view-only, navegação, carteira leve) | **Whonix** (este módulo) |
| **Gerar/custodiar** a chave fria e **assinar offline** | **Tails** (Módulo 1, bootado offline) |
| **Infra 24/7** (nó Monero, mineração) | **Home lab** (Módulo 1, Cap. 6) |
| **Tradear no Haveno** (quente) | **Tails** (Módulo 1) |
| **Custodiar o grosso com o mínimo de risco** | **Hardware wallet + Feather** (ver 5.5) |

---

## 8. Links oficiais

| Tema | Link |
|------|------|
| Whonix (site) · Download | https://www.whonix.org/ · https://www.whonix.org/wiki/Download |
| **Verificar a imagem** | https://www.whonix.org/wiki/Verify_the_images |
| Chave de assinatura (`916B8D99…2EEACCDA`) | https://www.whonix.org/keys/derivative.asc |
| Atualização do sistema | https://www.whonix.org/wiki/Operating_System_Software_Updates |
| Monero no Whonix | https://www.whonix.org/wiki/Monero |
| **Monero — assinatura offline (cold)** | https://docs.getmonero.org/cold-storage/offline-transaction-signing/ |
| Monero — carteira view-only | https://www.getmonero.org/resources/user-guides/view_only.html |
| **Feather — assinatura offline** | https://docs.featherwallet.org/guides/offline-tx-signing |
| Feather — criar carteira view-only | https://docs.featherwallet.org/guides/create-view-only-wallet |
| Feather (Tor) | https://docs.featherwallet.org/guides/tor-support |
| **Módulo 1 — Tails + Haveno** | [`../Tails OS Expert/README.md`](../Tails%20OS%20Expert/README.md) |

---

*Privacy-OS-Hub · Módulo 2 (Whonix Online + Cold-Tails-Hot-Whonix). Verificado em fonte oficial (jun/2026).
Os comandos exatos de assinatura offline mudam por versão — confirme sempre nas docs do Monero/Feather acima
antes de mover dinheiro real. Comece com **valores mínimos**.*
