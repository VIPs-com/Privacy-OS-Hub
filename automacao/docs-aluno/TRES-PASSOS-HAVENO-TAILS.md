# Três passos — Haveno no Tails (ZIP do GitHub)

> **Para o aluno:** só instalação e execução. Um script: `haveno-setup.sh`.  
> **Pré-requisito:** passos 1–4 manuais (USB Tails, **Persistência**, **Dotfiles**, senha **admin** no boot, **Tor** conectado).  
> **Logs:** [COMO-LER-SEUS-LOGS.md](COMO-LER-SEUS-LOGS.md) · **Detalhe de flags:** [MANUAL-SCRIPTS.md](../../MANUAL-SCRIPTS.md#comando-principal-haveno-setupsh)

---

## Passo 1 — Baixar o ZIP e copiar os scripts

**Uma vez** (ou quando baixar um ZIP novo do hub).

1. No **Tor Browser**, baixe:  
   https://github.com/VIPs-com/Privacy-OS-Hub/archive/refs/heads/main.zip
2. Extraia na **Persistência** (ex.: `~/Persistent/Privacy-OS-Hub-main/`).
3. No **Terminal**:

```bash
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
chmod +x sync-hub-scripts.sh
./sync-hub-scripts.sh
```

**Resultado:** scripts em `~/Persistent/hub-scripts/` (carteira e dados ficam em `~/Persistent/haveno/`, separado).

| Flag em `sync-hub-scripts.sh` | Quando |
|-------------------------------|--------|
| *(nenhuma)* | Copia para `~/Persistent/hub-scripts/` (padrão) |

---

## Passo 2 — Primeira instalação (até o **verde**)

```bash
~/Persistent/hub-scripts/haveno-setup.sh --qa-log
```

**O que faz:** valida ambiente → instala Haveno (download + PGP se preciso) → abre a janela → corrige rede → pergunta backup.

| Flag | Obrigatória? | Função |
|------|:------------:|--------|
| *(nenhuma)* | — | Modo **1ª instalação** (padrão) |
| `--qa-log` | Recomendada | Evidências em `~/Persistent/qa-logs/` |
| `--one-password` | Opcional | Senha de admin **uma vez** no fluxo |
| `--skip-backup` | Opcional | Não pergunta backup no fim |

**Exemplo (menos prompts de senha):**

```bash
~/Persistent/hub-scripts/haveno-setup.sh --qa-log --one-password
```

**OK se:** indicador **verde** na janela do Haveno.

### Recuperação (só se parou no meio)

Se o `.deb` já está em `~/Persistent/haveno/Install/` e falhou no passo de instalar:

```bash
~/Persistent/hub-scripts/haveno-setup.sh --install-only --qa-log
```

Se o `.deb` está completo só em `~/Persistent/haveno/.download/` (ex.: ~266 MB) e falhou na **assinatura** (`.sig` de ~119 bytes):

```bash
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
./sync-hub-scripts.sh
~/Persistent/hub-scripts/haveno-setup.sh --qa-log
```

O sync traz o fix da `.sig` (DIV-20260617-02): remove `.sig` inválida, baixa de novo via Tor e promove o `.deb` sem baixar tudo outra vez.

### Fallback atômico (se `haveno-setup` ainda falhar no [6/9])

Caminho **validado em Tails real** (piloto 17/jun) — etapas em pedaços, mesma pasta do ZIP:

```bash
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails/etapas/instalar-haveno
chmod +x *.sh
./01-pastas.sh
./02-baixar-deb.sh          # curl + Tor → Install/ (deb + sig)
./04-importar-chave.sh
./05-verificar-assinatura.sh
./06-deps-apt.sh
./07-instalar-deb.sh
./08-abrir-haveno.sh        # verde na janela
```

Se o `.deb` **já** está em `.download/` ou `Install/`:

```bash
# copiar .deb completo para Install/ se preciso
cp ~/Persistent/haveno/.download/haveno-v1.6.0-linux-x86_64-installer.deb \
   ~/Persistent/haveno/Install/
# só a assinatura (Tor)
curl -fsSL --socks5-hostname 127.0.0.1:9050 \
  -o ~/Persistent/haveno/Install/haveno-v1.6.0-linux-x86_64-installer.deb.sig \
  "https://github.com/retoaccess1/haveno-reto/releases/download/1.6.0-reto/haveno-v1.6.0-linux-x86_64-installer.deb.sig"
./05-verificar-assinatura.sh && ./06-deps-apt.sh && ./07-instalar-deb.sh && ./08-abrir-haveno.sh
```

Depois de instalar pelo atômico, nos próximos boots use o **Passo 3** (`--boot`) normalmente.

---

## Passo 3 — Depois de reiniciar o Tails (toda sessão nova)

Sempre que ligar o Tails de novo (**Haveno já instalado** uma vez):

```bash
~/Persistent/hub-scripts/haveno-setup.sh --boot
```

**O que faz:** valida ambiente → abre Haveno nesta sessão → **não baixa** o `.deb` de novo.

| Flag | Obrigatória? | Função |
|------|:------------:|--------|
| `--boot` | **Sim** | Modo “voltei ao Tails” |
| `--qa-log` | Opcional | Grava log em `qa-logs/` |
| `--one-password` | Opcional | Uma senha admin só |

**Exemplo:**

```bash
~/Persistent/hub-scripts/haveno-setup.sh --boot --one-password
```

**OK se:** Haveno abre e fica **verde** (amarelo alguns minutos na 1ª abertura da sessão pode ser normal).

---

## Resumo

| # | Situação | Comando |
|---|----------|---------|
| **1** | Preparar scripts do ZIP | `cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails && ./sync-hub-scripts.sh` |
| **2** | **1ª vez** instalar | `~/Persistent/hub-scripts/haveno-setup.sh --qa-log` |
| **3** | **Depois de reiniciar** | `~/Persistent/hub-scripts/haveno-setup.sh --boot` |

---

## Não faça

- Não rode `install.sh` nem `apt-get install -f` sozinhos.
- Não use `haveno-update.sh` na 1ª instalação.
- Não use `--boot` na 1ª vez; depois de instalado, use sempre `--boot` (não o comando sem flags).

**Não precisa** rodar `haveno-auto.sh` nem `haveno-boot.sh` direto — o `haveno-setup.sh` chama eles por você.
