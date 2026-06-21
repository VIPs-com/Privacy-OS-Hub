# Mapa de migração — scripts antigos → novos comandos

> **Para alunos:** se você tem anotações com comandos antigos, use esta tabela para encontrar o equivalente novo.  
> **Para a equipe:** referência para comunicados de atualização e checklist da Fase 3.

---

## Comandos do aluno

| Antes (legado) | Depois (novo) | Quando usar |
|---|---|---|
| `haveno-setup.sh` | `hub.sh install` | 1ª vez — instalar o Haveno |
| `haveno-setup.sh --boot` | `hub.sh boot` | Cada sessão — abrir o Haveno |
| `haveno-setup.sh --install-only` | `hub.sh install --install-only` | Retomar instalação (sem baixar .deb) |
| `haveno-setup.sh --qa-log` | `hub.sh install --qa-log` | Gravar log completo para suporte |
| `haveno-backup.sh` | `hub.sh backup` | Backup da carteira |
| `haveno-update.sh` | `hub.sh update` | Atualizar para novo release |
| `feather-install-verify.sh` | `hub.sh feather` | Instalar Feather (módulo 2) |
| `etapas/TUDO.sh` | `steps/run-all.sh` | Fallback atômico completo |
| `etapas/07-instalar-deb.sh --force-depends` | `steps/07-install-deb.sh --force-depends` | Instalar ignorando libs Ubuntu |

---

## Scripts internos (nunca foram para o aluno)

| Antes | Depois | Papel |
|---|---|---|
| `haveno-auto.sh` | interno de `hub.sh` | Fluxo de instalação |
| `haveno-boot.sh` | interno de `hub.sh` | Fluxo de boot |
| `haveno-common.sh` | `lib/common.sh` (canônico) | Biblioteca de funções |
| `_config.sh` (etapas) | `lib/config.sh` | Única fonte de verdade |
| `haveno-onion-grater.yml` | `lib/onion-grater.yml` | Filtro Tor corrigido |

---

## Flags mantidas (backward-compat)

Todas as flags dos scripts antigos funcionam no `hub.sh`:
- `--one-password` — digitar senha admin uma vez só
- `--qa-log` — gravar log completo
- `--no-clock` — pular ajuste de relógio
- `--force-depends` — instalar ignorando dependências ausentes

---

## Checklist Fase 3 — equipe ✅ concluída (2026-06-19)

- [x] Remover `haveno-setup.sh` — deletado
- [x] Remover `haveno-auto.sh` — movido para `haveno/install.sh` (interno)
- [x] Remover `haveno-boot.sh` — movido para `haveno/boot.sh` (interno)
- [x] Remover `haveno-common.sh` — deletado; `lib/common.sh` é o canônico
- [x] Remover `etapas/instalar-haveno/` — substituída por `steps/`
- [x] Reorganizar `hub-aliases/` em subpastas `parte-1/` · `parte-2/` · `manutencao/` (v2.0 — 21/06/2026)
- [x] Atualizar `sync-hub-scripts.sh` para não copiar arquivos removidos
- [x] Atualizar documentação do curso para `hub.sh install` / `hub.sh boot`
- [ ] Comunicado para alunos — aguardando piloto B+ concluir

**Template de comunicado:**
```
Atualização de scripts — o que muda para você:

Comando antigo → Comando novo:
  haveno-setup.sh        →  hub.sh install
  haveno-setup.sh --boot →  hub.sh boot
  etapas/TUDO.sh         →  steps/run-all.sh

Para atualizar seus scripts:
  cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
  ./sync-hub-scripts.sh
```

---

*docs/MIGRATION.md · Privacy-OS-Hub · atualizado 2026-06-19*
