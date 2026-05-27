# Estado Atual - Estudio

- Ultima atualizacao: `2026-05-27`
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

- Status: **P2_IMPLEMENTACAO - internal alpha v0 T03-P18 complete; handoff ready**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Track 00 completa com primeiro slice server-authoritative, Track 01 completa para hardening do alpha PC local e Track 02 com Progression Lab/Battle Lab v1, Character Systems Rework, Source Identity Balance v2, batalha visual procedural 2D, smokes e validacoes verdes. Track 03 esta completa para Internal Alpha v0: design lock, QA local, Supabase remoto, auth email/senha, manifest/version gate, exports Android/PC/Web, publicacao unlisted, passada de ergonomia Android e handoff final `T03-P18`. O app cobre email/senha, guest dev, save ativo `normal`/`progression_lab`, reset separado, aplicacao server-backed de healthy saves no Lab, Base Manager jogavel, Social basico jogavel, Competicao/leaderboard alpha, Loja proof-of-concept, Batalha com readout compacto/HP percentual/tooltips melhores e Hub com checagem de update/bloqueio online por versao minima e modo compacto Android. Supabase remoto `armxgipvnbbshzqawklw` esta linkado, migrado, com Edge Functions publicadas, Auth email/senha sem confirmacao obrigatoria, `/account/bootstrap`, `create_alpha_account`, `release/manifest`, Storage `draxos-internal-alpha`, APK/PC ZIP republicados via Storage, Portal/Web republicados no Cloudflare Pages em `https://draxos-mobile-internal-alpha.pages.dev`, manifest remoto atualizado, HTML remoto igual ao pacote local e smokes remotos verdes para release manifest. Handoff final: `Projetos/draxos-mobile/docs/internal-alpha-v0-handoff.md`. Supabase segue para alpha, Backend Proprio + Postgres e o plano de saida preferido, e Nakama fica apenas se realtime/social competitivo virar pilar.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo. Secrets e service role nunca entram no cliente/export.
- Proximo passo: rodada fechada Fabio + tester e backlog de feedback pos-handoff.

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
