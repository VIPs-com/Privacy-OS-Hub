---
passo_hub: 4
trilha: m1-tor
rede: tails_online_tor
scripts: [haveno-backup.sh, qa-confirm-seed-papel.sh]
livro: modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#5-próximos-passos-pós-verde
playbook_legacy: modulos/m1-tails-haveno/Playbooks/Playbooks.md
---

# P04 — Backup · seed em papel

**Cartão:** [passo-04](../../trilha/passos/passo-04.md) · **Livro:** [Cap. 5](../../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#5-próximos-passos-pós-verde)

```bash
# Feche o Haveno antes do backup (menu ou sair do app)
~/Persistent/haveno-backup.sh           # cifrado, em ~/Persistent/Backups
~/Persistent/haveno-backup.sh --usb     # em um USB montado
~/Persistent/haveno-backup.sh --restore CAMINHO/arquivo.tar.gz.gpg
```

Com validação de log:

```bash
~/Persistent/haveno-backup.sh --qa-log
~/Persistent/qa-confirm-seed-papel.sh
```

**OK se:** `04-haveno-backup-*.txt` → PASS · `04-seed-papel-*.txt` → 3× SIM · seed em **papel** (nunca só no PC).
