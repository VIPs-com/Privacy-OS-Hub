# Playbooks — Rede Descentralizada (só comandos)

**Volume II.** Direto ao ponto. Telas, checklists e teoria: [`Curso-Rede-Descentralizada-Extensao.md`](Curso-Rede-Descentralizada-Extensao.md).

**Pré-requisito:** Volume I concluído — Haveno **verde** ([`../Playbooks/Playbooks.md`](../Playbooks/Playbooks.md) passos 1–7, **mais as seções 9–10 Backup/Atualizar**). **Faça backup cifrado (Playbooks §9) antes do 1º depósito de XMR.** Tails **7.8.1+** (atualização emergencial jun/2026). Rede turma: **Reto `1.6.0-reto`**.

> Tradear: versão **`1.6.0-reto`+**, confirme retomada nos canais oficiais, **valores pequenos** primeiro.

---

## 1 — Primeira conta Haveno + seed (UI + backup)

# Haveno verde -> Aplicações -> Outros -> Haveno
# Account -> Create account (ou assistente 1ª abertura) -> senha forte
# Account -> Wallet seed -> anote OFFLINE (papel/metal) -> confirme se pedir
# NUNCA: foto, nuvem, chat, e-mail da seed

```bash
~/Persistent/haveno-backup.sh
# ou: ~/Persistent/haveno-backup.sh --usb
```

# OK se: seed em papel separado do USB + backup cifrado de Data/ feito ANTES do 1º depósito.
# Seed != backup completo (trades/contas ficam em Data/).

---

## 2 — Feather no Tails (download + PGP + executar)

# Tor Browser -> https://featherwallet.org/download
# Baixe: AppImage Tails + featherwallet.asc + feather-x.x.x.AppImage + feather-x.x.x.AppImage.asc

```bash
# Ou automatizado (apos o download pelo Tor Browser):
~/Persistent/feather-install-verify.sh
```

```bash
mkdir -p ~/Persistent/feather/wallets
mv ~/Tor\ Browser/Browser/Downloads/feather-* ~/Persistent/feather/ 2>/dev/null || true
mv ~/Tor\ Browser/Browser/Downloads/featherwallet.asc ~/Persistent/feather/ 2>/dev/null || true
cd ~/Persistent/feather
ls -la
```

```bash
cd ~/Persistent/feather
gpg --import featherwallet.asc
gpg --list-keys dev@featherwallet.org
# Fingerprint: 8185 E158 A333 30C7 FD61 BC0D 1F76 E155 CEFB A71C

# Pasta só com UMA versão; se houver 2+ .AppImage/.asc, digite os nomes exatos.
# Use o par .asc + .AppImage baixados (ponto antes de AppImage, nao hifen):
gpg --verify feather-*AppImage.asc feather-*AppImage
# OK: Good signature from FeatherWallet
```

```bash
chmod +x feather-*.AppImage
./feather-*.AppImage
```

# UI: Create new wallet -> seed em PAPEL (carteira SEPARADA do Haveno)
# Salvar .keys em ~/Persistent/feather/wallets/
# Settings -> Network -> Always over Tor

# OK se: Feather abre, sincroniza, saldo visível (0 XMR no início é normal).

---

## 3 — PGP na mão — Haveno (se install falhou ou auditoria)

```bash
cd ~/Persistent/haveno/Install

curl -fsSLO https://retoswap.com/reto_public.asc
gpg --import reto_public.asc
gpg --list-keys --with-fingerprint
# Reto: DAA24D878B8D36C90120A897CA02DAC12DAE2D0F

gpg --verify haveno-v1.6.0-linux-x86_64-installer.deb.sig \
  haveno-v1.6.0-linux-x86_64-installer.deb
```

# Outra rede: importe a chave do SITE OFICIAL da rede, não a Reto.
# OK se: Good signature + fingerprint bate com a URL do .deb.

---

## 4 — Feather <-> Haveno (teste micro XMR)

# Haveno: Funds/Wallet -> Receive -> copie endereço XMR
# Feather: Send -> endereço Haveno -> valor pequeno (ex. 0.01) -> confirme
# Aguarde ~10-20 min confirmações

# Saque de volta:
# Haveno: Funds -> Send -> endereço Receive da Feather

# OK se: XMR foi Feather -> Haveno -> Feather sem erro.

---

## 5 — Conta de pagamento + comprar XMR (UI)

# Account -> Payment accounts -> Add new -> PIX/banco/etc. (dados reais)
# Markets -> Buy XMR -> escolha oferta (reputação + valor PEQUENO)
# Take offer -> depósito segurança entra no multisig
# Pague fiat pelos dados NO APP -> guarde comprovante
# Mark payment as sent -> SOMENTE depois de pagar de verdade
# Aguarde vendedor liberar XMR

# OK se: trade concluído; XMR no Haveno -> sacar p/ Feather (passo 4).

---

## 6 — Vender XMR (UI — mais cuidado)

