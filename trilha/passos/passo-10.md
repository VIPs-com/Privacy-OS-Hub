# Passo 10 — Instalar e verificar Whonix (PGP)

| Campo | Valor |
|-------|-------|
| **Modo** | M2 quente · host Linux |
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
| Comandos | [whonix-verify-image.sh](../../automacao/whonix-host/whonix-verify-image.sh) · [Playbooks M2](../../modulos/m2-whonix-custodia/Playbooks/Playbooks.md) |
| Trilha | [m2-whonix-quente.md](../trilhas/m2-whonix-quente.md) |

**Anterior:** [passo-09.md](passo-09.md) · **Próximo:** [passo-11.md](passo-11.md)
