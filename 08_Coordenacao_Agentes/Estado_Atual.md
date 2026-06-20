# Estado Atual - Estudio

- Ultima atualizacao: `2026-06-20`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- Regra de tamanho: maximo ~12 linhas por projeto. Historia de pacotes/validacoes vai para os arquivos de historico do projeto (`implementation/tracks/`, `docs/release-history.md`, Kanban Done), nunca para este snapshot.

## Prioridade Do Estudio

- Foco operacional ativo: `Projetos/JogoDaCopa/` (09S publicada com gates remotos PASS; reteste humano pendente; 09Q fallback aprovado) + `Projetos/draxos-mobile/` (Arena Runtime Config Sync Ready v3 publicado Web/APK/PC; aguardando prova humana) + `Projetos/FpsPlayground/` (Track 14E bot decision boundary aprovada; movimento atual preservado)
- Pausados temporariamente (poucos dias): `Projetos/draxos-roguelike-cardgame/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## JogoDaCopa

- Status: `P2_IMPLEMENTACAO - TRACK09S_PUBLISHED_REMOTE_GATES_PASS`
- Marker: `JOGO_DA_COPA_TRACK09S_PUBLISHED_REMOTE_GATES_PASS`
- Baseline publico atual: `Super Campeao v1.2.1+925f3b9f` (`web/v1-copa-arena-futebol-20260620-925f3b9f`) em `https://copa-arena-futebol.pages.dev/`; gates remotos 09S PASS, reteste humano pendente.
- Fallback humano aprovado: Track 09Q `Super Campeao v1.2.1+bb604c77`; remote menu/first-minute/stability/luma PASS (`js_heap_growth +8.41%`) e aprovada por Fabio/tester.
- Publicacao atual: Track 09S suaviza o foco visual da chase camera em toques rapidos de A/D; validate/export/Web smoke local PASS; remote menu/first-minute/stability/luma PASS (`js_heap_growth +8.63%`).
- Trabalho permitido: codigo, design, validacao, playtest no editor e documentacao local.
- Proximo passo: Fabio/tester retestar a URL publica 09S focando toques rapidos em A/D e movimento W/S; se aprovada, registrar 09S como baseline humano aprovado antes de retomar reducoes do `FootballRoot`.

## draxos-roguelike-cardgame

- Status: `PAUSADO_TEMPORARIO - retomada prevista em poucos dias`
- Track ativa preservada: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline: Track 02 completa em Godot 4.6.2 (rota de 29 mapas, save v5, keywords, AI/intent, labs Card Impact V5 e Design Lab V1, `validate.gd` 220/220). Detalhes em `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`.
- Meta preservada: expansao de conteudo via Design Lab antes de playtests completos de sensacao.
- Trabalho permitido: consulta historica; retomada apenas com pedido explicito.
- Proximo passo: retomar quando o foco temporario do JogoDaCopa encerrar.

## DraxosMobile

- Status: `P2_IMPLEMENTACAO` - Arena runtime_config recovery v3 publicado Web/APK/PC em 2026-06-16; aguardando prova humana
- Marker: `ARENA_RUNTIME_CONFIG_SYNC_READY_V3_PUBLISHED_INTERNAL_ALPHA`
- Pacote publicado: `Arena Runtime Config Sync Ready v3`, Web/APK/PC `0.0.27-alpha.0` / vc `27`, preview `https://a50d282b.draxos-mobile-internal-alpha.pages.dev`. Historico: `Projetos/draxos-mobile/docs/release-history.md`.
- Programa de hardening: runtime_config Web repinta rota ao sair de fallback; smoke remoto obrigatorio de runtime_config passou antes do reteste.
- Resultado de produto Arena PVE: `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN`; decisao em `08_Coordenacao_Agentes/Decisoes/2026-06-14_draxos-mobile_arena-core-ux-fix-not-proven.md`.
- Guardrails preservados: Track 13 release safety, Track 14 agent ops; fundacao server-authoritative/idempotencia/RLS NAO deve ser refatorada.
- Restricao operacional: ver `Projetos/draxos-mobile/AGENTS.md` (Hard Stops); secrets nunca no cliente; publicacao remota exige `-ConfirmRemoteMutation`; sem tuning numerico/PVP/economia/visual final sem decisao.
- Proximo passo: Fabio/tester executar a prova humana do pacote v3 seguindo `docs/arena-pve-product-proof.md`; registrar veredito antes de tuning, economia, PVP, conteudo novo, visual final ou expansao Openworld.

## FpsPlayground

- Status: `P2_IMPLEMENTACAO - TRACK14E_BOT_DECISION_BOUNDARY_APPROVED`
- Marker: `FPS_PLAYGROUND_TRACK14E_BOT_DECISION_BOUNDARY_APPROVED`
- Baseline: Track 14E extraiu scoring/intencoes do bot para `bot_decision_model.gd` sem alterar gameplay; testes `62/62`, `564 asserts`; aprovada por Fabio/tester.
- Guardrail recente: Track 08 movement feel descartada antes de merge; movimento atual, jump pads, mapas e bot route-control preservados.
- Validacao: `tools/validate.gd` quick/full PASS `62/62`, `564 asserts`; `tools/check_doc_drift.ps1` PASS; warnings GUT UID/text-path conhecidos.
- Trabalho permitido: codigo, design, validacao, playtest no editor e documentacao local.
- Proximo passo: executar `Track 14F - Cleanup And Documentation V1`.

## rpg-isometrico

- Status: `PAUSADO_INDEFINIDO` (current-status de `2026-04-26`)
- Baseline preservada: B0 interno com Arena / Survival / Boss jogaveis e frontend campaign-first.
- Trabalho permitido: consulta historica com pedido explicito; nao implementar nem expandir escopo.

## rpg-turnos

- Status: `PAUSADO_INDEFINIDO` (current-status de `2026-05-13`)
- Baseline preservada: slice Godot 4.6.2 jogavel com runtime C1, modos de batalha, 3 classes, 13 encontros e save/load JSON v2.
- Trabalho permitido: consulta historica com pedido explicito; nao implementar, nao regenerar `.tres`.

## Kanban Rapido

- Backlog / Doing / Review / Done: `08_Coordenacao_Agentes/Kanban/`
- Handoffs: `08_Coordenacao_Agentes/Handoffs/`
- Decisoes: `08_Coordenacao_Agentes/Decisoes/`

## Canon

- Fonte compartilhada estavel: `canon/` (brief rapido: `canon/canon-brief.md`)
