# 🏠 Home-Lab – VERSÃO 1.0 (apêndice do Privacy-OS-Hub)

**Sistema:** Debian / Ubuntu (NÃO Tails)
**Serviços:** monerod · Tor Hidden Service · P2Pool · xmrig
**Versão:** 1.0 · jun/2026

> ⚠️ **AVISO — OPCIONAL:** Esta trilha é completamente opcional. A trilha principal do Privacy-OS-Hub são os **Passos 1–12**. Monte o Home Lab apenas depois de concluir os passos 1–12. O Home Lab roda em **outro PC** (Debian/Ubuntu), nunca no pendrive Tails.

> ⚠️ **SISTEMA:** estes scripts usam `systemd` e `apt` — rodam em **Debian/Ubuntu normal**, não no Tails. Tentar rodar no Tails vai falhar ou corromper o ambiente.

---

## 0. O QUE É O HOME LAB

### Para quem é

O Home Lab é para quem quer:
- Ter **seu próprio nó Monero** (independência total, sem depender de nós de terceiros)
- **Publicar o nó via Tor** (`.onion:18089` — o Feather/Whonix conecta aqui)
- **Minerar Monero** de forma descentralizada (P2Pool + xmrig)
- Contribuir para a rede Monero rodando infraestrutura

**Não é necessário** para usar o Haveno, fazer trades, ou completar a custódia frio↔quente. A trilha principal (passos 1–12) funciona sem Home Lab, usando nós `.onion` públicos confiáveis.

### O que o Home Lab adiciona

| Benefício | Sem Home Lab | Com Home Lab |
|-----------|:------------:|:------------:|
| Usar Haveno | Sim | Sim |
| Cold-signing | Sim | Sim |
| Nó próprio `.onion` | Não (usa nó público) | Sim |
| Mineração Monero | Não | Sim |
| Independência de terceiros | Parcial | Total |
| Complexidade | Baixa | Alta |

### Pré-requisitos

| Requisito | Mínimo | Recomendado |
|-----------|:------:|:-----------:|
| Sistema | Debian 11+ ou Ubuntu 20.04+ | Debian 12 / Ubuntu 22.04 |
| RAM | 4 GB (nó pruned) | 8 GB+ (nó full + mineração) |
| Disco | 120 GB SSD (pruned) | 300 GB+ SSD/NVMe (full) |
| CPU | qualquer x86_64 | 4+ núcleos (mineração) |
| Arquitetura | x86_64 ou aarch64/ARM | x86_64 |
| Virtualização | — | Não necessária |
| Sempre ligado | Recomendado | Sim (mini PC, NUC, RPi 4/5) |

**Hardware recomendado para Home Lab completo:**
- Mini PC (Intel NUC, Beelink, etc.) ou Raspberry Pi 4/5 com SSD externo
- SSD de 500 GB+ (NVMe ou SATA — HDD é muito lento para a blockchain Monero)
- Conexão estável de internet (não necessariamente rápida, mas estável)

### Relação com a trilha principal

```text
Trilha principal (passos 1–12) — NO TAILS
  ↓ usa nó remoto .onion público (OK sem Home Lab)
  ↓ ou usa nó próprio do Home Lab (mais privado)
         ↓
Home Lab (outro PC, Debian/Ubuntu) — OPCIONAL
  ├── monerod (nó Monero)
  ├── Tor Hidden Service (publica .onion:18089)
  ├── P2Pool (mineração descentralizada)
  └── xmrig (minerador)
```

---

## PASSO HL-0 — Verificar Requisitos (pré-voo)

**Este script só lê — não muda nada no sistema.**

```bash
# No home lab (Debian/Ubuntu):
# Baixe os scripts do repositório ou copie de outro PC
chmod +x *.sh

# Execute o pré-voo (não precisa de root para a maioria):
./00-verificar-requisitos.sh

# Com DATA_DIR diferente (ex.: SSD montado em /mnt/monero):
DATA_DIR=/mnt/monero ./00-verificar-requisitos.sh
```

