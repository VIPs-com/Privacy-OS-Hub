---
passo_hub: 7
trilha: m1-tor
rede: tails_online_tor
scripts: [haveno-setup.sh, post-session-check.sh, haveno-backup.sh, haveno-update.sh]
livro: automacao/tails/README.md
---

# P07 — Rotina scripts (cada sessão)

**Cartão:** [passo-07](../../trilha/passos/passo-07.md)

## Playbook canônico

- [Playbooks §7 — Cada boot](../../modulos/m1-tails-haveno/Playbooks/Playbooks.md)
- [Playbooks §9 — Backup](../../modulos/m1-tails-haveno/Playbooks/Playbooks.md)
- [Playbooks §10 — Atualizar](../../modulos/m1-tails-haveno/Playbooks/Playbooks.md)

## Comandos

```bash
~/Persistent/haveno-setup.sh --boot --qa-log
~/Persistent/post-session-check.sh --qa-log
```

## OK se

- Haveno verde a cada boot
- Sabe quando rodar backup/update
