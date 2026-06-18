# Passo 7 — Automação pós-verde

| Campo | Valor |
|-------|-------|
| **Modo** | M1 · scripts |
| **Rede** | Online (Tor) |
| **Ferramenta** | `haveno-setup.sh --boot` |
| **Scripts** | `haveno-setup.sh --boot --qa-log` · `post-session-check.sh --qa-log` |
| **Log esperado** | logs de boot/sessão em `qa-logs/` |
| **Não confundir com** | Passo 2 (1ª instalação) — aqui é **cada sessão** |

---

## OK se

- [ ] Scripts em `~/Persistent/` com `chmod +x`
- [ ] `--boot` deixa Haveno verde a cada login
- [ ] Sabe quando rodar backup/update (manual scripts)

---

## Links

| Tipo | Link |
|------|------|
| Livro | [Scripts — ciclo de uso](../../automacao/tails/README.md) |
| Processo | [P07](../../processos/m1-tor/P07-rotina-scripts.md) |
| Comandos | [P07](../../processos/m1-tor/P07-rotina-scripts.md) |
| Manual | [MANUAL-SCRIPTS.md](../../meta/MANUAL-SCRIPTS.md) |
| Diagrama | [FIG-1](../mapa-modos/diagrama-mestre.md) |
| Matriz | [scripts-matriz.md](../referencia/scripts-matriz.md) |

**Anterior:** [passo-06.md](passo-06.md) · **Próximo:** [passo-08.md](passo-08.md)
