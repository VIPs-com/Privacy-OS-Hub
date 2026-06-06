# Playbooks — Multisig 2-de-3 manual CLI (só comandos)

**Teoria:** [`Multisig 2-de-3 — criação manual CLI.md`](Multisig%202-de-3%20—%20criação%20manual%20CLI.md)  
**Haveno trade (automático):** Volume II Cap. 10 — **não** precisa deste playbook para tradear.

> Use **stagenet/testnet** para praticar. Mainnet só após dominar o fluxo.

---

## Setup — cada participante (3 carteiras)

```bash
# Abrir CLI (ex.: stagenet + daemon; ajuste flags ao seu ambiente)
monero-wallet-cli --stagenet --daemon-address <URL_DO_DAEMON>

# Dentro do CLI:
set enable-multisig-experimental 1
set inactivity-lock-timeout 0
prepare_multisig
# Copie a string MultisigV1… — troque com os outros 2 participantes por canal seguro
```

---

## make_multisig — cada participante (threshold 2-of-3)

```bash
# Substitua pelas strings dos OUTROS dois participantes (não a sua):
make_multisig 2 <MultisigV1_participante_B> <MultisigV1_participante_C>
# Copie a NOVA string de saída — troque de novo com os outros
```

---

## exchange_multisig_keys — cada participante

```bash
exchange_multisig_keys <nova_string_B> <nova_string_C>
# Repita até todos os 3 participantes concluírem
# OK se: wallet info mostra multisig 2/3
```

---

## Receber

```bash
address
# Envie teste mínimo ao endereço exibido
```

---

## Gastar (2 assinaturas necessárias)

```bash
# Participante que monta:
transfer <ENDERECO> <VALOR>
# Gera multisig_monero_tx (nome pode variar)

# Cada co-signatário:
export_multisig_info
# Troque os arquivos/strings; depois:
import_multisig_info <info_do_outro>

# Assinar (quem falta):
sign_multisig multisig_monero_tx

# Transmitir (quando threshold atingido):
submit_multisig multisig_monero_tx
```

---

## Links

```text
Teoria (anexo)    Multisig 2-de-3 — criação manual CLI.md
Doc oficial       https://docs.getmonero.org/multisignature/
Whonix            https://www.whonix.org/wiki/Monero_Multisig
Haveno (app)      Curso — Rede Descentralizada (Extensão).md §10
```

*Playbooks Multisig CLI · Privacy-OS-Hub. Confirme na doc oficial antes de mainnet.*
