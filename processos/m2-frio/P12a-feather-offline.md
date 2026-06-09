---
passo_hub: 12
trilha: m2-frio-a
rede: tails_air_gap
scripts: [qa-confirm-passo12.sh]
livro: modulos/m2-whonix-custodia/Curso-Whonix-Online.md#5-cold-tails-hot-whonix
playbook_legacy: modulos/m2-whonix-custodia/Trilha-A-Feather/Playbook-Feather-GUI.md
---

# P12A — Cold-signing · Feather GUI

**Cartão:** [passo-12](../../trilha/passos/passo-12.md) · **Trilha A** (recomendada)

> Siga **só** este processo — **não** misture com Trilha B ([P12B](P12b-cli-offline.md)).

**Pré-requisito:** [P08](../porteiro/P08-porteiro-trilha-ab.md) · [P10](../m2-quente/P10-whonix-pgp.md) · Feather completo no Tails ([P05](../m1-tor/P05-feather.md)).

> **Regra inegociável:** seed / spend key **só no Tails offline**. Whonix é **view-only** — nunca assina.

---

## Mapa do fluxo (USB, nunca rede)

```text
  TAILS offline (FRIO)                          WHONIX online (QUENTE)
  Feather COMPLETO                              Feather VIEW-ONLY
        │  (0) address + viewkey + restore height ───────►│  cria view-only
        │◄──── (1) outputs ───────────────────────────────│  exporta outputs
        │───── (2) key images ───────────────────────────►│  importa key images
        │◄──── (3) transação NÃO-ASSINADA ────────────────│  monta a tx
        │───── (4) transação ASSINADA ───────────────────►│  transmite
   ASSINA offline                                    BROADCAST via Tor/seu nó
```

---

## A — Whonix pronto

```text
# Lado FRIO: boot OFFLINE (desconecte Wi-Fi/cabo ANTES de ligar o Tails).
# Só então abra Feather com carteira COMPLETA.
# Imagem Whonix verificada + Gateway/Workstation atualizados.
# Feather PGP: 8185E158…CEFBA71C
```

**OK se:** Workstation só via Gateway; Feather sincroniza via Tor.

---

## A1 — Criar view-only no Whonix

Na carteira **FRIA** (Feather/Tails), anote:

- Endereço primário (`4…`)
- Secret **VIEW** key (nunca spend key/seed)
- Restore height

No Whonix (Feather): **Create new wallet → View only** → cole os três → **Always over Tor** → nó `.onion:18089`.

**OK se:** view-only mostra o **mesmo** saldo da fria.

---

## A2 — Sincronizar (1º envio e quando saldo parecer velho)

> Menus variam por versão — confirme na [doc oficial](https://docs.featherwallet.org/guides/offline-tx-signing).

```text
# (Quente) view-only -> Export outputs -> USB
# (Frio)   completa -> Import outputs -> Export key images -> USB
# (Quente) import key images
```

---

## A3 — Gastar (montar quente · assinar frio · transmitir quente)

```text
# (Quente) Send -> Export unsigned transaction -> USB
# (Frio)   importe -> CONFIRA destino e valor NA TELA FRIA -> Sign -> USB
# (Quente) import signed -> broadcast
```

> A máquina **FRIA** é fonte de verdade — confira endereço antes de assinar.

---

## Regras de ouro

- Teste com **valor mínimo** antes do grosso.
- **DUAS** cópias seed offline + pasta cifrada ([P04](../m1-tor/P04-backup-seed.md)).
- Re-sync key images **após cada envio** (troco).
- Spend key/seed **nunca** em máquina online.

---

## Após assinar offline

```bash
~/Persistent/qa-confirm-passo12.sh
```

**OK se:** Tails **sem** rede antes de abrir carteira · `12-cold-signing-*.txt` → `tails_offline_airgap=SIM`.

**Fontes:** [Feather offline signing](https://docs.featherwallet.org/guides/offline-tx-signing) · [Whonix Monero](https://www.whonix.org/wiki/Monero)
