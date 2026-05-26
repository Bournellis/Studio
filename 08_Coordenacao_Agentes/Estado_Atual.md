# Estado Atual - Estudio

- Ultima atualizacao: `2026-05-26`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade do Estudio

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao: `Projetos/draxos-mobile/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Projetos pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## draxos-roguelike-cardgame

- Status: **P0_IMPLEMENTACAO - ativo**
- Fase: `Implementacao`
- Track ativa: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline atual: Track 02 completa para playtest de usuario em Godot 4.6.2 com rota fixa de 29 mapas, recompensas/reliquias/loja expandida, keywords completas, AI/intent, modos e formatos de encontro, field effects, boss hooks, UI polida para mapa/batalha/recompensa/loja/tooltips, descarte marcado na fase principal, validacao verde 94/94, telemetria de rota completa e screenshots obrigatorias capturadas.
- Meta ativa: playtest manual da Track 02 completa e coleta de feedback de balanceamento.
- Trabalho permitido: codigo, validacao, playtest e documentacao local.
- Proximo passo: executar playtest de usuario da Track 02 completa.

## DraxosMobile

- Status: **P2_IMPLEMENTACAO - source identity balance v2 + dev lab flow/visual hardened + battle stage 2d procedural**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Track 00 completa com T00-P01 a T00-P13 concluidos e Track 01 completa para hardening do alpha PC local. Track 02 tem Progression Lab v1, Battle Lab dev-only, Character Systems Rework e Source Identity Balance v2 implementados em docs, catalogo, simulador, Edge Functions, seeds/migrations, Godot dev tools e testes: armas viraram Instrumentos Rituais, passivas viraram Doutrinas, pets viraram Familiares, Mental virou familia de status e fontes vivas agora sao Arcano/Fisico/Fogo/Agua/Gelo/Terra/Vento/Raio/Veneno/Sangue/Morte. Cliente Godot 4.6.2 segue com hub alpha, `tools/validate.gd`, GUT `35/35`, `203` asserts, exports Android/PC/Web, pipeline `data/definitions/*.json` -> `data/generated/draxos_mobile_catalog.tres`, Supabase local em `supabase/`, conta guest, `battle/request` server-authoritative, Base/Social/Competicao/Monetizacao/Telemetria v0 e smokes verdes. Batalha e Battle Lab compartilham `BattleVisualMockup` para apresentar `battle_log_v1` com palco procedural 2D estilo luta lateral, personagens parados frente a frente, ataque basico, spells, buffs, dano, numeros flutuantes, projeteis simples, icons, cooldowns, tooltips objetivos durante efeitos, slots front/middle/back, summons, Familiar e HUD basica, sem simular combate no cliente. Battle Lab/Progression Lab no Godot tem invocacao Deno sanitizada contra comandos completos/args acumulados, wrapper Windows-safe para `npx.cmd`, smoke real `tools/smoke_dev_labs.gd` e smoke visual `tools/smoke_dev_lab_ui.gd`; Battle Lab prioriza amostra de replay com spells visiveis, replay custom agora aparece em Replay/History e a aba Replay e rolavel. Progression Lab consegue carregar cache local-only a partir de healthy saves quando nao ha Supabase service key. Battle Lab run `2026-05-25_source_identity_balance_v02` gera `3132` batalhas e `212` builds com status `PASS`, duracao media `24.08s`, anti-stall `4.95%`, dominancia em poder proximo maxima `63.46%` e checks de identidade de fonte em `PASS`; Progression Lab gera `25` saves e `75` bots com status `REVIEW` por premium gap e janelas 15h/20h.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo.
- Proximo passo: rodar Progression Lab com Supabase local, carregar saves `2h`-`20h` manualmente no Godot e abrir rodada before/after focada em premium gap 10h, janelas 15h/20h, poder, recompensa, Defesa/Mental e sensacao de Familiar/Funeral.

## rpg-isometrico

- Status: **PAUSADO_INDEFINIDO**
- Fase: `Pausado`
- Baseline preservada: B0 interno com Arena / Survival / Boss jogaveis e frontend campaign-first.
- Ultima atualizacao do current-status: `2026-04-26`
- Trabalho permitido: consulta historica e leitura de contexto quando o usuario pedir explicitamente.
- Restricao operacional: nao implementar, expandir gates, selecionar Next Gate ou alterar escopo sem pedido explicito.
- Proximo passo: nenhum enquanto pausado.

## rpg-turnos

- Status: **PAUSADO_INDEFINIDO**
- Fase: `Pausado`
- Baseline preservada: slice Godot 4.6.2 jogavel com runtime C1, modos de batalha, 3 classes, 13 encontros, ranks de operacao e save/load JSON v2.
- Ultima atualizacao do current-status: `2026-05-13`
- Trabalho permitido: consulta historica e leitura de contexto quando o usuario pedir explicitamente.
- Restricao operacional: nao implementar, selecionar proxima track/gate, regenerar `.tres` ou alterar escopo sem pedido explicito.
- Proximo passo: nenhum enquanto pausado.

## Kanban rapido

- Backlog: `08_Coordenacao_Agentes/Kanban/Backlog/`
- Doing: `08_Coordenacao_Agentes/Kanban/Doing/`
- Review: `08_Coordenacao_Agentes/Kanban/Review/`
- Done: `08_Coordenacao_Agentes/Kanban/Done/`

## Canon

- Fonte de verdade compartilhada: `canon/`
- Brief rapido: `canon/canon-brief.md`
