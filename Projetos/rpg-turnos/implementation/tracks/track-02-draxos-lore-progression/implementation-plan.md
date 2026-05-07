# Track 02 Implementation Plan - Draxos Lore And Progression Alignment

- Last Updated: `2026-05-07`
- Status: `linear execution registered; stage 1 practically complete; stage 2 catalog populated and now entering engine/session/UI integration via Codex prompts`
- Depends On:
  - `../../../docs/lore-campaign.md`
  - `../../../docs/lore-content-migration.md`
  - `../../../docs/game-design-document.md`
  - `../../../docs/classes/README.md`
  - `linear-execution-plan.md`
  - `../track-01-foundation-first-prototype/current-status.md`

## Analysis Snapshot

Track 01 entregou o slice C1 jogável: todos os battle modes oficiais, recompensas, save/load, validação verde, placeholders art-ready.

Track 02 tem dois trabalhos distintos:

1. **Lore skin**: migrar o conteúdo visível para a campanha Draxos sem quebrar mecânicas.
2. **Class identity + progression**: definir as classes jogáveis e dar profundidade RPG ao sistema.

O design das 5 classes está completo. Os specs estão em `docs/classes/`. Todo o conteúdo de cartas atual é placeholder e será substituído.

## Implementation Guardrails

- Manter C1 como o jogo principal.
- Manter IDs mecânicos estáveis até a passagem de compatibilidade dedicada.
- Preferir `display_name`, diálogo, notas, labels de UI e texto de catálogo para migração de lore inicial.
- Manter cada passagem validável e reversível.
- Não importar regras de loadout, combate ou campanha do RPG Isométrico.
- Nenhuma carta deve depender da existência de um herói inimigo — apenas o modo `duelo` tem um.
- A implementação agora segue obrigatoriamente a ordem linear em `linear-execution-plan.md`; não dividir tarefas em paralelo.

## Stage 0 - Baseline Audit

Status: `complete`

Findings:
- Slice atual tem todos os battle modes oficiais e validação verde.
- `docs/lore-campaign.md` e `canon/lore/draxos-invasion.md` são a direção de lore ativa.
- `docs/lore-content-migration.md` define o princípio seguro: player-facing names primeiro, IDs depois.
- O catálogo já tem display names Draxos/elemental para heróis, cartas, tabuleiros e encontros.
- As 5 classes foram projetadas e estão documentadas em `docs/classes/`.

## Stage 1 - Runtime-Facing Lore Skin

Status: `praticamente completo — revisar e confirmar`

Purpose: o slice jogável deve ler consistentemente como uma operação Draxos sem mudar mecânicas.

Scope:
- Labels de herói jogador e inimigo
- Diálogo do NPC/comando na cena do mundo
- `display_name` e `notes` dos encontros
- `display_name` dos tabuleiros
- Nenhum ID mecânico renomeado
- Nenhuma carta nova
- Nenhuma mudança de regra de batalha

Exit criteria:
- Um novo jogador entende: base de comando → primeira operação → resistência elemental crescente.
- Nenhum save quebrou.

## Stage 2 - Class Identity (Design Completo)

Status: `catálogo populado — aguarda implementação de engine`

Purpose: definir as classes jogáveis antes de qualquer renomeação profunda de cartas ou sistemas de progressão.

O design está inteiramente documentado em `docs/classes/`. As 5 classes são:

- **Assaltante de Vazio** — pressão imediata, rapido, abertura de rotas
- **Arquiteto de Éter** — instalação permanente, upkeep triggers, estruturas
- **Dominador Astral** — paralisia do tabuleiro, enjoo aplicado, Extrator crescente
- **Vinculador** — capturar e converter criaturas inimigas, spawn de tokens
- **Tecelão Astral** — sequenciar feitiços, escalonamento por Ressonância

### Decisões tomadas

- O jogador escolhe uma classe no início da campanha e mantém toda a jornada.
- Recompensas são dos encontros, não específicas por classe.
- Todo o conteúdo de cartas atual é placeholder — redesign completo autorizado.
- Nenhuma carta ou poder de herói depende de herói inimigo existir.

### O que está no catálogo

As 50 cartas das 5 classes estão em `data/definitions/slice_catalog.json`, junto com a seção `classes` com hero powers e starter decks completos. O schema completo está em `docs/class-catalog-schema.md`.

