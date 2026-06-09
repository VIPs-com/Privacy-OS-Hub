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
- Relatório: `Privacy-OS-Hub-equipe-dev/validacao/07-REVISAO-PEDAGOGICA-ESTATICA-R21.md`

---

## Stubs v1 + pacote piloto (R22)

- Índice público: [trilha/referencia/stubs-v1-indice.md](trilha/referencia/stubs-v1-indice.md)
- Stub criado: `Whonix-Online/Scripts/README.md` → `automacao/whonix-host/`
- Pacote equipe-dev: `Privacy-OS-Hub-equipe-dev/validacao/PACOTE-PILOTO-B+-PRONTO.md`

---

## Pendente pós-beta

- [ ] Piloto B+ Tails físico — porta: [PACOTE-PILOTO-B+-PRONTO](Privacy-OS-Hub-equipe-dev/validacao/PACOTE-PILOTO-B+-PRONTO.md) · [05-CHECKLIST](Privacy-OS-Hub-equipe-dev/validacao/05-CHECKLIST-PILOTO-B+-V2.md) — **equipe-dev**
- [x] Revisão pedagógica amostra estática (passos 4, 8, 9, 12) — R21
- [ ] Remoção gradual dos stubs após período de redirect
- [ ] Tag `v2.0.0` estável

---

*Privacy-OS-Hub · CHANGELOG v2 · jun/2026*
