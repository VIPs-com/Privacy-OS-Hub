# Screenshots Whonix — o que capturar (manifesto)

Estas imagens **faltam** no Módulo 2. Capture-as no **host real** (Windows/Linux/macOS) e salve nesta pasta
com o nome indicado — os pontos de inserção no guia de instalação já estão mapeados abaixo.

> 🔒 **Segurança ao tirar screenshot:** redija qualquer dado sensível (caminhos com nome de usuário, IPs,
> chaves privadas). Use a mesma resolução/tema em todas; PNG; nomes em minúsculas como abaixo.

| Arquivo a criar | Onde entra | O que deve mostrar |
|-----------------|------------|--------------------|
| `01-vbox-import-appliance.png` | `Instalar-Whonix-passo-a-passo-por-SO.md` | VirtualBox → **File → Import Appliance** com o `.ova` selecionado |
| `02-kleopatra-good-signature.png` | §5 Windows | Kleopatra → **Decrypt/Verify** com assinatura válida + fingerprint `916B8D99…2EEACCDA` |
| `03-linux-good-signature.png` | §5 Linux/macOS | Terminal com `gpg: Good signature` e fingerprint Whonix |
| `04-vbox-gateway-workstation.png` | pós-import | VirtualBox com **Gateway + Workstation** na lista de VMs |
| `05-gateway-tor-connected.png` | primeiro boot Gateway | Gateway com **Tor Connection** conectado |

Depois de adicionar, referencie no guia com `![legenda](imagens/screenshots-whonix/NOME.png)`.

> Status: **pendente de captura** (precisa de VirtualBox + download Whonix no host). Este manifesto torna a
> contribuição um "encaixe direto" — quem instalar captura e o curso ganha as telas.

### Enquanto não há print, o aluno deve ver…

- **Import Appliance:** janela do VirtualBox com o caminho do `.ova` selecionado e botão **Import** habilitado.
- **Verificação GPG (Linux):** terminal com `gpg: Good signature from "Whonix…"` e fingerprint `916B8D99…2EEACCDA`.
- **Kleopatra (Windows):** ícone verde / "Signature valid" após **Decrypt/Verify**.
- **Lista de VMs:** duas entradas — **Whonix-Gateway** e **Whonix-Workstation**.
- **Gateway no 1º boot:** ícone ou painel **Tor Connection: Connected** antes de usar a Workstation.

Se qualquer passo divergir, use [`Instalar-Whonix-passo-a-passo-por-SO.md`](../../Instalar-Whonix-passo-a-passo-por-SO.md) §3.4, §5.4 e [`Playbooks/Playbooks.md`](../../Playbooks/Playbooks.md) §6.
