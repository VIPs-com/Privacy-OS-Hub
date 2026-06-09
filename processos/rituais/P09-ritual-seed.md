---
passo_hub: 9
trilha: ritual
rede: tails_online_tor
scripts: [qa-confirm-passo9.sh]
livro: modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix
---

# P09 — Ritual 2× cópias físicas da seed

**Cartão:** [passo-09](../../trilha/passos/passo-09.md)

## Playbook canônico

[Playbook backup air-gap](../../modulos/m2-whonix-custodia/Playbook-Backup-e-protecao-air-gap.md)

> Tails **com Tor** OK — não é air-gap de rede.

## Comando

```bash
~/Persistent/qa-confirm-passo9.sh
```

## OK se

- `09-seed-confirmacao-*.txt` → 3× SIM
- Duas cópias em locais separados
