---
passo_hub: 4
trilha: m1-tor
rede: tails_online_tor
scripts: [haveno-backup.sh, qa-confirm-seed-papel.sh]
livro: modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#5-próximos-passos-pós-verde
---

# P04 — Backup · seed em papel

**Cartão:** [passo-04](../../trilha/passos/passo-04.md)

## Playbook canônico

[Playbooks §9 — Backup](../../modulos/m1-tails-haveno/Playbooks/Playbooks.md)

## Comandos

```bash
~/Persistent/haveno-backup.sh --qa-log
~/Persistent/qa-confirm-seed-papel.sh
```

## OK se

- `04-haveno-backup-*.txt` → PASS
- `04-seed-papel-*.txt` → 3× SIM
- Seed em **papel** (nunca só no PC)
