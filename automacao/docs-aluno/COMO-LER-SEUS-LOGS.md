# Como ler seus logs de validação (QA)

> **Para o aluno:** saber se o passo deu certo **sem adivinhar** — e **sem** expor seed, senha ou chaves.

---

## Onde ficam os arquivos

| Ambiente | Pasta |
|----------|--------|
| **Tails** | `~/Persistent/qa-logs/*.txt` |
| **Host Linux (Whonix)** | `~/whonix-download/qa-logs/*.txt` (com `--qa-log`) |

Ative gravação com **`--qa-log`** nos scripts (ou `hub.sh install --qa-log`).

---

## Como rodar

```bash
# Exemplos (Tails com Tor):
~/Persistent/hub-scripts/hub.sh install --qa-log          # 1ª vez (Enter nos prompts = backup + qa finalize)
~/Persistent/hub-scripts/hub.sh boot --qa-log             # cada sessão
~/Persistent/hub-scripts/hub.sh backup --qa-log           # backup carteira
~/Persistent/hub-scripts/hub.sh feather --qa-log          # Feather (passo 5)
~/Persistent/hub-scripts/system/preflight.sh --qa-log     # só validar ambiente
~/Persistent/hub-scripts/system/post-session.sh --qa-log  # pós-upgrade Tails

# QA via hub.sh qa (recomendado — tela + log simultâneos):
~/Persistent/hub-scripts/hub.sh qa finalize               # validate + confirm-seed (1ª vez, 1 vez)
~/Persistent/hub-scripts/hub.sh qa validate               # revalidar scripts a qualquer momento
~/Persistent/hub-scripts/hub.sh qa confirm-seed           # após anotar seed no papel (passo 4)
~/Persistent/hub-scripts/hub.sh qa confirm-step9          # passo 9 — 2 cópias físicas
~/Persistent/hub-scripts/hub.sh qa confirm-step12         # passo 12 — Tails SEM rede

# Exportar para equipe / outro PC:
~/Persistent/hub-scripts/hub.sh qa export-logs --usb
```

**Host Debian (passo 10):**

```bash
./whonix-verify-image.sh --qa-log Whonix-*.ova Whonix-*.ova.asc
```

---

## O que NUNCA deve aparecer no log

- As 25 palavras da seed  
- Senhas (conta Haveno, GPG do backup)  
- View key / spend key completas  
- TX ID completo (no passo 12: só prefixo + `[BORRADO]`)

Se aparecer → **apague o arquivo**, refaça o passo, não compartilhe.

---

## Tabela PASS / FAIL

| Arquivo (prefixo) | PASS se contém | FAIL se |
|-------------------|----------------|---------|
| `01-preflight-*` | `Tor conectado (IsTor: true)` + `RESULTADO: PASS` | `Preflight FALHOU` ou `RESULTADO: FAIL` |
| `02-haveno-auto-*` | `Dependencias do .deb OK` + `RESULTADO: PASS` | `install.sh falhou`, `Failed to download Haveno signature`, ou `RESULTADO: FAIL` |
| `03-haveno-boot-*` / `07-haveno-boot-*` | `Haveno instalado` + `RESULTADO: PASS` | `ERRO:` fatal ou `RESULTADO: FAIL` |
| `04-haveno-backup-*` | `Backup concluido:` + `RESULTADO: PASS` | `ERRO:` ou `RESULTADO: FAIL` |
| `04-seed-papel-*` | 3× `CONFIRMACAO_HUMANA: ...=SIM` + `RESULTADO: PASS` | qualquer `=NAO` ou ausência de `RESULTADO: PASS` |
| `qa-validate-*` | `QA Validate: PASS` + `RESULTADO: PASS` | `FAIL —` ou `RESULTADO: FAIL` |
| `05-feather-*` | `Fingerprint OK: 8185E158` + `VALIDSIG 8185E158` | `Assinatura GPG FALHOU` |
| `06-haveno-update-*` | `Novo .deb verificado e preparado` + `RESULTADO: PASS` | `Atualizacao falhou` ou `RESULTADO: FAIL` |
| `07-post-session-*` | `Haveno instalado` + `RESULTADO: PASS` | `ERRO:` fatal |
| `09-seed-confirmacao-*` | 3 confirmações `=SIM` | qualquer `=NAO` |
| `12-cold-signing-*` | `tails_offline_airgap=SIM` + confirmações `=SIM` | campo crítico `=NAO` |
| `10-whonix-verify-*` | `Good signature: SIM` + fingerprint Whonix | ausente |

---

## Exemplo — log bom (passo 4 backup)

```text
=== 04-haveno-backup — 2026-06-08T15:00:00 ===
...
Backup concluido: /home/amnesia/Persistent/Backups/haveno-data-....tar.gz.gpg
REDE: tails_online_tor_esperado=SIM
exit_code: 0
RESULTADO: PASS
```

Depois rode `~/Persistent/hub-scripts/hub.sh qa confirm-seed` e confira `04-seed-papel-*.txt`.

---

## Glossário rápido (online × offline)

| Termo | Significado |
|-------|-------------|
| **Online (Tor)** | Tails com rede só via Tor — passos 1–9 na trilha. |
| **Offline (suporte)** | Seed em papel — pode ser com Tor ativo. |
| **Offline (rede)** | Tails sem Wi‑Fi/cabo — passo **12** only. |

Ver também: [README — o que você vai aprender (12 passos)](../../README.md#o-que-você-vai-aprender-12-passos).

---

## Se deu FAIL

1. Leia a linha `ERRO:` ou `Preflight FALHOU` no `.txt`.  
2. **`02-haveno-auto` no [6/9]:**
   - **Progresso:** linhas `[download] [########----] NN%` (a cada 10s) ou barra curl no `.deb`/`.sig`.
   - **`.deb` ~266 MB só em `.download/`:** `sync-hub-scripts.sh` + `hub.sh install --qa-log` (promove para `Install/`).
   - **Já em `Install/`:** `hub.sh install --install-only`.
   - Alternativa: [TRES-PASSOS — fallback atômico](TRES-PASSOS-HAVENO-TAILS.md).  
3. Consulte `automacao/tails/docs/TROUBLESHOOTING.md` — tabela de diagnóstico por mensagem de erro.  
4. Corrija e rode de novo com `--qa-log`.  
5. **Não** edite o `.txt` à mão para fingir PASS.

---

*Privacy-OS-Hub · Scripts · validação por evidência · jun/2026*
