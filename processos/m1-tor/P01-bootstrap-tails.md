---
passo_hub: 1
trilha: m1-tor
rede: tails_online_tor
scripts: [tails-preflight.sh]
livro: modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#2-fundamentos-do-tails
---

# P01 — Bootstrap Tails (USB · Tor · persistência · admin)

**Cartão trilha:** [trilha/passos/passo-01.md](../../trilha/passos/passo-01.md)

## Playbook canônico (comandos completos)

| Bloco | Seção |
|-------|--------|
| Gravar USB | [Playbooks §1](../../modulos/m1-tails-haveno/Playbooks/Playbooks.md) |
| Tor | [Playbooks §2](../../modulos/m1-tails-haveno/Playbooks/Playbooks.md) |
| Persistência + Dotfiles | [Playbooks §3](../../modulos/m1-tails-haveno/Playbooks/Playbooks.md) |
| Senha admin | [Playbooks §4](../../modulos/m1-tails-haveno/Playbooks/Playbooks.md) |

## Validação

```bash
~/Persistent/tails-preflight.sh --qa-log
```

Log: `~/Persistent/qa-logs/01-preflight-*.txt` → [COMO-LER](../../automacao/docs-aluno/COMO-LER-SEUS-LOGS.md)

## OK se

- Tor `IsTor: true` · persistência · Dotfiles · admin OK
