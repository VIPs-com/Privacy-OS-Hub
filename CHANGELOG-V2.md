# CHANGELOG — Reorganização v2

> **Tag:** `v2.0.0-beta` · **Data:** 2026-06-08 · **Branch:** `main`

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
