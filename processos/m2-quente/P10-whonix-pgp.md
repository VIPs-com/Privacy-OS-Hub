---
passo_hub: 10
trilha: m2-quente
rede: host_linux
scripts: [whonix-verify-image.sh]
livro: modulos/m2-whonix-custodia/Instalar-Whonix-passo-a-passo-por-SO.md
---

# P10 — Whonix PGP + import VMs

**Cartão:** [passo-10](../../trilha/passos/passo-10.md)

## Playbook canônico

- [Playbooks M2 §1](../../modulos/m2-whonix-custodia/Playbooks/Playbooks.md)
- Detalhe por SO: [Instalar por SO](../../modulos/m2-whonix-custodia/Instalar-Whonix-passo-a-passo-por-SO.md)

## Comando (host)

```bash
./whonix-verify-image.sh --qa-log Whonix-*.ova Whonix-*.ova.asc
```

## OK se

- `Good signature` / Assinatura válida
- Gateway + Workstation importadas
