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

- **HEAD `main`:** `6ae2126` (`049d426` rename paths · `e53ffb0` CHANGELOG Rodada 20)
- **Veredito:** LIBERADO para piloto B+ — ver `Privacy-OS-Hub-equipe-dev/validacao/HANDOFF-EQUIPE-DEV.md` (local)

---

## Pendente pós-beta

- [ ] Piloto B+ Tails físico (`Privacy-OS-Hub-equipe-dev/validacao/05-CHECKLIST-PILOTO-B+-V2.md`)
- [ ] Revisão pedagógica amostra (passos 4, 8, 9, 12)
- [ ] Remoção gradual dos stubs após período de redirect
- [ ] Tag `v2.0.0` estável

---

*Privacy-OS-Hub · CHANGELOG v2 · jun/2026*
