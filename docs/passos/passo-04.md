# Passo 4 — Carteira, backup, seed em papel

| Campo | Valor |
|-------|-------|
| **Modo** | M1 · Tails + Haveno |
| **Rede** | Online (Tor) — **OK** anotar seed com Tor ativo |
| **Ferramenta** | Haveno carteira · backup cifrado |
| **Scripts** | `haveno-backup.sh --qa-log` · `qa-confirm-seed-papel.sh` |
| **Log esperado** | `04-haveno-backup-*.txt` (PASS) · `04-seed-papel-*.txt` (3× SIM) |
| **Não confundir com** | Passo 9 (2× **locais** físicos) · Passo 12 (air-gap de **rede**) |

---

## OK se

- [ ] Backup cifrado de `Data/` feito
- [ ] Seed anotada em **papel** (nunca foto/chat/nuvem)
- [ ] Ritual `qa-confirm-seed-papel.sh` concluído

> **Offline (suporte)** = papel/metal. **Não** precisa desligar Wi‑Fi para anotar a seed.

---

## Links

| Tipo | Link |
|------|------|
| Livro | [Curso Vol I — Cap. 5](../../Tails-OS-Expert/Curso-Tails-OS-Expert.md#5-próximos-passos-pós-verde) |
| Comandos | [Playbooks §9](../../Tails-OS-Expert/Playbooks/Playbooks.md#9--backup-pós-verde) |
| Glossário | [offline suporte vs air-gap](../mapa-modos/glossario.md) |
| Como ler logs | [COMO-LER-SEUS-LOGS.md](../../Tails-OS-Expert/Scripts/COMO-LER-SEUS-LOGS.md) |

**Anterior:** [passo-03.md](passo-03.md) · **Próximo:** [passo-05.md](passo-05.md)
