# História consolidada — RPG Isométrico

## Metadata

- status: reference
- authority: historical_record
- last_verified: 2026-07-17
- review_when: uma fonte histórica for removida do HEAD ou uma correção factual for necessária
- supersedes: `phase-g1/ a phase-g4/, tracks/, checkpoints/ e execution-log.md como rota normal de história`
- superseded_by: none

Este registro preserva a linhagem técnica e de validação que continua útil depois da curadoria Documentation Lite v2. Ele não define estado, não abre gate e não autoriza retomada.

## Autoridade e limites

- Estado técnico atual: `current-status.md`.
- Canon e decisões de produto: `../docs/canon/README.md`.
- Proveniência e supersessões do canon: `../docs/canon/historical-provenance.md`.
- QA executável atual: `../qa/qa_manifest.json` e `../qa/QA_INDEX.md`.
- Fontes históricas continuam presentes no worktree e no Git até um cutover destrutivo separado, literal e aprovado.

O projeto permanece `PAUSADO_INDEFINIDO`, sem track, gate ou próximo passo. Aprovações abaixo são fatos históricos e não aprovações atuais de produto, publicação ou retomada.

## Cobertura da curadoria

Foram auditados 73 documentos:

- 29 documentos em `tracks/`, incluindo o router da pasta;
- 35 documentos em `phase-g1/` a `phase-g4/`;
- 4 documentos em `checkpoints/`;
- `execution-log.md`;
- 4 smokes em `docs/`.

## Linhagem G1–G4

| Ciclo | Resultado retido | Validação registrada | Limite preservado |
| --- | --- | --- | --- |
| G1 — Combat Foundation | Primeiro fluxo Godot, C0 e geração JSON. | `validate.gd`/GUT verdes; jogado e iterado; aprovado para G2. | Solo/PC; mobile, online e breadth fora. |
| G2 — Slice Stabilization | Cenas editor-owned, anchors e gerador não destrutivo. | GUT `5/5`, 57 asserts e saída limpa. | Qualidade e ownership, sem ampliar gameplay. |
| G3 — Combat Productionization | Baseline de combate legível, julgável e aceita. | GUT `15/15`, 119 asserts; first slice aceita após playtests. | Escala, mobile, online e visual final não provados. |
| G4 — Shared Solo Base | Arena, Survival e Boss em shell e retorno comuns. | De 18 testes a `25/25`, 352 asserts; checkpoint aceito. | Release, Steam, campanha, co-op e playtest público fora. |

### Detalhes únicos de G3

- G3-01 adicionou eventos e estatísticas de combate ao `GameContext`, telegraph do bot e resumo de round.
- G3-02 introduziu pre-match countdown, linger pós-morte e feedback para dano, cura, barreira, bloqueio e morte.
- G3-03 adicionou resposta de câmera, readiness de ataque/dash e ritmo `pressure -> windup -> reposition` do bot.
- G3-04, registrado no progress log mesmo sem stage spec próprio, adicionou anéis de alcance/ameaça e marcador de aim no piso.
- G3-05 separou tells de projectile, buff, burst e leap e adotou autoridade de mira manual no desktop.
- G3-06 reforçou impacto no alvo, motion pause curto e final-blow beat.
- G3-07 reduziu clutter e tornou previews/contextos mais seletivos.
- G3-08 ampliou arena, zoom ortográfico, perímetro fechado e obstáculos internos.

### Detalhes únicos de G4

- G4-01 criou roteamento comum, launch context sanitizado e ownership por bootstrap/session/game loop.
- G4-02 entregou Survival local com waves, rest windows, trolls e término rápido na Wave 7.
- G4-03 entregou Boss Troll com três fases, invulnerabilidade de transição, regeneração e Martelada/Tremor/Rugido.
- G4-04 consolidou shell snapshots e seções de resultado para os três modos.
- G4-05 cobriu copy/defaults, consumo sequencial do launch context e o protocolo de smoke/handoff.

## Track 01 — baseline Godot B0

Track 01 partiu da base G4 aceita e concluiu quatro threads validadas:

1. B01 removeu linguagem de validação do frontend e tornou seleção/saved kit mais legíveis.
2. B02 consolidou hierarquia e retorno da família de resultados.
3. B03 persistiu o último modo, detectou save incompatível e evitou restauração parcial ambígua.
4. B04 refinou CombatHud, eventos recentes e cues específicos de Arena, Survival e Boss sem forkar a shell.

Cada thread registra `tools/validate.gd` verde. Nenhuma registra contagem própria de testes/asserts, portanto esta história não atribui números a essas execuções.

### Baseline C0 e candidato C1

C0 implementou exatamente:

- race `heroic`;
- weapon `heroic_hammer`;
- skills `breaker_leap`, `hammer_impact`, `heroic_rally` e `seismic_ring`;
- potions `bastion_tonic` e `vital_flask`.