**O que o script verifica:**

| Checagem | O que avalia |
|----------|-------------|
| Sistema operacional | Debian/Ubuntu + systemd |
| Arquitetura | x86_64 (ideal) ou aarch64/ARM |
| RAM | Suficiente para pruned (4 GB) ou full+mineração (8 GB+) |
| Disco | Espaço livre e tipo (SSD vs HDD) |
| Ferramentas | curl, tar, tor |
| Conectividade | Acesso a downloads.getmonero.org |

**Você deve ver ao final:**
```text
=== Resumo: N OK · N avisos · N falhas ===
  Pre-voo concluido. Proximo: sudo ./01-setup-monero-node.sh
```

🔴 **Se houver FALHAS:** resolva antes de continuar. Disco HDD vai deixar a sincronização extremamente lenta.

---

## PASSO HL-1 — Nó Monero (monerod como serviço systemd)

**Requer root. Rode no home lab (Debian/Ubuntu).**

```bash
# Nó pruned (padrão — menor disco, ~100 GB):
sudo ./01-setup-monero-node.sh

# Nó full (necessário para P2Pool/mineração, ~250 GB):
sudo PRUNED=0 ./01-setup-monero-node.sh

# Com pasta de dados em SSD separado:
sudo DATA_DIR=/mnt/ssd/monero ./01-setup-monero-node.sh

# Nó full em SSD separado:
sudo PRUNED=0 DATA_DIR=/mnt/ssd/monero ./01-setup-monero-node.sh
```

**O que o script faz:**

1. Cria usuário dedicado `monero` (sem login, sem shell)
2. Baixa o `monerod` oficial de https://downloads.getmonero.org
3. **Verifica o binário** (fail-closed): hash fixado via `MONEROD_SHA256` OU assinatura GPG de binaryfate em `hashes.txt` — **aborta** se não conferir
4. Escreve `/etc/monerod.conf` (pruned por padrão)
5. Cria e ativa o serviço systemd `monerod`

**Fingerprint oficial Monero (binaryfate):**
```text
81AC 591F E9C4 B65C 5806  AFC3 F0AF 4D46 2A0B DF92
```

---

### Variáveis de ambiente disponíveis

| Variável | Padrão | Uso |
|----------|--------|-----|
| `DATA_DIR` | `/var/lib/monero` | Pasta da blockchain — aponte para o SSD |
| `PRUNED` | `1` | `0` = nó full (necessário para P2Pool) |
| `RPC_PORT` | `18089` | Porta do RPC restrito (Tor publica esta) |
| `MONEROD_SHA256` | (vazio) | Hash fixado; se vazio, usa verificação GPG |
| `MONERO_SIGNER_FPR` | `81AC591F…2A0BDF92` | Fingerprint binaryfate |

---

### Portas usadas pelo monerod

| Porta | Protocolo | Finalidade | Onde escuta |
|:-----:|:---------:|-----------|:-----------:|
| 18080 | P2P | Sincronização com outros nós | `0.0.0.0` (intencional) |
| 18081 | RPC | RPC irrestrito local (P2Pool) | `127.0.0.1` |
| 18083 | ZMQ | Pub para P2Pool | `127.0.0.1` |
| 18089 | RPC | RPC restrito (Tor publica este) | `127.0.0.1` |

🟡 **Sobre a porta 18080 em `0.0.0.0`:** esta é a porta P2P do Monero. O monerod escuta em todas as interfaces por design — é como o nó contribui para a rede. O RPC fica em `127.0.0.1` (local only). Em rede doméstica, considere `ufw` na borda — o curso não cobre hardening de firewall.

---

### Acompanhar o serviço

```bash
# Ver logs em tempo real:
journalctl -u monerod -f

# Status do serviço:
systemctl status monerod

# Parar/iniciar/reiniciar:
sudo systemctl stop monerod
sudo systemctl start monerod
sudo systemctl restart monerod
```

