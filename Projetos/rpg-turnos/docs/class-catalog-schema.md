# Class Catalog Schema

- Last Updated: `2026-05-06`
- Status: `autoridade — Codex deve seguir este documento para qualquer dado de classe`
- Referências: `classes/README.md`, `game-design-document.md`, `class-selection-flow.md`

## Propósito

Este documento define como classes, hero powers e efeitos de carta são representados em JSON no catálogo. É o contrato entre o design e a implementação. Nenhuma decisão de schema deve ser tomada pelo Codex sem estar definida aqui.

---

## 1. Seção `classes` no Catálogo

O catálogo (`data/definitions/slice_catalog.json`) inclui um array `classes`. Cada entrada define uma classe jogável completa.

```json
"classes": [
  {
    "id": "assaltante",
    "display_name": "Assaltante de Vazio",
    "tagline": "Pressão imediata. Fechar antes do turno 7.",
    "hero": {
      "id": "assaltante_heroi",
      "display_name": "Novato Draxos",
      "max_health": 25,
      "hero_power": { ... }
    },
    "starter_deck": [ "incursor_vazio", "incursor_vazio", ... ]
  }
]
```

Campos obrigatórios por entrada:

| Campo | Tipo | Uso |
|---|---|---|
| `id` | string | chave técnica; também usada em `GameSession.selected_class` |
| `display_name` | string | exibido na tela de seleção |
| `tagline` | string | identidade em uma linha; exibida na tela de seleção |
| `hero` | object | definição completa do herói (ver seção 2) |
| `starter_deck` | array de string | 20 IDs de cartas na ordem do deck inicial |

---

## 2. Hero Power — Formato Estruturado

O campo `hero.hero_power` substitui `hero_power_text` como fonte de verdade para o engine. O campo `hero_power_text` pode ser mantido como alias de exibição legado.

```json
"hero_power": {
  "id": "disparo_choque",
  "display_name": "Disparo de Choque",
  "cost": 1,
  "speed": "normal",
  "once_per_own_turn": true,
  "text": "Causa 2 de dano mágico a qualquer permanente inimigo.",
  "effect": {
    "action": "damage",
    "amount": 2,
    "damage_type": "magico",
    "target": "any_enemy_permanent"
  }
}
```

Campos obrigatórios:

| Campo | Tipo | Notas |
|---|---|---|
| `id` | string | chave técnica |
| `display_name` | string | exibido na UI |
| `cost` | int | custo em energia (0 para Foco Astral) |
| `speed` | `"normal"` | só normal por enquanto |
| `once_per_own_turn` | bool | sempre `true` nas classes atuais |
| `text` | string | texto descritivo para a UI |
| `effect` | object | efeito estruturado (ver seção 3) |

### Hero Powers das 5 Classes

```json
// Assaltante
"hero_power": {
  "id": "disparo_choque", "display_name": "Disparo de Choque",
  "cost": 1, "speed": "normal", "once_per_own_turn": true,
  "text": "Causa 2 de dano mágico a qualquer permanente inimigo.",
  "effect": { "action": "damage", "amount": 2, "damage_type": "magico", "target": "any_enemy_permanent" }
}

// Arquiteto
"hero_power": {
  "id": "reparacao_eter", "display_name": "Reparação de Éter",
  "cost": 1, "speed": "normal", "once_per_own_turn": true,
  "text": "Regenera 4 HP de uma estrutura sua danificada.",
  "effect": { "action": "heal_permanent", "amount": 4, "target": "any_own_damaged_structure" }
}

// Dominador
"hero_power": {
  "id": "dominancia_astral", "display_name": "Dominância Astral",
  "cost": 2, "speed": "normal", "once_per_own_turn": true,
  "text": "Aplica enjoo a um permanente inimigo.",
  "effect": { "action": "apply_status", "status": "enjoo", "target": "any_enemy_permanent" }
}

// Vinculador
"hero_power": {
  "id": "captura_forcada", "display_name": "Captura Forçada",
  "cost": 2, "speed": "normal", "once_per_own_turn": true,
  "text": "Destrói permanente inimigo com HP ≤ 3. Spawna Forma Vinculada com seus stats (máx 4/4) em slot vazio.",
  "effect": { "action": "capture", "hp_threshold": 3, "spawn_vinculada": true, "max_attack": 4, "max_health": 4, "target": "any_enemy_permanent_hp_lte" }
}

// Tecelão
"hero_power": {
  "id": "foco_astral", "display_name": "Foco Astral",
  "cost": 0, "speed": "normal", "once_per_own_turn": true,
  "text": "Adiciona 1 de Ressonância.",
  "effect": { "action": "add_resonance", "amount": 1 }
}
```

