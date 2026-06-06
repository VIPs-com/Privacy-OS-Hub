# 🛡️ Folheto Expert — Regras de Ouro & Golpes (1 página)

**Imprima ou cole no grupo da turma.** Resumo do que evita 99% dos prejuízos. Detalhes: [`Curso — Tails OS Expert.md`](Curso%20—%20Tails%20OS%20Expert.md) Capítulo 9 · Volume II Cap. 2 (seed na criação).

**Cartaz do fluxo comprar/vender (imprimível):**

![Comprar e vender com segurança](imagens/cartaz-comprar-vender-seguro.png)

---

## ✅ Regras de ouro (decore)

- **Baixe só de fontes oficiais:** `tails.net`, `getmonero.org`, GitHub da sua rede.
- **Verifique o PGP** de todo `.deb` — URL e PGP da **mesma** rede, **mesmo** release.
- **Use `1.6.0-reto`+** (versão com o fix do exploit de trades).
- **Instalar ≠ tradear.** Comece com **valores pequenos**.
- **Seed = seus fundos.** Nunca compartilhe. Anote **offline** (papel/metal) — ritual na criação: Volume II, Cap. 2.
- **Seed ≠ backup completo** → faça backup da pasta `Data/` (cifrada).
- **Abra o Haveno sempre pelo menu** (senão a carteira não persiste).
- **Senha admin** a cada sessão; a **persistência** guarda os dados.
- **Backup cifrado e offline**, em mídia separada do pendrive.

---

## 🚨 Golpes — como NÃO cair em roubadas

| Armadilha | Sua defesa |
|-----------|-----------|
| Instalador "modificado" / link de fórum/Telegram | Só oficial + **verificar PGP** |
| "Suporte" no privado pedindo **seed/senha/tela** | **Ninguém** legítimo pede. Ignore e bloqueie |
| Site clone (phishing) | Confira o domínio; use favoritos; via Tor |
| "Vamos negociar **por fora** do app" | **Tudo** dentro do Haveno (escrow/multisig) |
| Preço bom demais + **pressa** | Desconfie; siga o fluxo normal |
| Pedem **enviar fundos antes** do escrow | Nunca antecipe; siga o passo a passo |
| "Mixer / privacidade extra" por uma taxa | **Desnecessário** no Monero; geralmente é scam |
| "Sou o **árbitro**, me passe a chave" | Árbitro age **dentro** do app, nunca por fora |

> **Regra única:** se envolve sua **seed**, sua **senha**, ou enviar fundos **"por fora" do app** → **é golpe.**

---

## 🔎 KYC & swaps (em 30 segundos)

- **KYC** = verificação de identidade (documento/selfie). Quem busca privacidade evita.
- **Haveno é no-KYC** por desenho (P2P; identificado só pelo método de pagamento).
- **Trocador e agregadores** não pedem KYC, mas **roteiam** para um **parceiro** que **pode** pedir (risco AML). Por isso *"o parceiro final pode pedir KYC"*.
- Se for usar swap: filtre **No-KYC**, valores pequenos, subendereço novo, via Tor.

---

## 💱 Trade seguro (resumo)

- **Comprando** (paga fiat, recebe XMR): pague pelo app, **guarde comprovante**, só então marque "pago"; sumiu? **disputa**.
- **Vendendo** (recebe fiat, entrega XMR): **só libere** o XMR quando o dinheiro estiver **na sua conta e irreversível** (prefira **PIX**/dinheiro; cuidado com estorno de cartão/PayPal).
- **Sempre:** tudo dentro do app (escrow multisig + chat); valores pequenos; na dúvida, **disputa** (nunca "por fora"). Detalhes: [`Expansão Curso/`](Expansão%20Curso/Curso%20—%20Rede%20Descentralizada%20(Extensão).md) Cap. 7–9.

## 🔁 Rotina a cada sessão

**Tor → admin → abrir Haveno pelo menu → verde.** Dados em `~/Persistent/haveno/Data/`.

---

*Folheto resumo · maio/2026 · [`Curso — Tails OS Expert.md`](Curso%20—%20Tails%20OS%20Expert.md) · [`Expansão Curso/`](Expansão%20Curso/Curso%20—%20Rede%20Descentralizada%20(Extensão).md)*
