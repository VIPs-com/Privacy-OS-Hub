# Guia Rápido — Privacy-OS-Hub

## Os 4 comandos que você precisa saber

```bash
# 0. Sincronizar scripts + instalar atalhos GNOME (uma vez, e a cada update)
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails && ./sync-hub-scripts.sh
# → instala "Haveno — Iniciar" e "Haveno — Backup" no menu GNOME

# 1ª vez — instalar o Haveno (só precisa fazer uma vez)
# Ao final: pergunta se quer instalar o Feather também (s/N) — pode pular e fazer depois
~/Persistent/hub-scripts/hub.sh install

# Cada sessão — abrir o Haveno (ou clique "Haveno — Iniciar" no menu GNOME)
~/Persistent/hub-scripts/hub.sh boot

# Antes do 1º depósito e após cada trade — backup da carteira
~/Persistent/hub-scripts/hub.sh backup

# Novo release disponível — atualizar
~/Persistent/hub-scripts/hub.sh update
```

## Opções úteis

```bash
# Gravar log completo para enviar ao suporte
hub.sh install --qa-log

# Digitar a senha de admin só uma vez no fluxo
hub.sh install --one-password

# Retomar instalação quando o .deb já está em Install/ (não apenas em .download/)
hub.sh install --install-only

# Instalar o Feather Wallet — instala atalho GNOME automaticamente (passo 5)
hub.sh feather

# Snapshot completo para pendrive (Haveno + Feather + Dotfiles) — estratégia 3-2-1-1-0
hub.sh backup --full --usb
```

## Se o `hub.sh` falhar

```bash
cd ~/Persistent/hub-scripts/steps/
./run-all.sh          # roda passo a passo, para no 1º FAIL
```

Leia o `FAIL` — ele diz exatamente o que fazer. Corrija, rode o passo sozinho, depois volte ao `run-all.sh`.

Consulte também: `automacao/tails/docs/TROUBLESHOOTING.md` — diagnóstico por mensagem de erro.

---

## Para a equipe (mantenedores): atualizar para novo release

Edite estas **3 linhas** em `lib/config.sh`:

```bash
HAVENO_VERSION="X.Y.Z-reto"
HAVENO_PGP_FPR="NOVA_FINGERPRINT"
INSTALL_SCRIPT_HASH="SHA256_DO_HAVENO_INSTALL_SH"  # curl -sL <URL_install.sh> | sha256sum | cut -d' ' -f1
```

> ⚠️ **O aluno nunca edita `config.sh`** — ele roda `sync-hub-scripts.sh` para receber o config atualizado e depois `hub.sh update`.

Todos os scripts — `hub.sh`, `steps/` — leem automaticamente de `lib/config.sh`.

> **Atenção ao nome do binário:** a TAG pode ter prefixo `v` (ex.: `v1.8.0-reto`) ou não (ex.: `1.6.0-reto`).
> O **nome do arquivo** sempre omite o prefixo `v` extra e o sufixo `-reto`: `haveno-vX.Y.Z-linux-x86_64-installer.deb`.
> O template em `config.sh` deriva isso em dois passos: remove `-reto` (`%-*`) e remove `v` inicial (`#v`).
> Ao publicar, valide: `source lib/config.sh && curl -sI "$HAVENO_DEB_URL" | grep content-length`.
> Guia completo: `docs/RELEASE-UPDATE.md`.
