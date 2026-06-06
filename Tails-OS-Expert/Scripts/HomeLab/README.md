# Scripts bônus — Home Lab (infraestrutura)

> ⚠️ **Estes scripts NÃO rodam no Tails.** Eles são para o seu **home lab** — uma instalação **Debian/Ubuntu** normal, sempre ligada (mini PC, NUC, Raspberry Pi 4/5 com SSD). O Tails é o **cliente** (carteira/Haveno); o home lab é a **infraestrutura** (nó, mineração).
>
> Contexto: Volume I [`../../Curso-Tails-OS-Expert.md`](../../Curso-Tails-OS-Expert.md) Cap. 6 · **Lab integrado:** Volume II [`../../Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md`](../../Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md) Cap. 13.

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
| `P2POOL_SIGNER_FPR` | 03 | (vazio) | Fingerprint do SChernykh; se passado, **exige** que a assinatura do checksums seja dela (`1FCAAB4D…4DA87ADF`) |
| `XMRIG_SHA256` | 04 | (vazio) | Hash esperado do xmrig; se vazio, compara com o checksums oficial do release |

## Segurança e avisos

- **Verificação de binários (fail-closed).** Os três scripts **abortam** se o binário não conferir:
  - `01` (monerod) e `04` (xmrig) validam **assinatura GPG** — *binaryfate* (`81AC591F…2A0BDF92`) em `hashes.txt`, e *xmrig* (`9AC4CEA8…8BE94409`, [xmrig.com/docs/gpg-key](https://xmrig.com/docs/gpg-key)) em `SHA256SUMS.sig`.
  - `03` (P2Pool) — o release publica a lista de hashes **clearsigned** em `sha256sums.txt.asc` (não há `.txt` separado). Por isso a **assinatura GPG é obrigatória**: o script valida a assinatura do checksums **antes** de confiar no hash e aborta em qualquer falha. Importa a chave do *SChernykh* de [p2pool.io/SChernykh.asc](https://p2pool.io/SChernykh.asc) (fallback keyserver). Como o P2Pool usa *reproducible builds* e não publica uma fingerprint central proeminente, sem fixá-la a checagem é **TOFU sobre HTTPS** — para cadeia de confiança forte, confirme a fingerprint `1FCAAB4D…4DA87ADF` (cross-validada em p2pool.io **+** monero-project/gitian.sigs) e rode com `P2POOL_SIGNER_FPR=…` (aí o script **exige** essa fingerprint).
  - Todos aceitam hash fixado: `MONEROD_SHA256` / `XMRIG_SHA256` / `P2POOL_SHA256` (este último **pula** o GPG — use só com `DL_URL` próprio).
- Os serviços rodam num **usuário dedicado `monero`** (sem login), não no seu usuário.
- O nó **baixa a blockchain pela internet normal** (não pela Tor). O Tor (script 2) só **publica o RPC** com privacidade.
- **Mineração:** os endereços no P2Pool são **públicos** — use uma **carteira separada** só para minerar, longe da sua carteira do Haveno.
- Estes scripts mexem em `systemd`, `apt` e `/etc` — **leia antes de rodar** e rode só em máquina que você controla.

*Scripts bônus Home Lab · complementam o Capítulo 6 · maio/2026.*
