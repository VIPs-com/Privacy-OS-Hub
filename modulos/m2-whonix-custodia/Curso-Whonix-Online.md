# Módulo 2 — Whonix Online (lado em rede) + Cold-Tails-Hot-Whonix

> **Guia aprofundado.** O lado **online persistente** do hub — e, sobretudo, a **custódia frio↔quente**
> que protege os seus fundos: a **chave de gasto (seed) nunca toca a internet**. Onde os comandos exatos
> mudam por versão/SO, aponto a **fonte oficial** — confira sempre antes de executar dinheiro real.
>
> **Pré-requisito:** [Módulo 1 (Tails + Haveno)](../m1-tails-haveno/README.md) concluído — seed, carteira,
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

### Glossário — termos do frio↔quente (leia antes do Cap. 5)

| Termo | Significado |
|-------|-------------|
| **Air-gap** | Máquina **sem rede** (Tails offline) — a spend key nunca toca a internet |
| **View-only** | Carteira que **vê** saldo e histórico, mas **não gasta** (só tem view key) |
| **Spend key / seed** | Chave que **autoriza gastos** — vive só na máquina **fria** (Tails offline); hardware wallet é opção (§5.6) |
| **Secret view key** | Chave de **visualização** — copiada para o Whonix; **não** move fundos sozinha |
| **Outputs** | Dados de saídas da blockchain que a carteira precisa para montar transações |
| **Key images** | Prova criptográfica de que outputs não foram gastos duas vezes — sincroniza frio↔quente |
| **Restore height** | Altura de bloco a partir da qual a carteira começa a sincronizar — **anote na criação** |
| **Unsigned / signed tx** | Transação **montada** (quente) → **assinada** (fria) → **transmitida** (quente) |

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

