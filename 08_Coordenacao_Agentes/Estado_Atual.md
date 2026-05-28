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

- Status: **P2_IMPLEMENTACAO - internal alpha site protected + Grimorio hub published; T03-P18 ready**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Track 00 completa com primeiro slice server-authoritative, Track 01 completa para hardening do alpha PC local e Track 02 com Progression Lab/Battle Lab v1, Character Systems Rework, Source Identity Balance v2, batalha visual procedural 2D, smokes e validacoes verdes. Track 03 tem design lock completo, T03-P11 local QA completo, T03-P12 release prep completo, T03-P13 remoto bootstrap completo, T03-P14 auth email/senha completo, T03-P15 manifest/version gate completo, T03-P16 exports locais Android/PC/Web completos com hashes registrados, T03-P17 verde para backend/downloads/Portal/Web e T03-P17A aprovada por Fabio com passada local de ergonomia Android no Hub/abas. O app cobre email/senha, guest dev, save ativo `normal`/`progression_lab`, reset separado, aplicacao server-backed de healthy saves no Lab, Base Manager jogavel, Social basico jogavel, Competicao/leaderboard alpha, Loja proof-of-concept, Batalha com readout compacto/HP percentual/tooltips melhores e Hub com checagem de update/bloqueio online por versao minima e modo compacto Android. Supabase remoto `armxgipvnbbshzqawklw` esta linkado, migrado, com Edge Functions publicadas, Auth email/senha sem confirmacao obrigatoria, `/account/bootstrap`, `create_alpha_account`, `release/manifest`, `content/grimoire`, Storage publico `draxos-internal-alpha`, bucket privado `draxos-internal-alpha-private` preservado para downloads autenticados futuros, Portal/Web republicados no Cloudflare Pages em `https://draxos-mobile-internal-alpha.pages.dev`, hub alpha privado com Grimorio estatico e smokes remotos verdes para release manifest/Grimorio. O site nao mostra login/acesso de jogo: Cloudflare Access por email e a barreira do hub, downloads usam links diretos do pacote publicado e registro/login ficam apenas in-game por enquanto. Hotfix de Web em 2026-05-27 reconciliou `index.js` ausente e `index.pck` stale no Supabase Storage, encerrando a tela preta apos `Jogar Web`. Upgrade visual local de 2026-05-28 aproximou o hub do tema Draxos com imagens otimizadas derivadas de `assets/referenciaimagens/`. Em 2026-05-27, Fabio aprovou o signoff para avancar para `T03-P18`. Supabase segue para alpha, Backend Proprio + Postgres e o plano de saida preferido, e Nakama fica apenas se realtime/social competitivo virar pilar.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo. Secrets e service role nunca entram no cliente/export.
- Proximo passo: executar `T03-P18 - Handoff Da Internal Alpha v0`.

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
