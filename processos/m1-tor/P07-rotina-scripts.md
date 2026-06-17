---
passo_hub: 7
trilha: m1-tor
rede: tails_online_tor
scripts: [haveno-setup.sh, post-session-check.sh, haveno-backup.sh, haveno-update.sh]
livro: automacao/tails/README.md
playbook_legacy: modulos/m1-tails-haveno/Playbooks/Playbooks.md
---

# P07 — Rotina scripts (cada sessão)

**Cartão:** [passo-07](../../trilha/passos/passo-07.md) · **Manual:** [automacao/tails](../../automacao/tails/README.md)

---

## 7 — Cada boot

```text
# Indicador amarelo 5–20 min na 1ª vez após instalar é normal (sincronização P2P/Monero).
# USB -> persistência -> + Mais opções (admin) -> Tor -> Aplicações -> Outros -> Haveno
```

```bash
# Automatizado (recomendado):
~/Persistent/hub-scripts/haveno-setup.sh --boot --qa-log
# ou: ~/Persistent/hub-scripts/haveno-boot.sh
```

Manual:

```bash
sudo /home/amnesia/Persistent/haveno/App/utils/install.sh
/home/amnesia/Persistent/haveno/App/utils/exec.sh
```

```bash
~/Persistent/hub-scripts/post-session-check.sh --qa-log
```

**OK se:** Haveno abre e fica verde. Dados: `/home/amnesia/Persistent/haveno/Data/`

---

## 10 — Atualizar (backup antes)

```bash
~/Persistent/hub-scripts/haveno-update.sh \
  --url "https://github.com/retoaccess1/haveno-reto/releases/download/VERSAO-NOVA/haveno-vVERSAO-linux-x86_64-installer.deb" \
  --pgp "FINGERPRINT_DA_MESMA_REDE"
```

Tails (sistema): atualize pelo Tails Upgrader, **não** por script. Backup primeiro.