---

## 3. Extensões do Schema de Efeito de Carta

O campo `effect` nas cartas segue o mesmo padrão do hero power. Os tipos abaixo são extensões do sistema existente.

### 3.1 Targets (valores de `target`)

| Valor | Descrição |
|---|---|
| `"any_enemy_permanent"` | jogador seleciona um permanente inimigo qualquer |
| `"any_permanent"` | jogador seleciona qualquer permanente (próprio ou inimigo) |
| `"any_permanent_or_hero"` | qualquer permanente ou herói inimigo (se existir) |
| `"any_own_structure"` | jogador seleciona uma de suas próprias estruturas |
| `"any_own_damaged_structure"` | estrutura própria com HP < HP máximo |
| `"any_enemy_permanent_hp_lte"` | permanente inimigo com HP ≤ `hp_threshold` (ver `capture`) |
| `"all_enemy_creatures"` | todas as criaturas inimigas |
| `"all_enemy_permanents"` | todos os permanentes inimigos |
| `"all_own_structures_with_attack"` | todas as estruturas próprias com ATK > 0 |
| `"choose_enemy_permanents"` | distribuição entre inimigos escolhidos pelo jogador |
| `"choose_enemy_x_choose_enemy_y"` | dois alvos inimigos diferentes (Dominação Forçada) |

### 3.2 Efeito de Dano com `on_destroy` (Garra do Vazio)

Efeito secundário que se aplica se o alvo for destruído pela carta.

```json
"effect": {
  "action": "damage",
  "amount": 3,
  "damage_type": "magico",
  "target": "any_enemy_permanent",
  "on_destroy": {
    "action": "damage",
    "amount": 2,
    "damage_type": "magico",
    "target": "any_enemy_permanent"
  }
}
```

### 3.3 Trigger `on_combat_kill` em Permanente (Pilhador, Laçador, Guardião de Cristal, Mestre Vinculador)

Acionado quando este permanente destrói outro em combate.

```json
"effect": {
  "on_combat_kill": {
    "action": "draw",
    "amount": 1
  }
}

// Laçador — crescimento permanente
"effect": {
  "on_combat_kill": {
    "action": "gain_stats",
    "attack": 1,
    "health": 1,
    "permanent": true
  }
}

// Guardião de Cristal — armadura
"effect": {
  "on_combat_kill": {
    "action": "gain_armor",
    "amount": 3
  }
}

// Mestre Vinculador — spawn
"effect": {
  "on_combat_kill": {
    "action": "spawn_vinculada",
    "spawn_attack": 2,
    "spawn_health": 2
  }
}
```

### 3.4 Trigger `upkeep_trigger` em Permanente (Bastião, Núcleo, Extrator, Senhor, Exodia)

Acionado no upkeep do controlador do permanente.

```json
// Bastião Arcano — armadura incondicional
"effect": {
  "upkeep_trigger": {
    "action": "gain_armor",
    "amount": 1
  }
}

// Núcleo de Éter — energia
"effect": {
  "upkeep_trigger": {
    "action": "gain_energy",
    "amount": 1
  }
}

// Extrator Astral — ATK crescente condicional
"effect": {
  "upkeep_trigger": {
    "condition": "if_any_enemy_enjoo",
    "action": "gain_stats",
    "attack": 1,
    "health": 0,
    "permanent": true
  }
}

// Senhor da Supressão — aplica enjoo a inimigo
"effect": {
  "upkeep_trigger": {
    "action": "apply_status",
    "status": "enjoo",
    "target": "any_ready_enemy_creature"
  }
}

// Exodia Vinculada — cresce com vinculadas
"effect": {
  "upkeep_trigger": {
    "action": "gain_stats_per_tag",
    "tag": "vinculado",
    "attack": 1,
    "health": 1,
    "permanent": true
  }
}
```

### 3.5 Trigger `on_spell_cast` em Permanente (Custódio do Fio, Conduit Astral)

Acionado sempre que o controlador lança um feitiço enquanto este permanente está em jogo.

```json
// Custódio do Fio — armadura por feitiço
"effect": {
  "on_spell_cast": {
    "action": "gain_armor",
    "amount": 1
  }
}

// Conduit Astral — draw ao atingir ressonância 3 (uma vez por turno)
"effect": {
  "on_spell_cast": {
    "resonance_milestone": 3,
    "once_per_turn": true,
    "action": "draw",
    "amount": 1
  }
}
```

### 3.6 Trigger `on_any_enemy_destroyed` em Permanente (Espectro Coletor)

