# Classes — Índice

- Last Updated: `2026-05-06`
- Status: `design completo, aguarda implementação`
- Referência: `../lore-campaign.md`, `../game-design-document.md`

## Decisão de Design

O jogador escolhe uma classe no início da campanha e joga toda a jornada com essa identidade. Recompensas são definidas pelos encontros, não pela classe — qualquer classe pode receber qualquer recompensa de campanha.

Todo o conteúdo de cartas abaixo é **redesign completo**. As cartas atuais no `slice_catalog.json` são placeholders e serão substituídas.

## As Cinco Classes

| Classe | Filosofia Central | Mecânica Chave |
|---|---|---|
| [Assaltante de Vazio](assaltante.md) | Pressão imediata, fechar antes do turno 7 | Rapido + abertura de rotas |
| [Arquiteto de Éter](arquiteto.md) | Instalação permanente, acúmulo de valor passivo | Upkeep triggers, estruturas |
| [Dominador Astral](dominador.md) | Paralisia do tabuleiro inimigo | Enjoo aplicado, Extrator crescente |
| [Vinculador](vinculador.md) | Capturar e converter criaturas inimigas | Forma Vinculada, spawn runtime |
| [Tecelão Astral](tecelao.md) | Sequenciar feitiços, explodir no turno certo | Ressonância, escalonamento por sequência |

## Princípio de Design Compartilhado

Nenhuma carta ou poder de herói depende da existência de um herói inimigo. Apenas o modo `duelo` tem herói inimigo — as outras cinco situações não têm. Todas as cartas devem funcionar nos 6 modos de batalha.

## Requisitos de Engine — Resumo

Novos sistemas necessários por classe, em ordem crescente de complexidade:

- **Tecelão**: contador de Ressonância por turno (o mais simples)
- **Assaltante + Arquiteto + Dominador**: "quando destrói permanente em combate" hook
- **Arquiteto + Dominador**: upkeep triggers em permanentes
- **Arquiteto**: HP máximo crescente, reset de estado em massa
- **Dominador**: enjoo aplicado por feitiço, enjoo com duração estendida, armadura proporcional ao dano
- **Vinculador**: spawn de criatura token em runtime, dano não-letal condicional, forçar combate inimigo vs inimigo

## Próximo Passo

Implementar as classes em ordem de complexidade crescente de engine:

1. Assaltante (zero sistemas novos obrigatórios além de hooks menores)
2. Arquiteto (upkeep triggers compartilhados com Dominador)
3. Dominador (reusa upkeep do Arquiteto)
4. Tecelão (Ressonância é simples mas central)
5. Vinculador (sistema de spawn mais complexo)
