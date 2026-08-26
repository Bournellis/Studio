# Fronteiras entre projetos

## Metadata

- status: living
- authority: operational_contract
- last_verified: 2026-08-26
- review_when: um projeto adotar contrato externo, domínio do Core ou regra originada em outro projeto
- supersedes: none
- superseded_by: none

## Regra central

Projetos podem pertencer ao mesmo Studio sem compartilhar universo. O vínculo e os domínios adotados são declarados no `STUDIO_CORE.md` de cada projeto; somente `universe_binding: shared` consome os domínios enumerados do Core.

Mesmo entre projetos vinculados, mecânica, economia, progressão, arquitetura, plataforma, backend, conteúdo, campanha, personagens e tuning permanecem locais até uma adoção explícita e rastreável pelo projeto receptor.

## Adoção explícita

Uma adoção válida deve:

1. identificar a regra e sua origem;
2. registrar o contrato local que passa a governá-la;
3. explicar adaptações e incompatibilidades;
4. definir validação própria do projeto receptor;
5. evitar referência viva que transforme o projeto de origem em dependência operacional acidental.

Lore local só sobe ao Core por decisão autoral e promoção explícita. Um projeto nunca se torna autoridade compartilhada para outro por referência direta.

Reuso de código também exige compatibilidade com os limites locais. Copiar uma implementação não promove automaticamente o seu comportamento a canon.

## Limites atuais

- O canon de produto do RPG Isométrico vive em `Projetos/rpg-isometrico/docs/canon/`.
- RPG Turnos não herda loadout, combate em tempo real, câmera, modos ou roadmap do RPG Isométrico.
- Draxos Roguelike Cardgame não é variante do RPG Turnos.
- DraxosMobile não herda gameplay, economia ou progressão dos outros projetos Draxos.
- JogoDaCopa e FpsPlayground possuem `universe_binding: none` e não herdam lore, identidade ou sistemas Draxos.
- Referências visuais eventuais são locais e não alteram esse vínculo.