**Sincronização inicial:** baixar a blockchain completa pode levar horas ou dias dependendo da velocidade de internet e do disco. O nó pruned (~100 GB) é mais rápido de sincronizar que o full (~250 GB).

**OK se:** serviço `monerod` rodando · logs mostram blocos sendo sincronizados · porta 18089 acessível em `127.0.0.1`.

---

### Alternativa — nó em Docker (opcional)

Se você prefere containers em vez de systemd, é possível rodar o nó com **docker compose**. Crie `docker-compose.yml`:

```yaml
services:
  monerod:
    image: sethsimmons/simple-monerod:latest   # imagem comunitária popular
    container_name: monerod
    restart: unless-stopped
    volumes:
      - bitmonero:/home/monero                 # blockchain persistente (use um SSD)
    ports:
      - "18080:18080"                          # P2P
      - "127.0.0.1:18089:18089"                # RPC restrito só local (Tor publica)
    command: >
      --prune-blockchain --sync-pruned-blocks
      --rpc-restricted-bind-ip=0.0.0.0 --rpc-restricted-bind-port=18089
      --no-igd --enable-dns-blocklist

volumes:
  bitmonero:
```

```bash
docker compose up -d        # sobe o nó
docker compose logs -f      # acompanha o sync
```

📎 **Para nó full** (necessário para P2Pool/mineração), remova `--prune-blockchain --sync-pruned-blocks`. O `torrc` do passo HL-2 continua igual — aponta para `127.0.0.1:18089`.

📎 **Sobre `0.0.0.0` no compose:** dentro do container, `0.0.0.0` significa "todas as interfaces do container" — o que restringe ao host é o mapeamento `ports: 127.0.0.1:18089:18089`. Para fora, quem publica o RPC é só o hidden service Tor (passo HL-2).

🟡 **Docker vs. systemd:** o script automático (`01-setup-monero-node.sh`) usa systemd. O compose é para quem já administra containers e prefere essa abordagem. Ambos resultam no mesmo serviço.

---

## PASSO HL-2 — Tor Hidden Service (publicar o nó via Tor)

**Requer root. Pré-requisito: monerod rodando (HL-1).**

```bash
sudo ./02-tor-hidden-service.sh

# Com porta RPC diferente (deve casar com o script 01):
sudo RPC_PORT=18089 ./02-tor-hidden-service.sh

# Com diretório do Hidden Service diferente:
sudo HS_DIR=/var/lib/tor/meu-no/ ./02-tor-hidden-service.sh
```

**O que o script faz:**

1. Instala o Tor via apt
2. Adiciona um `HiddenService` no `/etc/tor/torrc` apontando para o RPC local (`127.0.0.1:18089`)
3. Reinicia o Tor
4. Exibe o endereço `.onion` gerado

**Você deve ver ao final:**
```text
================================================================
  No Monero publicado via Tor.
  Endereco .onion:  abc123xyz789.onion
  Porta:            18089
  Use em carteiras: abc123xyz789.onion:18089
================================================================
```

---

### Usar o endereço .onion na carteira

Anote o endereço `.onion:18089`. Use-o:
- No **Feather Wallet** (Whonix/Tails): Settings → Network → Node → `abc123.onion:18089` → marcar como "trusted"
- No **Haveno** (Tails): configurações de nó → endereço `.onion:18089`

🟡 **O endereço `.onion` é derivado da chave privada em `HS_DIR/private_key`** — guarde este diretório em backup. Se perder a chave, o endereço muda.

```bash
# Ver o endereço .onion a qualquer momento:
cat /var/lib/tor/monero-rpc/hostname
```

**OK se:** Tor rodando · arquivo `hostname` existe · endereço `.onion` visível · Feather/carteira consegue conectar ao nó via `.onion:18089`.

---

## PASSO HL-3 — P2Pool (mineração descentralizada)

**Requer root. Pré-requisito: nó Monero FULL (PRUNED=0) rodando.**

> 🟡 **Por que nó full?** O P2Pool precisa de acesso ao ZMQ e RPC completo do `monerod`. Nó pruned não tem as transações completas necessárias.

