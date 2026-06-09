---
passo_hub: 12
trilha: m2-frio-a
rede: tails_air_gap
scripts: [qa-confirm-passo12.sh]
livro: modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix
---

# P12A — Cold-signing · Feather GUI

**Cartão:** [passo-12](../../trilha/passos/passo-12.md) · **Trilha A** (recomendada)

## Playbook canônico

[Trilha A — Feather GUI](../../modulos/m2-whonix-custodia/Trilha-A-Feather/Playbook-Feather-GUI.md)

## Após assinar offline

```bash
~/Persistent/qa-confirm-passo12.sh
```

## OK se

- Tails **sem** rede antes de abrir carteira
- `12-cold-signing-*.txt` → `tails_offline_airgap=SIM`
