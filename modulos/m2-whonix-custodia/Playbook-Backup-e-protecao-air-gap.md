# Playbook — Backup e proteção (air-gap, sem hardware wallet)

Checklist prático para custodiar o **grosso** com **Cold-Tails / Hot-Whonix** — sem depender de Trezor/Ledger
ou outro hardware proprietário caro. Teoria e modelo de ameaças: [`Curso-Whonix-Online.md`](Curso-Whonix-Online.md) Cap. 5.

> **Princípio do hub:** controle total e **responsabilidade sua**. A spend key vive só no Tails offline; o Whonix
> é view-only. Hardware wallet é **opcional** (§5.6) — não é pré-requisito deste curso.

---

## 1. Antes de mover qualquer valor relevante

- [ ] Fluxo frio↔quente testado com **valor mínimo** (Trilha A ou B — [`00 — Comece aqui`](00-Comece-aqui-Escolha-sua-trilha.md))
- [ ] **DUAS cópias offline** da seed anotadas (papel ou metal, **locais separados**)
- [ ] **Teste de restauração** feito numa sessão Tails offline (abrir carteira só com a seed de backup)
- [ ] **Restore height** anotado na criação da carteira
- [ ] Pendrive **dedicado** ao trânsito frio↔quente (rotulado; nunca misturar com mídia de boot do Tails)

---

## 2. Backup da carteira fria

### 2.1 Seed em papel/metal (obrigatório)

```text
# Ao criar a conta (Módulo 1 §5.1) — Tails COM Tor ativo:
# Account → Wallet seed → anote as 25 palavras em papel/metal.
# NUNCA foto, nuvem ou e-mail.
# Faça a 2ª cópia em outro local físico (passo 9 do hub — confirmação ritual).
```

**OK se:** existem **duas cópias físicas** em locais separados e backup cifrado da `Data/` (M1 §5.2).

**Opcional (avançado):** restaurar a carteira **só com a seed** num Tails **sem rede** — teste de recuperação; não é obrigatório no Mínimo M2.

### 2.2 Pasta de dados cifrada (recomendado)

Siga o Módulo 1 — backup da pasta de dados do Haveno/Feather:

- [`modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md`](../m1-tails-haveno/Curso-Tails-OS-Expert.md) §5.2
- [`modulos/m1-tails-haveno/Playbooks/Playbooks.md`](../m1-tails-haveno/Playbooks/Playbooks.md) seções Backup/Atualizar

**OK se:** existe cópia cifrada da pasta de dados **além** da seed em papel.

---

## 3. Pendrive frio↔quente (USB dedicado)

| Regra | Por quê |
|-------|---------|
| **Um pendrive só** para outputs, key images e transações | Evita misturar com mídia infectada ou de boot |
| **Nunca** conectar o pendrive de trânsito na máquina **online** com a carteira **completa** | Só a view-only no Whonix toca rede |
| Formato **exFAT** ou **FAT32** (compatível Tails ↔ host) | Feather/CLI precisam ler os arquivos |
| Rotule fisicamente: `FRIO-QUENTE — SEM REDE NO TAILS` | Disciplina operacional |

**OK se:** o mesmo pendrive nunca foi usado para instalar Tails nem navegar online.

---

## 4. Ameaças sem hardware wallet (tabela honesta)

| Ameaça | Air-gap (Tails) | Mitigação |
|--------|-----------------|-----------|
| Mídia Tails corrompe/some | **Perda total** se seed única | DUAS cópias seed + pasta cifrada |
| Erro no malabarismo USB | Tx errada ou saldo desatualizado | Teste mínimo; re-sync key images após cada envio |
| Malware no Whonix troca destino | Assina valor/endereço errado | **Confira destino na máquina FRIA** antes de assinar |
| Seed digitada no Whonix | Carteira deixa de ser fria | **Migre fundos** para nova carteira fria |
| VM Whonix quebrada | View-only perdida | Recrie view-only (endereço + view key + restore height) |

---

## 5. View-only descartável (Whonix)

Se a Workstation quebrar ou você apagar a VM:

```text
# Você NÃO perde os fundos se tiver:
#   - seed na máquina fria (Tails)
#   - endereço primário + secret view key + restore height anotados
# Recrie a view-only na nova Workstation (Trilha A ou B, passo 0).
```

**OK se:** os três dados (endereço, view key, restore height) estão anotados **offline**, separados da VM.

---

## 6. Quando migrar fundos (nova carteira fria)

- Seed ou spend key **tocou** rede (colada, foto, digitada no Whonix)
- Suspeita de comprometimento do pendrive ou do host
- Erro operacional grave (assinou tx para endereço errado e já transmitiu)

**Procedimento:** crie **nova** carteira no Tails offline → transfira o saldo → atualize view-only no Whonix → **novos** backups.

---

## 7. Hardware wallet (opcional)

Se **já tem** ou **quer comprar** Trezor/Ledger: [`Curso-Whonix-Online.md`](Curso-Whonix-Online.md) **§5.6** (custo extra, firmware proprietário).
Se **não tem** e busca baixo custo: **Trilha A + este playbook** é o caminho do hub.

---

## 8. Fontes oficiais

| Tema | Link |
|------|------|
| Cold storage / offline signing | https://docs.getmonero.org/cold-storage/offline-transaction-signing/ |
| Feather offline signing | https://docs.featherwallet.org/guides/offline-tx-signing |
| Backup Módulo 1 | [`../modulos/m1-tails-haveno/Curso-Tails-OS-Expert.md`](../m1-tails-haveno/Curso-Tails-OS-Expert.md) §5.2 |

---

*Privacy-OS-Hub · Módulo 2 · Backup air-gap. Confirme nas fontes antes de mover dinheiro real.*
