# Como ler seus logs de validação (QA)

> **Para o aluno:** saber se o passo deu certo **sem adivinhar** — e **sem** expor seed, senha ou chaves.

---

## Onde ficam os arquivos

| Ambiente | Pasta |
|----------|--------|
| **Tails** | `~/Persistent/qa-logs/*.txt` |
| **Host Linux (Whonix)** | `~/whonix-download/qa-logs/*.txt` (com `--qa-log`) |

Ative gravação com **`--qa-log`** nos scripts (ou `haveno-setup.sh --qa-log`).

---

## Como rodar

```bash
chmod +x ~/Persistent/*.sh

# Exemplos (Tails com Tor):
~/Persistent/tails-preflight.sh --qa-log
~/Persistent/haveno-setup.sh --qa-log
~/Persistent/haveno-backup.sh --qa-log
~/Persistent/feather-install-verify.sh --qa-log
~/Persistent/post-session-check.sh --qa-log
~/Persistent/qa-confirm-seed-papel.sh    # apos anotar seed no papel
~/Persistent/qa-confirm-passo9.sh        # passo 9 — 2 copias fisicas
~/Persistent/qa-confirm-passo12.sh       # passo 12 — Tails SEM rede

# Exportar para equipe / outro PC:
~/Persistent/qa-export-logs.sh --usb
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
| `04-haveno-backup-*` | `Backup concluido:` + `RESULTADO: PASS` | `ERRO:` ou `RESULTADO: FAIL` |
| `04-seed-papel-*` | 3× `CONFIRMACAO_HUMANA: ...=SIM` | qualquer `=NAO` |
| `05-feather-*` | `Fingerprint OK: 8185E158` + `VALIDSIG 8185E158` | `Assinatura GPG FALHOU` |
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

Depois rode `qa-confirm-seed-papel.sh` e confira `04-seed-papel-*.txt`.

---

## Glossário rápido (online × offline)

| Termo | Significado |
|-------|-------------|
| **Online (Tor)** | Tails com rede só via Tor — passos 1–9 na trilha. |
| **Offline (suporte)** | Seed em papel — pode ser com Tor ativo. |
| **Offline (rede)** | Tails sem Wi‑Fi/cabo — passo **12** only. |

Ver também: [README — trilha linear](../../README.md#trilha-linear).

---

## Se deu FAIL

1. Leia a linha `ERRO:` ou `Preflight FALHOU` no `.txt`.  
2. Volte ao passo certo em [README → Travou aqui?](../../README.md#travou-aqui) (cada situação → passo + processo P0x).  
3. Corrija e rode de novo com `--qa-log`.  
4. **Não** edite o `.txt` à mão para fingir PASS.

---

*Privacy-OS-Hub · Scripts · validação por evidência · jun/2026*
