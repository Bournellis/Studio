# RPG Turnos — história técnica curada

## Metadata

- status: `frozen`
- authority: `historical_record`
- last_verified: `2026-07-17`
- review_when: `uma fonte histórica, decisão ou baseline de validação precisar de correção`
- supersedes: `roadmap, track status, planos lineares, brief, gaps e smoke pré-Documentation Lite v2`
- superseded_by: `none`

Este registro preserva resultados e decisões já ocorridos. Ele não define estado atual, próxima track ou autorização de retomada; use `current-status.md` para a baseline local e `../docs/resume-brief.md` para reentrada.

## Inventário pré-cutover

- Sete Markdown de tracks pré-cutover: índice, três registros da Track 01 e três da Track 02.
- Seis documentos históricos adicionais: roadmap, experimentos C1, project brief, migração de lore, open gaps e primeiro smoke.
- As fontes foram retiradas do `HEAD` pelo manifesto aprovado e estão mapeadas em `history-ledger/`. O Git preserva o texto integral no baseline Documentation Lite.

## Fundação e Track 01

- O project brief definiu a separação entre exploração e combate, o tabuleiro de slots e a independência mecânica do RPG Isométrico. Energia 1, deck de 10 cartas e decisões abertas daquele brief foram supersedidos.
- A matriz experimental A1/A2/B1/B2 foi encerrada quando C1 virou o único turno oficial: manutenção, compra, fase principal, prioridade compartilhada, sem stack/resposta/counterspell.
- Track 01 entregou menu, exploração 2D, NPC, deck setup de 20 cartas, C1, JSON autoral, recursos/cenas gerados e retorno por resultado.
- A fundação concluiu dano físico/mágico, energia/hand ramp, descarte público, deck cíclico, `voadora`, `rapido`, `defensor`, `atropelar`, `alcance`, cobertura, queimando, movimento, neutral slots e topologia data-driven.
- Os seis modos oficiais entraram de forma incremental: `limpar_mesa`, `duelo`, `ondas`, `defesa`, `chefe_multiparte` e `quebra_cabeca`.
- World chain, recompensas one-time, save/load, placeholders art-ready, `UiTokens`/`AssetIds`, HUD e testes fecharam a Track 01. `Preparar Defesa` ficou somente como fallback sem classe.

## Track 02 — P01 a P14

| Prompts | Resultado durável |
|---|---|
| P01–P03 | Expuseram classes no recurso/ContentLibrary, persistiram `selected_class` e substituíram as cinco classes descartadas por Invocador, Arcano e Necromante, cada uma com deck de 20 cartas. |
| P04–P06 | Entregaram Invocador, `Comandante de Campo`, `Amplificar`, seleção de classe, deck, labels e integração ponta a ponta. |
| P07–P09 | Entregaram Fluxo por turno, amplificação isolada de dano mágico e `Pulso Astral` para Arcano. |
| P10–P13 | Entregaram Cinzas, Memorial, três degraus do `Ritual das Sombras`, `enjoo_estendido`, tokens, triggers `on_death` e deck do Necromante. |
| P14 | Travou regressão das três classes nos seis modos sem depender de herói inimigo fora de `duelo`. |

## Track 02 — P15 a P19

- P15 melhorou legibilidade mínima de HUD/classe e status sem aprovar direção visual final.
- P16 deu `mission` aos 11 encontros e alinhou a cadeia principal ao papel operacional Draxos, mantendo IDs naquele momento.
- P17 adicionou `operacao_rank` 0–3, persistência/retrocompatibilidade, gates de encontros laterais, labels e 18 testes.
- P18 registrou pressões por fraqueza de Invocador, Arcano e Necromante, ajustou dois spawns e adicionou cobertura contratual.
- P19 adicionou `centelha_duplicada`, `espectro_veloz`, `reduto_eter`, `escolta_vulcanica`, recompensas laterais e pool NPC ampliado.

## P20 — IDs, save e integridade

Os oito renames cobertos pela migração são:

| v1 | v2 |
|---|---|
| `emboscada_na_ponte` | `operacao_pouso` |
| `duelista_bandido` | `confronto_guardiao` |
| `emboscada_no_cruzamento` | `tomada_conduto` |
| `fortaleza_do_desfiladeiro` | `avanco_bastiao` |
| `invasao_em_ondas` | `ondas_resistencia` |
| `defesa_do_portao` | `defesa_base_ether` |
| `colosso_fragmentado` | `nucleo_fragmentado` |
| `enigma_da_ponte` | `ruptura_selos` |

- O inimigo `duelista_bandido` virou `guardiao_elemental`; portrait/AssetId acompanharam.
- `SAVE_VERSION` passou de 1 para 2. A migração cobre encontro ativo, completados e recompensas reivindicadas sem mutar o input.
- `patrulha_avancada`, `duelista_sombrio`, `emboscada_reforcos`, `escolta_vulcanica` e `reduto_eter` ficaram deliberadamente inalterados por falta de decisão de lore.
- O reparo de 2026-07-16 restaurou `initialize_deck_for_class()`, tornou a migração pura/determinística, regenerou somente o catálogo oficial e removeu bytes NUL de documentos.
- A suite integral fechou `249/249` testes e `954` asserts. Uma segunda execução deixou o mesmo estado Git. Jogabilidade humana não foi revalidada.

## Documentos supersedidos

- `implementation/roadmap.md` acumulava passes concluídos e uma direção antiga; não autoriza continuação.
- `docs/cardgame-core-experiments.md` preservava variantes rejeitadas; a decisão C1 permanece no GDD.
- `docs/project-brief.md` era a conversa inicial, não contrato ativo.
- `docs/lore-content-migration.md` apontava incorretamente o Roguelike como autoridade de nomes. RPG Turnos usa lore compartilhada e adoção local explícita.
- `docs/open-gaps.md` misturava gaps resolvidos, opções de produto e dívida. Questões ainda deliberadas foram levadas ao `resume-brief.md` sem abrir backlog.
- `docs/first-playable-slice-smoke.md` descrevia o primeiro C1 e o fallback `Preparar Defesa`; a jornada atual vive em `../qa/QA_INDEX.md`.
- A versão anterior de `docs/class-catalog-schema.md` continha exemplos completos das cinco classes abandonadas. O contrato atual foi reduzido às três classes realmente presentes no JSON.

## Gates preservados

- Não existe gate ativo nem próxima track enquanto o portfólio mantiver a pausa.
- Retomada, lore, progressão, direção visual, balanceamento e conteúdo futuro exigem decisão explícita de Fabio quando forem tocados.
- Validação técnica ou recuperação documental não aprova qualquer uma dessas superfícies.