### Próxima ação em Stage 2

Implementar os sistemas de engine necessários para jogar cada classe. Ordem sugerida por complexidade:

1. Assaltante (zero sistemas novos obrigatórios além de hooks menores)
2. Arquiteto (upkeep triggers — base para o Dominador)
3. Dominador (reusa upkeep do Arquiteto)
4. Tecelão (Ressonância é simples mas central)
5. Vinculador (spawn de tokens é o sistema mais complexo)

### Novos sistemas de engine necessários (resumo)

| Sistema | Classes | Complexidade |
|---|---|---|
| Ressonância counter por turno | Tecelão | Baixa |
| "Quando destrói em combate" hook | Assaltante, Arquiteto, Vinculador | Média |
| Upkeep triggers em permanentes | Arquiteto, Dominador | Média (compartilhado) |
| HP máximo crescente | Arquiteto | Baixa |
| Reset de estado em massa | Arquiteto | Baixa |
| Enjoo aplicado por feitiço | Dominador | Baixa |
| Enjoo com duração estendida | Dominador | Média |
| ATK crescente condicional | Dominador, Vinculador | Baixa |
| Armadura proporcional ao dano | Dominador | Baixa |
| Spawn de criatura token em runtime | Vinculador | Alta |
| Dano não-letal condicional | Vinculador | Baixa |
| Forçar combate inimigo vs inimigo | Vinculador | Média |
| Milestone trigger (contador) | Tecelão | Média |

### Tela de Seleção de Classe

A escolha de classe acontece **antes de iniciar a campanha**, não dentro do primeiro encontro. É uma tela dedicada, não um diálogo inline.

Requisitos mínimos da tela:
- Apresentar as 5 classes disponíveis.
- Para cada classe: nome, identidade em uma linha, ponto de virada em uma linha.
- Confirmação explícita antes de iniciar — a escolha é permanente para aquela run.
- A classe selecionada determina qual deck starter é carregado ao entrar no primeiro encontro.
- Save/load deve persistir a classe escolhida na sessão.

Esta tela é bloqueante: sem ela, o sistema de classes não é jogável. Deve ser implementada junto com a primeira classe, não depois.

O design visual e de UX desta tela faz parte do **Stage 3 - UI e Apresentação**.

Exit criteria:
- Uma classe está implementada com deck funcional, hero power funcional e validação verde.
- A tela de seleção de classe está funcional e carrega o deck correto.
- As demais classes seguem em iterações separadas.

## Stage 3 - UI e Apresentação

Status: `aguarda sessão de design dedicada`

Purpose: endereçar os problemas de apresentação que tornam o jogo atual desconfortável de jogar. Este stage precisa de uma **sessão própria de design** para definir escopo, prioridades e abordagem antes de qualquer implementação.

### Por que este stage existe

O jogo atual tem problemas de apresentação identificados:
- Tabuleiro difícil de ler e visualizar.
- Cartas sem apelo visual ou hierarquia clara.
- Ausência de feedback de efeitos (dano, estados, triggers).
- HUD pouco legível.

Nenhum desses problemas tem solução óbvia — cada um pode ser abordado de formas diferentes com trade-offs distintos. Por isso esta sessão de design precisa acontecer antes da implementação.

### O que a sessão de design deve definir

- Quais problemas de apresentação são bloqueantes (impedem jogar e testar) vs. polimento tardio.
- Prioridade de endereçamento: tabuleiro primeiro, cartas, HUD, efeitos, ou outro ângulo.
- Escopo mínimo que torna o jogo testável por alguém além do desenvolvedor.
- Abordagem de implementação: mudanças em cena existente, novo sistema de UI, art proxies.

### O que não deve entrar neste stage

- Arte final de qualquer elemento.
- Animações complexas.
- Qualquer mudança que quebre a validação existente.

Exit criteria: definidos na sessão de design antes de iniciar a implementação.

## Stage 4 - Campaign Content Alignment

Status: `pending`

Purpose: alinhar a cadeia de encontros, nomes de missão e recompensas com a identidade de lore e de classe definida em Stages 1 e 2.

