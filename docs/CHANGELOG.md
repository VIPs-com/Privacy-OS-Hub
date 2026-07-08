# CHANGELOG — Privacy-OS-Hub

> **v1.0 canônica** · jul/2026 · branch `main`

> **Nota (jul/2026):** entradas históricas podem citar `Hub-equipe-dev/` — pasta renomeada para **`Hub-equipe-dev/`** (camada local gitignored).

---

## 2026-07-04 — release v1.0.9 (Whonix passo 10 — curso canônico)

| Item | Detalhe |
|------|---------|
| **Curso canônico** | Passo 10: install VB · verify · import · `whonix-verificar-tor.sh` |
| **Scripts** | Cabeçalhos autocontidos (sem link ZTC) |
| **Commits** | `1e664cb` · `4f96e6a` · `c3e1fe0` |

Trilha host: `whonix-install-virtualbox` → `whonix-verify-image` → `whonix-import-ova` → `whonix-verificar-tor`.

---

## 2026-07-04 — Whonix passo 10 completo (host + Workstation)

| Item | Detalhe |
|------|---------|
| **`whonix-verificar-tor.sh`** | Novo — `systemcheck` + check.torproject.org na Workstation |
| **Docs** | MANUAL passo 10 · `automacao/whonix-host/README.md` — autocontido (sem link ZTC) |
| **Commit** | `1e664cb` |

Trilha host: `whonix-install-virtualbox` → `whonix-verify-image` → `whonix-import-ova` → `whonix-verificar-tor` (guest).

---

### Reteste rápido (MOK já enrolada — ex.: bloodyroar)

```bash
cd ~/Downloads/Privacy-OS-Hub
git pull
cd automacao/whonix-host
chmod +x whonix-sign-virtualbox-modules.sh whonix-verify-virtualbox-host.sh
sudo rm -f /root/module-signing/.mok-import-requested
sudo ./whonix-sign-virtualbox-modules.sh -y --qa-log
sudo ./whonix-verify-virtualbox-host.sh --qa-log
```

Sem reboot MOK. Se `sign` falhar, leia o bloco **Diagnóstico automático** em `/var/log/virtualbox-sign.log`.

---

## 2026-07-08 — whonix-host v3.5.4 (polish pós-PASS bloodyroar)

| Item | Detalhe |
|------|---------|
| Extension Pack | `Usable: true` fica ~7 linhas após o nome — `grep -A2/-A3` nunca alcançava: verify dava WARN falso e install reinstalava toda vez |
| install log | `PASS_NEEDS_SIGN` + sign PASS → agora PASS "superado" (era WARN contraditório) |
| Campo | Passo 10 **PASS 8/0/2** no bloodyroar 08/07 04:17 (Debian 13 · SB ON · VBox 7.2.12) |

---

## 2026-07-08 — whonix-host v3.5.3 (fix falso negativo lsmod/pipefail)

| Item | Detalhe |
|------|---------|
| Causa | `lsmod \| grep -q` sob `set -o pipefail`: grep fecha o pipe no 1º match → lsmod morre com SIGPIPE (141) → falso "não carregado" com módulo Live no kernel |
| Fix | `vbox_modules_loaded()` lê `/proc/modules` direto (install · sign · verify) |
| Campo | bloodyroar 08/07 04:01 — sign/verify FAIL enquanto `vboxdrv.service` active e `/dev/vboxdrv` presente |
| Extra | check KVM e verificação final também migrados para `/proc/modules` |

---

## 2026-07-08 — whonix-host v3.5.2 (sync MOK → shim-signed)

| Item | Detalhe |
|------|---------|
| `sync_mok_to_shim_signed()` | Copia MOK Hub (`/root/module-signing/`) → `/var/lib/shim-signed/mok/` antes de `vboxconfig` |
| `whonix-install-virtualbox.sh` | Chama sync em `ensure_mok_keypair()` |
| `whonix-sign-virtualbox-modules.sh` | Chama sync em `run_vboxconfig()` |
| Campo | Fix confirmado no piloto **bloodyroar** (Debian 13 trixie · SB ON · VBox 7.2.12) |
| `README.md` | Sintoma *"does not provide tools for automatic generation of keys"* |

---

## 2026-07-08 — whonix-host v3.5.1 (diagnóstico modprobe + vboxpci)

| Item | Detalhe |
|------|---------|
| `whonix-sign-virtualbox-modules.sh` | Remove `vboxpci`; `diagnose_silent_load_failure()` (blacklist · vermagic · dmesg) |
| `whonix-verify-virtualbox-host.sh` | FAIL com detalhe em falha silenciosa de `modprobe` |
| `whonix-install-virtualbox.sh` | `vboxpci` removido do reset unload |
| `README.md` | Reteste rápido; nota vboxpci descontinuado |

---

## 2026-07-08 — whonix-host v3.5 (sign separado + fluxo 4 etapas)

| Item | Detalhe |
|------|---------|
| **`whonix-sign-virtualbox-modules.sh`** | Novo — vboxconfig + sign-file + modprobe; SB off passa direto; `--sign-only` · `--qa-log` |
| `whonix-install-virtualbox.sh` | Assinatura delegada ao sign; fase `needs_sign`; fix MOK enrolada antes de pending |
| `whonix-verify-virtualbox-host.sh` | `FAIL_SIGN` exit 3 · `FAIL_MOK` exit 2 · parsing log corrigido · progresso |
| `README.md` | Fluxo install → tela azul → sign → verify; logs; kernel novo |
| Progresso | `/root/module-signing/.hub-vbox-progress` |

---

## 2026-07-08 — whonix-host v3.4 (validação host + UX MOK)

| Item | Detalhe |
|------|---------|
| **`whonix-verify-virtualbox-host.sh`** | Novo — 8 checks: SB · MOK · pacote · VBoxManage · vboxdrv · extpack · log · vboxusers; `--qa-log` |
| `whonix-install-virtualbox.sh` | Banner colorido v3.4; senha MOK com aviso visual; View key 0 documentado |
| `automacao/whonix-host/README.md` | Seção validação pós-MOK; tabela exit codes do validador |

---

## 2026-07-07 — whonix-install v3.3 (reset MOK + reboot Enter com -y)

| Item | Detalhe |
|------|---------|
| `whonix-install-virtualbox.sh` | `--reset-mok` / `--new-mok-keys`; `-y` → reboot `[S/n]` (Enter reinicia); card recuperação tela azul |
| `automacao/whonix-host/README.md` | Seção **Refazer do zero** (piloto / perdeu MOK) |

---

## 2026-07-07 — whonix-install v3.2.1 (mokutil import senha 2×)

