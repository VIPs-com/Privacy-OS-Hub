# Scripts bônus — Home Lab (infraestrutura)

> ⚠️ **Estes scripts NÃO rodam no Tails.** Eles são para o seu **home lab** — uma instalação **Debian/Ubuntu** normal, sempre ligada (mini PC, NUC, Raspberry Pi 4/5 com SSD). O Tails é o **cliente** (carteira/Haveno); o home lab é a **infraestrutura** (nó, mineração).
>
> Contexto: Volume I [`../../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md`](../../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md) Cap. 6 · **Lab integrado:** Volume II [`../../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md`](../../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md) Cap. 13.

Cada script é **independente** e cobre **uma modalidade**. Rode na ordem conforme o que quer explorar.

| Ordem | Script | Modalidade | Precisa antes |
|-------|--------|------------|----------------|
| 0 | `00-verificar-requisitos.sh` | **Pré-voo** (CPU, RAM, disco/SSD, rede) — só leitura | — |
| 1 | `01-setup-monero-node.sh` | **Nó Monero** (`monerod` + systemd) | pré-voo OK |
| 2 | `02-tor-hidden-service.sh` | **Publicar o nó via Tor** (.onion para a carteira) | script 1 |
| 3 | `03-setup-p2pool.sh` | **Mineração descentralizada** (P2Pool) | nó **full** + ZMQ |
| 4 | `04-setup-xmrig.sh` | **Minerador** (xmrig → P2Pool) | script 3 |

## Como usar

```bash
# No home lab (Debian/Ubuntu):
chmod +x *.sh

./00-verificar-requisitos.sh                   # pré-voo (não muda nada)

# Com sudo:
sudo ./01-setup-monero-node.sh                 # nó pruned (padrão)
sudo PRUNED=0 ./01-setup-monero-node.sh        # nó full (para mineração)
sudo ./02-tor-hidden-service.sh                # publica o RPC via Tor

# Mineração (opcional) — precisa de nó FULL + ZMQ:
sudo WALLET=SEU_ENDERECO_PRIMARIO_4xxxx ./03-setup-p2pool.sh
sudo ./04-setup-xmrig.sh
```

Acompanhe cada serviço:

```bash
journalctl -u monerod -f
journalctl -u p2pool -f
journalctl -u xmrig -f
```

## Variáveis que você pode ajustar (env)

| Variável | Script | Padrão | Uso |
|----------|--------|--------|-----|
| `DATA_DIR` | 01 | `/var/lib/monero` | Pasta da blockchain — aponte para o **SSD** |
| `PRUNED` | 01 | `1` | `0` = nó full (necessário p/ P2Pool) |
| `RPC_PORT` | 01 | `18089` | Porta do RPC restrito (a que o Tor publica) |
| `MONEROD_SHA256` | 01 | (vazio) | Hash esperado do `monerod`; se vazio, verifica a assinatura GPG (binaryfate) |
| `WALLET` | 03 | (obrigatório) | Endereço Monero **primário** (começa com `4`) |
| `MINI` | 03 | `1` | `1` = sidechain mini (hashrate menor) |
| `P2POOL_SHA256` | 03 | (vazio) | Hash esperado do P2Pool; se vazio, valida a **assinatura GPG** do checksums oficial e confere o hash |
| `P2POOL_SIGNER_FPR` | 03 | `1FCAAB4D…4DA87ADF` | Fingerprint exigida por padrão (SChernykh); passe outra se a chave rotacionar |
| `P2POOL_TOFU` | 03 | `0` | `1` = aceitar qualquer VALIDSIG sem match de fingerprint (escape raro) |
| `XMRIG_SHA256` | 04 | (vazio) | Hash esperado do xmrig; se vazio, compara com o checksums oficial do release |

## Segurança e avisos

- **Verificação de binários (fail-closed).** Os três scripts **abortam** se o binário não conferir:
  - `01` (monerod) e `04` (xmrig) validam **assinatura GPG** — *binaryfate* (`81AC591F…2A0BDF92`) em `hashes.txt`, e *xmrig* (`9AC4CEA8…8BE94409`, [xmrig.com/trilha/gpg-key](https://xmrig.com/trilha/gpg-key)) em `SHA256SUMS.sig`.
  - `03` (P2Pool) — o release publica a lista de hashes **clearsigned** em `sha256sums.txt.asc` (não há `.txt` separado). A **assinatura GPG é obrigatória** e, por padrão, o script **exige** a fingerprint do *SChernykh* (`1FCAAB4D…4DA87ADF`, cross-validada em p2pool.io **+** monero-project/gitian.sigs). Escape: `P2POOL_TOFU=1` (só VALIDSIG, sem match de fingerprint). Override: `P2POOL_SIGNER_FPR=<nova>` se a chave rotacionar.
  - `01` com `PRUNED=0` injeta no `monerod.conf` as flags necessárias ao P2Pool (priority nodes, `in-peers`, DNS blocklist) — o script `03` só pede conferir/reiniciar o `monerod`.
  - Todos aceitam hash fixado: `MONEROD_SHA256` / `XMRIG_SHA256` / `P2POOL_SHA256` (este último **pula** o GPG — use só com `DL_URL` próprio).
- Os serviços rodam num **usuário dedicado `monero`** (sem login), não no seu usuário.
- O nó **baixa a blockchain pela internet normal** (não pela Tor). O Tor (script 2) só **publica o RPC** com privacidade.
- **Firewall (opcional):** o `monerod` escuta P2P em `0.0.0.0:18080` (por desenho). O RPC fica em `127.0.0.1`. Em rede doméstica, considere `ufw` na borda — o curso **não** cobre hardening de firewall.
- **Mineração:** os endereços no P2Pool são **públicos** — use uma **carteira separada** só para minerar, longe da sua carteira do Haveno.
- Estes scripts mexem em `systemd`, `apt` e `/etc` — **leia antes de rodar** e rode só em máquina que você controla.

*Scripts bônus Home Lab · complementam o Capítulo 6 · maio/2026.*
