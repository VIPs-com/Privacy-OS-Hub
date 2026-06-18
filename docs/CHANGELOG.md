# CHANGELOG — Privacy-OS-Hub

> **v1.0 canônica** · jun/2026 · branch `main`

---

## 2026-06-18 — `hub-aliases/` numerados + sync para `hub-scripts/aliases/`

| Mudança | Detalhe |
|---------|---------|
| **21 aliases** | `00`–`20` com nomes descritivos e flags fixas (`--qa-log`, `--boot`, etc.) |
| **sync** | `sync-hub-scripts.sh` e `hub_sync_scripts_to_persistent` copiam `aliases/` |
| **Wrappers** | Resolvem `HUB=..` (pai = `hub-scripts/`) — funciona no Tails após sync |
| **Stubs** | `00-tails-install` / `00-bootstrap-tails` = passos manuais (exit 1 + orientação) |

---

## 2026-06-18 — `.sig` via Tor (espelha `02-baixar-deb.sh`) + mensagens Apêndice B

| Mudança | Scripts | Detalhe |
|---------|---------|---------|
| **`.sig` só Tor** | `haveno-common.sh` | `curl -fsSL` como `02-baixar-deb.sh`; removido fallback clearnet que gravava lixo ~119 B |
| **Retry `.sig`** | `haveno-common.sh` | Até 3 tentativas (15 s entre elas) antes de abortar |
| **Recovery `.sig`** | `haveno_sig_download_failed_msg` | Explica pendrive/W11 OK; aponta Apêndice B §3 e fallback atômico |
| **Mensagens obsoletas** | `haveno-auto.sh`, `README.md`, `MANUAL.md` | Cap. 7 / `Curso-Tails-OS-Expert.md` → **Apêndice B** do canônico |
| **Validação `.sig`** | `02-baixar-deb.sh` | Mín. 400 B + header PGP (fail-closed antes do `.deb`) |

---

## 2026-06-18 — Download: barra de progresso + fluxo `.download/` → `Install/`

| Mudança | Scripts | Detalhe |
|---------|---------|---------|
| **Barra ASCII** | `haveno-common.sh`, `haveno-auto.sh` | `[########----] NN%` a cada **10s** durante upstream (`HAVENO_DOWNLOAD_MONITOR_SEC`) |
| **curl `--progress-bar`** | `haveno-common.sh` | `.sig` e `.deb` quando `App/utils/` já existe (espelha `02-baixar-deb.sh`) |
| **Promoção verificada** | `haveno_finalize_verified_deb_in_cwd`, `haveno_try_promote_deb_from_cwd` | `.deb` completo em `.download/` → PGP `VALIDSIG` → **mv** para `Install/` + symlink `haveno.deb` |
| **Trap SIGINT** | `haveno-auto.sh`, `haveno-update.sh` | Mata filhos do download em Ctrl+C; `.download/` fica para retomar |
| **Recovery** | `haveno_deb_download_failed_msg` | Mensagens distintas: `.download/` vs `Install/` vs `--install-only` |
| **Auditoria** | `haveno_fix_dpkg_state` | Estado `half-installed`; `health-check.sh` valida YAML do onion-grater |

---

## 2026-06-18 — Scripts 10/10 (auditoria R31+)

| Fix | Scripts | Detalhe |
|-----|---------|---------|
| **Backup senha confirmada** | `haveno-common.sh`, `haveno-backup.sh`, `feather-backup.sh`, `haveno-update.sh` | `haveno_gpg_symmetric_encrypt` — dupla entrada antes do GPG |
| **Onion-grater loop 30s** | `haveno-common.sh`, `08-abrir-haveno.sh` | `haveno_wait_onion_grater_filter` substitui sleep fixo |
| **PGP etapas alinhado** | `05-verificar-assinatura.sh` | `grep VALIDSIG` como no fluxo principal |
| **Feather fallback** | `feather-install-verify.sh` | `FEATHER_VERSION_FALLBACK` (env) se scrape falhar |
| **LC_ALL=C deps** | `haveno-common.sh`, `06-deps-apt.sh` | locale neutro em apt |
| **TX ID hex** | `qa-confirm-passo12.sh` | valida 8 caracteres hex |
| **Health-check** | `health-check.sh` | validacao estatica (sintaxe + checks + YAML onion-grater) |

