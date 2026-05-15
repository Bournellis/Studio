# Draxos — Workflow de Criação de Cards via Card Designer

Guia para usar a aba 🎨 Designer do Card Browser para propor, exportar e implementar novas cartas no jogo.

---

## Fluxo Completo

### 1. Abrir o Card Browser

Abra `D:\Estudio\Visual\draxos-card-browser.html` no browser e clique na aba **🎨 Designer**.

### 2. Preencher o formulário

Para cada carta nova que você quer criar:

- **Nome do card** — o nome de display que vai aparecer no jogo
- **Classe** — Arcano, Invocador ou Necromante
- **Tipo** — `magia` (sem ATK/HP) ou `criatura` (com ATK e HP)
- **Custo de mana** — normalmente 0, 1, 2 ou 3
- **Mensagem para o Codex** — explique o que a carta faz, quais mecânicas ela usa, efeitos esperados, e se ela substitui algum placeholder

Clique em **＋ Adicionar à Lista**. O card aparece na lista de pendentes e fica salvo no browser (localStorage) mesmo se você fechar e reabrir.

### 3. Exportar para o Codex

Quando tiver um ou mais cards prontos, clique em **📥 Exportar para Codex (.md)**.

Um arquivo `draxos-cards-pendentes-YYYY-MM-DD.md` será baixado com todos os cards listados no formato:

```
## 1. Nome do Card
- Classe: Arcano
- Tipo: magia
- Custo de mana: 1

Mensagem para o Codex:
[seu texto aqui]
```

### 4. Enviar para o Codex

Abra uma sessão com o Codex e envie o arquivo exportado junto com este contexto:

```
Contexto: Draxos Roguelike Cardgame (Godot 4.6.2 / GDScript)
Arquivo de conteúdo: data/definitions/slice_catalog.json
Track ativa: Track 01 — P13_REAL_UPGRADES_REWARD_CARDS_VALIDATED

Quero implementar as cartas descritas no arquivo em anexo.
Para cada carta:
1. Adicionar entrada em slice_catalog.json (cards array)
2. Criar as 3 versões: base, _lvl2, _lvl3 (a menos que eu diga o contrário)
3. Manter padrão dos campos: id, display_name, type, cost, attack*, health*, keywords*, text
4. Se substituir um placeholder, remover o placeholder correspondente
5. Rodar validate.gd ao final para confirmar 65/65 testes passando
```

### 5. Marcar como Implementado

Após o Codex implementar e os testes passarem, volte ao Card Browser, aba Designer, e clique em **✓ Implementado** em cada card concluído. Ele sai da lista de pendentes.

---

## Dicas

- A lista de pendentes persiste no browser via localStorage. Não limpe os dados do browser antes de exportar.
- Você pode ter cards de classes diferentes na mesma exportação — o Codex consegue lidar com isso.
- Se quiser substituir um placeholder específico (ex: `arcano_recompensa_1`), mencione isso explicitamente na mensagem.
- Os IDs seguem o padrão: `{prefixo}_{nome}` e `{prefixo}_{nome}_lvl2` / `_lvl3`.
  - Arcano → `arcano_`
  - Invocador → `invocador_`
  - Necromante → `necro_`

---

## Comando de Validação

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd
```

Esperado: **65/65 testes passando**, sem erros.