| Item | Detalhe |
|------|---------|
| `whonix-install-virtualbox.sh` | `mokutil --import` recebe senha duplicada no stdin (`printf` 2×) — corrige `password doesn't match` em campo |

---

## 2026-07-07 — whonix-install v3.2 (assistente em fases + MOK fix Debian)

| Item | Detalhe |
|------|---------|
| `whonix-install-virtualbox.sh` | Assistente em fases (`fresh_install` / `pending_mok_reboot` / `post_reboot_sign` / `complete`); retomada pula passos 1–7; `mok_key_enrolled` parseia saída mokutil (Debian: exit 0 + "not enrolled"); Extension Pack `--accept-license` com `-y`; oferta `systemctl reboot -i` |
| `automacao/whonix-host/README.md` | Passo a passo detalhado: MOK, tela azul, diagnóstico, fases do assistente |
| Validação | Piloto campo Debian 13 trixie + Secure Boot ⏳ |

---

## 2026-07-07 — whonix-install v3 (MOK + Extension Pack padrão) ⏳ campo

| Item | Detalhe |
|------|---------|
| `whonix-install-virtualbox.sh` | Extension Pack ON por padrão (`--no-extpack`); fluxo MOK (gerar chave, `mokutil --import`, assinar módulos); `RESULTADO` + exit `0`/`2`/`1` |
| Validação | Pendente host Debian 13 + Secure Boot antes de release `v1.0.9.3` |

---

## 2026-07-07 — release v1.0.9.2 (sanitize virtualbox.list corrompido)

| Script | Fix |
|--------|-----|
| `whonix-install-virtualbox.sh` | `sanitize_stale_repo_file()` — remove `virtualbox.list` malformado **antes** do Passo 1 `apt-get update` (sobra de execução antiga com bug de `log`/stdout); traps + resumo de avisos |

---

## 2026-07-07 — release v1.0.9.1 (fixes Whonix / VirtualBox host)

| Script | Fix |
|--------|-----|
| `whonix-install-virtualbox.sh` | `log()` → stderr (bug `$CODENAME` corrompido); `apt-get update` exit real; `check_repo_availability`; escrita atômica; fetch retry |
| `whonix-import-ova.sh` | `VALIDSIG` + FPR (locale PT-BR); `EXPKEYSIG`; download derivative com retry |
| `whonix-verify-image.sh` | retry derivative.asc |
| `whonix-verificar-tor.sh` | CRLF→LF; retry/timeout check Tor |

---

## 2026-07-02 — baseline Tails 7.9.1 (validação em campo)

| Item | Detalhe |
|------|---------|
| **Tails turma** | **7.9.1** (2026-07-01) — substitui 7.8.1+ como referência operacional |
| **B+ histórico** | Mantido em **7.8.1** (jun/2026) — revalidação em 7.9.1 ⏳ |
| **Docs** | README · canônico Passo 1 · MANUAL |

Teste de campo combinado: Tails **7.9.1** + RetoSwap **v1.8.0-reto** (`hub.sh update --qa-log`).

---

## 2026-07-02 — release v1.0.8 (RetoSwap v1.8.0-reto + fix versionamento)

| Item | Detalhe |
|------|---------|
| **Baseline turma** | `HAVENO_VERSION="v1.8.0-reto"` em `lib/config.sh` |
| **`hub.sh check-release`** | Compara config com Latest GitHub + valida HTTP da `.sig` antes do download |
| **`haveno_resolve_latest_tag()`** | API GitHub via Tor, regex fail-closed, sem `jq` |
| **Erro `.sig` 404** | Mensagem distingue tag errada vs rede (TROUBLESHOOTING Erro 9) |
| **`haveno_run_install`** | Tolera falha GDBus/notificação se `dpkg` instalou o pacote (Erro 10) |
| **`hub.sh`** | Propaga exit code de install/boot/update/backup |
| **`install.sh`** | Banner lê `$HAVENO_VERSION` dinamicamente |
| **docs** | `pgp-check-log` (mantenedor, local) · RELEASE-UPDATE · TROUBLESHOOTING 9–10 |

`HAVENO_PGP_FPR` inalterado (`DAA24D87…DAE2D0F`) · `INSTALL_SCRIPT_HASH` inalterado (commit `9a14d55`).

---

## 2026-06-22 — release v1.0.7.2 (docs-aluno polish)

| Arquivo | Fix |
|---------|-----|
| `TRES-PASSOS` | Cabeçalho: `electrum/` no my-locker |
| `COMO-LER-SEUS-LOGS` | Caminho Tails para TROUBLESHOOTING; nota qa-validate PASS com avisos |

---

## 2026-06-22 — release v1.0.7.1 (docs MANUAL sync)

Patch de documentação pós-v1.0.7 — sem mudança de scripts. README banner → `v1.0.7.1`.

---

## 2026-06-22 — docs: MANUAL sincronizado com v1.0.7

| Seção | Detalhe |
|-------|---------|
| `feather/backup.sh` | `tar \| gpg` direto, USB index, `--no-encrypt`, wallet≠seed |
| `lib/config.sh` | `INSTALL_SCRIPT_HASH` + URL pin commit; nota mantenedor |
| `my-locker/` | `electrum/` + subpastas personalizadas |
| `haveno/boot.sh` | Monitor onion-grater no journal |
| `switch-network` | `haveno_guard_deb_url_pgp()` documentado |

---

## 2026-06-22 — polish pedagógico R7 (Ped#03–24) + release v1.0.7

| ID | Arquivo | Fix |
|----|---------|-----|
| **Ped#06** | canônico checklist | Ponte para requisitos hardware + my-locker auto; pendrive alinhado 8/16–64 GB |
| **Ped#20** | TRES-PASSOS | Cabeçalho 22/06, caminhos Tails absolutos, fallback simplificado |
| **Ped#03** | canônico 4.B | Separador “faça agora” vs rotina calendário 3-2-1-1-0 |
| **Ped#05** | canônico 2.5 + TRES-PASSOS | Aviso “avançado/suporte”; removido curl hardcoded no fallback |
| **Ped#08** | canônico §0 | Nota Passo 8 adiado; Manifesto opcional pós-Passo 1 |
| **Ped#11** | TRES-PASSOS | “item 3 deste guia” ≠ Passo 3 canônico |
| **Ped#17** | canônico 5 + 11 | wallet≠seed; auto-verificação papel no Passo 11 |
| **Ped#24** | canônico | Navegação rápida passos 3/6/7/11; Apêndice B “Você deve ver” |

---

## 2026-06-22 — backlog R6/R7 fechado (polish pré-v1.0.7)