---

## 2026-06-18 — `meta/` → `docs/` + `MANUAL.md` unificado

| Mudança | Detalhe |
|---------|---------|
| **Pasta** | `meta/` renomeada para `docs/` (≠ stub v1 `docs/` removido em `f0dc197`) |
| **MANUAL.md** | Unifica ex-`MANUAL-EXPERT`, ex-`MANUAL-SCRIPTS` e bloco logs/export em 3 partes |
| **Removidos** | `MANUAL-EXPERT.md`, `MANUAL-DO-CURSO.md`, `MANUAL-SCRIPTS.md` |
| **MANIFESTO** | §7 reescrito para arquitetura v1.0 canônica |
| **Links** | README, `automacao/`, canônico apontam para `docs/` |

---

## Histórico v2 (beta)

> **Tag:** `v2.0.0-beta` · **Data:** 2026-06-08

---

## 2026-06-17 — Download `.download/` + assinatura `.sig` (DIV-20260617-01/02)

**Commits:** `1dd2e47` · `1e8fe99`/`6acf2a1` (purge `.deb` ~119 B) · `42e9ff6` · merge `79a7dd3` · docs `1e4db26`

| Fix | Sintoma | Correção |
|-----|---------|----------|
| **DIV-17-01** | `.deb` em `/tmp` (RAM); monitor sem %; perdia no reboot | Pasta persistente `~/Persistent/haveno/.download/` + `wget -c` retoma após reboot |
| **DIV-17-02** | `.sig` de **119 B** (HTML GitHub); `Failed to download Haveno signature` com `.deb` completo (~266 MB) | Purge `.sig` &lt; 400 B; `haveno_predownload_sig` via **Tor** + `BEGIN PGP SIGNATURE`; promove `.deb` verificado para `Install/` sem re-baixar |

- **`haveno-common.sh`:** `haveno_purge_poisoned_partial_debs`, `haveno_sig_size_ok`, `haveno_finalize_verified_deb_in_cwd`
- **`haveno-auto.sh` / `haveno-update.sh`:** atalho quando `.deb` já está completo em `.download/`; fallback PGP local se upstream falhar na `.sig`
- **Docs aluno:** [TRES-PASSOS-HAVENO-TAILS.md](automacao/docs-aluno/TRES-PASSOS-HAVENO-TAILS.md) — recuperação + **fallback atômico**
- **`automacao/tails/etapas/instalar-haveno/`** — scripts em pedaços no ZIP público (caminho validado em Tails 11/jun e 17/jun)

> **Campo (17/jun):** purge do `.deb` confirmado (266 MB OK). Fix da `.sig` publicado em `main` — **validação Tails do caminho `haveno-setup` ainda pendente** após `sync-hub-scripts.sh`. Fallback atômico documentado até fechar verde no fluxo único.

---

## 2026-06-11 — Fixes de campo R29 (Tails real, Haveno 1.6.0)

Dois bugs **Major** encontrados e validados ao vivo na trilha do passo 2/7:

| Fix | Sintoma | Correção |
|-----|---------|----------|
| **R29a — cookie do Tor** | Haveno fecha na hora: `torControlCookieFile ... is not readable` | `chmod o+r` reaplicado a **cada** sessão, **antes** do `exec.sh` (Tails amnésico) — FAQ **7.12** |
| **R29b — filtro PoW** | Popup "conexão com a rede do Haveno falhou" (`Command filtered`) | Novo `automacao/tails/haveno-onion-grater.yml` — o yml do instalador upstream 1.6.0 não autoriza o `ADD_ONION` com params PoW (bug upstream) — FAQ **7.13** |

Arquivos: `haveno-common.sh` (ordem cookie/filtro→exec + preferência ao yml do hub) ·
`sync-hub-scripts.sh` (copia o yml) · `haveno-onion-grater.yml` (novo) ·
Curso Vol I FAQ 7.12–7.13 · `automacao/tails/README.md` (tabela "como ler os logs").
Validação: RetoSwap conectado à Mainnet via Tor, nó Tor criado (prints internos).

