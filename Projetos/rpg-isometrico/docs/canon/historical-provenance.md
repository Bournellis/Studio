# Proveniência histórica do canon — RPG Isométrico

## Metadata

- status: reference
- authority: historical_record
- last_verified: 2026-07-17
- review_when: uma fonte histórica for removida do HEAD ou o canon local mudar
- supersedes: none
- superseded_by: none

Este registro liga decisões implementadas em G1–G4 e nas Tracks 01–02 às autoridades locais que retêm seu significado. Ele não cria canon, não reabre gate e não descreve trabalho ativo.

## Regra de leitura

- O canon atual prevalece sobre a formulação de qualquer gate antigo.
- `implementation/current-status.md` continua sendo a única autoridade técnica local.
- `implementation/history.md` preserva a linhagem executada e as validações.
- Estados intermediários só explicam a sequência; não voltam a valer por estarem registrados aqui.

## Decisões absorvidas pelo canon atual

| Decisão consolidada | Origem histórica | Autoridade retida |
| --- | --- | --- |
| Campanha PvE é a espinha do produto; modos extras são complementares. | F10 e F11-A/F11-E | `product/product-vision.md`; `design/game-design-document.md` |
| Classic ensina e libera o kit; Free é replay/buildcraft posterior. | F10 e F11-B/F11-D | `design/game-design-document.md`; `design/progression-design.md` |
| O kit continua `Race -> 1 Weapon -> 4 Skills -> 2 Potions`, mas não precisa ser montado antes da campanha inicial. | G1, Track 01 C0 e F11-C | `product/product-vision.md`; `design/game-design-document.md`; `architecture/shared-architecture.md` |
| A primeira campanha usa cinco mapas; Missão 1 ensina e o quinto mapa é o boss. | F03, F07 e F09 | `design/game-design-document.md`; `design/progression-design.md` |
| `Easy` conduz desbloqueios permanentes; `Normal` não cria nova progressão de poder; `Livre` não concede recompensas permanentes. | F05, F09 e F11-D | `design/progression-design.md` |
| Campanha e Arena Bot começam disponíveis; Survival abre após Missão 1 e Boss após concluir `Easy`. | F03, F05 e F11 | `design/progression-design.md` |
| Runs suspensas são separadas por rota; integração online não é requisito para a autoridade PvE local. | F09 e F10 | `design/progression-design.md`; `architecture/shared-architecture.md` |
| Arena, Survival e Boss compartilham a família de Combat Shell e resultados. | G4-04 e F11-E | `product/product-vision.md`; `design/game-design-document.md`; `architecture/game-mode-standard.md` |
| Private Duel permanece futuro/experimental, sem matchmaking público, ranked ou dedicated server como requisito atual. | F10 e F11 | `product/product-vision.md`; `design/game-design-document.md`; `architecture/shared-architecture.md`; `platform/steam-platform.md` |
| Crescimento deve aprofundar uma base provada antes de ampliar serviços ou superfície especulativa. | Track 01, F07 e F10 | `roadmap/evolution-roadmap.md`; `roadmap/release-horizons.md` |

## Sequência de supersessão preservada

| Estado anterior | Resolução posterior | Leitura correta |
| --- | --- | --- |
| F01 abria um tutorial obrigatório antes do menu. | F03 moveu o primeiro contato para o frontend e a Missão 1; F10/F11 consolidaram a campanha primeiro. | F01 é contexto de implementação, não fluxo vigente. |
| O frontend de F03 expunha grupos Aventura/Versus e Arena PvP como placeholder. | F10/F11 tornaram Campanha primária, Extras secundários e esconderam PvP da navegação pública. | O enquadramento posterior prevalece. |
| T01-B05 registrou que nenhuma lane de conteúdo havia sido escolhida. | F07 adotou Lane C e o candidato C1 para aprofundar Heroic/Martelo sem aumentar breadth. | A indecisão foi encerrada para aquela execução; não cria próxima lane durante a pausa. |
| F09 sugeria Hard ou mudança de breadth como gate futuro. | F10/F11 foram executados e depois o portfólio pausou o projeto. | Não há gate, próxima track ou direção ativa. |
| O art track de F01 estava marcado `ACTIVE`. | A Track 02 foi encerrada como história pela pausa. | O rótulo antigo não autoriza produção de arte atual. |

## Fronteira entre canon e implementação

O canon retém identidade, regras, hierarquia de modos, progressão, arquitetura e plataforma. IDs concretos, cenas, conteúdo C0/C1, contratos de catálogo, migração de save suspenso e números de teste são fatos da implementação e vivem em `implementation/history.md`.

Os nomes `Heroic`, `heroic_hammer`, quatro skills e duas potions descrevem a baseline Godot C0. Eles não são declaração automática do pacote de lançamento nem escolha de conteúdo futuro.

## Fontes auditadas

A curadoria leu 29 documentos em `implementation/tracks/`, 35 em `implementation/phase-g1/` a `phase-g4/`, 4 checkpoints, `implementation/execution-log.md` e 4 smokes. As fontes permanecem intactas; recuperação final também continua disponível pelo Git.