Scope:
- Nomear o arco da operação inicial (aterrissagem de éter → aproximação vulcânica).
- Atribuir propósito de missão a cada encontro existente.
- Renomear display names de cartas do starter deck em torno da primeira classe implementada.
- Separar cartas player-side (ferramentas Draxos) de cartas enemy-side (defensores elementais).
- Definir o significado narrativo de cada fonte de recompensa.
- Manter IDs técnicos inalterados.

Exit criteria:
- A cadeia de mapa comunica escalada em direção ao vulcão/cristal.
- O deck inicial parece um kit de uma classe Draxos específica.
- Cada fonte de recompensa tem razão de história.
- Re-entrada para prática ainda funciona.

## Stage 5 - RPG Progression Slice

Status: `pending`

Purpose: adicionar a primeira camada real de progressão RPG após a shell de lore estar estável.

Decisões necessárias:
- Progressão é rank, nível, status dentro do time, ou uma combinação?
- Crescimento do herói muda HP, hero power, slots de deck, card pool, acesso a missões ou diálogos?
- Progressão é linear ou baseada em escolha neste slice?

Implementation candidate:
- Campo `rank/status` simples no estado de sessão.
- Acesso a missões e variantes de diálogo desbloqueados por encontros completados.
- Manter balanceamento de combate estável a menos que uma stat específica seja introduzida.
- Cobertura save/load para novos campos de progressão.

Exit criteria:
- Crescimento do jogador mapeia para status de novato subindo dentro do time Draxos.
- Save/load permanece compatível.

## Stage 6 - Encounter Design Pass

Status: `pending`

Purpose: projetar encontros que testem as fraquezas de cada classe e criem decisões reais. O jogo atual está fácil demais — este stage endereça isso.

Princípio:
- Cada classe tem um ponto fraco documentado. Pelo menos um encontro por classe deve ativar esse ponto fraco.
- Modos de batalha existentes são as regras de objetivo — não criar novos antes que os 6 existentes estejam totalmente explorados.

Exemplos de design de encontro de referência dos specs de classe:
- **vs Assaltante**: defensor 0/7 no slot central + ondas com queimando pré-aplicado nos slots do jogador
- **vs Arquiteto**: magia de tabuleiro de área + criaturas voadoras abundantes
- **vs Dominador**: estruturas (imunes a enjoo) como ameaça principal + oleada de criaturas rapido simultâneas
- **vs Vinculador**: inimigos com HP muito alto + poucos alvos de captura valiosos
- **vs Tecelão**: criaturas rapido agressivas nos primeiros turnos + chefe de HP extremamente alto

Exit criteria:
- Pelo menos um encontro por classe ativa o ponto fraco documentado.
- Validação verde.

## Stage 7 - New Content Expansion

Status: `pending`

Purpose: adicionar volume de campanha apenas após naming, identidade de classe e significado de recompensa estarem estáveis.

Scope:
- Adicionar um cluster de encontros pequeno por vez.
- Preferir battle modes existentes antes de inventar novas regras.
- Adicionar tabuleiros apenas quando a missão precisar de nova topologia.
- Adicionar cartas apenas quando progressão ou design de encontro precisar delas.

Exit criteria:
- Cada cluster de conteúdo tem propósito de missão, propósito de recompensa e cobertura de validação.

## Stage 8 - Technical ID And Asset Migration

Status: `pending`

Purpose: limpar IDs legados após o naming player-facing estabilizar.

Esta é uma passagem de compatibilidade dedicada, não limpeza oportunista.

Required coverage:
- save migration
- generated `.tres` resources
- scene references
- tests e contratos de validação
- `AssetIds`
- JSON references

Exit criteria:
- IDs técnicos correspondem à terminologia final sem quebrar saves existentes ou conteúdo gerado.

## Recommended Immediate Next Task

Executar `P01 - Catalog class resource plumbing` em `linear-execution-plan.md`.

Resumo:
1. Expor `classes` no recurso gerado do catalogo.
2. Adicionar helpers de classe em `ContentLibrary`.
3. Cobrir as 5 classes e seus starter decks em testes.
4. Regenerar recursos e rodar validacao.

Depois disso, seguir estritamente o cursor do plano linear. A tela de selecao de classe nao deve comecar antes dos prompts de plumbing, sessao, hero power e deck do Assaltante.