## 2026-06-11 — R30/R31: Feather + boot do zero (continuação da bateria)

| Fix | Sintoma | Correção |
|-----|---------|----------|
| **R30 — chave Feather 404** | `feather-install-verify.sh` morria baixando `featherwallet.asc` (URL do GitHub master morta) | Fallback em cadeia: site oficial → keyserver pinado pelo fingerprint; download automático do AppImage via Tor; **gate humano** de fingerprint ("confira no olho"); abre o app + atalhos — `639c841`…`29bbfea` |
| **R30b — Persistent poluída** | `sync-hub-scripts.sh` despejava ~17 arquivos na raiz | Scripts agora em **`~/Persistent/hub-scripts/`** (pasta única; dados do operador fora) — `1c5da78` |
| **R31 — apt update sem retry** | Boot novo: update via Tor falhava e o script seguia → todas as libs "sem candidato" | Retry 3×30s + abort fail-closed — `37c54b6` |
| **R31b — ⚠️ deps com nomes UBUNTU** | Mesmo com update OK, `libicu74`/`libavcodec60`/etc. **não existem no Debian 13** — o `.deb` 1.6.0-reto declara Depends com nomes de libs do **Ubuntu** | Deps lidas **de dentro do `.deb`**, instala só o que existe, fallback `dpkg --force-depends` (app embute runtime — funciona; validado em boot do zero) — `62fdb62` · FAQ **7.11** reescrito |

> ⚠️ **Para mantenedores:** nunca fixar lista de dependências do `.deb` em script ou doc —
> os nomes vêm do empacotamento upstream (Ubuntu) e quebram no Debian/Tails.
> Sempre ler do próprio pacote (`dpkg-deb -f ... Depends`). Reportar ao haveno-reto
> junto com a issue do filtro PoW.

Reorganização em **4 camadas** sem mudar a trilha pedagógica 1–12 nem os nomes dos scripts em `~/Persistent/`.

---

## Camadas v2

| Camada | Pasta | Função |
|--------|-------|--------|
| A — Porta | `README.md` | Trilha linear 1–12 |
| B — Ensino | `modulos/` | Livros, folhetos, índices de playbook |
| C — Execução | `processos/` | Comandos por passo (P01–P12) |
| D — Automação | `automacao/` | Scripts `.sh` (cópia para `~/Persistent/`) |
| Navegação | `trilha/` | Cartões L0/L1, glossário, mapas |

---

## Tabela de redirects

| Antes (v1) | Agora (v2) |
|------------|------------|
| `docs/` | `trilha/` |
| `docs/passos/` | `trilha/passos/` |
| `Tails-OS-Expert/` | `modulos/m1-tails-haveno/` |
| `Tails-OS-Expert/Scripts/` | `automacao/tails/` (+ `homelab/`) |
| `Whonix-Online/` | `modulos/m2-whonix-custodia/` |
| `Whonix-Online/Scripts/` | `automacao/whonix-host/` |
| Playbooks M1 (comandos) | `processos/m1-tor/` P01–P07 |
| Playbooks M2 (comandos) | `processos/` P08–P12 |
| Feather obrigatório M2 | `processos/m1-tor/P05-feather.md` |
| Trades Haveno (opcional) | `modulos/.../Playbooks-Rede-Descentralizada.md` §4–6 |

**Stubs mantidos** (redirect): `docs/`, `Tails-OS-Expert/`, `Whonix-Online/`.

---

## Copiar scripts no Tails (caminho novo no repo)

```bash
cp automacao/tails/*.sh automacao/tails/hub-aliases/*.sh ~/Persistent/
chmod +x ~/Persistent/*.sh
```

---

## Commits principais v2

| Commit | Conteúdo |
|--------|----------|
| `45b73d2` | `docs/` → `trilha/` (navegação L0/L1) |
| `b8fde60` | `modulos/` + `automacao/` + stubs |
| `48707a9` | `processos/` cartões P01–P12 |
| `c3526e8` | Fatiar comandos nos processos; playbooks → índice |

---

## Inalterado (pedagogia)

