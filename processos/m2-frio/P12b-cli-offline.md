---
passo_hub: 12
trilha: m2-frio-b
rede: tails_air_gap
scripts: [qa-confirm-passo12.sh]
livro: modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix
playbook_legacy: modulos/m2-whonix-custodia/Trilha-B-CLI/Playbook-monero-wallet-cli.md
---

# P12B — Cold-signing · monero-wallet-cli

**Cartão:** [passo-12](../../trilha/passos/passo-12.md) · **Trilha B** (avançada)

> Siga **só** este processo — **não** misture com Trilha A ([P12A](P12a-feather-offline.md)). Quer mais simples? Use P12A.

**Pré-requisito:** [P08](../porteiro/P08-porteiro-trilha-ab.md) · [P10](../m2-quente/P10-whonix-pgp.md).

> Comandos abaixo na **Workstation Whonix** (quente), exceto assinatura no **Tails offline** (frio).

---

## Mapa do fluxo

```text
  TAILS offline (FRIO)                          WHONIX online (QUENTE)
  carteira COMPLETA                             carteira VIEW-ONLY
        │◄──── (1) export_outputs ──────────────│
        │───── (2) export_key_images ──────────►│
        │◄──── (3) unsigned_monero_tx ──────────│  transfer
        │───── (4) signed_monero_tx ───────────►│  submit_transfer
```

---

## B1 — Criar view-only (Whonix)

```bash
monero-wallet-cli --generate-from-view-key NOME-VIEW \
  --daemon-address SEU_NO.onion:18089
```

```bash
set refresh-from-block-height N
```

**OK se:** view-only mostra o mesmo saldo da fria.

---

## B2 — Sincronizar (repita após CADA envio)

```bash
# QUENTE (view-only):
export_outputs outputs_file
```

```bash
# FRIO (Tails offline):
import_outputs outputs_file
export_key_images ki_file
```

```bash
# QUENTE:
import_key_images ki_file
```

---

## B3 — Gastar

```bash
# QUENTE:
transfer ENDERECO VALOR
```

```bash
# FRIO:
sign_transfer
```

```bash
# QUENTE:
submit_transfer
```

> Confira destino/valor na máquina **FRIA** antes de assinar.

---

## Após assinar offline

```bash
~/Persistent/qa-confirm-passo12.sh
```

**OK se:** mesmo critério que [P12A](P12a-feather-offline.md) — air-gap real.

**Fontes:** [Monero cold signing](https://docs.getmonero.org/cold-storage/offline-transaction-signing/) · playbook completo: [Trilha B](../../modulos/m2-whonix-custodia/Trilha-B-CLI/Playbook-monero-wallet-cli.md)
