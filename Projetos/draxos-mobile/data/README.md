# data/

Definicoes de conteudo em JSON e resources Godot gerados.

- `definitions/` - fonte autorada dos contratos de conteudo.
- `generated/` - resources Godot produzidos por ferramentas locais, nao editar manualmente.
- `resources/` - scripts de Resource usados pelo catalogo gerado.

Fluxo atual:

```text
definitions/*.json -> tools/content_generator.gd -> generated/draxos_mobile_catalog.tres
definitions/*.json + tool models + simulator mirrors -> tools/generate_foundation_ruleset.ts -> rulesets/foundation_ruleset_v0.json
```

Fixtures `MVP_ONLY` sao tecnicas e nao representam balanceamento final.

Arena PVE v1 adiciona definitions ruleset-only:

- `definitions/pve_arenas.json`
- `definitions/pve_arena_difficulties.json`
- `definitions/pve_enemies.json`
- `definitions/arena_buffs.json`
- `definitions/arena_rewards.json`

Essas collections entram no ruleset e nos contratos backend/labs. Elas nao entram no catalogo Godot atual ate o client/package escolher consumi-las.

`pve_arenas.json` define o comprimento, regras e unlocks das arenas. `pve_arena_difficulties.json` define os tiers de Season 1 por arena/dificuldade, incluindo sequencia de inimigos, power final, reward profile planejado e clear-rate alvo.

Mode descriptors vivem em `definitions/modes/<mode_id>/`. Eles sao scaffolds
declarativos para registry/docs e nao entram no catalogo Godot nem mudam o
ruleset publicado nesta lane. Cada placeholder deve permanecer nao jogavel,
sem launch e sem reward ate uma decisao de pacote propria.
