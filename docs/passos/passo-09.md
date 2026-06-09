# Passo 9 — Confirmar 2× cópias físicas da seed

| Campo | Valor |
|-------|-------|
| **Modo** | Ritual operacional |
| **Rede** | Online (Tor) **OK** — não é air-gap |
| **Ferramenta** | Papel/metal · locais separados |
| **Scripts** | `qa-confirm-passo9.sh` |
| **Log esperado** | `09-seed-confirmacao-*.txt` → 3× `CONFIRMACAO_HUMANA=SIM` |
| **Não confundir com** | Passo 4 (anotar seed) · Passo 12 (Tails sem rede) · 2º boot offline (**não** exigido no Mínimo M2) |

---

## OK se

- [ ] Duas cópias físicas da seed (do passo 4/5) em **locais diferentes**
- [ ] Ritual de confirmação humano concluído
- [ ] Log sem nenhum `=NAO`

> Este passo **não** pede gerar seed de novo nem desligar a rede.

---

## Links

| Tipo | Link |
|------|------|
| Livro | [Curso Whonix — Cap. 5](../../Whonix-Online/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) |
| Comandos | [qa-confirm-passo9.sh](../../Tails-OS-Expert/Scripts/qa-confirm-passo9.sh) · [Playbook backup](../../Whonix-Online/Playbook-Backup-e-protecao-air-gap.md) |
| Trilha | [ritual-seed-passo-9.md](../trilhas/ritual-seed-passo-9.md) |

**Anterior:** [passo-08.md](passo-08.md) · **Próximo:** [passo-10.md](passo-10.md)