```bash
# WALLET é obrigatório — endereço PRIMÁRIO (começa com 4):
sudo WALLET=4xxxx... ./03-setup-p2pool.sh

# Sidechain mini (padrão, ideal para PC doméstico):
sudo MINI=1 WALLET=4xxxx... ./03-setup-p2pool.sh

# Sidechain principal (hashrate maior necessário):
sudo MINI=0 WALLET=4xxxx... ./03-setup-p2pool.sh
```

🔴 **Use endereço PRIMÁRIO (começa com 4).** Subendereços (começa com 8) não são aceitos pelo P2Pool.

🔴 **Use uma carteira SEPARADA para mineração.** Os endereços no P2Pool são públicos — nunca use o mesmo endereço da sua carteira principal do Haveno.

---

### Flags do monerod necessárias para P2Pool

O script `01-setup-monero-node.sh` com `PRUNED=0` injeta essas flags automaticamente. Se você instalou o monerod manualmente ou quer ajustar, estas são as flags exigidas pelo P2Pool (adicione ao `ExecStart` do serviço ou ao `monerod.conf`):

```text
--zmq-pub tcp://127.0.0.1:18083
--out-peers 32 --in-peers 64
--add-priority-node=p2pmd.xmrvsbeast.com:18080
--add-priority-node=nodes.hashvault.pro:18080
--enable-dns-blocklist --enforce-dns-checkpointing
--rpc-bind-ip=127.0.0.1 --rpc-bind-port=18081
```

📎 Se sua banda de **upload** for menor que 10 Mbit, troque `--out-peers 32 --in-peers 64` por `--out-peers 8 --in-peers 16`. O P2Pool conversa com o monerod pelo RPC local **18081** e pelo **ZMQ 18083**.

---

### Unit systemd p2pool.service (referência manual)

O script `03-setup-p2pool.sh` cria o serviço automaticamente. Se precisar criar ou ajustar manualmente, crie `/etc/systemd/system/p2pool.service`:

```ini
[Unit]
Description=P2Pool (Monero)
After=monerod.service
Wants=monerod.service

[Service]
User=monero
Group=monero
Type=simple
WorkingDirectory=/var/lib/p2pool
ExecStart=/usr/local/bin/p2pool --host 127.0.0.1 --rpc-port 18081 --zmq-port 18083 --wallet SEU_ENDERECO_PRIMARIO_4xxxxx --mini
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
```

🔴 **SUBSTITUA** `SEU_ENDERECO_PRIMARIO_4xxxxx` pelo seu endereço Monero **primário** (começa com `4`). O `--mini` usa a sidechain p2pool-mini (ideal para PC doméstico com hashrate menor).

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now p2pool
journalctl -u p2pool -f       # aguarde a sincronização do P2Pool
```

---

### Verificação de binário (fail-closed)

O P2Pool publica a lista de hashes como arquivo assinado (`sha256sums.txt.asc`). O script:
1. Baixa o checksums **assinado**
2. Verifica a assinatura GPG do SChernykh (obrigatório por padrão)
3. Confirma que o fingerprint bate com a fonte conhecida
4. Só então confere o hash do binário
5. **Aborta** se qualquer etapa falhar

**Fingerprint oficial P2Pool (SChernykh):**
```text
1FCA AB4D 3DC3 310D 16CB  D508 C47F 82B5 4DA8 7ADF
```
Cross-validada em: https://p2pool.io + https://github.com/monero-project/gitian.sigs

**Variáveis de controle P2Pool:**

| Variável | Padrão | Uso |
|----------|--------|-----|
| `WALLET` | (obrigatório) | Endereço Monero primário (começa com `4`) |
| `MINI` | `1` | `1` = sidechain mini (ideal PC doméstico); `0` = principal |
| `P2POOL_SIGNER_FPR` | `1FCAAB4D…4DA87ADF` | Override se a chave do SChernykh rotacionar |
| `P2POOL_TOFU` | `0` | `1` = aceitar qualquer VALIDSIG sem match de fingerprint (escape raro) |
| `P2POOL_SHA256` | (vazio) | Hash fixado (pula GPG — use só com `DL_URL` próprio) |

---

### Acompanhar o P2Pool

```bash
journalctl -u p2pool -f
systemctl status p2pool
```

**O P2Pool ouve em:**
- `127.0.0.1:3333` — stratum para o xmrig (próximo passo)
- Rede P2P do P2Pool (porta varia por versão — veja os logs)

**OK se:** serviço `p2pool` rodando · logs mostram conexão com o `monerod` local · stratum em `127.0.0.1:3333`.

---

## PASSO HL-4 — XMRig (minerador)

**Requer root. Pré-requisito: P2Pool rodando (HL-3).**

```bash
sudo ./04-setup-xmrig.sh