- Ordem passos **1–12** no README
- Passo **9** = ritual 2× seed (Tor OK)
- Passo **12** = único air-gap de rede obrigatório
- Scripts: `haveno-setup.sh`, `qa-confirm-passo9.sh`, etc. (só mudou caminho no repo)
- QA: `--qa-log` → `~/Persistent/qa-logs/`

---

## Publicação pós-Rodada 20

- **Publicação:** `git pull origin main` — cadeia `79f6d3e` (FIG-4/FIG-1) · `104a751`+ (fechamento P1–P2) · `f32b735` (HEAD)
- **Veredito:** LIBERADO para piloto B+ — ver `Privacy-OS-Hub-equipe-dev/validacao/HANDOFF-EQUIPE-DEV.md` (local)

---

## Diagramas v2 (FIG-1…4)

- **`79f6d3e`** — FIG-4 (4 camadas + jornada 1–12 no README); FIG-1 reescrito (P01–P12, tabela rede); índice `diagramas-indice.md`; âncoras FIG-3/FIG-4
- **`104a751`** — fechamento P1–P2: cartões passo FIG-1/2/3; MANUAL-EXPERT `#arquitetura-do-repositorio`; índices; roadmap interno `Privacy-OS-Hub-equipe-dev/ROADMAP-FECHAMENTO-DIAGRAMAS-V2.md`

---

## Alinhamento documentação v2

- **Travou aqui?** passos 1–12 + P01–P12 · Feather=P05 · trades opcional separado · FIG-3 no passo 12
- **M2 README** coluna Comandos → `processos/` P08–P12
- **MANUAL-SCRIPTS** fluxo visual ↔ passos/P0x · **Playbooks Vol II** banner P05
- **Âncoras** Vol II caps 4–17 · Whonix §4 · `#trilha-script-first`
- Roadmap interno: `Privacy-OS-Hub-equipe-dev/ROADMAP-ALINHAMENTO-DOCUMENTACAO-V2.md`

---

## Revisão pedagógica R21 (estática)

- Passos **4, 8, 9, 12** — veredito **APROVADO** (gate sem Tails)
- Correção principal: **P08** pré-requisitos em 2 fases (passo 8 ≠ passo 12)
- Relatório: gate pedagógico estático (camada local da equipe-dev)

---

## Stubs v1 + pacote piloto (R22)

- Índice público: [trilha/referencia/stubs-v1-indice.md](trilha/referencia/stubs-v1-indice.md)
- Stub criado: `Whonix-Online/Scripts/README.md` → `automacao/whonix-host/`
- Pacote equipe-dev: `Privacy-OS-Hub-equipe-dev/validacao/PACOTE-PILOTO-B+-PRONTO.md`

---

## Liberação campo R23 (2026-05-29)

- **HEAD:** `2ba833b` · doc v2-beta **fechada** (gates estáticos R20→R23)
- **Veredito:** LIBERADO PARA CAMPO — piloto B+ Tails físico
- Relatório local: `Auditoria/Rodada-23-Liberacao-Campo-Tails.md`
- Porta execução: `validacao/PACOTE-PILOTO-B+-PRONTO.md` · `validacao/HANDOFF-EQUIPE-DEV.md`

---

## Manutenção R24 + backlog Purple P-1…P-5 (2026-06-09)

- **Âncora:** `Instalar-Whonix-passo-a-passo-por-SO.md` §10 → `#10-prints-do-manifesto-pi-1`
- **Scripts:** `feather-install-verify.sh` · `haveno-verify-deb.sh` — PGP `--status-fd 1` + `VALIDSIG` (locale-independente); `haveno-switch-network.sh` — `die` em opção inválida
- **Doc manual PGP (P-3):** Vol II §3.3/§4.1 · Playbooks §2–3 · `P05-feather.md` — exigem fingerprint do signatário
- **README:** passos online **1–9** (alinha passo 9 em Tails com Tor)
- Gate local (gitignored): `Privacy-OS-Hub-equipe-dev/checkers/` — ver `Auditoria/Rodada-24-Correcoes-Doc-e-Gate-Links.md`

---

## Baseline de proteção + backup prático (2026-06-09)

