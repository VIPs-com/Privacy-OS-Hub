---
passo_hub: 1
trilha: m1-tor
rede: tails_online_tor
scripts: [tails-preflight.sh]
livro: modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#2-fundamentos-do-tails
playbook_legacy: modulos/m1-tails-haveno/Playbooks/Playbooks.md
---

# P01 — Bootstrap Tails (USB · Tor · persistência · admin)

**Cartão trilha:** [passo-01](../../trilha/passos/passo-01.md) · **Livro:** [Cap. 2](../../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#2-fundamentos-do-tails)

Tails **7.8.1+** · Rede turma: **Reto `1.6.0-reto`**.

---

## 1 — Tails no pendrive (outro PC)

```text
# Baixe só em tails.net (pendrive 8 GB+ será apagado): https://tails.net/install/index.en.html
# Tails Installer -> Instalar no USB -> Boot F12/F11/Esc -> USB -> Tails
```

> **Tecla de boot varia por fabricante** (Dell/Lenovo/Acer F12/F11 · HP Esc→F9 · ASUS Esc/F8): [Livro Cap. 2](../../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#2-fundamentos-do-tails).

**OK se:** tela "Bem-vindo ao Tails".

---

## 2 — Primeiro boot + Tor

```text
# Boas-vindas -> Iniciar Tails -> Conexão à rede Tor -> conectado
```

```bash
curl -s --max-time 30 https://check.torproject.org/api/ip | grep IsTor
```

**OK se:** aparece `"IsTor":true` e o Navegador Tor abre.

---

## 3 — Persistência (com Dotfiles)

```text
# Aplicações -> Tails -> Armazenamento persistente -> Criar
# Marque: Arquivos pessoais + Dotfiles -> Salvar -> Reiniciar
# Após reboot: senha da persistência -> Tor de novo
```

```bash
ls /home/amnesia/Persistent
```

**OK se:** pasta Persistent existe e não está vazia.

---

## 4 — Senha admin (toda sessão)

```text
# Boas-vindas -> + Mais opções -> Senha de administrador -> Iniciar Tails
```

```bash
sudo echo ok
```

**OK se:** imprime `ok`.

---

## Validação (script)

```bash
~/Persistent/hub-scripts/tails-preflight.sh --qa-log
```

Log: `~/Persistent/qa-logs/01-preflight-*.txt` → [COMO-LER](../../automacao/docs-aluno/COMO-LER-SEUS-LOGS.md)
