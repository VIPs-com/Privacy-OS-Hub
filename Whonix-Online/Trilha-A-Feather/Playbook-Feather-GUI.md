# Trilha A — Feather (GUI) · Playbook cold-signing

> ✅ **Trilha recomendada** (interface gráfica). Você está na **Trilha A** — siga **só** este arquivo do início ao fim. **Não** use comandos da Trilha B (`monero-wallet-cli`) no meio; a carteira nasce e morre no Feather.
>
> ⬅️ Veio sem passar pelo mapa? Leia antes [`../00-Comece-aqui-Escolha-sua-trilha.md`](../00-Comece-aqui-Escolha-sua-trilha.md) (pré-requisitos + regras de ouro). Teoria/“porquê”: [`../Curso-Whonix-Online.md`](../Curso-Whonix-Online.md) (Cap. 5).

**Pré-requisito:** [Módulo 1 (Tails + Haveno)](../../Tails-OS-Expert/README.md) concluído — seed, Feather **completo** no Tails, verificação de binários.

> 🔒 **Regra inegociável:** a **seed / spend key vive só na máquina FRIA (Tails, bootado offline)**. O Whonix é **view-only**: vê saldo, monta, transmite — **nunca** assina.

---

## Mapa do fluxo (o que cruza por USB, nunca por rede)

```text
  TAILS offline (FRIO)                          WHONIX online (QUENTE)
  Feather COMPLETO                              Feather VIEW-ONLY
  seed + view key + SPEND key                   endereço + view key + restore height
        │  (0) address + viewkey + restore height ───────►│  cria view-only
        │◄──── (1) outputs ───────────────────────────────│  exporta outputs
        │───── (2) key images ───────────────────────────►│  importa key images
        │◄──── (3) transação NÃO-ASSINADA ────────────────│  monta a tx
        │───── (4) transação ASSINADA ───────────────────►│  transmite
   ASSINA offline                                    BROADCAST via Tor/seu nó
```

> Dedique **um pendrive** ao trânsito frio↔quente. Nada de rede no lado frio, **nunca**.

---

## A — Whonix pronto (pré-requisitos)

# Lado FRIO (Tails): boot **offline** (desconecte Wi-Fi/cabo **antes** de ligar o Tails).
# Só então abra o Feather com a carteira **completa** — spend key nunca em rede.

# Imagem verificada (fingerprint 916B8D99…2EEACCDA) + Gateway/Workstation atualizados — Curso Cap. 2–3.
# Feather verificado por PGP (8185E158…CEFBA71C) — Curso Cap. 4.3.

# OK se: Workstation navega só via Gateway; Feather sincroniza via Tor (saldo 0 é normal no início).

---

## A1 — Criar a view-only no Whonix

# Na carteira FRIA (Feather/Tails) pegue 3 coisas:
#   - Endereço primário (começa com 4)
#   - Secret VIEW key  (a de VISÃO — nunca a spend key/seed!)
#   - Restore height   (altura de criação — sem ela, não enxerga os fundos)

# No Whonix (Feather): Create new wallet -> View only
#   -> cole endereço + secret view key + restore height
#   -> "Always over Tor" -> conecte ao seu nó .onion:18089 (Curso 4.1)

# OK se: a view-only mostra o MESMO saldo da fria — sem ter a chave de gasto.
# Saldo antigo não aparece? restore height alto demais -> recrie com a altura correta (não é perda).

## A2 — Sincronizar (obrigatório no 1º envio e quando o saldo parecer velho)

# (Quente/Whonix)  view-only -> exportar OUTPUTS -> arquivo no USB
# O nome do arquivo e' gerado pelo Feather (varia por versao) — aceite o padrao da UI ou anote o nome antes de mover o USB.
# (Frio/Tails)     carteira completa -> importar outputs -> exportar KEY IMAGES -> USB
# (Quente/Whonix)  importar key images -> saldo e gastos ficam corretos

## A3 — Gastar (montar quente, assinar frio, transmitir quente)

# (Quente/Whonix)  monte a tx (destino + valor) -> gera transação NÃO-ASSINADA (arquivo USB)
# (Frio/Tails)     importe a não-assinada -> CONFIRA destino e valor NA TELA DA FRIA -> assine -> ASSINADA (USB)
# (Quente/Whonix)  importe a assinada -> transmita (broadcast) via Tor/seu nó

# 🔎 A máquina FRIA é a fonte de verdade: confira o endereço nela antes de assinar (malware quente pode trocar).
# OK se: a view-only transmite uma tx assinada no Tails offline; a spend key nunca esteve em rede.

> O Feather faz o air-gap por **QR animado (UR) via webcam** (método primário na doc) **ou** por **arquivos via USB/SD**. No par Tails↔Whonix, **arquivos via USB** costumam ser mais simples. Siga a UI atual em [offline-tx-signing](https://docs.featherwallet.org/guides/offline-tx-signing).

---

## Regras de ouro (não pule)

- **Teste com valor mínimo** o fluxo inteiro antes do grosso.
- **Backups da FRIA:** seed em papel/metal **offline** (DUAS cópias, locais separados) + pasta de dados cifrada (Módulo 1 §5.2). Tails é amnésico — mídia que corrompe = **perda total**.
- **View-only é descartável:** recria-se de endereço + view key + restore height. Anote o **restore height**.
- **Re-sincronize key images após cada envio** (troco).
- **Spend key/seed nunca** é digitada, colada ou fotografada numa máquina online. Se acontecer uma vez, a carteira deixou de ser fria → **migre os fundos**.
- **Haveno é exceção** (quente, escrow ao vivo): leve só o valor do trade ao quente; após operar, saque o excedente para o frio (Curso Cap. 6).

> 💡 Para o **grosso** sem hardware proprietário: reforce **backups** ([`Playbook-Backup-e-protecao-air-gap.md`](../Playbook-Backup-e-protecao-air-gap.md)). Trezor/Ledger é **opcional** — Curso §5.6.

---

## Fontes oficiais (confirme antes de mover dinheiro real)

| Tema | Link |
|------|------|
| Feather — assinatura offline | https://docs.featherwallet.org/guides/offline-tx-signing |
| Feather — criar view-only | https://docs.featherwallet.org/guides/create-view-only-wallet |
| Feather (Tor) | https://docs.featherwallet.org/guides/tor-support |
| Whonix — Monero | https://www.whonix.org/wiki/Monero |
| Livro do módulo (teoria) | [`../Curso-Whonix-Online.md`](../Curso-Whonix-Online.md) (Cap. 5) |
| Mapa de decisão das trilhas | [`../00-Comece-aqui-Escolha-sua-trilha.md`](../00-Comece-aqui-Escolha-sua-trilha.md) |

---

*Privacy-OS-Hub · Módulo 2 · Trilha A (Feather/GUI). Comandos verificados em fonte oficial (jun/2026).
A UI muda por versão — confirme na doc acima e **comece com valores mínimos**.*
