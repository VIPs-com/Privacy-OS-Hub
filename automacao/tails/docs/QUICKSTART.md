# Guia Rápido — Privacy-OS-Hub

## Os 4 comandos que você precisa saber

```bash
# 1ª vez — instalar o Haveno (só precisa fazer uma vez)
~/Persistent/hub-scripts/hub.sh install

# Cada sessão — abrir o Haveno (pendrive ligado, Tor conectado)
~/Persistent/hub-scripts/hub.sh boot

# Antes do 1º depósito — backup da carteira
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

# Retomar instalação quando o .deb já está em Install/
hub.sh install --install-only

# Instalar o Feather Wallet (passo 5 do curso)
hub.sh feather
```

## Se o `hub.sh` falhar

```bash
cd ~/Persistent/hub-scripts/steps/
./run-all.sh          # roda passo a passo, para no 1º FAIL
```

Leia o `FAIL` — ele diz exatamente o que fazer. Corrija, rode o passo sozinho, depois volte ao `run-all.sh`.

Consulte também: `steps/README.md` — tabela de diagnóstico por passo.

---

## Para a equipe: atualizar para novo release

Edite **apenas** estas 2 linhas em `lib/config.sh`:

```bash
HAVENO_VERSION="X.Y.Z-reto"
HAVENO_PGP_FPR="NOVA_FINGERPRINT"
```

Todos os scripts — `hub.sh`, `steps/`, `etapas/` — leem automaticamente de `lib/config.sh`.