**OK se:** você sabe explicar Gateway (roteia tudo por Tor) × Workstation (trabalho isolado), e **por que** isso protege o IP de forma arquitetural. *(Verificação prática no Cap. 2: com o Gateway no ar, o navegador da Workstation deve mostrar um **IP de saída Tor** — não o seu real — em [check.torproject.org](https://check.torproject.org).)*

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
   - Se aparecer **`EXPKEYSIG`** (chave expirada no keyring antigo), **reimporte** `derivative.asc` da URL acima — o fingerprint `916B8D99…2EEACCDA` **não mudou** após a re-certificação (jan/2026).
2. **Verifique a assinatura** do arquivo baixado:
   ```bash
   gpg --verify Whonix-*.asc Whonix-*    # precisa dizer: Good signature
   ```
   Procure por **"Good signature"** **e** confirme que o **fingerprint** que assinou é o `916B8D99…2EEACCDA`. "Good signature" de uma chave **errada** não vale.
3. **Passos exatos por SO** (Linux/Windows/macOS — o `gpg` e o nome dos arquivos variam): guia prático deste módulo em [`Instalar-Whonix-passo-a-passo-por-SO.md`](Instalar-Whonix-passo-a-passo-por-SO.md) (§5), ou a fonte oficial **"Verify the images"** (§8). Não pule esta etapa por preguiça de ler o guia do seu SO.
4. Importe a imagem **verificada** no VirtualBox/KVM e inicie **Gateway + Workstation** — passo a passo em [`Instalar-Whonix-passo-a-passo-por-SO.md`](Instalar-Whonix-passo-a-passo-por-SO.md).

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

> Se a view-only **não mostrar fundos antigos**, o **restore height** provavelmente está **alto demais** — **não é perda**; recrie a view-only com a altura correta (anterior à 1ª recepção).

### 5.3 Gastar com assinatura offline — fluxo **Feather** (recomendado)

> ⚠️ **Há dois caminhos para a MESMA custódia: Feather (§5.3, interface) OU `monero-wallet-cli` (§5.4, terminal).**
> **Escolha UM e siga do início ao fim.** Não misture — uma carteira nasce e morre na mesma ferramenta;
> não importe num lado o que você exportou no outro. Na dúvida: **Feather** (continue aqui). Vai de CLI? Pule para o **§5.4**.

O Feather faz airgapped por **QR animado (UR) via webcam** (método primário na doc) **ou** por **arquivos via USB/SD**. No par Tails↔Whonix, **arquivos via USB** costumam ser mais simples para um air-gap estrito. Passo a passo (siga a UI atual em [offline-tx-signing](https://docs.featherwallet.org/guides/offline-tx-signing)):

1. **(Quente/Whonix)** sincronize a view-only → **exporte os outputs** para um arquivo (USB).
2. **(Frio/Tails)** abra a carteira **completa** (Tails **offline**), **importe os outputs**, **exporte as key images** (USB).
3. **(Quente/Whonix)** **importe as key images** → agora a view-only mostra saldo e gastos **corretos**.
4. **(Quente/Whonix)** **monte a transação** (destino + valor) → o Feather gera uma **transação não-assinada** (arquivo).
5. **(Frio/Tails)** **importe a não-assinada** na carteira completa → **confira o destino e o valor na tela da carteira FRIA** → **assine** → gera a **transação assinada** (arquivo).
6. **(Quente/Whonix)** **importe a assinada** e **transmita** (broadcast) via Tor/seu nó.

> Os passos 1–3 (sincronizar key images) são **obrigatórios no 1º envio** e recomendados sempre que o saldo parecer desatualizado (refletem o **troco** das transações).

> 🔎 **Confira o endereço de destino na máquina FRIA** antes de assinar — a fria é a **fonte de verdade**.
> Malware na máquina quente poderia trocar o endereço na hora de montar; a sua última checagem é no Tails.

**OK se:** a view-only no Whonix transmite uma transação que foi **assinada no Tails offline**; a chave de gasto **nunca** esteve numa máquina em rede.

### 5.4 O mesmo fluxo no **CLI** (`monero-wallet-cli`, avançado)

> ⚠️ **Alternativa ao §5.3 — não os dois.** Se você criou a carteira no Feather, faça **tudo** no Feather.
> Este caminho CLI é para quem prefere terminal (ou quer auditar). Não combine as ferramentas no meio do fluxo.

Fonte oficial: [Monero — Offline Transaction Signing](https://docs.getmonero.org/cold-storage/offline-transaction-signing/) e [view-only](https://www.getmonero.org/resources/user-guides/view_only.html).

> ⚡ **Comandos só** — escolha sua trilha em [`00-Comece-aqui-Escolha-sua-trilha.md`](00-Comece-aqui-Escolha-sua-trilha.md): Trilha A ([Feather](Trilha-A-Feather/Playbook-Feather-GUI.md)) **ou** Trilha B ([`monero-wallet-cli`](Trilha-B-CLI/Playbook-monero-wallet-cli.md)) — **não as duas**.

- **Criar a view-only** (na quente): pegue `address` e `viewkey` da fria, depois:
  ```bash
  monero-wallet-cli --generate-from-view-key NOME-VIEW
  ```
  > O `--generate-from-view-key` pede só **endereço + view key**. Defina a **altura** depois, **dentro da carteira**, com `set refresh-from-block-height N` — senão sincroniza do bloco 0 (lento). Use a altura **anterior** à 1ª recepção. (No CLI a altura define-se aqui dentro, não como flag de criação.)
- **Sincronizar gastos** (a view-only não conhece key images):
  ```bash
  # quente:  export_outputs outputs_file
  # fria:    import_outputs outputs_file   →   export_key_images ki_file
  # quente:  import_key_images ki_file
  ```
  > **Repita este ciclo de sincronização após CADA envio** — senão a view-only não enxerga o **troco** e mostra saldo errado (é o passo mais esquecido). A doc oficial mostra esse ciclo **após** o `submit_transfer` (recuperação de troco); aqui ele é apresentado também antes do gasto, por didática — mesmos comandos.
- **Gastar:**
  ```bash
  # quente:  transfer ENDERECO VALOR   →   gera 'unsigned_monero_tx'
  # fria:    sign_transfer unsigned_monero_tx   →   gera 'signed_monero_tx'
  # quente:  submit_transfer signed_monero_tx
  ```

### 5.5 Qual caminho é o seu? — **air-gap primeiro (trilha do hub)**

Este hub ensina **Cold-Tails / Hot-Whonix** como trilha principal: **sem depender de hardware proprietário
caro**, com **controle total** e **responsabilidade sua**. A spend key vive no Tails offline; o Whonix só
opera em view-only.

| Caminho | Complexidade | Para quem |
|---------|--------------|-----------|
| **Feather air-gap** (Trilha A) | Média | **Padrão do hub** — maioria dos alunos, baixo custo |
| **monero-wallet-cli air-gap** (Trilha B) | Alta | Terminal / auditoria do processo |
| **Hardware wallet + Feather** (§5.6) | Baixa (operação) | **Opcional** — se já tem ou quer comprar Trezor/Ledger |

> A documentação do Monero também descreve cold storage manual como **complexo e com margem de erro** — por
> isso exigimos **backups reforçados** e teste com valor mínimo. Checklist: [`Playbook-Backup-e-protecao-air-gap.md`](Playbook-Backup-e-protecao-air-gap.md).

> ⚠️ **Perda total por falha de mídia** (o risco que não é golpe nem comando errado): se a **única**
> cópia da seed/chave de gasto estiver na máquina fria e o **pendrive/persistência do Tails** (amnésico!)
> corromper ou sumir, **os fundos somem para sempre** — ninguém recupera. **Antes de custodiar qualquer
> valor, tenha DUAS cópias offline independentes da seed** (papel/metal, em locais separados). Ver Módulo 1 §5.2.

**Regras de ouro do frio↔quente:**
- **Teste com valor mínimo** o fluxo **inteiro** (criar view-only → montar → assinar → transmitir) **antes** de mover o grosso.
- **Backups:** a **fria** precisa de backup (seed em papel/metal **offline** + pasta de dados cifrada — Módulo 1 §5.2). A **view-only** é **descartável** (recria-se a partir de endereço+view key+restore height).
- **Restore height** correto — anote-o quando criar a carteira.
- A **seed/spend key nunca** é digitada, fotografada ou colada numa máquina online. Se isso acontecer uma vez, a carteira deixou de ser fria — **migre os fundos** para uma nova.

> 👉 **Não tem Trezor/Ledger?** Trilha A (Feather air-gap) + [`Playbook-Backup-e-protecao-air-gap.md`](Playbook-Backup-e-protecao-air-gap.md) é o seu caminho. Hardware wallet é **opcional** (§5.6).

<a id="56-hardware-wallet-opcional"></a>

### 5.6 Alternativa opcional: hardware wallet (Trezor/Ledger) + Feather — **custo extra**

As Trilhas A/B são a **trilha principal** deste hub. Uma **carteira de hardware** é uma **alternativa** se
você **já possui** ou **decide comprar** dispositivo proprietário: a spend key nasce e vive num chip dedicado
e **não sai dele**. O computador só recebe a transação já assinada — menos malabarismo de arquivos por USB,
em troca de confiar no **fabricante + firmware**.

> Isto **não substitui** o conceito frio↔quente — **encaixa** nele: view-only no Whonix; quem assina é o chip.

#### 5.6.1 Comparativo rápido (comece pelo §5.5 se não tem hardware)

| Caminho | Complexidade | Raiz de confiança | Para quem |
|---------|--------------|-------------------|-----------|
| **Feather air-gap** (Trilha A) | Média | Máquina fria offline | **Padrão do hub** — baixo custo |
| **`monero-wallet-cli`** (Trilha B) | Alta | Máquina fria offline | Avançado / auditoria |
| **Hardware wallet + Feather** (§5.6) | Baixa (operação) | Chip + firmware do fabricante | Quem **já tem** ou quer comprar HW |

> **Na dúvida e sem hardware:** Trilha A + backup reforçado. §5.6 só se você **escolher** o caminho proprietário.

#### 5.6.2 O que muda no modelo de segurança (leia com atenção)

Com air-gap (Trilhas A/B), você confia que a **máquina fria nunca tocou a rede**. Com hardware wallet, a
confiança **se desloca** para o **chip seguro + o firmware do fabricante**. São ameaças diferentes:

| Modelo | Protege bem contra | Onde é frágil |
|--------|--------------------|---------------|
| **Air-gap (Tails offline)** | Malware de rede, vigilância; nada sai online | **Mídia que corrompe** (Tails é amnésico); USB malicioso no boot; erro humano no malabarismo de arquivos |
| **Hardware wallet** | Máquina **online ou comprometida** (a chave fica no chip); roubo do PC | **Supply-chain** (device adulterado na compra); **firmware** malicioso; você **não conferir o destino na tela do device** |

A consequência prática: **você pode conectar o dispositivo a uma máquina online** (inclusive o Whonix) sem
expor a chave — porque ela **não sai do chip**. Isso simplifica muito o dia a dia. Em troca, você assume a
confiança no **fabricante** e precisa de disciplina nova (comprar de fonte idônea, conferir na tela do device).

#### 5.6.3 Trezor × Ledger para Monero (fatos verificados)

| | **Trezor** | **Ledger** |
|---|-----------|-----------|
| Modelos atuais c/ Monero | **Safe 3** e **Safe 5** | **Nano S+, Nano X, Stax, Flex** (via app **Monero**) |
| App nativo do fabricante | **Não** suporta Monero no Trezor Suite | App **Monero** instalável (Ledger Live); mantido pela Ledger em `LedgerHQ/app-monero` (em desenvolvimento ativo — confira issues/limitações antes de usar) |
| Como usar | **Só** por terceiros: **Feather** ou Monero GUI/CLI | Feather, Monero GUI/CLI |
| A chave de gasto | Assina **dentro do device**; não é exportada | Assina **dentro do device**; não é exportada |

> A Feather também lista modelos mais antigos (Trezor **Model T**, Ledger **Nano S**), mas eles têm
> memória/suporte limitados — **prefira os atuais** acima. Lista oficial: [hardware-wallet-support](https://docs.featherwallet.org/guides/hardware-wallet-support).

> **Recomendação do curso:** use o **Feather** como interface (leve, já adotado no Módulo 1) com qualquer um
> dos dois. Trezor e Ledger são ambos válidos; escolha pela sua confiança no fabricante e disponibilidade.

> 🔒 **O fato verificável que sustenta o modelo:** a doc oficial do Monero confirma que **"os fundos não podem
> ser comprometidos apenas com a view key"** — a assinatura exige o dispositivo. É isso que torna seguro deixar
> a view-only numa máquina online enquanto o gasto fica preso ao chip.

#### 5.6.4 Fluxo no Feather (passo a passo)

**Antes:** inicialize o dispositivo **você mesmo** (PIN + frase de recuperação gerada **no próprio device**)
e **faça o backup offline dessa frase** (papel/metal, DUAS cópias) — ela é a sua salvaguarda real (5.6.5).

1. Conecte o dispositivo. **Ledger:** abra o **app Monero** no device. **Trezor:** **desbloqueie**.
2. **Linux (Tails/Whonix):** aplique as **udev rules** oficiais do dispositivo (senão o Feather não o enxerga).
3. No Feather: **File → New/Restore → Create wallet from hardware device**.
4. Selecione o **tipo de dispositivo** → **Create new wallet file from device** (1ª vez) ou **Restore a wallet from device** (já usado).
5. Se estiver restaurando, informe o **restore height** (a **data de compra** serve se você não souber a altura).
6. Dê um **nome** e uma **senha** ao arquivo da carteira → conclua.
7. **Gastar:** monte a transação no Feather → **confirme o valor e o endereço NA TELA DO DISPOSITIVO** → aprove no device → o Feather transmite via Tor/seu nó.

> 🔎 **A tela do dispositivo é a fonte de verdade** (substitui o "confira na máquina fria" das Trilhas A/B):
> malware no PC pode trocar o endereço na hora de montar — sua última checagem é **no hardware**, sempre.

> **Ledger — uma escolha no setup:** ele pergunta se você quer **exportar a view key** para o computador.
> **Exportar** = escaneia a blockchain mais **rápido**, mas se a máquina for comprometida o adversário vê seu
> histórico (**não** gasta seus fundos — view key só vê). **Manter no device** = mais **privado**, porém o
> escaneamento é **bem mais lento**. No Whonix (online via Tor), exportar é aceitável; para o máximo de
> privacidade, mantenha no device.

**OK se:** o Feather mostra a carteira como **hardware** e o saldo correto; ao gastar, o **device pede
confirmação na tela** e a transação só sai após você aprovar nele.

#### 5.6.5 No Tails/Whonix na prática (USB)

- **VirtualBox (Whonix):** instale o **Extension Pack** e adicione um **filtro USB** do dispositivo à
  **Workstation** (Settings → USB) para que a VM o enxergue.
- **Qubes-Whonix:** anexe o dispositivo USB do `sys-usb` ao qube da Workstation (`qvm-usb attach`).
- **Tails:** o USB funciona, mas o Tails é **amnésico** — você refaz as udev rules/abertura a cada sessão
  (use a persistência para guardar o arquivo `.keys`, que **não** contém a chave de gasto).

**Onde assinar?** O **dispositivo é a custódia fria** — ele pode assinar tanto a partir do **Tails** quanto
do **Whonix**:

| Postura | Como | Para quem |
|---------|------|-----------|
| **Duplo-frio** | Tails **offline** + dispositivo | Paranoia máxima |
| **Conveniente** | Dispositivo + **Whonix online** (view-only no mesmo lugar) | Dia a dia — **ainda seguro** (a chave fica no chip) |

#### 5.6.6 Ressalvas que decidem (não pule)

- **Backup da frase de recuperação do DISPOSITIVO** — é o que recupera seus fundos se o device sumir/quebrar.
  **DUAS cópias offline** (papel/metal, locais separados), igual à seed do Tails (Módulo 1 §5.2). Sem backup,
  device perdido = **perda total**.
- **Firmware é a raiz de confiança** — atualize-o numa **máquina confiável** (não no Tails amnésico), seguindo
  o app oficial do fabricante.
- **Supply-chain:** compre de **fonte idônea** e **inicialize você mesmo**. **Nunca** use um device que veio com
  uma frase de recuperação "pronta" — é golpe clássico.
- **USB é obrigatório para assinar.** Sem o device plugado, você só tem a **view-only** (vê, não gasta).
- **Confirme sempre destino + valor na tela do device** antes de aprovar.
- **Teste com valor mínimo** o ciclo inteiro (criar → receber → gastar → confirmar no device) antes do grosso.

> **Quando NÃO usar hardware wallet:** se você não confia no fabricante/supply-chain do seu modelo, ou quer
> uma raiz de confiança 100% software-livre auditável — aí as Trilhas A/B (air-gap) fazem mais sentido.

**Fontes oficiais (confira — muda por versão):** Feather hardware
([create-wallet-hardware-device](https://docs.featherwallet.org/guides/create-wallet-hardware-device) ·
[supported devices](https://docs.featherwallet.org/guides/hardware-wallet-support)) · Trezor Monero
(https://trezor.io/coins/wallet/monero) · Ledger Monero
(https://www.getmonero.org/resources/user-guides/ledger-wallet-cli.html · https://github.com/LedgerHQ/app-monero).

---

<a id="6-onde-o-haveno-entra"></a>

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

<a id="7-quando-usar"></a>

## 7. Quando usar Whonix × Tails × home lab

| Você quer… | Use |
|------------|-----|
| **Ver/operar online e persistente** (view-only, navegação, carteira leve) | **Whonix** (este módulo) |
| **Gerar/custodiar** a chave fria e **assinar offline** | **Tails** (Módulo 1, bootado offline) |
| **Infra 24/7** (nó Monero, mineração) | **Home lab** (Módulo 1, Cap. 6) |
| **Tradear no Haveno** (quente) | **Tails** (Módulo 1) |
| **Custodiar o grosso (baixo custo, air-gap)** | **Tails offline + Trilha A/B** + [`Playbook-Backup-e-protecao-air-gap.md`](Playbook-Backup-e-protecao-air-gap.md) |
| **Alternativa com hardware proprietário** | **Hardware wallet + Feather** (opcional — §5.6) |

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
| **Feather — hardware wallet** (§5.6) | https://docs.featherwallet.org/guides/create-wallet-hardware-device · https://docs.featherwallet.org/guides/hardware-wallet-support |
| **Trezor — Monero** | https://trezor.io/coins/wallet/monero |
| **Ledger — Monero** | https://www.getmonero.org/resources/user-guides/ledger-wallet-cli.html · https://github.com/LedgerHQ/app-monero |
| **Módulo 1 — Tails + Haveno** | [`../modulos/m1-tails-haveno/README.md`](../m1-tails-haveno/README.md) |

---

*Privacy-OS-Hub · Módulo 2 (Whonix Online + Cold-Tails-Hot-Whonix). Verificado em fonte oficial (jun/2026).
Os comandos exatos de assinatura offline mudam por versão — confirme sempre nas docs do Monero/Feather acima
antes de mover dinheiro real. Comece com **valores mínimos**.*
