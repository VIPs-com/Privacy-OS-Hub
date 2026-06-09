# Playbooks — Tails OS Expert (índice)

> **v2 — canônico em [`processos/`](../../../processos/README.md).** Este arquivo é **índice** + links essenciais. Comandos completos nos cartões abaixo.

Direto ao ponto. Fundamentos e telas: [`../Curso-Tails-OS-Expert.md`](../Curso-Tails-OS-Expert.md). Automação: [`../../../automacao/tails/`](../../../automacao/tails/README.md).

**Ordem obrigatória.** Tails **7.8.1+**. Rede turma: **Reto `1.6.0-reto`**.

---

## Índice → processos

| Seção antiga | Passo hub | Processo |
|--------------|:---------:|----------|
| §1–4 Bootstrap | 1 | [P01](../../../processos/m1-tor/P01-bootstrap-tails.md) |
| §5–6, §8 Haveno verde | 2 | [P02](../../../processos/m1-tor/P02-haveno-verde.md) |
| §3b Pré-trade | 3 | [P03](../../../processos/m1-tor/P03-pre-trade.md) |
| §9 Backup | 4 | [P04](../../../processos/m1-tor/P04-backup-seed.md) |
| Vol II Feather | 5 | [P05](../../../processos/m1-tor/P05-feather.md) |
| Folheto | 6 | [P06](../../../processos/m1-tor/P06-folheto.md) |
| §7, §10 Rotina | 7 | [P07](../../../processos/m1-tor/P07-rotina-scripts.md) |

---

## Manual ou automático?

Passos **1–4** são sempre manuais. Do **5** em diante, você pode automatizar.

**Antes de automatizar:** copie os scripts para `~/Persistent/` uma vez ([`../../../automacao/tails/README.md`](../../../automacao/tails/README.md) → "Ciclo de uso").

```bash
~/Persistent/haveno-auto.sh
```

---

## Links essenciais

```text
Tails install   https://tails.net/install/index.en.html
haveno-install   https://github.com/haveno-dex/haveno/blob/master/scripts/install_tails/haveno-install.sh
haveno.yml       https://github.com/haveno-dex/haveno/blob/master/scripts/install_tails/assets/haveno.yml
Reto releases    https://github.com/retoaccess1/haveno-reto/releases
Reto PGP         https://retoswap.com/reto_public.asc
```

**Volume II:** [`../Expansao-Curso/Playbooks-Rede-Descentralizada.md`](../Expansao-Curso/Playbooks-Rede-Descentralizada.md) · teoria: [`../Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md`](../Expansao-Curso/Curso-Rede-Descentralizada-Extensao.md)

*Índice Volume I · Reto 1.6.0-reto · jun/2026.*
