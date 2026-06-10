# Passo 11 — Teoria frio↔quente (view-only)

| Campo | Valor |
|-------|-------|
| **Modo** | M2 quente · teoria |
| **Rede** | Leitura (Whonix online depois) |
| **Ferramenta** | Modelo de ameaças |
| **Scripts** | — |
| **Log esperado** | — |
| **Não confundir com** | Passo 12 (prática air-gap) |

---

## OK se (responda sem olhar — antes do passo 12)

- [ ] **Quente vê · frio assina:** Whonix (quente) é view-only; **spend key** nunca sai do Tails (frio)
- [ ] O Whonix **assina** a transação? → **Não** — quem assina é o Tails offline (passo 12)
- [ ] O que viaja no USB entre quente e frio? → **unsigned tx** (quente→frio) e **signed tx** (frio→quente); **nunca** seed nem spend key
- [ ] Sabe por que nó remoto `.onion` é alternativa (Cap. 4.2)

---

## Links

| Tipo | Link |
|------|------|
| Livro | [Curso Whonix — §5.1](../../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#51-por-que-separar-o-princípio) |
| Processo | [P11](../../processos/m2-quente/P11-modelo-frio-quente.md) |
| Comandos | [P11](../../processos/m2-quente/P11-modelo-frio-quente.md) |
| Diagrama | [FIG-1](../mapa-modos/diagrama-mestre.md) · [FIG-3 preview](../mapa-modos/diagrama-mestre.md#fig-3-usb-frio-quente) (USB no passo 12) |

**Anterior:** [passo-10.md](passo-10.md) · **Próximo:** [passo-12.md](passo-12.md)