| ID | Arquivo | Fix |
|----|---------|-----|
| **P6-08** | `haveno/boot.sh` | Monitor onion-grater: `loaded filter: haveno\|command allowed` (sem rajada cosmética) |
| **P6-02** | `lib/common.sh` | `haveno_guard_deb_url_pgp()` — ramo PGP-Reto + URL≠Reto |
| **R7-FEATHER-TMP** | `feather/backup.sh` | `tar \| gpg` direto no disco; USB multi-volume; prompt `--no-encrypt` |
| **AUD-URL-PIN** | `lib/config.sh` | `INSTALL_SCRIPT_URL` pinado em commit `9a14d55` (hash `658780…` inalterado) |

---

## 2026-06-22 — doc: pastas excluídas do backup --full

| Item | Detalhe |
|------|---------|
| **Excluídas** | `Backups/`, `qa-logs/`, `hub-scripts/` — de propósito (sem backup-dentro-de-backup) |
| **LEIA-ME.txt** | Atualizado em todo `sync`/`install` |
| **Docs** | Canônico 4.A.2, MANUAL, tails/README, hub.sh, mensagem pós `--full` |

---

## 2026-06-22 — my-locker automático (sync + install)

| Mudança | Arquivo | Detalhe |
|---------|---------|---------|
| **`haveno_ensure_my_locker()`** | `lib/common.sh` | Cria `my-locker/{keepass,comprovantes}` + `LEIA-ME.txt` (idempotente) |
| **Sync** | `sync-hub-scripts.sh` | Chama ensure após validar persistência |
| **Install** | `haveno/install.sh` | Após Dotfiles OK (+ `--install-only`) |
| **Fallback** | `steps/01-setup-dirs.sh` | Mesma função no caminho atômico |
| **Docs** | canônico · README · MANUAL | Sem `mkdir` manual; regra “arquivos pessoais só em my-locker/” |

---

## 2026-06-22 — backup `--full`: my-locker + gravação direta em disco

### Scripts

| Mudança | Arquivo | Detalhe |
|---------|---------|---------|
| **`my-locker/`** | `haveno/backup.sh` | `--full` inclui `~/Persistent/my-locker/` (KeePass, comprovantes) além de Data/, wallets/, dotfiles/ |
| **Sem /tmp/RAM** | `haveno/backup.sh` | Backup cifrado: `tar -czf - \| gpg` direto no destino (`--usb`/`--dest`); checagem de espaço no disco destino |
| **Passphrase** | `lib/common.sh` | `haveno_read_backup_passphrase()` extraído para reutilização |

### Documentação