# Com dificuldade fixa (para estatísticas — não muda recompensa):
sudo DIFF=50000 ./04-setup-xmrig.sh

# Com stratum diferente:
sudo STRATUM=127.0.0.1:3333 ./04-setup-xmrig.sh
```

**O que o script faz:**

1. Baixa o xmrig do GitHub (release mais recente)
2. **Verifica com GPG** (fail-closed): assinatura xmrig em `SHA256SUMS.sig` — aborta se falhar
3. Confere o hash do binário
4. Cria o serviço systemd `xmrig` minerando para o P2Pool local

**Fingerprint oficial xmrig:**
```text
9AC4 CEA8 E66E 35A5 C7CD  DC1B 446A 5363 8BE9 4409
```
Fonte: https://xmrig.com/docs/gpg-key

---

### Unit systemd xmrig.service (referência manual)

O script `04-setup-xmrig.sh` cria o serviço automaticamente. Se precisar criar ou ajustar manualmente, crie `/etc/systemd/system/xmrig.service`:

```ini
[Unit]
Description=xmrig (minerador RandomX)
After=p2pool.service
Wants=p2pool.service

[Service]
User=monero
Group=monero
Type=simple
ExecStart=/usr/local/bin/xmrig -o 127.0.0.1:3333 -u x --no-color
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
```

| Campo | Explicação |
|-------|------------|
| `-o 127.0.0.1:3333` | Conecta ao stratum do P2Pool local |
| `-u x` | Usuário qualquer — o endereço do xmrig é ignorado; quem paga é o `--wallet` do P2Pool |
| (opcional) `-u x+50000` | Define dificuldade fixa só para estatísticas (não muda recompensa) |

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now xmrig
journalctl -u xmrig -f        # deve mostrar "accepted" shares
```

📎 **Tuning (opcional):** para máximo hashrate o xmrig recomenda **hugepages** e ajustes de **MSR** (precisam de root). Sem isso ele minera igual, só um pouco mais devagar.

---

### Variáveis de controle xmrig

| Variável | Padrão | Uso |
|----------|--------|-----|
| `STRATUM` | `127.0.0.1:3333` | Stratum do P2Pool local |
| `DIFF` | (vazio) | Dificuldade fixa para estatísticas (não afeta recompensa) |
| `XMRIG_SHA256` | (vazio) | Hash fixado; se vazio, usa verificação GPG |
| `XMRIG_SIGNER_FPR` | `9AC4CEA8…8BE94409` | Fingerprint xmrig |

---

### Acompanhar o minerador

```bash
journalctl -u xmrig -f
systemctl status xmrig
```

**Você deve ver nos logs:**
```text
[CPU] accepted (N/M) diff X
[miner] speed 10s/60s/15m H/s
```

**OK se:** serviço `xmrig` rodando · conectado ao stratum `127.0.0.1:3333` · shares sendo aceitos nos logs · hashrate visível.

---

## CHECKPOINT HOME LAB

Antes de considerar o Home Lab funcional:

