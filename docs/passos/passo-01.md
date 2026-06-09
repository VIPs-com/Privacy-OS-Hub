# Passo 1 — Gravar Tails + Tor + persistência

| Campo | Valor |
|-------|-------|
| **Modo** | M1 · Tails + Haveno |
| **Rede** | Online (Tor) |
| **Ferramenta** | Tails USB · Tor Browser |
| **Scripts** | `tails-preflight.sh --qa-log` (validação, **não** grava USB) |
| **Log esperado** | `~/Persistent/qa-logs/01-preflight-*.txt` → `RESULTADO: PASS` |
| **Não confundir com** | Passo 12 (Tails **sem** rede) |

---

## OK se

- [ ] Tails boota do pendrive
- [ ] Tor conecta (`IsTor: true` no preflight)
- [ ] Persistência ativa + admin password definida

---

## Links

| Tipo | Link |
|------|------|
| Livro | [Curso Vol I — Cap. 2](../../Tails-OS-Expert/Curso-Tails-OS-Expert.md#2-fundamentos-do-tails) |
| Comandos | [Playbooks §1–4](../../Tails-OS-Expert/Playbooks/Playbooks.md) |
| Glossário | [online vs offline](../mapa-modos/glossario.md) |

**Anterior:** — · **Próximo:** [passo-02.md](passo-02.md)
