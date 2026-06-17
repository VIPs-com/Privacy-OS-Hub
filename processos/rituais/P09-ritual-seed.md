---
passo_hub: 9
trilha: ritual
rede: tails_online_tor
scripts: [qa-confirm-passo9.sh]
livro: modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix
playbook_legacy: modulos/m2-whonix-custodia/Playbook-Backup-e-protecao-air-gap.md
---

# P09 — Ritual 2× cópias físicas da seed

**Cartão:** [passo-09](../../trilha/passos/passo-09.md)

> Tails **com Tor** OK — não é air-gap de rede. Confirma o ritual físico do passo 4.

---

## Checklist (antes de mover valor relevante)

- [ ] **DUAS cópias offline** da seed (papel/metal, **locais separados**)
- [ ] **Teste de restauração** numa sessão Tails offline (opcional avançado)
- [ ] **Restore height** anotado na criação da carteira
- [ ] Pendrive **dedicado** ao trânsito frio↔quente (rotulado)

### Seed em papel (obrigatório)

```text
# Ao criar a conta (Módulo 1) — Tails COM Tor ativo:
# Account → Wallet seed → anote as 25 palavras em papel/metal.
# NUNCA foto, nuvem ou e-mail.
# Faça a 2ª cópia em outro local físico.
```

Teoria completa: [Playbook backup air-gap](../../modulos/m2-whonix-custodia/Playbook-Backup-e-protecao-air-gap.md)

---

## Confirmação (script)

```bash
~/Persistent/hub-scripts/qa-confirm-passo9.sh
```

**OK se:** `09-seed-confirmacao-*.txt` → 3× SIM · duas cópias em locais separados.