Isso provou pipeline JSON, geração de catálogos, montagem do kit e suporte à base local. Não definiu pacote de lançamento.

T01-B05 nasceu sem lane escolhida. F07 depois adotou C1/Lane C: aprofundar a rota atual sem adicionar race, weapon, skill ou potion. A adoção descreve a execução encerrada e não escolhe conteúdo futuro durante a pausa.

## Track 02 — fundação de produto executada

| Gate | Resultado histórico retido | Supersessão ou limite |
| --- | --- | --- |
| F01 | Perfil local, boot, tutorial e disponibilidade de modos. | O tutorial pré-menu foi substituído por frontend primeiro e tutorial na Missão 1. |
| F03 | Framework da primeira campanha, persistência de conclusão e unlock de Boss. | O framing Aventura/Versus e PvP placeholder foi substituído por F10/F11. |
| F05 | Rewards authored com `reward_id`, `applied_reward_ids`, unlocks permanentes e idempotência em resume/replay. | Sem loot economy, shop, moeda ou backend. |
| F07 | Catálogo gerado para `blacksmith_campaign/easy`; runtime deixou de hardcodar a sequência de cenas. | Lane C manteve Heroic/Martelo sem breadth. |
| F09 | Rota pública `normal`, cinco stages, boss no quinto, chaves de suspensão por rota e migração do save Easy legado. | Normal não concedeu novos unlocks; Hard ficou fora. |
| F10 | Canon alinhado a campanha PvE-first, kit-first, co-op condicional e Private Duel experimental. | Gate documental; não implementou online, co-op ou PvP. |
| F11 | Cinco slices concluídos: frontend campaign-first, Classic, UX de kit, Campanha Livre e framing de Extras. | Nenhum gate seguinte foi escolhido antes da pausa. |

### Runtime ao fim de F11

- Boot abre o frontend; `Campanha do Troll` é primária e Extras são secundários.
- Easy e Normal usam catálogos authored; Campanha Livre é replay/buildcraft pós-Easy.
- Campaign runs são suspensas por `campaign + difficulty`; o save Easy legado migra no primeiro resume compatível.
- Rewards permanentes são idempotentes; Livre e Extras não concedem progressão permanente.
- Arena PvP/Private Duel continua definido internamente, mas ausente da navegação pública.
- O validador passou a executar GUT in-process para evitar o hang de subprocesso Windows observado durante F11-E.

## Linhagem de validação

| Marco | Automação registrada | Evidência humana registrada |
| --- | --- | --- |
| G1 | `validate.gd` + GUT, sem contagem preservada. | Slice jogado/iterado; aprovado para G2. |
| G2 | `5/5`, 57 asserts, saída limpa. | G1 aceito como base para estabilização. |
| G3 | `15/15`, 119 asserts. | Playtests repetidos; first slice aceito como provado. |
| G4-01 | 18 testes; asserts não registrados. | Nenhuma aprovação autônoma inferida. |
| G4-02 | Suite verde; contagem não registrada. | Nenhuma aprovação autônoma inferida. |
| G4-03 | 21 testes; asserts não registrados. | Nenhuma aprovação autônoma inferida. |
| G4-04 | 23 testes, 280 asserts. | Nenhuma aprovação autônoma inferida. |
| G4-05 / Checkpoint | 25 testes, 352 asserts. | Pacote aceito após corrigir erros iniciais; fresh play pass do handoff exato continuou listado como não provado. |
| Baseline posterior preservada | 63/63 testes, 1.310 asserts; geração byte-estável. | Nenhum gate humano ativo e nenhuma playability nova inferida. |

Contagens ausentes permanecem ausentes. “Validador verde” não é convertido em número nem em aprovação humana.

## Smokes e significado da evidência

- `docs/first-slice-smoke.md` é o protocolo antigo de frontend/Arena/result e foi supersedido pelo smoke G4.
- `docs/g4-shared-mode-foundation-smoke.md` cobre Arena Bot, Survival, Boss, shell, retorno e reentrada.
- `docs/canonical-product-foundation-smoke.md` cobre boot, campanha primeiro, tutorial, perfil, Livre e Extras.
- `docs/campaign-framework-smoke.md` cobre Easy/Normal/Livre, rewards, resume, migração de chave e unlocks.

Um checklist descreve como validar; não prova que uma execução ocorreu. Só checkpoints e registros que declaram execução/decisão são tratados como evidência histórica de aceitação.

## Recuperação

As fontes originais permanecem recuperáveis pelos caminhos registrados e pelo Git. Uma eventual remoção do HEAD exige manifesto literal aprovado, autoridade retida e receipt de execução; este documento isoladamente não autoriza exclusão.
