---
passo_hub: 2
trilha: m1-tor
rede: tails_online_tor
scripts: [haveno-setup.sh, haveno-auto.sh]
livro: modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#3-instalação-e-configuração-do-haveno-na-mão
playbook_legacy: modulos/m1-tails-haveno/Playbooks/Playbooks.md
---

# P02 — Haveno até o verde

**Cartão:** [passo-02](../../trilha/passos/passo-02.md) · **Livro:** [Cap. 3](../../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#3-instalação-e-configuração-do-haveno-na-mão)

> Segurança: exploit de trades (20/05/2026) **corrigido** na `1.6.0-reto`. Instalar: ok. Tradear: Cap. 4 do livro.

**Antes de automatizar:** instale os scripts uma vez (`sync-hub-scripts.sh` → `~/Persistent/hub-scripts/`) ([automacao/tails](../../automacao/tails/README.md) → "Ciclo de uso"). Guia curto: [3 passos (ZIP → 1ª vez → reiniciar)](../../automacao/docs-aluno/TRES-PASSOS-HAVENO-TAILS.md). O `haveno-setup.sh` também **sincroniza** scripts mais novos do ZIP (ou rode `./sync-hub-scripts.sh` manualmente).

```bash
# Recomendado (depois do passo 4): preflight -> install -> verde -> backup?
~/Persistent/hub-scripts/haveno-setup.sh --qa-log

# Retomar instalacao parcial (.deb ja em Install/, falhou em [7/9]):
~/Persistent/hub-scripts/haveno-setup.sh --install-only --qa-log

# Avancado (equivalente, sem orquestrador):
~/Persistent/hub-scripts/haveno-auto.sh --qa-log
```

Ou siga manual abaixo.

---

## 5 — Instalar Haveno (download + PGP)

### 5A — Rede Reto (turma — pronto)

```bash
curl -fsSLO https://github.com/haveno-dex/haveno/raw/master/scripts/install_tails/haveno-install.sh \
  && bash haveno-install.sh \
  "https://github.com/retoaccess1/haveno-reto/releases/download/1.6.0-reto/haveno-v1.6.0-linux-x86_64-installer.deb" \
  "DAA24D878B8D36C90120A897CA02DAC12DAE2D0F"
```

PGP Reto: https://retoswap.com/reto_public.asc — release novo: troque só a URL do `.deb`.

### 5B — Outra rede (URL + PGP do mesmo release)

```bash
curl -fsSLO https://github.com/haveno-dex/haveno/raw/master/scripts/install_tails/haveno-install.sh \
  && bash haveno-install.sh "COLE_URL_DO_DEB" "COLE_FINGERPRINT_PGP"
```

### Se o curl falhar (baixar via Tor)

```bash
curl -x socks5h://127.0.0.1:9050 -fsSLO https://github.com/haveno-dex/haveno/raw/master/scripts/install_tails/haveno-install.sh
bash haveno-install.sh "SUA_URL.deb" "SEU_PGP"
```

### Verificar

```bash
ls ~/Persistent/haveno/
ls ~/Persistent/haveno/Install/
ls ~/Persistent/haveno/App/utils/
```

**OK se:** "Haveno installation setup completed successfully." · pastas App Data Install · `haveno.deb` em Install/ · ícone em Aplicações → Outros.

---

## 6 — Abrir e ficar verde

```text
# Aplicações -> Outros -> Haveno -> senha admin -> aguardar (amarelo 5–20 min na 1ª vez é normal)
```

```bash
sudo journalctl -u onion-grater --no-pager | tail -20
```

**OK se:** indicador verde · log `loaded filter: haveno` · sem pop-up "No default Tor Instance configured".

---

## 8 — Se NÃO ficou verde

```text
# Pop-up "No default Tor Instance configured" ou log "loaded filter: None" / "AUTHCHALLENGE" / "bad YAML"
# Feche o Haveno antes.
```

```bash
sudo cp /home/amnesia/Persistent/haveno/App/utils/haveno.yml /etc/onion-grater.d/haveno.yml
sudo chmod o+r /var/run/tor/control.authcookie
python3 -c "import yaml; yaml.safe_load(open('/etc/onion-grater.d/haveno.yml')); print('YAML OK')"
sudo systemctl restart onion-grater
```

**OK se:** imprime `YAML OK` · reabrir pelo menu → verde · log `loaded filter: haveno`. Mais sintomas: Cap. 7 (FAQ) do livro.
