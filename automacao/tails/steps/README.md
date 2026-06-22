# steps/ — Fallback Haveno (passo a passo)

> **O que é:** 8 scripts atômicos que reproduzem exatamente o que `hub.sh install` faz,
> mas **um passo de cada vez**. Serve para diagnosticar e recuperar quando o `hub.sh` trava.
>
> **Haveno-only:** estes scripts instalam **somente o Haveno**.
> Feather Wallet **não está aqui** — para Feather use `hub.sh feather`.
>
> **Quando usar:** somente se `hub.sh install` falhou e você precisa saber
> em **qual passo** e **por quê** ele falhou.
>
> **Como usar:** rode `run-all.sh` — ele para no 1º `FAIL` com a causa.
> Corrija o problema, rode aquele passo isolado de novo, depois volte ao `run-all.sh`.

---

## `hub.sh install` vs `steps/` — quando usar cada um

| Situação | O que usar |
|----------|-----------|
| 1ª instalação normal | `hub.sh install` |
| Cada sessão após instalado | `hub.sh boot` |
| `hub.sh install` deu erro | **`steps/run-all.sh`** — descobre onde parou |
| Quero re-testar só o download | **`steps/02-download-deb.sh`** |
| Quero re-testar só a assinatura PGP | **`steps/05-verify-sig.sh`** |
| Download completo mas install falhou | **`steps/05-verify-sig.sh`** depois **`steps/07-install-deb.sh`** (ou `hub.sh install --install-only`) |
| Não sei onde falhou | **`steps/run-all.sh`** — mostra o FAIL exato |

---

## Como usar

```bash
# Opção A — roda tudo em sequência, para no 1º FAIL:
cd ~/Persistent/hub-scripts/steps
./run-all.sh

# Opção B — roda um passo isolado para diagnóstico:
./steps/02-download-deb.sh      # só o download
./steps/05-verify-sig.sh        # só a verificação PGP
./steps/07-install-deb.sh       # só o install
```

Se um passo der **FAIL**: a mensagem diz o que corrigir.
Corrija → rode esse passo de novo → continue com o próximo (ou `run-all.sh`).

Após resolver com `steps/`, nas **próximas sessões** volte ao `hub.sh boot` — não
use `steps/` como rotina, use só para depuração.

---

## O que cada passo faz

| Script | Função | Quando executa |
|--------|--------|----------------|
| `01-setup-dirs.sh` | Cria pastas `Install/`, `Data/`, `App/utils/` | Sempre |
| `02-download-deb.sh` | Baixa `.deb` + `.sig` pelo Tor — retoma se interrompido | 1ª vez / update |
| `03-rescue-tmp.sh` | **Emergência** — resgata `.deb` de `/tmp` (RAM!) para a persistência | Só se Tails reiniciou no meio do download |
| `04-import-key.sh` | Importa chave PGP da Reto — **confirme o fingerprint com seus olhos** | 1ª vez |
| `05-verify-sig.sh` | Verifica assinatura PGP — fail-closed, independe do idioma do sistema | Sempre |
| `06-check-deps.sh` | Instala deps apt disponíveis; lista as Ubuntu-only ausentes (normal) | Sempre |
| `07-install-deb.sh` | Instala o `.deb` verificado via dpkg | Sempre |
| `07-install-deb.sh --force-depends` | Força install ignorando libs Ubuntu-only ausentes | Quando `06` listou libs ausentes |
| `08-open-haveno.sh` | Aplica filtro Tor (onion-grater) e abre o Haveno | Sempre |

---

## Diagnóstico rápido

| Falhou em | Causa provável | O que fazer |
|-----------|----------------|-------------|
| `01` | Persistência não montada | Ative a Persistência no menu Tails e reinicie a sessão |
| `02` | Tor lento ou circuito substituído | Rode de novo — o curl retoma de onde parou automaticamente |
| `04` | URL da chave mudou ou sem Tor | Confira `lib/config.sh` · verifique conexão Tor |
| `05` | `.sig` inválida ou `.deb` corrompido | Re-baixe com `02-download-deb.sh` |
| `06` | Libs Ubuntu-only ausentes (aviso) | Normal — use `07 --force-depends` no passo seguinte |
| `07` | dpkg quebrado ou deps faltando | Leia o FAIL; tente `--force-depends` |
| `08` | onion-grater ou exec.sh | Veja Apêndice B do guia `🛡️ Privacy-OS-Hub - Versão 1.0.md` |

---

## Para a equipe

Cada script é um **teste unitário** do fluxo de instalação. Rodar `06-check-deps.sh`
isolado confirma ou descarta problema de dependências sem contaminar o diagnóstico
com falhas de rede ou PGP.

Para novo release, edite **somente** `lib/config.sh` (2 linhas: `HAVENO_VERSION` +
`HAVENO_PGP_FPR`) — todos os scripts aqui lêem as constantes de lá via `_config.sh`.

> **Convenção de nome:** a TAG pode ter prefixo `v` (`v1.8.0-reto`) ou não (`1.6.0-reto`).
> O binário omite o prefixo `v` extra e o sufixo `-reto` (ex.: `haveno-v1.8.0-linux-x86_64-installer.deb`).
> O `config.sh` faz dois passos: `%-*` remove `-reto`; `#v` remove o `v` inicial.
> Ao atualizar, confira no GitHub o nome exato do `.deb` — ver `docs/RELEASE-UPDATE.md §1`.