- [ ] HL-0: pré-voo OK — RAM/disco/SSD adequados
- [ ] HL-1: `monerod` rodando como serviço systemd · verificação GPG binaryfate OK · porta 18089 em 127.0.0.1
- [ ] HL-2: Tor Hidden Service ativo · endereço `.onion:18089` gerado · carteira consegue conectar
- [ ] HL-3 (se quiser minerar): `p2pool` rodando · nó full (PRUNED=0) · stratum em 127.0.0.1:3333
- [ ] HL-4 (se quiser minerar): `xmrig` rodando · shares aceitos nos logs · mineração acontecendo

**Verificação conjunta:**

```bash
# Status de todos os serviços:
systemctl status monerod p2pool xmrig tor

# Logs em tempo real de todos:
journalctl -u monerod -u p2pool -u xmrig -u tor -f
```

```bash
# Endereço .onion do seu nó:
cat /var/lib/tor/monero-rpc/hostname
```

---

## APÊNDICE — Scripts Home Lab (referência completa)

### Estrutura e ordem de execução

```text
automacao/homelab/
├── 00-verificar-requisitos.sh   # pré-voo (só leitura, sem root)
├── 01-setup-monero-node.sh      # nó monerod + systemd
├── 02-tor-hidden-service.sh     # publica nó via Tor (.onion)
├── 03-setup-p2pool.sh           # mineração P2Pool
└── 04-setup-xmrig.sh            # minerador xmrig
```

### Tabela de variáveis de ambiente

| Variável | Script | Padrão | Descrição |
|----------|:------:|--------|-----------|
| `DATA_DIR` | 00, 01 | `/var/lib/monero` | Pasta da blockchain — aponte para SSD |
| `PRUNED` | 01 | `1` | `0` = nó full (~250 GB, necessário p/ P2Pool) |
| `RPC_PORT` | 01, 02 | `18089` | Porta do RPC restrito (Tor publica) |
| `MONEROD_SHA256` | 01 | (vazio) | Hash fixado do monerod; vazio = usa GPG |
| `MONERO_SIGNER_FPR` | 01 | `81AC591F…2A0BDF92` | Fingerprint binaryfate |
| `HASHES_URL` | 01 | downloads.getmonero.org | URL do hashes.txt assinado |
| `HS_DIR` | 02 | `/var/lib/tor/monero-rpc/` | Pasta do Hidden Service Tor |
| `WALLET` | 03 | (obrigatório) | Endereço Monero PRIMÁRIO (começa com `4`) |
| `MINI` | 03 | `1` | `1` = sidechain mini; `0` = principal |
| `P2POOL_SHA256` | 03 | (vazio) | Hash fixado do P2Pool; vazio = usa GPG |
| `P2POOL_SIGNER_FPR` | 03 | `1FCAAB4D…4DA87ADF` | Fingerprint SChernykh |
| `P2POOL_TOFU` | 03 | `0` | `1` = aceitar qualquer VALIDSIG (escape raro) |
| `STRATUM` | 04 | `127.0.0.1:3333` | Stratum P2Pool local |
| `XMRIG_SHA256` | 04 | (vazio) | Hash fixado do xmrig; vazio = usa GPG |
| `XMRIG_SIGNER_FPR` | 04 | `9AC4CEA8…8BE94409` | Fingerprint xmrig |

### Segurança dos scripts (resumo)

**Verificação de binários (fail-closed):** todos os scripts que baixam binários **abortam** se a verificação falhar.

- `01` (monerod): GPG binaryfate (`81AC591F…2A0BDF92`) em `hashes.txt`
- `03` (P2Pool): GPG SChernykh (`1FCAAB4D…4DA87ADF`) em `sha256sums.txt.asc` (clearsigned)
- `04` (xmrig): GPG xmrig (`9AC4CEA8…8BE94409`) em `SHA256SUMS.sig`

**Usuário dedicado:** os serviços rodam como usuário `monero` (sem login, sem shell) — não como root.

**Rede:** o nó baixa a blockchain pela internet normal (não pelo Tor). O Tor (script 02) apenas **publica o RPC** com privacidade. O P2P do monerod (18080) escuta em `0.0.0.0` por design.

