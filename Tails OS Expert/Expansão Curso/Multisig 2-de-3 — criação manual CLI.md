# Anexo — Multisig 2-de-3: criação manual CLI

> **Não omitimos este caminho.** O aluno escolhe: para **trades no Haveno**, o app cria o escrow **automaticamente**
> (Cap. 10 do Volume II). Este anexo ensina **multisig Monero manual** via `monero-wallet-cli` — laboratório,
> entendimento do protocolo, carteiras compartilhadas fora do Haveno ou arbitragem avançada.

**Comandos só:** [`Playbooks — Multisig CLI.md`](Playbooks%20—%20Multisig%20CLI.md)

---

## 1. Quando usar vs. quando NÃO

| Situação | Precisa deste anexo? |
|----------|----------------------|
| **Tradear no Haveno** (escrow por trade) | **Não** — o protocolo cria multisig 2-de-3 **sozinho** ao aceitar/criar oferta ([Cap. 10](Curso%20—%20Rede%20Descentralizada%20(Extensão).md#10-multisig-2-de-3--o-que-você-faz-vs-o-que-o-app-faz)) |
| **Entender** como 2-de-3 funciona na prática | **Sim** — leitura + exercício em testnet/stagenet |
| **Carteira multisig Monero** fora do Haveno (2-of-3 entre pessoas) | **Sim** — fluxo completo abaixo |
| **Árbitro / infra Haveno** (panorama) | Ver Cap. 17 do Volume II; este anexo é **carteira**, não rede Haveno |

---

## 2. Avisos load-bearing (leia antes)

- Multisig no Monero é **experimental** no CLI. Antes de qualquer comando:
  ```text
  set enable-multisig-experimental 1
  ```
- A documentação oficial lista riscos: fundos podem ficar **irrecuperáveis**, gastos duplos ou roubo por participante malicioso se o setup falhar.
- `prepare_multisig` **inclui a view key privada** na string `MultisigV1…` — troque só por **canal seguro** entre os participantes da **mesma** carteira multisig.
- **Nunca** misture strings de participantes de **outras** carteiras ou ordens erradas.
- Confirme comandos na versão do seu `monero-wallet-cli` — a doc muda: https://docs.getmonero.org/multisignature/

---

## 3. Onde rodar no hub (Cold-Tails / Hot-Whonix)

| Papel | Máquina | Por quê |
|-------|---------|---------|
| Participante que **assina** gastos | **Tails offline** (ou cada participante na sua máquina fria) | Spend keys não tocam rede |
| Sincronizar / montar tx (opcional) | **Whonix Workstation** | Tor + nó `.onion` — só se **view-only** ou participante quente acordado |

Guia Whonix (referência oficial): https://www.whonix.org/wiki/Monero_Multisig

Para **laboratório**, use **stagenet** ou **testnet** — nunca aprenda com mainnet e fundos reais.

---

## 4. Fluxo 2-de-3 (três participantes, threshold 2)

Cada um dos **três** participantes cria (ou abre) uma carteira normal no CLI e habilita multisig experimental.

### Passo A — `prepare_multisig` (cada participante)

Cada um executa no **seu** `monero-wallet-cli`:

```text
set enable-multisig-experimental 1
set inactivity-lock-timeout 0
prepare_multisig
```

**Saída:** string longa começando com `MultisigV1…` (ou `MultisigxV2…` conforme versão).

**OK se:** cada participante tem **uma** string própria; nenhuma foi enviada por canal inseguro (e-mail, Discord).

### Passo B — Troca segura

Os três participantes trocam as strings `MultisigV1…` por canal acordado (presencial, SimpleX cifrado, etc.).

### Passo C — `make_multisig` (cada participante)

Cada um roda com o **threshold** e as strings dos **outros dois** (não a sua):

```text
make_multisig 2 <MultisigV1_do_participante_B> <MultisigV1_do_participante_C>
```

(substitua pelos dados reais; cada carteira usa as strings dos **outros**)

**OK se:** o CLI confirma criação multisig; cada participante obteve **nova** string de saída.

### Passo D — `exchange_multisig_keys` (cada participante — **duas rodadas**)

Em **2-de-3**, a doc oficial exige **mais de uma rodada** de troca: cada participante executa com as **novas** strings do passo C, troca a saída de novo e repete até **todos** concluírem.

**Rodada 1** — cada participante:

```text
exchange_multisig_keys <nova_string_do_B> <nova_string_do_C>
```

**Rodada 2** — troque as **novas** strings geradas na rodada 1 e execute de novo (mesmo comando, dados atualizados):

```text
exchange_multisig_keys <string_rodada2_B> <string_rodada2_C>
```

Repita até o CLI indicar que a troca está completa para os três.

**OK se:** `wallet info` (ou equivalente) mostra carteira **multisig** com threshold **2/3**; endereço compartilhado **igual** nos três CLIs.

---

## 5. Receber fundos

Depois do setup completo, qualquer participante pode exibir o endereço multisig:

```text
address
```

Envie **teste mínimo** antes do grosso.

**OK se:** saldo aparece em **pelo menos dois** dos três CLIs após sincronização.

---

## 6. Gastar (resumo)

1. Um participante monta a transação:
   ```text
   transfer <ENDERECO> <VALOR>
   ```
   Gera arquivo `multisig_monero_tx` (nome pode variar).

2. **Exportar** info de assinatura (cada co-signatário necessário) — **com arquivo de saída**:
   ```text
   export_multisig_info multisig_info.txt
   ```

3. **Importar** info dos outros (troque o arquivo por canal seguro):
   ```text
   import_multisig_info multisig_info_do_outro.txt
   ```

4. **Assinar:**
   ```text
   sign_multisig multisig_monero_tx
   ```

5. Quando threshold atingido, **transmitir** (qualquer participante com daemon):
   ```text
   submit_multisig multisig_monero_tx
   ```

**OK se:** tx confirmada on-chain; saldo atualizado nos três CLIs.

Detalhes e variantes: https://docs.getmonero.org/multisignature/ (seções *Spending*).

---

## 7. Relação com Haveno

No **Haveno**, cada trade abre uma carteira multisig **2-de-3** (você + contraparte + árbitro) **sem** você rodar
`prepare_multisig` manualmente. Este anexo **complementa** o Cap. 10 — não substitui o fluxo de trade.

---

## 8. Links oficiais

| Tema | Link |
|------|------|
| Multisig Monero (doc primária) | https://docs.getmonero.org/multisignature/ |
| Whonix + Monero multisig | https://www.whonix.org/wiki/Monero_Multisig |
| Haveno — o que o app faz (Cap. 10) | [Curso — Rede Descentralizada (Extensão).md](Curso%20—%20Rede%20Descentralizada%20(Extensão).md#10-multisig-2-de-3--o-que-você-faz-vs-o-que-o-app-faz) |

---

*Anexo Volume II · Privacy-OS-Hub. Use stagenet/testnet para praticar. Confirme comandos na doc oficial antes de mainnet.*
