# Etapas — Instalar Haveno no Tails (1 processo = 1 script)

> **Por que esta pasta existe:** no piloto de 2026-06-10, o fluxo monolítico
> (`haveno-auto.sh` → `haveno-common.sh` → `haveno-install.sh` upstream) quebrou
> em 3 pontos diferentes e ninguém sabia **onde**. Aqui cada script faz **um**
> processo, imprime **PASS ou FAIL** com instrução do próximo passo, e pode ser
> re-rodado sem estragar nada (idempotente). Quebrou? Você sabe exatamente qual
> arquivo abrir e o que atualizar.
>
> **Guia do aluno (3 passos + fallback):** [TRES-PASSOS-HAVENO-TAILS.md](../../../docs-aluno/TRES-PASSOS-HAVENO-TAILS.md)

## Como usar (uma etapa de cada vez — ritmo humano)

```bash
cd ~/Persistent/Privacy-OS-Hub-main/automacao/tails/etapas/instalar-haveno
chmod +x *.sh

./01-pastas.sh                  # espere PASS, então:
./02-baixar-deb.sh              # 30–90 min pelo Tor, com % e retomada
./04-importar-chave.sh          # confira o fingerprint COM OS OLHOS
./05-verificar-assinatura.sh    # à prova de idioma (PT-BR ok)
./06-deps-apt.sh                # tabela clara do que falta
./07-instalar-deb.sh            # (--force-depends só se o 06 mandar)
./08-abrir-haveno.sh            # gate final: VERDE na janela
```

Quer registrar evidência? Acrescente ` 2>&1 | tee ~/Persistent/qa-logs/etapa-XX.txt` a qualquer linha.

## Mapa: qual script mexer quando algo mudar

| Script | Único processo que faz | Quando atualizar |
|--------|------------------------|------------------|
| `_config.sh` | **Só constantes** (URL, fingerprint, pastas) | **Novo release da Reto** → edite as 3 linhas do bloco "Release" e mais nada |
| `01-pastas.sh` | `mkdir` das pastas na persistência | Mudança de layout de pastas |
| `02-baixar-deb.sh` | Download .deb + .sig **direto na persistência**, com % e retomada | URL/CDN mudar comportamento |
| `03-resgatar-tmp.sh` | Socorro: acha .deb perdido em `/tmp` e copia p/ persistência | — (ferramenta de resgate, fora da sequência) |
| `04-importar-chave.sh` | Importa chave Reto + confere fingerprint | Chave/fonte da chave mudar |
| `05-verificar-assinatura.sh` | `gpg --status-fd` + `VALIDSIG` amarrado ao fingerprint | Nunca por idioma (já é locale-proof) |
| `06-deps-apt.sh` | Lê `Depends` de dentro do .deb e confere no apt | Não precisa: lê do próprio .deb |
| `07-instalar-deb.sh` | Limpa estado dpkg quebrado + `dpkg -i` | Política de instalação mudar |
| `08-abrir-haveno.sh` | onion-grater + abrir o app | Tails mudar o onion-grater |
| `TUDO.sh` | Chama 01→08 em ordem, para no 1º FAIL | Só quando entrar/sair etapa |

**Regra de ouro:** script não chama script (exceção: todos leem `_config.sh`,
que é só uma lista de constantes, e o `TUDO.sh`, que é só a sequência).

## O que esta pasta corrige do piloto 2026-06-10

- **PGP "falhava" em português** (DIV-20260610-01): o `05` usa a saída de
  máquina do gpg (`--status-fd`/`VALIDSIG`) — funciona em qualquer idioma.
- **.deb de 255 MB morria em `/tmp`** (DIV-20260610-03): o `02` baixa direto na
  persistência com porcentagem e retomada; o `03` resgata downloads antigos de `/tmp`.
- **Dependências Ubuntu inexistentes no Tails** (DIV-20260610-02): o `06` lê as
  dependências de dentro do próprio .deb, mostra exatamente o que não existe e
  oferece o caminho documentado (`07 --force-depends`) — sem o `apt-get install -f`
  que removeria o pacote.
- **`.sig` rejeitada por script antigo** (DIV-20260617-02 → fix 2026-06-18): a `.sig`
  do release 1.6.0-reto é uma assinatura **Ed25519 binária legítima de 119 B** (OpenPGP
  `0x88` + fingerprint `DAA24D...`). O script antigo esperava ASCII-armored (`>= 400 B` +
  `BEGIN PGP SIGNATURE`) e descartava a sig válida. Fix: `HAVENO_SIG_MIN_BYTES=60` +
  `haveno_sig_valid_format()` aceita `0x88/0x89/0xC2` ou armored. `sync-hub-scripts.sh`
  distribui a versão corrigida.

## Validação em campo

| Data | Resultado |
|------|-----------|
| 2026-06-11 | Cookie Tor + filtro PoW (`08-abrir-haveno.sh`) — RetoSwap verde |
| 2026-06-17 03:54 GMT | Passo 2 **VERDE** via `02-baixar-deb.sh` → `08` (piloto B+) |
| 2026-06-18 | `.sig` Ed25519 binária (119 B) — script corrigido (`haveno_sig_valid_format`); `02-baixar-deb.sh` e `haveno-predownload_sig` PASS |

## Relação com os scripts antigos

`haveno-setup.sh` / `haveno-auto.sh` **continuam sendo o caminho padrão** do aluno.
Esta pasta é o **fallback** e a base da reorganização modular (Rodada 1).

1. ✅ `instalar-haveno/` — esta pasta (**validada** em Tails 11/jun e 17/jun)
2. ⏳ `sessao-diaria/` — o que o `haveno-boot.sh` faz hoje
3. ⏳ `backup/` — o que `haveno-backup.sh` faz hoje
4. ⏳ `atualizar/` — o que `haveno-update.sh` faz hoje (com o fix do DIV-20260610-04)
5. ⏳ aposentar os monolíticos (só quando TODAS as rodadas tiverem PASS em campo)

---
*Rodada 1 da reorganização modular · piloto B+ · validada em Tails real · jun/2026*