- **Nova página:** [trilha/trilhas/opcionais-zero-trust-baseline.md](trilha/trilhas/opcionais-zero-trust-baseline.md) — entrega o processo de **cofre · PGP · backup 3-2-1 off-site** usando o que o aluno já criou (seed P04, ritual P09, Feather, hábito PGP); aprofundamento opcional no **Zero-Trust-Core** (não tira o aluno do curso).
- **Prático Haveno:** `haveno-backup.sh` (compacta + cifra GPG + `.sha256`; `--usb` salva em pendrive), restauração e *atualizar com backup antes* amarrados ao 3-2-1 + insight **`seed ≠ backup completo`** (seed recupera fundos, não histórico/contas de pagamento → backup da pasta `Data/`).
- **Navegação repontada:** README "Trilhas opcionais"/"Baseline opcional", `MANUAL-EXPERT`, `MANUAL-DO-CURSO` e `trilha/trilhas/README.md` apontam para a página local (que linka o ZTC).

---

## Orquestração `haveno-setup` R29 (2026-05-29)

- **`haveno-setup.sh`:** sync repo→Persistent (mtime); `hub_resolve_script`; auto-resume `--install-only`; propaga `--qa-log` a preflight/auto/boot/backup/feather
- **`haveno-auto.sh` / `haveno-boot.sh`:** QA-log `02-haveno-auto` / `03-haveno-boot`
- **`haveno-update.sh`:** `haveno-common` + `haveno_run_install`; backup [4/6] skip amigável sem `Data/`
- **Doc:** P02, `COMO-LER-SEUS-LOGS.md` (linha `02-haveno-auto-*`); gate local `check-script-orchestration.sh`
- **Auditoria local:** `Auditoria/Rodada-29-Scripts-M1-Orquestracao.md`

---

## Recuperação `--install-only` + sync R28b (2026-06-10)

- **`haveno-auto.sh --install-only`:** continua do [7/9] sem re-download (deps + purge config-files + install)
- **`sync-hub-scripts.sh`:** copia `*.sh` do repo para `~/Persistent/`
- **`haveno-common.sh`:** `haveno_fix_dpkg_state`, `haveno_ensure_install_deb_link`, detecta qualquer `*.deb` em `Install/`

---

## Deps `.deb` + diário piloto R28 (2026-06-10)

- **`haveno-common.sh`:** `haveno_ensure_deb_deps()` + `haveno_run_install()` — apt das 12 libs antes de `install.sh` (Tails 7.8+)
- **FAQ 7.11:** armadilha `apt-get install -f` · Software adicional opcional
- **Auditoria local:** `Auditoria/Rodada-28-Piloto-Campo-Progresso.md` (diário campo B+ até [7/9])

---

## UX piloto campo R27 (2026-06-10)

- **`haveno-auto.sh` [5/9]:** 3 tentativas de `Date:` via Tor; fallback explica `timedatectl synchronized: no` no Tails e mostra `date -u`
- **`haveno-auto.sh` [6/9]:** aviso 30–90 min + monitor `[download]` com tamanho e % a cada 30s durante `haveno-install.sh`
- **Docs:** Curso §3.2 · `MANUAL-SCRIPTS.md` (CRLF/ZIP) · `automacao/tails/README.md`
- **Auditoria local:** `Auditoria/Rodada-27-Piloto-Campo-UX.md`

---

## Fechamento backlog R26 (2026-06-09)

- **Scripts:** `feather-backup.sh` — `--restore` com confirmação `(s/N)` + `AES256`; QA-log `tails_online_tor_esperado=SIM`; `haveno-auto.sh` loga sha256 do `haveno-install.sh`
- **Baseline:** `--usb` ≠ off-site; aviso `--restore`; link restauração
- **Didática:** README passo 5 · cartões 01/02/10/11 · MANUAL-DO-CURSO mínimo M2 · Folheto alt-text · [REGRA] trilha M2

---

## Pendente pós-beta

- [ ] Piloto B+ Tails físico — **LIBERADO R23** · pacote/checklist do piloto na camada local da equipe-dev — **equipe campo**
- [x] Revisão pedagógica amostra estática (passos 4, 8, 9, 12) — R21
- [ ] Remoção gradual dos stubs após período de redirect
- [ ] Tag `v2.0.0` estável

---

*Privacy-OS-Hub · CHANGELOG v2 · jun/2026*