Acionado quando qualquer criatura inimiga é destruída enquanto este permanente está em jogo.

```json
"effect": {
  "on_any_enemy_destroyed": {
    "action": "spawn_vinculada",
    "spawn_attack": 1,
    "spawn_health": 1
  }
}
```

### 3.7 Efeitos de Ressonância (cartas do Tecelão)

Ressonância é um contador inteiro de turno. Começa em 0 no início do turno do jogador, incrementa por cada feitiço resolvido, reseta no final da fase de descarte.

```json
// Centelha Astral — dano igual à ressonância atual (mín 1)
"effect": {
  "action": "damage",
  "damage_type": "magico",
  "target": "any_enemy_permanent",
  "amount": "resonance",
  "min_amount": 1
}

// Eco Arcano — ressonância × 2
"effect": {
  "action": "damage",
  "damage_type": "magico",
  "target": "any_enemy_permanent",
  "amount": "resonance_x2"
}

// Pulso Ressonante — dano condicional por limiar
"effect": {
  "action": "damage",
  "damage_type": "magico",
  "target": "any_permanent",
  "amount": 2,
  "resonance_override": { "threshold": 3, "amount": 4 }
}

// Barreira Ressonante — armadura igual à ressonância
"effect": {
  "action": "gain_armor",
  "amount": "resonance"
}

// Onda de Éter — área com limiar de ressonância
"effect": {
  "action": "damage",
  "damage_type": "magico",
  "target": "all_enemy_permanents",
  "amount": 2,
  "resonance_override": { "threshold": 4, "amount": 3 }
}

// Tempestade de Ressonância — área igual à ressonância
"effect": {
  "action": "damage",
  "damage_type": "magico",
  "target": "all_enemy_permanents",
  "amount": "resonance"
}

// Apoteose Astral — base + ressonância × 2
"effect": {
  "action": "damage",
  "damage_type": "magico",
  "target": "any_permanent_or_hero",
  "amount": 5,
  "resonance_bonus": { "multiplier": 2 }
}
```

### 3.8 Dano Não-Letal (Ferida Astral)

Aplica dano mas não pode reduzir HP a 0 ou menos.

```json
"effect": {
  "action": "damage",
  "amount": 2,
  "damage_type": "magico",
  "target": "any_enemy_permanent",
  "non_lethal": true
}
```

### 3.9 Spawn de Token Vinculado (Lança de Captura, Ritual de Colheita)

Cria uma criatura token com a tag `vinculado` em um slot vazio do jogador.

```json
// Lança de Captura — spawn se destruir
"effect": {
  "action": "damage",
  "amount": 4,
  "damage_type": "magico",
  "target": "any_enemy_permanent",
  "on_destroy": {
    "action": "spawn_vinculada",
    "spawn_attack": 2,
    "spawn_health": 2
  }
}

// Ritual de Colheita — área + spawn por destruído
"effect": {
  "action": "damage",
  "amount": 2,
  "damage_type": "magico",
  "target": "all_enemy_permanents",
  "on_each_destroy": {
    "action": "spawn_vinculada",
    "spawn_attack": 1,
    "spawn_health": 1
  }
}
```

### 3.10 Draw Escalável por Tag (Fluxo de Vínculo)

Compra N cartas onde N é o número de permanentes do jogador com determinada tag.

```json
"effect": {
  "action": "draw",
  "amount": "count_own_tag",
  "tag": "vinculado",
  "max_amount": 3
}
```

### 3.11 Força Combate Inimigo vs Inimigo (Dominação Forçada)

O jogador escolhe dois permanentes inimigos. O primeiro ataca o segundo neste turno. Requer rota válida entre os dois.

```json
"effect": {
  "action": "force_combat",
  "attacker": "choose_enemy_permanent",
  "defender": "choose_enemy_permanent"
}
```

### 3.12 Cura de Permanente (Reparação de Éter — hero power do Arquiteto)

```json
"effect": {
  "action": "heal_permanent",
  "amount": 4,
  "target": "any_own_damaged_structure"
}
```

### 3.13 Aumento de HP Máximo (Reforço Estrutural)

```json
"effect": {
  "action": "increase_max_health",
  "amount": 3,
  "target": "any_own_structure"
}
```

### 3.14 Reset de Estado em Massa (Elo de Éter)

Marca todos os permanentes próprios com ATK > 0 como `pronta` imediatamente.

```json
"effect": {
  "action": "set_state",
  "state": "pronta",
  "filter": "own_structures_with_attack"
}
```

### 3.15 Dano Distribuído Escalável (Sobrecarga de Construto)

