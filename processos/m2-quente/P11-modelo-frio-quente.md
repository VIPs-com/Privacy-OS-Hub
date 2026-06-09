---
passo_hub: 11
trilha: m2-quente
rede: leitura
scripts: []
livro: modulos/m2-whonix-custodia/Curso-Whonix-Online.md#51-por-que-separar-o-princípio
---

# P11 — Modelo frio ↔ quente

**Cartão:** [passo-11](../../trilha/passos/passo-11.md)

## Livro canônico

[Curso Whonix §5.1 — Por que separar (o princípio)](../../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#51-por-que-separar-o-princípio)

## OK se (responda sem olhar — antes do passo 12)

- **Quente vê · frio assina:** o Whonix (quente) é **view-only**; a **spend key** nunca sai do Tails (frio).
- **O Whonix assina a transação?** → **Não.** Ele monta e transmite; quem **assina** é o Tails offline (passo 12).
- **O que viaja no pendrive USB entre quente e frio?** → o **unsigned tx** (quente → frio) e o **signed tx** (frio → quente). **Nunca** a seed nem a spend key.
- **Por que isso protege?** → mesmo que a máquina online (quente) seja comprometida, sem a spend key ela **não gasta** seus fundos.
