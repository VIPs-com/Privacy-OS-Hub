# Trilha B — monero-wallet-cli · Playbook cold-signing

> ⚙️ **Trilha avançada** (terminal). Você está na **Trilha B** — siga **só** este arquivo do início ao fim. **Não** use o Feather (Trilha A) no meio; a carteira nasce e morre no `monero-wallet-cli`.
>
> 💡 Quer o caminho mais simples? Use a **Trilha A (Feather)**. Esta trilha é para quem prefere terminal **ou** quer auditar o processo.
>
> ⬅️ Veio sem passar pelo mapa? Leia antes [`../00 — Comece aqui — Escolha sua trilha.md`](../00%20—%20Comece%20aqui%20—%20Escolha%20sua%20trilha.md) (pré-requisitos + regras de ouro). Teoria/“porquê”: [`../Curso — Whonix Online.md`](../Curso%20—%20Whonix%20Online.md) (Cap. 5).

**Pré-requisito:** [Módulo 1 (Tails + Haveno)](../../Tails%20OS%20Expert/README.md) concluído — seed, carteira **completa** no Tails, verificação de binários.

> 🔒 **Regra inegociável:** a **seed / spend key vive só na máquina FRIA (Tails, bootado offline)**. O Whonix é **view-only**: vê saldo, monta, transmite — **nunca** assina.

---

## Mapa do fluxo (o que cruza por USB, nunca por rede)

```text
  TAILS offline (FRIO)                          WHONIX online (QUENTE)
  carteira COMPLETA                             carteira VIEW-ONLY
  seed + view key + SPEND key                   endereço + view key + restore height
        │  (0) address + viewkey + restore height ───────►│  --generate-from-view-key
        │◄──── (1) outputs (export_outputs) ──────────────│  export_outputs
        │───── (2) key images (export_key_images) ───────►│  import_key_images
        │◄──── (3) unsigned_monero_tx (transfer) ─────────│  transfer (monta)
        │───── (4) signed_monero_tx (sign_transfer) ─────►│  submit_transfer
   ASSINA offline (sign_transfer)                    BROADCAST via Tor/seu nó
```

> Dedique **um pendrive** ao trânsito frio↔quente. Nada de rede no lado frio, **nunca**.

---

## B0 — Whonix pronto (pré-requisitos)

# Imagem verificada (fingerprint 916B8D99…2EEACCDA) + Gateway/Workstation atualizados — Curso Cap. 2–3.
# monero-wallet-cli verificado por PGP (binaryfate 81AC591F…2A0BDF92) — Curso Cap. 4.3.

# OK se: Workstation navega só via Gateway; o daemon remoto responde via Tor.

---

## B1 — Criar a view-only (no Whonix/QUENTE)

```bash
# pegue address + viewkey da carteira FRIA, depois:
monero-wallet-cli --generate-from-view-key NOME-VIEW \
  --daemon-address SEU_NO.onion:18089
```

```bash
# defina a altura (anterior à 1ª recepção) — senão sincroniza do bloco 0 (lento):
set refresh-from-block-height N
# (--generate-from-view-key pede só endereço + view key; a altura define-se aqui dentro)
```

# OK se: a view-only mostra o MESMO saldo da fria — sem ter a chave de gasto.

## B2 — Sincronizar gastos (repita após CADA envio — pega o TROCO)

# Nos comandos abaixo, o nome do arquivo é o CAMINHO no pendrive montado
# (ex.: /media/user/USB/outputs_file). Ajuste ao ponto de montagem do seu USB.

```bash
# QUENTE (view-only):
export_outputs outputs_file
```
```bash
# FRIO (carteira completa, Tails offline):
import_outputs outputs_file
export_key_images ki_file
```
```bash
# QUENTE (view-only):
import_key_images ki_file
```

> O passo mais esquecido. Sem re-sincronizar key images, a view-only não enxerga o troco e mostra saldo errado.
> 📖 A doc oficial do Monero mostra este ciclo **depois** do `submit_transfer` (para recuperar o troco). Aqui ele aparece adiantado por didática — **mesmos comandos, resultado equivalente**: o importante é rodá-lo no **1º uso** e **após cada envio**.

## B3 — Gastar

```bash
# QUENTE: monta a tx -> gera 'unsigned_monero_tx'
transfer ENDERECO VALOR
```
```bash
# FRIO: confira destino/valor na tela -> assina -> gera 'signed_monero_tx'
sign_transfer
```
```bash
# QUENTE: transmite via Tor/seu nó
submit_transfer
```

# 🔎 A máquina FRIA é a fonte de verdade: confira o endereço nela antes de assinar (malware quente pode trocar).
# OK se: o submit retorna o txid; a assinatura aconteceu na máquina fria.

---

## Regras de ouro (não pule)

- **Teste com valor mínimo** o fluxo inteiro antes do grosso.
- **Backups da FRIA:** seed em papel/metal **offline** (DUAS cópias, locais separados) + pasta de dados cifrada (Módulo 1 §5.2). Tails é amnésico — mídia que corrompe = **perda total**.
- **View-only é descartável:** recria-se de endereço + view key + restore height. Anote o **restore height**.
- **Re-sincronize key images após cada envio** (troco).
- **Spend key/seed nunca** é digitada, colada ou fotografada numa máquina online. Se acontecer uma vez, a carteira deixou de ser fria → **migre os fundos**.
- **Haveno é exceção** (quente, escrow ao vivo): leve só o valor do trade ao quente; após operar, saque o excedente para o frio (Curso Cap. 6).

> 💡 Para o **grosso**, considere **hardware wallet + Feather** (a spend key nunca sai do dispositivo, sem malabarismo de arquivos). A própria doc do Monero recomenda — Curso 5.5.

---

## Fontes oficiais (confirme antes de mover dinheiro real)

| Tema | Link |
|------|------|
| Monero — assinatura offline (cold) | https://docs.getmonero.org/cold-storage/offline-transaction-signing/ |
| Monero — carteira view-only | https://www.getmonero.org/resources/user-guides/view_only.html |
| Whonix — Monero | https://www.whonix.org/wiki/Monero |
| Livro do módulo (teoria) | [`../Curso — Whonix Online.md`](../Curso%20—%20Whonix%20Online.md) (Cap. 5) |
| Mapa de decisão das trilhas | [`../00 — Comece aqui — Escolha sua trilha.md`](../00%20—%20Comece%20aqui%20—%20Escolha%20sua%20trilha.md) |

---

*Privacy-OS-Hub · Módulo 2 · Trilha B (monero-wallet-cli). Comandos verificados em fonte oficial (jun/2026).
Os comandos exatos mudam por versão — confirme na doc acima e **comece com valores mínimos**.*
