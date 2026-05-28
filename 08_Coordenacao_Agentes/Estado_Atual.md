# Estado Atual - Estudio

- Ultima atualizacao: `2026-05-28`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade Do Estudio

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao: `Projetos/draxos-mobile/` (Track 15 `TRACK_15_MOBILE_UX_OVERHAUL_ACTIVE`, sobre Track 13 release safety e Track 14 agent ops)
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Projetos pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## draxos-roguelike-cardgame

- Status: **P0_IMPLEMENTACAO - ativo**
- Fase: `Implementacao`
- Track ativa: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline atual: Track 02 completa para playtest de usuario em Godot 4.6.2 com rota fixa de 29 mapas, recompensas/reliquias/loja, keywords, AI/intent, modos, field effects, boss hooks, UI polida, validacao verde 94/94, telemetria de rota completa e screenshots obrigatorias capturadas.
- Meta ativa: playtest manual da Track 02 completa e coleta de feedback de balanceamento.
- Trabalho permitido: codigo, validacao, playtest e documentacao local.
- Proximo passo: executar playtest de usuario da Track 02 completa.

## DraxosMobile

- Status: **P2_IMPLEMENTACAO - Track 15 TRACK_15_MOBILE_UX_OVERHAUL_ACTIVE**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Track 00-14 integradas. O projeto tem primeiro slice server-authoritative, Internal Alpha v0 aprovada por Fabio + tester, Refugio portrait como cena de jogo, batalha portrait fullscreen, Supabase remoto, manifest/version gate e builds Internal Alpha site/Web/APK/Windows republicadas em 2026-05-28. Track 11 consolidou estado vivo, Kanban, docs e walkthrough; Track 12 decompos `boot.gd` com action contract, account/session flow, surface action flow, battle lifecycle flow e helpers de superficie; Track 13 centralizou validacao foundation e protegeu release/publicacao por `Mode Plan` default, `-ConfirmRemoteMutation`, checks de safety/readiness e gate manual Android/Windows/Web; Track 14 reorganizou entrada de agentes, indice documental, snapshot vivo, coordenacao e guardas de validacao. Track 15 esta convertendo o app de alpha/dev funcional para UX interna premium Android portrait sem alterar gameplay, backend, schema ou economia.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo. Secrets e service role nunca entram no cliente/export. Publicacao remota exige `-ConfirmRemoteMutation`. Migration conta/save e tuning numerico ficam bloqueados ate walkthrough manual e decisao propria.
- Proximo passo: revisar checkpoint visual Track 15 em Android portrait para Entry, Refugio, Batalha/Summary, Base e Loja; depois continuar polish focado ou executar walkthrough manual Track 13 antes de gameplay, tuning, migration conta/save ou release.

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

## Kanban Rapido

- Backlog: `08_Coordenacao_Agentes/Kanban/Backlog/`
- Doing: `08_Coordenacao_Agentes/Kanban/Doing/`
- Review: `08_Coordenacao_Agentes/Kanban/Review/`
- Done: `08_Coordenacao_Agentes/Kanban/Done/`

## Canon

- Fonte de verdade compartilhada: `canon/`
- Brief rapido: `canon/canon-brief.md`
