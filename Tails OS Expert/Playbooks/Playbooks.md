# Playbooks — Tails OS Expert (só comandos)

Direto ao ponto. Fundamentos e telas: no livro [`../Curso — Tails OS Expert.md`](../Curso%20—%20Tails%20OS%20Expert.md). Automação: pasta [`../Scripts/`](../Scripts/README.md).

**Ordem obrigatória.** Tails **7.8.1+** (7.8.1 = atualização emergencial de segurança, jun/2026). Rede da turma: **Reto `1.6.0-reto`**.

> Segurança: exploit de trades (20/05/2026) **corrigido** na `1.6.0-reto`. Instalar: ok. Tradear: use a versão corrigida, confirme retomada nos canais oficiais, comece pequeno. (Cap. 4 do livro.)

---

## Manual ou automático?

Passos **1–4** são sempre manuais. Do **5** em diante:

```bash
# Automático (depois do passo 4): instala -> abre -> corrige -> verde
# (instale os scripts antes: ver ../Scripts/README.md)
~/Persistent/haveno-auto.sh
```

Ou siga manual abaixo.

---

## 1 — Tails no pendrive (outro PC)

# Baixe só em tails.net (pendrive 8 GB+ será apagado): https://tails.net/install/index.en.html
# Tails Installer -> Instalar no USB -> Boot F12/F11/Esc -> USB -> Tails

# OK se: tela "Bem-vindo ao Tails".

---

## 2 — Primeiro boot + Tor

# Boas-vindas -> Iniciar Tails -> Conexão à rede Tor -> conectado

```bash
curl -s --max-time 30 https://check.torproject.org/api/ip | grep IsTor
```

# OK se: aparece `"IsTor":true` e o Navegador Tor abre.

---

## 3 — Persistência (com Dotfiles)

# Aplicações -> Tails -> Armazenamento persistente -> Criar
# Marque: Arquivos pessoais + Dotfiles -> Salvar -> Reiniciar
# Após reboot: senha da persistência -> Tor de novo

```bash
ls /home/amnesia/Persistent
```

# OK se: pasta Persistent existe e não está vazia.

---

## 4 — Senha admin (toda sessão)

# Boas-vindas -> + Mais opções -> Senha de administrador -> Iniciar Tails

```bash
sudo echo ok
```

# OK se: imprime `ok`.

---

## 5 — Instalar Haveno (download + PGP)

### 5A — Rede Reto (turma — pronto)

```bash
curl -fsSLO https://github.com/haveno-dex/haveno/raw/master/scripts/install_tails/haveno-install.sh \
  && bash haveno-install.sh \
  "https://github.com/retoaccess1/haveno-reto/releases/download/1.6.0-reto/haveno-v1.6.0-linux-x86_64-installer.deb" \
  "DAA24D878B8D36C90120A897CA02DAC12DAE2D0F"
```

# PGP Reto: https://retoswap.com/reto_public.asc — se sair release novo, troque só a URL do .deb.

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

# OK se: "Haveno installation setup completed successfully." · pastas App Data Install · haveno.deb em Install/ · ícone em Aplicações -> Outros.

---

## 6 — Abrir e ficar verde

# Aplicações -> Outros -> Haveno -> senha admin -> aguardar (amarelo 5–20 min na 1ª vez é normal)

```bash
sudo journalctl -u onion-grater --no-pager | tail -20
```

# OK se: indicador verde · log "loaded filter: haveno" · sem pop-up "No default Tor Instance configured".

---

## 7 — Cada boot

# USB -> persistência -> + Mais opções (admin) -> Tor -> Aplicações -> Outros -> Haveno

```bash
sudo /home/amnesia/Persistent/haveno/App/utils/install.sh
/home/amnesia/Persistent/haveno/App/utils/exec.sh
```

# OK se: Haveno abre e fica verde.
# Dados: /home/amnesia/Persistent/haveno/Data/

---

## 8 — Se NÃO ficou verde

# Pop-up "No default Tor Instance configured" ou log "loaded filter: None" / "AUTHCHALLENGE" / "bad YAML"
# Feche o Haveno antes.

```bash
sudo cp /home/amnesia/Persistent/haveno/App/utils/haveno.yml /etc/onion-grater.d/haveno.yml
sudo chmod o+r /var/run/tor/control.authcookie
python3 -c "import yaml; yaml.safe_load(open('/etc/onion-grater.d/haveno.yml')); print('YAML OK')"
sudo systemctl restart onion-grater
```

# OK se: imprime "YAML OK" · reabrir pelo menu -> verde · log "loaded filter: haveno".
# Mais sintomas: Cap. 7 (FAQ) do livro.

---

## Backup (pós-verde)

```bash
~/Persistent/haveno-backup.sh           # cifrado, em ~/Persistent/Backups
~/Persistent/haveno-backup.sh --usb     # em um USB montado
~/Persistent/haveno-backup.sh --restore CAMINHO/arquivo.tar.gz.gpg
```

---

## Atualizar (backup antes)

```bash
# Edite a URL/PGP do novo release e rode:
~/Persistent/haveno-update.sh \
  --url "https://github.com/retoaccess1/haveno-reto/releases/download/VERSAO-NOVA/haveno-vVERSAO-linux-x86_64-installer.deb" \
  --pgp "FINGERPRINT_DA_MESMA_REDE"
```

# Tails (sistema): atualize pelo Tails Upgrader, NÃO por script. Backup primeiro.

---

## Links essenciais

```text
Tails install   https://tails.net/install/index.en.html
haveno-install   https://github.com/haveno-dex/haveno/blob/master/scripts/install_tails/haveno-install.sh
haveno.yml       https://github.com/haveno-dex/haveno/blob/master/scripts/install_tails/assets/haveno.yml
Reto releases    https://github.com/retoaccess1/haveno-reto/releases
Reto PGP         https://retoswap.com/reto_public.asc
```

**Volume II (pós-verde):** [`../Expansão Curso/Playbooks — Rede Descentralizada.md`](../Expansão%20Curso/Playbooks%20—%20Rede%20Descentralizada.md) · teoria: [`../Expansão Curso/Curso — Rede Descentralizada (Extensão).md`](../Expansão%20Curso/Curso%20—%20Rede%20Descentralizada%20(Extensão).md)

*Comandos Volume I · Reto 1.6.0-reto · maio/2026. Teoria: `../Curso — Tails OS Expert.md`.*