- Canônico Passo 4: seção **4.A.1 my-locker/** + limites de tamanho (USB vs RAM)
- `README.md`, `MANUAL.md`, `TROUBLESHOOTING.md` (Erro 8), `hub.sh` usage

---

## 2026-06-21 — Rodada 6: fixes auditoria (Tails 7.8.1 · RetoSwap 1.6.0-reto)

> **Auditoria:** 7 agentes · relatório `Hub-equipe-dev/auditoria-repo/AUDITORIA-RODADA-6-21062026.md`

### Scripts (8 fixes)

| Fix | Arquivo | Detalhe |
|-----|---------|---------|
| **AUD-R6-01** | `hub.sh:246,251,257` | `"${EXTRA_ARGS[@]}"` sem `:-` — corrige `hub.sh feather` que abortava |
| **AUD-R6-02** | `lib/common.sh` + `switch-network.sh` + `update.sh` | `haveno_guard_deb_url_pgp()` — URL não-Reto exige `CONFIRMO` |
| **AUD-R6-03** | `steps/07-install-deb.sh` | `fail` se `.sig` ausente (exige `./05-verify-sig.sh` antes) |
| **AUD-R6-04** | `haveno/backup.sh` | `--no-encrypt` exige confirmação `sim` |
| **AUD-R6-07** | `haveno/update.sh` | `haveno_check_install_script_hash` após download do install script |
| **AUD-RESTORE** | `haveno/backup.sh` | `--restore` sem `.sha256` exige confirmação `s/N` |
| **AUD-STEPS-LOG** | `steps/04-import-key.sh` | Confirmação humana do fingerprint antes de PASS |
| **Docs** | canônico · `MANUAL.md` · `TRES-PASSOS` | Comandos QA via `hub.sh qa` · prompts pós-install documentados |

> **Pendente (release futuro):** bump `1.8.0-reto` — `@release-watcher` checklist; não alterado nesta versão.

---

## 2026-06-21 — senha de admin pedida 1× por padrão (sem `--one-password` nas docs)

> **Commit:** `39d8adb`

### UX: `--one-password` agora é o padrão do `hub.sh`

O Tails pede senha de admin a cada `sudo` por design. Antes, o aluno precisava digitar
`--one-password` explicitamente para evitar múltiplos prompts. Agora o hub ativa
esse comportamento **automaticamente** em todos os subcomandos (`install`, `boot`, `update`).

| Antes | Depois |
|-------|--------|
| `hub.sh install --one-password --qa-log` | `hub.sh install --qa-log` |
| `hub.sh boot --one-password` | `hub.sh boot` |

**O que muda no código (`hub.sh`):**
```bash
export HAVENO_ONE_PASSWORD="${HAVENO_ONE_PASSWORD:-1}"  # padrão: ativo
```

O ajuste de sudoers é **temporário de sessão** — removido ao fim do script e no reboot (Tails amnésico). Para desativar: `HAVENO_ONE_PASSWORD=0 hub.sh install`.

**Docs atualizadas** (9 arquivos): `README.md`, canônico, `TRES-PASSOS`, `MANUAL.md`,
`QUICKSTART.md`, `MIGRATION.md`, `automacao/tails/README.md`, `lib/common.sh`, `hub.sh`.

---

## 2026-06-21 — torsocks warm-up · Dotfiles fix · Feather prompt pós-install

> **Commits:** `3163faf` (torsocks warm-up + Dotfiles + auto-sync subpastas) · `3c33e74` (Feather prompt)

### Fixes de campo — segunda sessão 21/06/2026

| Fix | Detalhe |
|-----|---------|
| **torsocks DNS warm-up** (`install.sh` [4/9]) | `IsTor:true` passava mas `torsocks` falhava com `Status reply: 4` ao baixar `haveno.yml` upstream — forçava rodar install duas vezes. Fix: loop 6×15s aguarda `torsocks curl` responder antes do [6/9]. |
| **Atalhos GNOME em Dotfiles** (`install.sh` [7/9]) | Se Dotfiles foi ativado *após* `sync-hub-scripts.sh`, `.desktop` ficava só na sessão e sumia no reboot. Fix: pós-`haveno_run_install` copia automaticamente `haveno-boot.desktop` + `haveno-backup.desktop` para `$DOTFILES_DIR/.local/share/applications/`. |
| **Auto-sync subpastas** (`lib/common.sh`) | `hub_sync_scripts_to_persistent()` usava `cp *.sh` (sem subdiretórios) — aliases v2.0 `parte-1/` `parte-2/` `manutencao/` se perdiam; só copiava `haveno-backup.desktop`. Fix: `cp -rf hub-aliases/.` + loop `boot+backup.desktop`. |

### Feather prompt ao final do install

Ao final de `hub.sh install` (após Haveno verde + QA), novo prompt:

```
Instalar o Feather agora tambem? (Passo 5 — carteira XMR) [s/N]
```

- **Enter / N:** pula — rode `hub.sh feather` quando quiser (Passo 5 do curso)
- **S:** chama `exec hub.sh feather` diretamente, herdando `--qa-log` se ativo

---

## 2026-06-21 — `hub.sh qa` + `qa-validate.sh` + prompts S/n + B+ APROVADO

> **Commits:** `7273437` (hub.sh qa + qa-validate.sh) · `7d39491` (prompts S/n) · `dcffaa1` (boot dedup + v1.0.2) · `ed9672f` (INSTALL_SCRIPT_HASH + B+)

### `hub.sh qa` — novo subcomando completo

| Subcomando | O que faz |
|------------|-----------|
| `hub.sh qa validate` | `system/qa-validate.sh --qa-log` — tela + log simultâneos |
| `hub.sh qa confirm-seed` | `qa/confirm-seed.sh` |
| `hub.sh qa ritual-seed` | `qa/confirm-step9.sh` |
| `hub.sh qa cold-sign` | `qa/confirm-step12.sh` |
| `hub.sh qa export-logs` | `qa/export-logs.sh` |
| `hub.sh qa finalize` | `validate` + `confirm-seed` — 1ª instalação, 1 vez |

### `system/qa-validate.sh` — renomeado de `health-check.sh`

- Saída simultânea: tela (tempo real) **e** `~/Persistent/qa-logs/qa-validate-*.txt`
- Implementado via `qa_log_tee_begin` (mesma lib de todos os scripts)
- `hub-aliases/19-qa-validate.sh` atualizado para o novo nome

### QA Finalize automático pós-install

Ao final de `hub.sh install`, se `04-seed-papel-*.txt` não existir:
```
→ "Rodar backup agora? (S/n):"     — Enter = backup (padrão S)
→ "Finalizar QA agora? (S/n):"     — Enter = qa validate + confirm-seed
```

O aluno sai com `qa-logs/` completo em uma única sessão sem passos extras.

### Prompts com padrão S (Enter = sim)

- `hub.sh install` → backup: `(s/N)` → **`(S/n)`** — backup é sempre recomendado
- `hub.sh install` → QA finalize: `(s/N)` → **`(S/n)`** — completar QA na 1ª vez

### Cosméticos e fixes de campo

| Fix | Detalhe |
|-----|---------|
| `boot.sh` monitor dedup | Loop imprimia mesma linha journalctl 32× — adicionado `last=""` + `[ "$line" != "$last" ]` (espelha `install.sh`) |
| `lib/config.sh` PU-07 | `INSTALL_SCRIPT_HASH="658780708f1556a8135f2800c9182067909c5c77682bda68a98d70086779eeba"` confirmado em campo 21/06/2026 |
| Tag `v1.0.2` | Publicada no GitHub apontando para `dcffaa1` |

### B+ APROVADO — 21/06/2026

**Evidências:** 5 logs QA PASS (`01-preflight`, `02-haveno-auto`, `04-haveno-backup`, `07-haveno-boot`, `09-seed-confirmacao`) · Tails **7.8.1** · RetoSwap **1.6.0-reto** · 12 peers P2P · bloco 3.700.884 · walletInitialized=true · porta 9062 confirmada (`haveno-exec.log:78`).

---

## 2026-06-19 — Auditoria multi-agent: hardening + 16 fixes cirúrgicos

> **Método:** 4 agentes especializados em paralelo (técnico · segurança · pedagógico · consistência).  
> **Contexto incorporado:** no Tails, todo TCP vai pelo Tor via iptables kernel — "clearnet fallback" no código é Tor transparente (TransPort 9040), não clearnet real. Variação 4–90 min no download = circuito Tor diferente.

### Fixes de scripts (9 itens)

| Arquivo | Linha | Fix |
|---------|:-----:|-----|
| `automacao/tails/docs/QUICKSTART.md` | 57 | `etapas/` removida (pasta deletada na Phase 3) |
| `automacao/tails/haveno/backup.sh` | 207 | `qa-confirm-seed-papel.sh` → `qa/confirm-seed.sh` |
| `automacao/tails/feather/install.sh` | 198 | `feather-backup.sh` → `feather/backup.sh` |
| `automacao/tails/hub-aliases/04-daily-routine.sh` | 2–4 | Chamava `haveno/boot.sh` diretamente (bypass de preflight); roteado via `hub.sh boot` |
| `automacao/docs-aluno/COMO-LER-SEUS-LOGS.md` | 107 | Link morto `README.md#travou-aqui` + referência a `processos/P0x` → `TROUBLESHOOTING.md` |
| `automacao/tails/haveno/install.sh` | 6–44 | Cabeçalho reescrito: citava `haveno-auto.sh`, `haveno-common.sh`, `haveno-boot.sh` (todos deletados) |
| `automacao/tails/hub-aliases/README.md` | 50 | `04-daily-routine.sh` documentado como `haveno/boot.sh` → corrigido para `hub.sh boot` |
| `automacao/tails/qa/confirm-seed.sh` | 3–6 | Cabeçalho: `qa-confirm-seed-papel.sh` → `qa/confirm-seed.sh`; uso atualizado |
| `.gitignore` | 5 | Entrada `Auditoria/` (pasta inexistente) removida |

### Hardening de segurança e robustez (4 itens)

| Arquivo | Fix |
|---------|-----|
| `automacao/tails/lib/common.sh` | `haveno_ensure_reto_pgp_key()`: fallback clearnet removido; fluxo Tor→keyserver Tor→`die()` explícito; fingerprint verificado após import |
| `automacao/tails/lib/config.sh` | Campo `INSTALL_SCRIPT_HASH=""` adicionado — vazio=só loga sha256; preenchido=verifica fail-closed a cada release |
| `automacao/tails/haveno/install.sh` | Lógica de verificação de hash do `haveno-install.sh` upstream; `die()` local chama `qa_log_finish 1` (QA log sempre finalizado); download via Tor primeiro (consistência com base de código) |
| `docs/CHANGELOG.md` | Banner `⚠️ Nota histórica` na seção `## Histórico v2 (beta)` — contexto para mantenedores |

### Melhorias pedagógicas (3 itens)

| Arquivo | Fix |
|---------|-----|
| `automacao/tails/docs/QUICKSTART.md` | `--install-only` com nota de pré-requisito: `.deb` deve estar em `Install/`, não só em `.download/` |
| `🛡️ Privacy-OS-Hub - Versão 1.0.md` | Link para `TROUBLESHOOTING.md` adicionado no §2.2, próximo ao bloco de recuperação do download |
| `automacao/tails/hub-aliases/README.md` | Tabela atualizada: `04-daily-routine` → `hub.sh boot` |

### Verificado como correto (sem alteração)

- Verificação PGP do `.deb` — fail-closed confirmado (`VALIDSIG` → `mv` → `dpkg`)
- `INSTALL_SCRIPT_HASH=""` — lógica `[ -n "" ]` falsa → só loga ✅
- Seed nunca exposta em log, variável ou arquivo ✅
- Onion-grater — portas restritas ao mínimo do Haveno ✅
- Sourcing chain `hub.sh → lib/common.sh → lib/config.sh` chega a todos os scripts ✅

---

## 2026-06-19 — Reorganização por produto (Phase 3) + auditoria de documentação

> Commit `6d1a831` · `254c23b`

Scripts movidos de raiz plana para pastas por produto (`haveno/` · `feather/` · `system/` · `qa/`). Scripts legados deletados. Todos os `.md` públicos atualizados para `hub.sh`. Zero referências a `haveno-setup.sh`, `haveno-auto.sh`, `etapas/instalar-haveno/` em qualquer arquivo público.

---

## 2026-06-18 — Fix download: `.sig` apagada como lixo + retomada `.deb` parcial (DIV-20260618-01)

**Campo:** `02-haveno-auto-20260618-074604.txt` — upstream `haveno-install.sh` falhou com `Failed to download Haveno binary` após ~210 MiB (circuito Tor substituído). Dois bugs encadeados impediram a recuperação automática.

| Bug | Localização | Causa | Fix |
|-----|-------------|-------|-----|
| **DIV-20260618-01a** | `haveno_purge_poisoned_partial_debs` | Padrão `*.deb.*` casava com `*.deb.sig` (119 B) → apagado como "lixo" | `! -name '*.sig'` excluído do `find` do primeiro loop |
| **DIV-20260618-01b** | `haveno_run_upstream_install_deb` (fallback) | `.deb` parcial (> 100 MiB min) passava `haveno_deb_size_ok` mas era incompleto → PGP falhava | Detecta `size < expected` → retoma via `haveno_hub_download_and_promote_deb` (curl `-C-`) antes de tentar PGP; `App/utils/` já existe neste ponto |

> **Nota:** o `.sig` deletado era re-baixado imediatamente pelo `haveno_predownload_sig`, mas a verificação falhava porque o `.deb` estava incompleto, não por causa do `.sig`. O fix correto combina os dois: não apagar o `.sig` válido E retomar o `.deb` antes de verificar.

---

## 2026-06-18 — Fix validação `.sig`: aceitar assinatura PGP binária (Ed25519)

**Commit:** `8729b58`

| Mudança | Scripts | Detalhe |
|---------|---------|---------|
| **Causa raiz** | — | GitHub API + hex dump confirmam: `.sig` do release 1.6.0-reto é assinatura Ed25519 **binária** legítima (119 B, OpenPGP old-format `0x88`, fingerprint `DAA24D...ae2d0f`). Não é HTML. |
| **`HAVENO_SIG_MIN_BYTES`** | `haveno-common.sh` | `400` → `60`; Ed25519 binário tem ~119 B por design |
| **`haveno_sig_valid_format()`** | `haveno-common.sh` | Nova função: aceita `0x88`/`0x89`/`0xC2` (binário) **ou** `BEGIN PGP SIGNATURE` (armored); usa `od` portável |
| **`haveno_predownload_sig`** | `haveno-common.sh` | Substituído `head -1 \| grep BEGIN PGP` por `haveno_sig_valid_format` |
| **`02-baixar-deb.sh`** | `etapas/instalar-haveno/` | `400` → `60`, check `BEGIN PGP` → magic byte `0x88/0x89/0xC2` |
| **`.hashes` (referência)** | — | SHA-256 oficial: `9c052b6348bbebbb7bb9c4346afa97e38bbc3e7304e51f172aaa7dfbf63faf69` |

> **Campo:** erro `ERRO: Assinatura .sig invalida (0 bytes)` após 3 tentativas com `.sig` de 119 B — os checks de `>= 400 B` e `BEGIN PGP SIGNATURE` descartavam uma assinatura válida. GPG `--verify` aceita binário e armored automaticamente.

---

## 2026-06-18 — `hub-aliases/` numerados + sync para `hub-scripts/aliases/`

| Mudança | Detalhe |
|---------|---------|
| **21 aliases** | `00`–`20` com nomes descritivos e flags fixas (`--qa-log`, `--boot`, etc.) |
| **sync** | `sync-hub-scripts.sh` e `hub_sync_scripts_to_persistent` copiam `aliases/` |
| **Wrappers** | Resolvem `HUB=..` (pai = `hub-scripts/`) — funciona no Tails após sync |
| **Stubs** | `00-tails-install` / `00-bootstrap-tails` = passos manuais (exit 1 + orientação) |

---

## 2026-06-18 — `.sig` via Tor (espelha `02-baixar-deb.sh`) + mensagens Apêndice B

| Mudança | Scripts | Detalhe |
|---------|---------|---------|
| **`.sig` só Tor** | `haveno-common.sh` | `curl -fsSL` como `02-baixar-deb.sh`; removido fallback clearnet que podia gravar HTML CDN |
| **Retry `.sig`** | `haveno-common.sh` | Até 3 tentativas (15 s entre elas) antes de abortar |
| **Recovery `.sig`** | `haveno_sig_download_failed_msg` | Explica pendrive/W11 OK; aponta Apêndice B §3 e fallback atômico |
| **Mensagens obsoletas** | `haveno-auto.sh`, `README.md`, `MANUAL.md` | Cap. 7 / `Curso-Tails-OS-Expert.md` → **Apêndice B** do canônico |
| **Validação `.sig` (intermediária)** | `02-baixar-deb.sh` | Mín. 400 B + header PGP — **supersedida** no mesmo dia por `haveno_sig_valid_format` (`8729b58`) |

> **Nota:** a `.sig` oficial do release 1.6.0-reto tem **119 B** por design (Ed25519 binário). O check `>= 400 B` era falso positivo — ver seção Ed25519 acima.

---

## 2026-06-18 — Download: barra de progresso + fluxo `.download/` → `Install/`

| Mudança | Scripts | Detalhe |
|---------|---------|---------|
| **Barra ASCII** | `haveno-common.sh`, `haveno-auto.sh` | `[########----] NN%` a cada **10s** durante upstream (`HAVENO_DOWNLOAD_MONITOR_SEC`) |
| **curl `--progress-bar`** | `haveno-common.sh` | `.sig` e `.deb` quando `App/utils/` já existe (espelha `02-baixar-deb.sh`) |
| **Promoção verificada** | `haveno_finalize_verified_deb_in_cwd`, `haveno_try_promote_deb_from_cwd` | `.deb` completo em `.download/` → PGP `VALIDSIG` → **mv** para `Install/` + symlink `haveno.deb` |
| **Trap SIGINT** | `haveno-auto.sh`, `haveno-update.sh` | Mata filhos do download em Ctrl+C; `.download/` fica para retomar |
| **Recovery** | `haveno_deb_download_failed_msg` | Mensagens distintas: `.download/` vs `Install/` vs `--install-only` |
| **Auditoria** | `haveno_fix_dpkg_state` | Estado `half-installed`; `qa-validate.sh` valida YAML do onion-grater |

---

## 2026-06-18 — Scripts 10/10 (auditoria R31+)

| Fix | Scripts | Detalhe |
|-----|---------|---------|
| **Backup senha confirmada** | `haveno-common.sh`, `haveno-backup.sh`, `feather-backup.sh`, `haveno-update.sh` | `haveno_gpg_symmetric_encrypt` — dupla entrada antes do GPG |
| **Onion-grater loop 30s** | `haveno-common.sh`, `08-abrir-haveno.sh` | `haveno_wait_onion_grater_filter` substitui sleep fixo |
| **PGP etapas alinhado** | `05-verificar-assinatura.sh` | `grep VALIDSIG` como no fluxo principal |
| **Feather fallback** | `feather-install-verify.sh` | `FEATHER_VERSION_FALLBACK` (env) se scrape falhar |
| **LC_ALL=C deps** | `haveno-common.sh`, `06-deps-apt.sh` | locale neutro em apt |
| **TX ID hex** | `qa-confirm-passo12.sh` | valida 8 caracteres hex |
| **QA Validate** | `qa-validate.sh` | validacao estatica (sintaxe + checks + YAML onion-grater) |

---

## 2026-06-18 — `meta/` → `docs/` + `MANUAL.md` unificado

| Mudança | Detalhe |
|---------|---------|
| **Pasta** | `meta/` renomeada para `docs/` (≠ stub v1 `docs/` removido em `f0dc197`) |
| **MANUAL.md** | Unifica ex-`MANUAL-EXPERT`, ex-`MANUAL-SCRIPTS` e bloco logs/export em 3 partes |
| **Removidos** | `MANUAL-EXPERT.md`, `MANUAL-DO-CURSO.md`, `MANUAL-SCRIPTS.md` |
| **MANIFESTO** | §7 reescrito para arquitetura v1.0 canônica |
| **Links** | README, `automacao/`, canônico apontam para `docs/` |

---

## Histórico v2 (beta)

> **⚠️ Nota histórica para mantenedores**  
> Esta seção documenta o estado do repositório **antes** da reorganização de 2026-06-19.  
> Os scripts mencionados abaixo (`haveno-auto.sh`, `haveno-boot.sh`, `haveno-common.sh`,  
> `haveno-setup.sh`, `etapas/instalar-haveno/`) foram **removidos ou renomeados**.  
> Estrutura atual: `hub.sh` → `haveno/` · `feather/` · `system/` · `lib/` · `steps/`  
> Ver: `automacao/tails/docs/MIGRATION.md` para o mapa completo antes → depois.

> **Tag:** `v2.0.0-beta` · **Data:** 2026-06-08

---

## 2026-06-17 — Download `.download/` + assinatura `.sig` (DIV-20260617-01/02)

**Commits:** `1dd2e47` · `1e8fe99`/`6acf2a1` (purge `.deb` parcial) · `42e9ff6` · merge `79a7dd3` · docs `1e4db26` · refinamento **18/jun:** `8729b58`

| Fix | Sintoma | Correção |
|-----|---------|----------|
| **DIV-17-01** | `.deb` em `/tmp` (RAM); monitor sem %; perdia no reboot | Pasta persistente `~/Persistent/haveno/.download/` + `wget -c` retoma após reboot |
| **DIV-17-02** | `Failed to download Haveno signature` / bloqueio no [6/9] com `.sig` de **119 B** e `.deb` completo (~266 MB) | **17/jun:** purge `.sig` truncadas; `haveno_predownload_sig` via **Tor**; promove `.deb` verificado para `Install/`. **18/jun (`8729b58`):** causa raiz = falso positivo — `.sig` oficial é Ed25519 **binária** 119 B (`0x88`), não ASCII-armored; `haveno_sig_valid_format` + mín. 60 B |

- **`haveno-common.sh`:** `haveno_purge_poisoned_partial_debs`, `haveno_sig_size_ok`, `haveno_finalize_verified_deb_in_cwd` → pós-`8729b58`: `haveno_sig_valid_format`
- **`haveno-auto.sh` / `haveno-update.sh`:** atalho quando `.deb` já está completo em `.download/`; fallback PGP local se upstream falhar na `.sig`
- **Docs aluno:** [TRES-PASSOS-HAVENO-TAILS.md](automacao/docs-aluno/TRES-PASSOS-HAVENO-TAILS.md) — recuperação + **fallback atômico**
- **`automacao/tails/etapas/instalar-haveno/`** — scripts em pedaços no ZIP público (caminho validado em Tails 11/jun e 17/jun)

> **Campo (17/jun):** purge do `.deb` confirmado (266 MB OK). **Hipótese inicial** DIV-17-02: HTML GitHub ~119 B. **Refinamento (18/jun):** hex dump + API GitHub confirmam `.sig` legítima de 119 B; scripts com `>= 400 B` rejeitavam assinatura válida. Lixo CDN (HTML sem `0x88`) continua possível — distinguido por `haveno_sig_valid_format`. **Validação Tails** do fluxo `haveno-setup` @ `8729b58` ainda pendente após `sync-hub-scripts.sh`.

---

## 2026-06-11 — Fixes de campo R29 (Tails real, Haveno 1.6.0)

Dois bugs **Major** encontrados e validados ao vivo na trilha do passo 2/7:

| Fix | Sintoma | Correção |
|-----|---------|----------|
| **R29a — cookie do Tor** | Haveno fecha na hora: `torControlCookieFile ... is not readable` | `chmod o+r` reaplicado a **cada** sessão, **antes** do `exec.sh` (Tails amnésico) — FAQ **7.12** |
| **R29b — filtro PoW** | Popup "conexão com a rede do Haveno falhou" (`Command filtered`) | Novo `automacao/tails/haveno-onion-grater.yml` — o yml do instalador upstream 1.6.0 não autoriza o `ADD_ONION` com params PoW (bug upstream) — FAQ **7.13** |

Arquivos: `haveno-common.sh` (ordem cookie/filtro→exec + preferência ao yml do hub) ·
`sync-hub-scripts.sh` (copia o yml) · `haveno-onion-grater.yml` (novo) ·
Curso Vol I FAQ 7.12–7.13 · `automacao/tails/README.md` (tabela "como ler os logs").
Validação: RetoSwap conectado à Mainnet via Tor, nó Tor criado (prints internos).

## 2026-06-11 — R30/R31: Feather + boot do zero (continuação da bateria)

| Fix | Sintoma | Correção |
|-----|---------|----------|
| **R30 — chave Feather 404** | `feather-install-verify.sh` morria baixando `featherwallet.asc` (URL do GitHub master morta) | Fallback em cadeia: site oficial → keyserver pinado pelo fingerprint; download automático do AppImage via Tor; **gate humano** de fingerprint ("confira no olho"); abre o app + atalhos — `639c841`…`29bbfea` |
| **R30b — Persistent poluída** | `sync-hub-scripts.sh` despejava ~17 arquivos na raiz | Scripts agora em **`~/Persistent/hub-scripts/`** (pasta única; dados do operador fora) — `1c5da78` |
| **R31 — apt update sem retry** | Boot novo: update via Tor falhava e o script seguia → todas as libs "sem candidato" | Retry 3×30s + abort fail-closed — `37c54b6` |
| **R31b — ⚠️ deps com nomes UBUNTU** | Mesmo com update OK, `libicu74`/`libavcodec60`/etc. **não existem no Debian 13** — o `.deb` 1.6.0-reto declara Depends com nomes de libs do **Ubuntu** | Deps lidas **de dentro do `.deb`**, instala só o que existe, fallback `dpkg --force-depends` (app embute runtime — funciona; validado em boot do zero) — `62fdb62` · FAQ **7.11** reescrito |

> ⚠️ **Para mantenedores:** nunca fixar lista de dependências do `.deb` em script ou doc —
> os nomes vêm do empacotamento upstream (Ubuntu) e quebram no Debian/Tails.
> Sempre ler do próprio pacote (`dpkg-deb -f ... Depends`). Reportar ao haveno-reto
> junto com a issue do filtro PoW.

Reorganização em **4 camadas** sem mudar a trilha pedagógica 1–12 nem os nomes dos scripts em `~/Persistent/`.

---

## Camadas v2

| Camada | Pasta | Função |
|--------|-------|--------|
| A — Porta | `README.md` | Trilha linear 1–12 |
| B — Ensino | `modulos/` | Livros, folhetos, índices de playbook |
| C — Execução | `processos/` | Comandos por passo (P01–P12) |
| D — Automação | `automacao/` | Scripts `.sh` (cópia para `~/Persistent/`) |
| Navegação | `trilha/` | Cartões L0/L1, glossário, mapas |

---

## Tabela de redirects

| Antes (v1) | Agora (v2) |
|------------|------------|
| `docs/` | `trilha/` |
| `docs/passos/` | `trilha/passos/` |
| `Tails-OS-Expert/` | `modulos/m1-tails-haveno/` |
| `Tails-OS-Expert/Scripts/` | `automacao/tails/` (+ `homelab/`) |
| `Whonix-Online/` | `modulos/m2-whonix-custodia/` |
| `Whonix-Online/Scripts/` | `automacao/whonix-host/` |
| Playbooks M1 (comandos) | `processos/m1-tor/` P01–P07 |
| Playbooks M2 (comandos) | `processos/` P08–P12 |
| Feather obrigatório M2 | `processos/m1-tor/P05-feather.md` |
| Trades Haveno (opcional) | `modulos/.../Playbooks-Rede-Descentralizada.md` §4–6 |

**Stubs mantidos** (redirect): `docs/`, `Tails-OS-Expert/`, `Whonix-Online/`.

---

## Copiar scripts no Tails (caminho novo no repo)

```bash
cp automacao/tails/*.sh automacao/tails/hub-aliases/*.sh ~/Persistent/
chmod +x ~/Persistent/*.sh
```

---

## Commits principais v2

| Commit | Conteúdo |
|--------|----------|
| `45b73d2` | `docs/` → `trilha/` (navegação L0/L1) |
| `b8fde60` | `modulos/` + `automacao/` + stubs |
| `48707a9` | `processos/` cartões P01–P12 |
| `c3526e8` | Fatiar comandos nos processos; playbooks → índice |

---

## Inalterado (pedagogia)

- Ordem passos **1–12** no README
- Passo **9** = ritual 2× seed (Tor OK)
- Passo **12** = único air-gap de rede obrigatório
- Scripts: `haveno-setup.sh`, `qa-confirm-passo9.sh`, etc. (só mudou caminho no repo)
- QA: `--qa-log` → `~/Persistent/qa-logs/`

---

## Publicação pós-Rodada 20

- **Publicação:** `git pull origin main` — cadeia `79f6d3e` (FIG-4/FIG-1) · `104a751`+ (fechamento P1–P2) · `f32b735` (HEAD)
- **Veredito:** LIBERADO para piloto B+ — ver `Hub-equipe-dev/validacao/HANDOFF-EQUIPE-DEV.md` (local)

---

## Diagramas v2 (FIG-1…4)

- **`79f6d3e`** — FIG-4 (4 camadas + jornada 1–12 no README); FIG-1 reescrito (P01–P12, tabela rede); índice `diagramas-indice.md`; âncoras FIG-3/FIG-4
- **`104a751`** — fechamento P1–P2: cartões passo FIG-1/2/3; MANUAL-EXPERT `#arquitetura-do-repositorio`; índices; roadmap interno `Hub-equipe-dev/ROADMAP-FECHAMENTO-DIAGRAMAS-V2.md`

---

## Alinhamento documentação v2

- **Travou aqui?** passos 1–12 + P01–P12 · Feather=P05 · trades opcional separado · FIG-3 no passo 12
- **M2 README** coluna Comandos → `processos/` P08–P12
- **MANUAL-SCRIPTS** fluxo visual ↔ passos/P0x · **Playbooks Vol II** banner P05
- **Âncoras** Vol II caps 4–17 · Whonix §4 · `#trilha-script-first`
- Roadmap interno: `Hub-equipe-dev/ROADMAP-ALINHAMENTO-DOCUMENTACAO-V2.md`

---

## Revisão pedagógica R21 (estática)

- Passos **4, 8, 9, 12** — veredito **APROVADO** (gate sem Tails)
- Correção principal: **P08** pré-requisitos em 2 fases (passo 8 ≠ passo 12)
- Relatório: gate pedagógico estático (camada local da equipe-dev)

---

## Stubs v1 + pacote piloto (R22)

- Índice público: [trilha/referencia/stubs-v1-indice.md](trilha/referencia/stubs-v1-indice.md)
- Stub criado: `Whonix-Online/Scripts/README.md` → `automacao/whonix-host/`
- Pacote equipe-dev: `Hub-equipe-dev/validacao/PACOTE-PILOTO-B+-PRONTO.md`

---

## Liberação campo R23 (2026-05-29)

- **HEAD:** `2ba833b` · doc v2-beta **fechada** (gates estáticos R20→R23)
- **Veredito:** LIBERADO PARA CAMPO — piloto B+ Tails físico
- Relatório local: `Auditoria/Rodada-23-Liberacao-Campo-Tails.md`
- Porta execução: `validacao/PACOTE-PILOTO-B+-PRONTO.md` · `validacao/HANDOFF-EQUIPE-DEV.md`

---

## Manutenção R24 + backlog Purple P-1…P-5 (2026-06-09)

- **Âncora:** `Instalar-Whonix-passo-a-passo-por-SO.md` §10 → `#10-prints-do-manifesto-pi-1`
- **Scripts:** `feather-install-verify.sh` · `haveno-verify-deb.sh` — PGP `--status-fd 1` + `VALIDSIG` (locale-independente); `haveno-switch-network.sh` — `die` em opção inválida
- **Doc manual PGP (P-3):** Vol II §3.3/§4.1 · Playbooks §2–3 · `P05-feather.md` — exigem fingerprint do signatário
- **README:** passos online **1–9** (alinha passo 9 em Tails com Tor)
- Gate local (gitignored): `Hub-equipe-dev/checkers/` — ver `Auditoria/Rodada-24-Correcoes-Doc-e-Gate-Links.md`

---

## Baseline de proteção + backup prático (2026-06-09)

- **Nova página:** [trilha/trilhas/opcionais-zero-trust-baseline.md](trilha/trilhas/opcionais-zero-trust-baseline.md) — entrega o processo de **cofre · PGP · backup 3-2-1 off-site** usando o que o aluno já criou (seed P04, ritual P09, Feather, hábito PGP); aprofundamento opcional no **Zero-Trust-Core** (não tira o aluno do curso).
- **Prático Haveno:** `haveno-backup.sh` (compacta + cifra GPG + `.sha256`; `--usb` salva em pendrive), restauração e *atualizar com backup antes* amarrados ao 3-2-1 + insight **`seed ≠ backup completo`** (seed recupera fundos, não histórico/contas de pagamento → backup da pasta `Data/`).
- **Navegação repontada:** README "Trilhas opcionais"/"Baseline opcional", `MANUAL-EXPERT`, `MANUAL-DO-CURSO` e `trilha/trilhas/README.md` apontam para a página local (que linka o ZTC).

---

## Orquestração `haveno-setup` R29 (2026-05-29)

- **`haveno-setup.sh`:** sync repo→Persistent (mtime); `hub_resolve_script`; auto-resume `--install-only`; propaga `--qa-log` a preflight/auto/boot/backup/feather
- **`haveno-auto.sh` / `haveno-boot.sh`:** QA-log `02-haveno-auto` / `03-haveno-boot`
- **`haveno-update.sh`:** `haveno-common` + `haveno_run_install`; backup [4/6] skip amigável sem `Data/`
- **Doc:** P02, `COMO-LER-SEUS-LOGS.md` (linha `02-haveno-auto-*`); gate local `check-script-orchestration.sh`
- **Auditoria local:** `Auditoria/Rodada-29-Scripts-M1-Orquestracao.md`

---

## Recuperação `--install-only` + sync R28b (2026-06-10)

- **`haveno-auto.sh --install-only`:** continua do [7/9] sem re-download (deps + purge config-files + install)
- **`sync-hub-scripts.sh`:** copia `*.sh` do repo para `~/Persistent/`
- **`haveno-common.sh`:** `haveno_fix_dpkg_state`, `haveno_ensure_install_deb_link`, detecta qualquer `*.deb` em `Install/`

---

## Deps `.deb` + diário piloto R28 (2026-06-10)

- **`haveno-common.sh`:** `haveno_ensure_deb_deps()` + `haveno_run_install()` — apt das 12 libs antes de `install.sh` (Tails 7.8+)
- **FAQ 7.11:** armadilha `apt-get install -f` · Software adicional opcional
- **Auditoria local:** `Auditoria/Rodada-28-Piloto-Campo-Progresso.md` (diário campo B+ até [7/9])

---

## UX piloto campo R27 (2026-06-10)

- **`haveno-auto.sh` [5/9]:** 3 tentativas de `Date:` via Tor; fallback explica `timedatectl synchronized: no` no Tails e mostra `date -u`
- **`haveno-auto.sh` [6/9]:** aviso 30–90 min + monitor `[download]` com tamanho e % a cada 30s durante `haveno-install.sh`
- **Docs:** Curso §3.2 · `MANUAL-SCRIPTS.md` (CRLF/ZIP) · `automacao/tails/README.md`
- **Auditoria local:** `Auditoria/Rodada-27-Piloto-Campo-UX.md`

---

## Fechamento backlog R26 (2026-06-09)

- **Scripts:** `feather-backup.sh` — `--restore` com confirmação `(s/N)` + `AES256`; QA-log `tails_online_tor_esperado=SIM`; `haveno-auto.sh` loga sha256 do `haveno-install.sh`
- **Baseline:** `--usb` ≠ off-site; aviso `--restore`; link restauração
- **Didática:** README passo 5 · cartões 01/02/10/11 · MANUAL-DO-CURSO mínimo M2 · Folheto alt-text · [REGRA] trilha M2

---

## Pendente pós-beta

- [ ] Piloto B+ Tails físico — **LIBERADO R23** · pacote/checklist do piloto na camada local da equipe-dev — **equipe campo**
- [x] Revisão pedagógica amostra estática (passos 4, 8, 9, 12) — R21
- [ ] Remoção gradual dos stubs após período de redirect
- [ ] Tag `v2.0.0` estável

---

*Privacy-OS-Hub · CHANGELOG v2 · jun/2026*