Dano total igual ao número de permanentes próprios com filtro. Jogador distribui entre alvos.

```json
"effect": {
  "action": "damage_distributed",
  "damage_type": "magico",
  "amount": "count_own_tag",
  "tag": "estrutura",
  "target": "choose_enemy_permanents"
}
```

### 3.16 Dreno com Armadura (Drenar Vitalidade)

Causa dano e converte o dano efetivo causado em armadura para o herói.

```json
"effect": {
  "action": "damage",
  "amount": 4,
  "damage_type": "magico",
  "target": "any_enemy_permanent",
  "lifesteal": "armor"
}
```

### 3.17 Enjoo com Duração Estendida (Supressão em Massa)

Enjoo que persiste até o início do próximo upkeep da criatura afetada (cobre o turno inteiro do inimigo).

```json
"effect": {
  "action": "apply_status",
  "status": "enjoo",
  "target": "all_enemy_creatures",
  "duration": "extended"
}
```

---

## 4. GameSession — Campos Necessários para Classes

Campos a adicionar em `core/game_session.gd` com cobertura de save/load:

| Campo | Tipo | Default | Descrição |
|---|---|---|---|
| `selected_class` | `String` | `""` | ID da classe selecionada (vazio = nenhuma classe) |
| `resonance` | `int` | `0` | Contador de ressonância do turno atual (zerado no descarte; não persiste entre sessões) |

Migração de save: se `selected_class` não estiver no JSON do save, o valor padrão é `""` (string vazia), o que aciona a tela de seleção de classe na próxima sessão.

O campo `resonance` **não é persistido no save** — é estado volátil de combate.

---

## 5. Forma Vinculada — Token Runtime

Criaturas geradas por Captura Forçada, Espectro Coletor, Lança de Captura, Mestre Vinculador e Ritual de Colheita.

Propriedades:
- Tag obrigatória: `"vinculado": true` no objeto de permanente em runtime
- Não retornam ao deck quando destruídas (removidas do jogo)
- ATK e HP definidos pelo efeito que as gerou (ou copiados do alvo para Captura Forçada)
- Comportam-se como criaturas normais em combate

O engine representa Formas Vinculadas como permanentes runtime sem `card_id` no deck — apenas existem enquanto estão em jogo.

---

## 6. Resumo dos Sistemas de Engine por Prioridade de Implementação

| Sistema | Cartas / Hero Powers | Complexidade | Primeira Classe que Precisa |
|---|---|---|---|
| Hero power data-driven | Todas (5 hero powers) | Média | Assaltante |
| `on_destroy` em feitiço | Garra do Vazio | Baixa | Assaltante |
| `on_combat_kill` hook | Pilhador, Laçador, Guardião, Mestre | Média | Assaltante |
| `upkeep_trigger` em permanente | Bastião, Núcleo, Extrator, Senhor, Exodia | Média (compartilhado) | Arquiteto |
| `increase_max_health` | Reforço Estrutural | Baixa | Arquiteto |
| `set_state` em massa | Elo de Éter | Baixa | Arquiteto |
| `damage_distributed` | Sobrecarga de Construto | Média | Arquiteto |
| `apply_status` via feitiço em permanente alvo | Correntes, Drenagem, Névoa, Supressão | Baixa | Dominador |
| `duration: extended` em enjoo | Supressão em Massa | Média | Dominador |
| `lifesteal: armor` | Drenar Vitalidade | Baixa | Dominador |
| `gain_stats` permanente condicional | Extrator | Baixa (usa upkeep system) | Dominador |
| Ressonância counter | Todas as cartas do Tecelão | Baixa | Tecelão |
| `resonance_override` condicional | Pulso Ressonante, Onda de Éter | Baixa | Tecelão |
| `amount: resonance` | Centelha, Eco, Barreira, Tempestade, Apoteose | Trivial (lê variável) | Tecelão |
| `on_spell_cast` trigger | Custódio, Conduit | Média | Tecelão |
| `resonance_milestone` once_per_turn | Conduit Astral | Média | Tecelão |
| Spawn token runtime | Captura Forçada, Espectro, Lança, Mestre, Ritual | Alta | Vinculador |
| `non_lethal` dano | Ferida Astral | Baixa | Vinculador |
| `force_combat` inimigo vs inimigo | Dominação Forçada | Média | Vinculador |
| `count_own_tag` | Fluxo de Vínculo, Sobrecarga, Exodia | Baixa | Vinculador |
| `on_any_enemy_destroyed` trigger | Espectro Coletor | Média | Vinculador |
| `capture` hero power | Captura Forçada | Alta (depende de spawn) | Vinculador |
