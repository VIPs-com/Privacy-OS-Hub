---
passo_hub: 5
trilha: m1-tor
rede: tails_online_tor
scripts: [feather-install-verify.sh]
livro: modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#3-feather-no-tails--instalar-e-verificar
playbook_legacy: modulos/m1-tails-haveno/Expansao-Curso/Playbooks-Rede-Descentralizada.md
---

# P05 — Feather (obrigatório M2)

**Cartão:** [passo-05](../../trilha/passos/passo-05.md) · **Livro:** [Vol II Cap. 3](../../modulos/m1-tails-haveno/Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md#3-feather-no-tails--instalar-e-verificar)

**Pré-requisito:** Haveno **verde** + backup cifrado (P04) antes do 1º depósito de XMR.

> **Trades (opcional):** Caps. 7–8 do Vol II — comandos em [Playbooks Vol II §4–6](../../modulos/m1-tails-haveno/Expansao-Curso/Playbooks-Rede-Descentralizada.md).

---

## Feather no Tails (download + PGP + executar)

```text
# Tor Browser -> https://featherwallet.org/download
# Baixe: AppImage Tails + featherwallet.asc + feather-x.x.x.AppImage + feather-x.x.x.AppImage.asc
```

```bash
# Automatizado (após o download pelo Tor Browser):
~/Persistent/feather-install-verify.sh --qa-log
```

Manual:

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

gpg --verify feather-*AppImage.asc feather-*AppImage
# OK SE (2 condicoes): "Good signature from FeatherWallet" E a linha
#   "Primary key fingerprint:" == 8185 E158 A333 30C7 FD61 BC0D 1F76 E155 CEFB A71C
# "Good signature" sozinho NAO basta (chave de mesmo nome forja isso). User ID igual != chave igual.
```

```bash
chmod +x feather-*.AppImage
./feather-*.AppImage
```

```text
# UI: Create new wallet -> seed em PAPEL (carteira SEPARADA do Haveno)
# Salvar .keys em ~/Persistent/feather/wallets/
# Settings -> Network -> Always over Tor
```

**OK se:** Feather abre, sincroniza, saldo visível (0 XMR no início é normal) · PGP OK · seed em papel.
