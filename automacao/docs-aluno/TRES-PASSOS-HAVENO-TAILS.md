# Três passos — Haveno no Tails (ZIP do GitHub)

> **Atualizado:** 2026-06-19 · `.sig` via Tor (3 tentativas) · fluxo `.download/` → `Install/` · rode `sync-hub-scripts.sh` após baixar ZIP novo.
>
> **Scripts do pendrive/Windows:** copiar os `.sh` para o Tails está **correto** (`sync-hub-scripts.sh` faz o mesmo). O **`.deb` e a `.sig` do Haveno** são baixados **no Tails via Tor** quando você roda o setup — não vêm do pendrive.
>
> **Para o aluno:** só instalação e execução. Um script: `hub.sh`.  
> **Pré-requisito:** passos 1–4 manuais (USB Tails, **Persistência**, **Dotfiles**, senha **admin** no boot, **Tor** conectado).  
> **Logs:** [COMO-LER-SEUS-LOGS.md](COMO-LER-SEUS-LOGS.md) (no Tails: mesma pasta deste arquivo) · **Detalhe de flags:** [MANUAL.md](../../docs/MANUAL.md#parte-ii--scripts-para-novato) (no Tails: `~/Persistent/Privacy-OS-Hub-main/docs/MANUAL.md`)

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

**Resultado:** scripts em `~/Persistent/hub-scripts/` (subpastas: `haveno/`, `feather/`, `system/`, `qa/`, `lib/`, `steps/`) + aliases em `hub-scripts/aliases/` (parte-1/ · parte-2/ · manutencao/) + atalhos GNOME instalados (carteira e dados em `~/Persistent/haveno/`, separado).

**Aliases opcionais (por passo):**

```bash
~/Persistent/hub-scripts/aliases/parte-1/passo-02-instalar.sh   # = hub.sh install --qa-log
~/Persistent/hub-scripts/aliases/parte-1/passo-07-boot-sessao.sh # = hub.sh boot --qa-log
~/Persistent/hub-scripts/aliases/parte-1/passo-04-backup.sh     # = hub.sh backup --qa-log
```

Tabela completa: `~/Persistent/hub-scripts/aliases/README.md` (no Tails) ou [hub-aliases/README.md](../tails/hub-aliases/README.md) (GitHub).

| Flag em `sync-hub-scripts.sh` | Quando |
|-------------------------------|--------|
| *(nenhuma)* | Copia para `~/Persistent/hub-scripts/` (padrão) |

---

## Passo 2 — Primeira instalação (até o **verde**)

```bash
~/Persistent/hub-scripts/hub.sh install --qa-log
```

**O que faz:** valida ambiente → instala Haveno (download + PGP se preciso) → abre a janela → corrige rede → pergunta backup.

| Flag | Obrigatória? | Função |
|------|:------------:|--------|
| *(nenhuma)* | — | Modo **1ª instalação** (padrão) |
| `--qa-log` | Recomendada | Evidências em `~/Persistent/qa-logs/` |
| `--skip-backup` | Opcional | Não pergunta backup no fim |

> A senha de admin é pedida **apenas uma vez** — comportamento padrão do hub.

**Exemplo:**

```bash
~/Persistent/hub-scripts/hub.sh install --qa-log
```

**OK se:** indicador **verde** na janela do Haveno.

### Recuperação (só se parou no meio)

| Onde está o `.deb` | O que fazer |
|--------------------|-------------|
| **`Install/`** (≥ 100 MiB) + `App/utils/install.sh` existe | `hub.sh install --install-only --qa-log` |
| **Só em `.download/`** (ex.: ~266 MB), falhou assinatura ou promoção | `sync-hub-scripts.sh` + `hub.sh install --qa-log` |
| **Erro `.sig` inválida** (versão antiga do script) | Faça `sync-hub-scripts.sh` — versão nova aceita assinatura binária Ed25519 |

```bash
# Caso A — já em Install/
~/Persistent/hub-scripts/hub.sh install --install-only --qa-log
```

```bash
# Caso B — completo só em .download/ (ou .sig inválida)
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
./sync-hub-scripts.sh
~/Persistent/hub-scripts/hub.sh install --qa-log
```

O hub verifica PGP (`VALIDSIG`), **move** o `.deb` para `Install/` e cria `haveno.deb` (symlink se o nome for longo). **Não** use `--install-only` se o pacote ainda está só em `.download/`.

---

> **Apenas se `hub.sh install` ainda falhar após as recuperações acima:**

### Fallback atômico

Passos atômicos já em `hub-scripts/steps/` — **Haveno-only**, não para Feather:

```bash
cd ~/Persistent/hub-scripts/steps
./run-all.sh
```

O `run-all.sh` roda 01→08 em sequência e **para no 1º FAIL** com a causa exata.
Para diagnóstico passo a passo:

```bash
cd ~/Persistent/hub-scripts/steps
./01-setup-dirs.sh
./02-download-deb.sh         # curl + Tor → Install/ (deb + sig)
./04-import-key.sh
./05-verify-sig.sh
./06-check-deps.sh
./07-install-deb.sh
./08-open-haveno.sh          # verde na janela
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
./05-verify-sig.sh && ./06-check-deps.sh && ./07-install-deb.sh && ./08-open-haveno.sh
```

Depois de instalar pelo atômico, nos próximos boots use o **Passo 3** (`hub.sh boot`) normalmente.
Detalhe completo: `~/Persistent/hub-scripts/steps/README.md` (no Tails) ou [steps/README.md](../tails/steps/README.md) (GitHub).

---

## Passo 3 — Depois de reiniciar o Tails (toda sessão nova)

Sempre que ligar o Tails de novo (**Haveno já instalado** uma vez):

```bash
~/Persistent/hub-scripts/hub.sh boot
```

**O que faz:** valida ambiente → abre Haveno nesta sessão → **não baixa** o `.deb` de novo.

| Flag | Obrigatória? | Função |
|------|:------------:|--------|
| *(nenhuma)* | — | Modo "voltei ao Tails" |
| `--qa-log` | Opcional | Grava log em `qa-logs/` |

> A senha de admin é pedida **apenas uma vez** — comportamento padrão do hub.

**Exemplo:**

```bash
~/Persistent/hub-scripts/hub.sh boot
```

**OK se:** Haveno abre e fica **verde** (amarelo alguns minutos na 1ª abertura da sessão pode ser normal).

---

## Resumo

| # | Situação | Comando |
|---|----------|---------|
| **1** | Preparar scripts do ZIP | `cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails && ./sync-hub-scripts.sh` |
| **2** | **1ª vez** instalar | `~/Persistent/hub-scripts/hub.sh install --qa-log` |
| **3** | **Depois de reiniciar** | `~/Persistent/hub-scripts/hub.sh boot` |

---

## Não faça

- Não rode `install.sh` nem `apt-get install -f` sozinhos.
- Não use `hub.sh update` na 1ª instalação.
- Não use `hub.sh boot` na 1ª vez; depois de instalado, use sempre `hub.sh boot`.

**Não precisa** rodar `haveno/install.sh` nem `haveno/boot.sh` direto — o `hub.sh` chama eles por você.
