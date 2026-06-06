# 00 — Comece aqui — Escolha sua trilha (Cold-Tails-Hot-Whonix)

Você vai montar a **custódia frio↔quente**: a **chave de gasto (seed) fica só no Tails offline** e o **Whonix online** apenas vê o saldo, monta a transação e transmite. Antes de abrir comandos, **escolha UMA trilha** e siga **só ela** do início ao fim.

> 📖 **Entenda o *porquê* primeiro** (modelo de ameaças, frio↔quente, view-only, riscos): leia o livro [`Curso — Whonix Online.md`](Curso%20—%20Whonix%20Online.md), Cap. 5. Este arquivo é o **mapa de decisão**; os comandos estão nas trilhas.

---

## 1. Qual trilha é a sua?

Há **duas formas de fazer a MESMA coisa**. Mesmo resultado, ferramentas diferentes.

```text
                  ┌─────────────────────────────────────────────┐
                  │   Mesma custódia frio↔quente, MESMO resultado │
                  └─────────────────────────────────────────────┘
                                      │
              ┌───────────────────────┴───────────────────────┐
              ▼                                                 ▼
   ┌────────────────────────┐                      ┌────────────────────────┐
   │  TRILHA A — FEATHER     │   ✅ recomendado     │  TRILHA B — CLI          │
   │  (interface / cliques)  │                      │  (monero-wallet-cli)     │
   ├────────────────────────┤                      ├────────────────────────┤
   │ • GUI, botões e QR      │                      │ • terminal, comandos     │
   │ • maioria dos alunos    │                      │ • avançado / auditoria   │
   └────────────────────────┘                      └────────────────────────┘
              │                                                 │
              └───────────────►  ESCOLHA UMA  ◄─────────────────┘
                  (a carteira nasce e morre na mesma ferramenta)
```

| | **Trilha A — Feather** | **Trilha B — CLI** |
|---|---|---|
| Como você opera | Interface gráfica (cliques) | Comandos no terminal |
| **Quando escolher** | Você quer o caminho mais simples e seguro | Você prefere terminal **ou** quer auditar o processo |
| **Para quem** | **Maioria** (recomendado) | Avançado |
| **Abra** | 👉 [`Trilha-A-Feather/Playbook — Feather (GUI).md`](Trilha-A-Feather/Playbook%20—%20Feather%20%28GUI%29.md) | 👉 [`Trilha-B-CLI/Playbook — monero-wallet-cli.md`](Trilha-B-CLI/Playbook%20—%20monero-wallet-cli.md) |

> ⚠️ **NÃO misture as trilhas.** Não crie a carteira no Feather e tente continuar no `monero-wallet-cli` (nem o contrário). Os arquivos de uma ferramenta não são feitos para a outra. **Escolheu A? Ignore B — e vice-versa.**
>
> 💡 **Na dúvida: Trilha A (Feather).**
>
> 🔐 **Para o grosso, há um caminho melhor que as duas trilhas:** **hardware wallet (Trezor/Ledger) + Feather** —
> a chave de gasto **nunca sai do chip**, sem o malabarismo de arquivos das Trilhas A/B. É o **recomendado**
> para quantias relevantes. Capítulo completo no livro: [`Curso — Whonix Online.md`](Curso%20—%20Whonix%20Online.md) **§5.6**.

---

## 2. Pré-requisitos comuns (valem para as DUAS trilhas)

Faça isto **antes** de abrir qualquer trilha:

- [ ] **Módulo 1 concluído** ([Tails + Haveno](../Tails%20OS%20Expert/README.md)) — você já tem **seed**, carteira **completa no Feather (Tails)** e sabe **verificar binários por PGP**.
- [ ] **Whonix instalado e verificado** — imagem conferida (fingerprint `916B8D99…2EEACCDA`), Gateway + Workstation atualizados via Tor (Curso Cap. 2–3).
- [ ] **Whonix só sai por Tor** — a Workstation navega **apenas** através do Gateway.
- [ ] **Seu nó Monero** acessível por Tor (`.onion:18089`) — ou um nó remoto `.onion` confiável (Curso Cap. 4).
- [ ] **Um pendrive dedicado** ao trânsito frio↔quente (nada de rede no lado frio, **nunca**).
- [ ] Você tem em mãos, da carteira **fria**: **endereço primário** (começa com `4`), **secret view key** e **restore height**.

---

## 3. O que cruza entre as máquinas (vale para as duas trilhas)

```text
  TAILS offline (FRIO)                          WHONIX online (QUENTE)
  carteira COMPLETA                             carteira VIEW-ONLY
  seed + view key + SPEND key                   endereço + view key + restore height
        │  (0) address + viewkey + restore height ───────►│  cria view-only
        │◄──── (1) outputs ───────────────────────────────│  exporta outputs
        │───── (2) key images ───────────────────────────►│  importa key images
        │◄──── (3) transação NÃO-ASSINADA ────────────────│  monta a tx
        │───── (4) transação ASSINADA ───────────────────►│  transmite
   ASSINA offline                                    BROADCAST via Tor/seu nó
```

Tudo isso cruza **por USB**, **nunca por rede**.

---

## 4. Regras de ouro (não pule — valem para as DUAS trilhas)

- 🔒 **A seed / spend key vive SÓ na máquina FRIA (Tails, bootado offline).** O Whonix é **view-only**: vê saldo, monta, transmite — **nunca** assina.
- **Teste com valor mínimo** o fluxo inteiro (criar view-only → montar → assinar → transmitir) **antes** de mover o grosso.
- **Backups da FRIA:** seed em papel/metal **offline** (DUAS cópias, locais separados) + pasta de dados cifrada (Módulo 1 §5.2). Tails é amnésico — mídia que corrompe = **perda total**.
- **View-only é descartável:** recria-se de endereço + view key + restore height. **Anote o restore height.**
- **Re-sincronize key images após cada envio** (senão a view-only não vê o **troco** e mostra saldo errado).
- 🔎 **Confira o endereço de destino na máquina FRIA antes de assinar** — ela é a fonte de verdade (malware no lado quente pode trocar o destino).
- **Spend key/seed nunca** é digitada, colada ou fotografada numa máquina online. Se acontecer uma vez, a carteira deixou de ser fria → **migre os fundos**.
- **Haveno é exceção** (quente, escrow ao vivo): leve só o valor do trade ao quente; após operar, saque o excedente para o frio (Curso Cap. 6).

> ⚠️ Os comandos exatos de assinatura offline **mudam por versão** — confirme nas fontes oficiais (no rodapé de cada trilha) **antes de mover dinheiro real**.

---

*Privacy-OS-Hub · Módulo 2 · Mapa de decisão das trilhas de cold-signing. Verificado em fonte oficial (jun/2026).*
