---
passo_hub: 2
trilha: m1-tor
rede: tails_online_tor
scripts: [haveno-setup.sh]
livro: modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#3-instalação-e-configuração-do-haveno-na-mão
---

# P02 — Haveno até o verde

**Cartão:** [passo-02](../../trilha/passos/passo-02.md)

## Playbook canônico

- [Playbooks §5 — Instalar](../../modulos/m1-tails-haveno/Playbooks/Playbooks.md)
- [Playbooks §6 — Abrir verde](../../modulos/m1-tails-haveno/Playbooks/Playbooks.md)
- Travou? [Playbooks §8](../../modulos/m1-tails-haveno/Playbooks/Playbooks.md)

## Comando

```bash
~/Persistent/haveno-setup.sh --qa-log
```

## OK se

- Indicador **verde** na janela Haveno
- Log: `loaded filter: haveno` · sem `ERRO:`
