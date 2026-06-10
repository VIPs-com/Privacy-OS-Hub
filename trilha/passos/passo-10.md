# Passo 10 — Instalar e verificar Whonix (PGP)

| Campo | Valor |
|-------|-------|
| **Modo** | M2 quente · **no SEU PC host** (Linux/Windows/macOS) — **não no Tails** |
| **Rede** | Tor via Gateway (após import) |
| **Ferramenta** | KVM/QEMU · imagens Whonix |
| **Scripts** | `whonix-verify-image.sh --qa-log` (no **host**, não no Tails) |
| **Log esperado** | `~/whonix-download/qa-logs/*.txt` |
| **Não confundir com** | Passo 12 (Tails frio) · Tails não roda VMs Whonix |

---

## OK se

- [ ] Imagem baixada + PGP `Assinatura válida`
- [ ] Gateway + Workstation importadas
- [ ] VMs bootam

---

## Links

| Tipo | Link |
|------|------|
| Livro | [Instalar por SO](../../modulos/m2-whonix-custodia/Instalar-Whonix-passo-a-passo-por-SO.md) |
| Processo | [P10](../../processos/m2-quente/P10-whonix-pgp.md) |
| Comandos | [P10](../../processos/m2-quente/P10-whonix-pgp.md) |
| Diagrama | [FIG-1](../mapa-modos/diagrama-mestre.md) |
| Trilha | [m2-whonix-quente.md](../trilhas/m2-whonix-quente.md) |
| Prints | [manifesto Whonix](../../modulos/m2-whonix-custodia/imagens/screenshots-whonix/README.md) — **2/5** no repo; passos textuais bastam |

**Anterior:** [passo-09.md](passo-09.md) · **Próximo:** [passo-11.md](passo-11.md)
