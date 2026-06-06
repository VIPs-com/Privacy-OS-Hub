# Tails OS Expert — índice do curso

Material ativo do curso **Haveno no Tails OS**. Comece pelo **Volume I**, depois a **Expansão**.

> Voltar à raiz do repositório: [`../README.md`](../README.md)

## Mapa rápido

| O quê | Onde |
|-------|------|
| **Volume I** — Tails + Haveno verde | [Curso-Tails-OS-Expert.md](Curso-Tails-OS-Expert.md) · [Playbooks/Playbooks.md](Playbooks/Playbooks.md) |
| **Volume II** — trades, Feather, home lab | [Expansao-Curso/](Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md) · [Playbooks-Rede-Descentralizada.md](Expansao-Curso/Playbooks-Rede-Descentralizada.md) |
| **Folheto** (1 página) | [Folheto-Regras-e-Golpes.md](Folheto-Regras-e-Golpes.md) |
| **Scripts** | [Scripts/](Scripts/README.md) · [Home Lab](Scripts/HomeLab/README.md) |

## Estrutura

```text
Tails-OS-Expert/
├── Curso-Tails-OS-Expert.md      ← Volume I (livro)
├── Folheto-Regras-e-Golpes.md    ← 1 página imprimível
├── Playbooks/
│   └── Playbooks.md                ← Volume I (só comandos)
├── Expansao-Curso/                 ← Volume II
│   ├── Curso-Rede-Descentralizada-Extensao.md
│   ├── Multisig-2-de-3-criacao-manual-CLI.md   ← anexo (educacional)
│   ├── Playbooks-Rede-Descentralizada.md
│   └── Playbooks-Multisig-CLI.md
├── Scripts/                        ← Automação Tails + HomeLab/
└── imagens/                        ← Cartazes e figuras
```

## 🧭 Trilha do aluno — siga nesta ordem

> **Regra:** livro (teoria) + Playbook (comandos) **em paralelo** no mesmo passo. Não pule o Volume I antes do II.

| Passo | O que fazer | Abrir |
|:-----:|-------------|-------|
| **1** | Pendrive → Tails → Haveno **verde** | 📖 [Curso-Tails-OS-Expert.md](Curso-Tails-OS-Expert.md) · ⚡ [Playbooks/Playbooks.md](Playbooks/Playbooks.md) |
| **2** | Seed, Feather, trades, home lab | 📖 [Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md](Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md) · ⚡ [Playbooks-Rede-Descentralizada.md](Expansao-Curso/Playbooks-Rede-Descentralizada.md) |
| **3** | Imprimir regras de ouro + golpes | 🖨️ [Folheto-Regras-e-Golpes.md](Folheto-Regras-e-Golpes.md) |
| **4** | Automação pós-verde (`auto` / `backup` / `update`) | 🔧 [Scripts/README.md](Scripts/README.md) |
| *Opc.* | Nó + mineração no home lab (Debian/Ubuntu) | 🏠 [Scripts/HomeLab/README.md](Scripts/HomeLab/README.md) |

**Objetivo Volume I:** pendrive → Tails → Haveno **verde**.  
**Objetivo Volume II:** seed, Feather, trades, home lab, ecossistema.

> **Próximo passo recomendado:** [Módulo 2 — Whonix Online](../Whonix-Online/README.md) — lado **online persistente** + custódia **frio↔quente** (a seed nunca toca a rede). Requer Volume I + II concluídos (Haveno verde + Feather no Tails).

---

*Revisão: jun/2026 · Tails **7.8.1+** · RetoSwap `1.6.0-reto`*
