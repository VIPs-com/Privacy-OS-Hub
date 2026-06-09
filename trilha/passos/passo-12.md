# Passo 12 — Cold-signing (Trilha A ou B)

| Campo | Valor |
|-------|-------|
| **Modo** | M2 frio · **único offline de rede obrigatório** |
| **Rede** | Tails **sem** Wi‑Fi/cabo (air-gap real) |
| **Ferramenta** | **A:** Feather GUI · **B:** `monero-wallet-cli` |
| **Scripts** | `qa-confirm-passo12.sh` (após assinar) |
| **Log esperado** | `12-cold-signing-*.txt` → `tails_offline_airgap=SIM` + confirmações SIM |
| **Não confundir com** | Passo 9 (Tor OK) · Passo 4 (seed em papel com Tor) · Whonix quente (passo 10–11) |

---

## Escolha UMA trilha (passo 8)

| Trilha | Playbook | Cartão trilha |
|--------|----------|---------------|
| **A** (recomendada) | [Feather GUI](../../modulos/m2-whonix-custodia/Trilha-A-Feather/Playbook-Feather-GUI.md) | [m2-tails-frio-feather-a.md](../trilhas/m2-tails-frio-feather-a.md) |
| **B** | [monero-wallet-cli](../../modulos/m2-whonix-custodia/Trilha-B-CLI/Playbook-monero-wallet-cli.md) | [m2-tails-frio-cli-b.md](../trilhas/m2-tails-frio-cli-b.md) |

---

## OK se

- [ ] Tails bootou **sem** rede antes de abrir carteira
- [ ] Transação assinada offline
- [ ] Whonix quente montou/transmitiu (conforme playbook)
- [ ] `qa-confirm-passo12.sh` sem `=NAO`

---

## Links

| Tipo | Link |
|------|------|
| Livro | [Curso Whonix — §5.5](../../modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix) |
| Processo | [P12A](../../processos/m2-frio/P12a-feather-offline.md) · [P12B](../../processos/m2-frio/P12b-cli-offline.md) |
| Glossário | [air-gap](../mapa-modos/glossario.md) |
| Como ler logs | [COMO-LER-SEUS-LOGS.md](../../automacao/docs-aluno/COMO-LER-SEUS-LOGS.md) |

**Anterior:** [passo-11.md](passo-11.md) · **Fim da trilha 1–12**
