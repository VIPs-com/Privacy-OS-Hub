# Trilha opcional — Baseline de proteção: cofre, PGP e backup 3-2-1 off-site

> **Quando:** só **depois** dos passos 1–12 · **Pré-requisito:** Módulo 1 (idealmente também o 2)
> **Não misture** com a trilha principal. Aqui você **protege** o que já criou — não instala nada novo.

Esta página entrega o **processo** de proteção usando o que você **já tem** neste curso.
Para o curso completo e prático (gerar sua própria chave PGP, cofre de senhas, SSH endurecido,
ferramentas de backup), o material dedicado é o **[Zero-Trust-Core](#aprofundar--zero-trust-core-curso-dedicado)** — você não precisa sair daqui para começar.

---

## O que você já tem para proteger

| Ativo | De onde veio | Natureza |
|-------|--------------|----------|
| **Seed do Haveno** (papel) | [Passo 4](../passos/passo-04.md) · [P04](../../processos/m1-tor/P04-backup-seed.md) | Segredo — **só** físico (papel/metal) |
| **Backup cifrado do Haveno** (`Data/`) | `haveno-backup.sh` · [automação Tails](../../automacao/tails/README.md) | Arquivo `.gpg` — pode ir a mídia digital |
| **Seed/carteira Feather** | [Passo 5](../passos/passo-05.md) · `feather-backup.sh` | Segredo (seed) + arquivo de carteira |
| **2× cópias físicas da seed** | [Passo 9](../passos/passo-09.md) · [P09](../../processos/rituais/P09-ritual-seed.md) | Já é o começo do 3-2-1 |
| **Backup air-gap (M2)** | [Playbook backup air-gap](../../modulos/m2-whonix-custodia/Playbook-Backup-e-protecao-air-gap.md) | Procedimento offline |
| **Hábito de verificar PGP** (fail-closed) | Passos 5 e 10 | Você já **usa** PGP — falta **ser dono** de uma chave |

> A regra de ouro continua valendo (ver [Folheto](../../modulos/m1-tails-haveno/Folheto-Regras-e-Golpes.md)):
> **a seed nunca vira foto, arquivo, chat ou nuvem.** Tudo nesta página respeita isso.

---

## 1. A regra 3-2-1 (o princípio)

| Número | Significa | No seu caso |
|:------:|-----------|-------------|
| **3** | três cópias do que importa | a "original" + 2 backups |
| **2** | em **duas mídias diferentes** | ex.: papel/metal **e** pendrive cifrado |
| **1** | **uma off-site** (fora de casa) | uma cópia longe do local principal (incêndio/roubo) |

**Atenção — dois fluxos diferentes, não confunda:**

- **Seed (as 25 palavras):** o 3-2-1 dela é **100% físico** — papel/metal, em **locais separados** (você já começou no [Passo 9](../passos/passo-09.md)). A seed **nunca** entra em arquivo, nuvem ou pendrive, **mesmo cifrada**.
- **Backup cifrado** (`Data/` do Haveno, carteira Feather): é um arquivo `.gpg`/cifrado. Esse **pode** ir para 2 pendrives + 1 cópia off-site (até numa nuvem), **porque está cifrado**. A **senha** do backup é outro segredo — guarde-a **separada** do backup.

> **OK se:** você consegue apontar, agora, **onde** estão as 3 cópias da sua seed e as 3 do seu backup cifrado — e nenhuma delas é uma foto no celular.

---

## 2. O cofre (onde e como guardar)

**Físico (seed):**
- 2 locais **diferentes** (ex.: casa + casa de confiança / cofre alugado). Off-site = o 2º local.
- Papel resiste pouco a água/fogo; **metal** (placa de aço) é a evolução opcional — custo extra, mesmo papel das palavras.
- Nunca rotule "SEED MONERO" no envelope. Discrição faz parte do cofre.

**Digital (backup cifrado + senhas):**
- Backup cifrado em **2 mídias** (ex.: 2 pendrives) + **1 off-site**.
- A **senha** do backup e a **senha do Persistent do Tails** são segredos à parte. Memorize ou use um **gerenciador de senhas** (o cofre de senhas é exatamente o que o Zero-Trust-Core ensina a montar).
- Teste a **restauração** pelo menos uma vez: um backup que você nunca abriu pode estar corrompido.

**Na prática — o backup do Haveno já faz o 3-2-1 digital para você:**

```bash
~/Persistent/haveno-backup.sh                 # compacta Data/ + cifra (GPG, senha) + gera .sha256
~/Persistent/haveno-backup.sh --usb           # mesmo backup salvo num pendrive montado = sua 2ª mídia / cópia off-site
sha256sum -c haveno-data-AAAAMMDD-HHMMSS.tar.gz.gpg.sha256   # conferir integridade depois
~/Persistent/haveno-backup.sh --restore haveno-data-...tar.gz.gpg   # restaurar (salva cópia do estado atual antes)
```

- Saída: um `.tar.gz.gpg` **cifrado por senha** + um `.sha256` para detectar corrupção. O que viaja no backup é a pasta `~/Persistent/haveno/Data/` — **carteira, histórico de trades e contas de pagamento**. Detalhe: [P04](../../processos/m1-tor/P04-backup-seed.md) · [Curso §5.1 — onde ficam os dados](../../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#51-carteira--criar-restaurar-onde-ficam-os-dados) · [scripts](../../automacao/tails/README.md). A carteira **Feather** tem o equivalente `feather-backup.sh`.
- **Feche o Haveno antes** de rodar (não copiar carteira em uso).
- A **seed não entra** neste arquivo — anote-a em papel à parte (a regra de ouro acima). **`Seed ≠ backup completo`:** a seed recupera os *fundos*, mas **não** o histórico de trades nem as contas de pagamento — para restauração fiel é preciso o backup da pasta `Data/`.
- Guarde a **senha** do backup **separada** do `.gpg`; mantenha o `.gpg` **offline**.

> **OK se:** seed em 2 locais físicos separados · backup cifrado em 2 mídias + 1 off-site · senha do backup guardada **fora** do backup · você já restaurou um backup de teste com sucesso.

**Manter no tempo — atualizar com backup antes:** quando sua rede publicar uma versão nova do Haveno, **backup primeiro, atualizar depois** — os dados em `Data/` são preservados. O `~/Persistent/haveno-update.sh` já faz o backup antes ([Curso §5.3](../../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md#53-atualizar-o-haveno-com-backup-antes) · [scripts](../../automacao/tails/README.md)). O **Tails** (sistema) atualize só pelo **Tails Upgrader** — **nunca por script**.

---

## 3. PGP — de "verificar" para "ser dono da chave"

Você **já usa PGP** neste curso, no modo fail-closed: só prossegue quando a assinatura bate com o
fingerprint certo (Feather no [Passo 5](../passos/passo-05.md), Whonix no [Passo 10](../passos/passo-10.md)).
O **próximo nível** do baseline é ter a **sua própria** chave para **assinar** e **cifrar** seus arquivos e mensagens.

- **Mantenha o hábito fail-closed:** "Good signature" de uma chave **errada** não vale — confira o **fingerprint**, sempre.
- **Não misture redes/chaves:** a URL de download e a chave PGP têm de ser **da mesma** fonte e release.
- **Gerar uma chave PGP de longo prazo** pede planejamento de armazenamento (não é para criar de qualquer jeito num Tails amnésico). O **passo a passo** disso **não** está neste hub de propósito — fica no curso dedicado abaixo, para você fazer com calma e do jeito certo.

> **OK se:** você sabe diferenciar **verificar** a assinatura de outra pessoa (o que já faz) de **assinar/cifrar** com a sua própria chave (o que o curso dedicado ensina) — e entende por que o fingerprint manda.

---

## Aprofundar — Zero-Trust-Core (curso dedicado)

Quando quiser o **hands-on completo** de cofre, PGP do zero, backup 3-2-1 com ferramentas e SSH endurecido:

| Material | Link |
|----------|------|
| Início | [INICIE AQUI](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/trilha/INICIE-AQUI.md) |
| Livro | [Zero-Trust-Core-Expert](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/%F0%9F%8E%93%20Zero-Trust-Core-Expert%20-%20Vers%C3%A3o%201.0.md) |
| Playbooks | [playbooks/](https://github.com/VIPs-com/Zero-Trust-Core/tree/main/playbooks) |
| Só PGP, do zero ao expert | [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert) |

> **Ordem sugerida:** passos **1–12** → **esta página** (baseline com o que você já tem) → **Zero-Trust-Core** (aprofundar). Os repositórios são separados; você abre o ZTC só quando quiser ir além deste hub.

---

## Checklist — baseline de proteção atingido

- [ ] **3-2-1 da seed:** 3 cópias físicas, 2 locais separados, 0 cópias digitais.
- [ ] **3-2-1 do backup cifrado:** 2 mídias + 1 off-site; senha guardada separada.
- [ ] **Restauração testada** uma vez.
- [ ] **Cofre** definido (físico + digital), sem rótulos entregando o conteúdo.
- [ ] Entende **verificar ≠ assinar** em PGP e sabe onde aprofundar (ZTC / OpenPGP).

---

**Voltar:** [trilha linear (passos 1–12)](../../README.md#trilha-linear) · **Índice de trilhas:** [trilhas/](README.md)

*Opcional · trilha/trilhas · baseline de proteção (cofre · PGP · 3-2-1) · aprofundamento: Zero-Trust-Core*