# Markets -> Sell XMR -> Create offer (método IRREVERSÍVEL: PIX, dinheiro)
# OU aceite oferta existente
# Comprador marca "enviado" -> NÃO confie só no print dele
# Confira conta REAL: valor exato + nome remetente
# Só libere XMR quando fiat estiver NA CONTA e irreversível
# Chargeback: evite PayPal/cartão ao VENDER

# OK se: liberou só após crédito real; ou abriu disputa se sumiu.

---

## 7 — Disputa (UI)

# Trade aberto -> Open dispute
# Descreva no CHAT do app + anexe comprovantes
# Árbitro decide; NUNCA mande seed/senha por fora

# OK se: tudo documentado dentro do Haveno.

---

## 8 — Outra rede (ex. Aloha)

# Feche trades + backup ANTES:
```bash
~/Persistent/haveno-backup.sh
```

# Obtenha URL .deb + PGP no site/GitHub OFICIAL da nova rede (mesmo release):
```bash
curl -fsSLO https://github.com/haveno-dex/haveno/raw/master/scripts/install_tails/haveno-install.sh \
  && bash haveno-install.sh "URL_DO_DEB_DA_REDE" "FINGERPRINT_PGP_DA_MESMA_REDE"
```

# NÃO restaure backup Data/ de outra rede.
# Aloha: https://haveno-aloha.com/ · https://github.com/The-Aloha-Project/haveno-aloha/releases

---

## 9 — Home Lab (Debian/Ubuntu — NÃO no Tails)

# Copie ../Scripts/HomeLab/ para o servidor. No home lab:

```bash
cd /caminho/para/Tails\ OS\ Expert/Scripts/HomeLab
chmod +x *.sh

./00-verificar-requisitos.sh

sudo ./01-setup-monero-node.sh
# Mineração depois: sudo PRUNED=0 ./01-setup-monero-node.sh

sudo ./02-tor-hidden-service.sh
sudo cat /var/lib/tor/monero-rpc/hostname
```

```bash
# Teste RPC via Tor (Tails ou máquina com Tor):
curl --socks5-hostname 127.0.0.1:9050 http://SEU_ENDERECO.onion:18089/get_info

journalctl -u monerod -f
```

# Feather no Tails: Settings -> Network -> node SEU.onion:18089, SOCKS 127.0.0.1:9050, trusted

# Mineração (opcional, nó FULL + sync completo):
```bash
sudo WALLET=SEU_ENDERECO_PRIMARIO_4xxxx ./03-setup-p2pool.sh
sudo ./04-setup-xmrig.sh
journalctl -u xmrig -f
```

# OK se: curl get_info retorna JSON; Feather sync via seu .onion.

---

## 10 — Trocador (BTC -> XMR)

# Feather -> Receive -> subendereço NOVO -> copie
# Tor Browser -> https://trocador.app/ -> BTC -> XMR, filtro No KYC, valor pequeno
# Envie BTC para endereço mostrado -> aguarde XMR na Feather
# Feather -> Send -> Haveno Receive (passo 4) se for tradear

# Parceiro final pode pedir KYC — ver Extensão Cap. 15.

---

## 11 — Atualizar Tails (sistema)

```bash
~/Persistent/haveno-backup.sh
# Backup persistência Tails: guia oficial tails.net
```

# Aplicações -> Tails -> Tails Upgrader (com Tor)
# OU regrave USB com versão nova em tails.net
# Boot -> persistência -> admin -> Tor -> Haveno menu -> verde -> Feather sync

# NUNCA atualize Tails por script não oficial.

---

## Multisig manual CLI (anexo — não é necessário para tradear no Haveno)

```text
# Haveno cria escrow 2-de-3 automaticamente por trade (Cap. 10 do livro).
# Para multisig Monero manual (educacional / fora do app):
#   Teoria:  Multisig-2-de-3-criacao-manual-CLI.md
#   Comandos: Playbooks-Multisig-CLI.md
# Pratique em stagenet/testnet primeiro.
```

---

## Links essenciais (Volume II)

```text
Extensão (teoria)     Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md
Multisig CLI (anexo)  Multisig-2-de-3-criacao-manual-CLI.md · Playbooks-Multisig-CLI.md
Volume I (comandos)   ../Playbooks/Playbooks.md
Volume I (livro)      ../Curso-Tails-OS-Expert.md
Feather Tails         https://docs.featherwallet.org/guides/tails
Reto releases         https://github.com/retoaccess1/haveno-reto/releases
Aloha                 https://haveno-aloha.com/
Trocador              https://trocador.app/
Bisq                  https://bisq.network/downloads/
eigenwallet           https://eigenwallet.org/
Haveno deployment     https://github.com/haveno-dex/haveno/blob/master/docs/deployment-guide.md
HomeLab scripts       ../Scripts/HomeLab/README.md
Tails upgrade         https://tails.net/doc/upgrade/index.en.html
```

*Playbooks Volume II · maio/2026 · Reto 1.6.0-reto. Teoria: `Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md`.*
