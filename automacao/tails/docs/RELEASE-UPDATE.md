# Como atualizar para um novo release do Haveno

> **Para:** equipe de desenvolvimento Privacy-OS-Hub  
> **Tempo estimado:** 30 minutos (edição) + tempo de teste no Tails

---

## 1. Único arquivo a editar: `lib/config.sh`

**Antes de editar manualmente**, no Tails:

```bash
hub.sh check-release    # compara com Latest GitHub + testa HTTP da .sig
```

```bash
# lib/config.sh — editar SOMENTE estas duas linhas:
HAVENO_VERSION="X.Y.Z-reto"          # ← tag EXATA do GitHub (pode ter prefixo v)
HAVENO_PGP_FPR="FINGERPRINT_NOVO"    # ← fingerprint da chave PGP (conferir manualmente)
```

Tudo o mais é derivado automaticamente:
- `HAVENO_DEB_URL` — URL do .deb calculada a partir de `HAVENO_VERSION`
- `HAVENO_SIG_URL` — URL da .sig calculada automaticamente
- `DEB_NAME` — nome do arquivo calculado automaticamente

**Não editar:** `RETO_KEY_URL`, caminhos de pasta, derivados.

> **⚠️ Convenção TAG × nome de arquivo (RetoSwap):**  
> A **TAG do GitHub** usa `HAVENO_VERSION` completo — ex.: `1.6.0-reto` ou `v1.8.0-reto` (inclui ou não prefixo `v`).  
> O **nome do binário** omite o prefixo `v` e o sufixo de rede — ex.: `haveno-v1.8.0-linux-x86_64-installer.deb` (sem `-reto`).  
> O template em `config.sh` deriva isso em dois passos:  
> `_HAVENO_VER_NUM="${HAVENO_VERSION%-*}"` → remove `-reto` (ex.: `v1.8.0-reto` → `v1.8.0`)  
> `_HAVENO_VER_NUM="${_HAVENO_VER_NUM#v}"` → remove `v` inicial (ex.: `v1.8.0` → `1.8.0`)  
> Resultado final: `haveno-v1.8.0-linux-x86_64-installer.deb` ✅  
> Antes de publicar, confirme no GitHub o nome exato do `.deb` — confirme que o padrão não mudou.

---

## 2. Onde obter os dados do novo release

**URL do release e fingerprint:**
- GitHub: `https://github.com/retoaccess1/haveno-reto/releases`
- Canais oficiais da Reto (Telegram, Matrix)

**Como verificar o fingerprint manualmente:**
```bash
# Baixar a chave pública do novo release
curl -fsSL https://retoswap.com/reto_public.asc | gpg --import

# Ver o fingerprint importado
gpg --fingerprint NOME_OU_ID_DA_CHAVE

# Comparar com o anunciado nos canais oficiais
# O fingerprint deve ser idêntico — qualquer diferença = NÃO publicar
```

---

## 3. Checklist antes de publicar

### 3.1 Editar e validar `lib/config.sh`
- [ ] `HAVENO_VERSION` atualizado para o novo release
- [ ] `HAVENO_PGP_FPR` atualizado com o fingerprint da nova chave
- [ ] Derivados calculados corretamente:
  ```bash
  source automacao/tails/lib/config.sh
  echo "$HAVENO_DEB_URL"
  echo "$HAVENO_SIG_URL"
  curl -sI "$HAVENO_DEB_URL" | grep -i content-length
  # Deve retornar Content-Length com o tamanho do .deb (não 404)
  # Se 404: verificar no GitHub o nome exato do binário — lembre que a TAG usa
  # "X.Y.Z-reto" mas o arquivo costuma ser "haveno-vX.Y.Z-linux-x86_64-installer.deb"
  # Template remove sufixo e prefixo "v" em dois passos:
  # _HAVENO_VER_NUM="${HAVENO_VERSION%-*}"  → "v1.8.0-reto" → "v1.8.0"
  # _HAVENO_VER_NUM="${_HAVENO_VER_NUM#v}"  → "v1.8.0" → "1.8.0"
  ```

### 3.2 Testar no Tails real (obrigatório antes de publicar)
- [ ] Atualizar `hub-scripts/` no Tails de teste:
  ```bash
  cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails
  ./sync-hub-scripts.sh
  ```
- [ ] Rodar o fluxo completo com qa-log:
  ```bash
  hub.sh install --qa-log
  ```
- [ ] Confirmar VERDE na janela do Haveno
- [ ] Abrir `~/Persistent/qa-logs/` e confirmar que não há `FAIL` nos logs
- [ ] Testar boot de sessão:
  ```bash
  hub.sh boot --qa-log
  ```
- [ ] Confirmar VERDE novamente após o boot

### 3.3 Testar o fallback atômico (steps/)
- [ ] Rodar pelo menos:
  ```bash
  cd ~/Persistent/hub-scripts/steps
  ./02-download-deb.sh   # novo .deb do novo release
  ./04-import-key.sh
  ./05-verify-sig.sh     # deve dar PASS com novo fingerprint
  ./06-check-deps.sh
  ./07-install-deb.sh    # ou --force-depends se necessário
  ./08-open-haveno.sh
  ```

### 3.4 Publicar
- [ ] Commit com mensagem clara:
  ```
  chore: atualizar para Haveno X.Y.Z-reto

  - lib/config.sh: HAVENO_VERSION e HAVENO_PGP_FPR atualizados
  - Testado no Tails real (qa-logs anexados)
  ```
- [ ] Comunicar turma com: versão anterior, versão nova, o que mudou, como atualizar:
  ```bash
  # Comando para alunos:
  hub.sh update
  ```

---

## 4. O que NÃO fazer

- ❌ Não editar `HAVENO_DEB_URL` diretamente — ela é derivada de `HAVENO_VERSION`
- ❌ Não publicar sem testar no Tails real — bugs de path ou PGP só aparecem no ambiente correto
- ❌ Não usar `apt-get install -f` para resolver dependências — remove o pacote haveno
- ❌ Não anunciar antes de confirmar o VERDE no Tails de teste

---

## 5. Rollback — se o novo release tiver problemas

```bash
# Reverter lib/config.sh para a versão anterior:
git checkout HEAD~1 -- automacao/tails/lib/config.sh

# No Tails do aluno, para reverter manualmente:
# Editar lib/config.sh e colocar os valores da versão anterior
# Em seguida:
hub.sh update
```

---

*docs/RELEASE-UPDATE.md · Privacy-OS-Hub · atualizado 2026-06-20*