**Mineração com carteira separada:** nunca use o endereço do Haveno ou da carteira fria para minerar. Os endereços de payout do P2Pool são públicos na blockchain.

### Comandos de manutenção

```bash
# Ver versão do monerod instalado:
monerod --version

# Ver status de sincronização:
monerod --rpc-bind-port 18089 status 2>/dev/null || true

# Reiniciar um serviço:
sudo systemctl restart monerod
sudo systemctl restart p2pool
sudo systemctl restart xmrig
sudo systemctl restart tor

# Parar mineração (sem parar o nó):
sudo systemctl stop xmrig p2pool

# Ver logs das últimas 100 linhas:
journalctl -u monerod -n 100
journalctl -u p2pool -n 100
journalctl -u xmrig -n 100
```

### Exemplos completos de uso

```bash
# Setup completo (nó full + tor + p2pool + xmrig):
chmod +x *.sh

./00-verificar-requisitos.sh

sudo PRUNED=0 DATA_DIR=/mnt/ssd/monero ./01-setup-monero-node.sh
sudo ./02-tor-hidden-service.sh

# Anote o endereço .onion:
cat /var/lib/tor/monero-rpc/hostname

# Aguarde o nó sincronizar completamente antes do P2Pool
# (pode levar horas/dias na primeira vez)
sudo systemctl is-active monerod

sudo WALLET=4SeuEnderecoMoneroPrimario... ./03-setup-p2pool.sh
sudo ./04-setup-xmrig.sh
```

```bash
# Atualizar o monerod manualmente (quando sair nova versão):
sudo systemctl stop monerod
sudo DATA_DIR=/mnt/ssd/monero ./01-setup-monero-node.sh
sudo systemctl start monerod
```

### Troubleshooting Home Lab

| Problema | Causa provável | Solução |
|----------|---------------|---------|
| monerod não sincroniza | Disco HDD | Migre para SSD; muito lento para blockchain |
| monerod usa muita RAM | Nó full + RAM limitada | Use PRUNED=1 (nó pruned) |
| P2Pool falha ao conectar | monerod não full ou ZMQ desabilitado | Rode 01 com PRUNED=0; reinicie monerod |
| xmrig sem shares aceitos | P2Pool não rodando | Verifique `systemctl status p2pool` |
| Tor .onion não acessível | Tor não iniciou ou chave corrompida | `systemctl restart tor`; veja `journalctl -u tor` |
| GPG falha na verificação | Rede ou chave expirada | Rode o script de novo; confira a rede |
| `permission denied` (P2Pool/xmrig) | Usuário `monero` não existe | Rode 01 primeiro |
| Blockchain corrompida | Desligamento forçado | `monerod --db-sync-mode fast` ou re-sync |

---

## CONCLUSÃO

O Home Lab está montado quando:
1. `monerod` sincroniza e responde em `127.0.0.1:18089`
2. O Tor publica o nó em um endereço `.onion:18089`
3. (Opcional) P2Pool e xmrig estão minerando para sua carteira separada
4. O Feather/Whonix da trilha principal consegue conectar ao seu `.onion:18089`

**Próximo passo:** configure o Feather (no Whonix ou Tails) para usar o seu próprio nó `.onion:18089` em vez de um nó público. Isso completa a independência da trilha principal.

```text
Trilha completa (passos 1–12) + Home Lab:
  Tails frio (passo 12) ← USB → Whonix quente (passo 10–12)
                                    ↓
                           seu nó .onion:18089
                                    ↓
                           Home Lab (Debian/Ubuntu)
                           monerod + Tor + P2Pool + xmrig
```

**Lembrete de segurança:**
- Scripts Home Lab **nunca** rodam no Tails
- Use carteira separada para mineração
- Endereços de payout P2Pool são públicos
- Não use Home Lab como justificativa para pular verificação PGP dos binários

---

*Privacy-OS-Hub · Home-Lab Versão 1.0 · jun/2026 · Licença scripts: MIT · Licença documentação: CC BY-SA 4.0*
