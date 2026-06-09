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
| Livro | [Scripts — ciclo de uso](../../Tails-OS-Expert/Scripts/README.md) |
| Comandos | [haveno-setup.sh](../../Tails-OS-Expert/Scripts/haveno-setup.sh) |
| Manual | [MANUAL-SCRIPTS.md](../../MANUAL-SCRIPTS.md) |
| Matriz | [scripts-matriz.md](../referencia/scripts-matriz.md) |

**Anterior:** [passo-06.md](passo-06.md) · **Próximo:** [passo-08.md](passo-08.md)
