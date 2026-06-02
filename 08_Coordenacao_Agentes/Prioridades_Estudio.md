# Prioridades do Estudio

Este documento e a fonte de verdade de portfolio para agentes e para coordenacao do `D:\Estudio`.

## Foco Atual

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao (`WEB_LAUNCH_RESILIENCE_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-web-launch-resilience-20260602-49dc5ea`, production URL `https://draxos-mobile-internal-alpha.pages.dev`, deployment evidence `https://9ba71c4e.draxos-mobile-internal-alpha.pages.dev`, preservando Refugio Visual Cleanup (`REFUGIO_VISUAL_CLEANUP_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0`), Openworld QoL regression fix (`OPENWORLD_QOL_REGRESSION_FIX_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129`) e Foundation Hardening V2 (`FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`) como baselines anteriores, Track 21 Arena Loop Unlock/Friction como contexto do Autobattler, Track 20 Season 1 Arena Calibration, Remote Lab Runner, Track 13 release safety e Track 14 agent ops): `Projetos/draxos-mobile/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/` (preservado como referencia - nao e o projeto ativo)
- Projetos pausados: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## Portfolio

| Prioridade | Projeto | Caminho | Fase | Status | Trabalho permitido | Proximo passo | Restricao operacional |
|---|---|---|---|---|---|---|---|
| P0 | Draxos Roguelike Cardgame | `Projetos/draxos-roguelike-cardgame/` | Implementacao | `P0_IMPLEMENTACAO` | Codigo, validacao, playtest, documentacao local | Playtest de usuario da Track 02 completa | Pode receber trabalho de implementacao por padrao |
| P2 | DraxosMobile | `Projetos/draxos-mobile/` | Implementacao - `WEB_LAUNCH_RESILIENCE_PUBLISHED_INTERNAL_ALPHA` | `P2_IMPLEMENTACAO` | Codigo, design, documentacao local, configuracao de infraestrutura | Web Launch Resilience encerrado com confirmacao humana em 2026-06-02 de que o Web esta funcionando. Proxima decisao: escolher novo polish visual dedicado ou voltar ao playtest funcional do Openworld | Web Launch Resilience publicado no release root `internal-alpha/v0-web-launch-resilience-20260602-49dc5ea`, production URL `https://draxos-mobile-internal-alpha.pages.dev`, deployment evidence `https://9ba71c4e.draxos-mobile-internal-alpha.pages.dev`; shell Web agora embute release/asset root, cache-bust nos assets pequenos, watchdog legivel apos 20s e limpeza seletiva de caches/service workers antigos, preservando sessoes Supabase/localStorage do jogo. Smoke Chrome/CDP no preview saiu da splash em 6715 ms, screenshot em `build/diagnostics/web-launch-remote-20260602-042353/web-launch-remote.png`; production fixo anonimo retorna Cloudflare Access como esperado. `index.pck` (`4611048`) e `index.wasm` (`37695054`) batem com `Content-Length` remoto. Validacao humana de 2026-06-02 confirmou que o Web esta funcionando. Sem gameplay, backend schema, migrations, economia, tuning ou conteudo novo. Android APK usa `debug_fallback`, aceito para playtest funcional, com release signing adiado para distribuicao Android mais ampla. Refugio Visual Cleanup segue preservado como baseline visual anterior no release root `internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0`; Openworld QoL regression fix segue preservado como baseline funcional anterior no release root `internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129`; Foundation Hardening V2 segue preservado como baseline anterior de hardening/multi-mode gates no release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`; Hardening Platform V1 segue preservado como baseline anterior. Track 21 Arena Loop Unlock/Friction e Track 20 Season 1 Arena Calibration seguem preservados como contexto do modo Autobattler/Arena PVE; Remote Lab Runner segue preservado para Battle Lab/Progression Lab no Web export; iOS sem pedido explicito; mobile browser fora do escopo primario; secrets e service role nunca entram no cliente/export; publicacao remota exige `-ConfirmRemoteMutation`; mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`; novos dados devem usar `account_profiles/game_saves`; regras devem passar por registry/ruleset versionado; mutations economicas/social novas devem passar por RPC transacional v1 com `request_id`/`request_hash`; direct chat, ajudas, contribuicoes, moderacao, PVP, novas armas, novas spells, economia ampla, previsao de vitoria, contra-escolha por oponente, thresholds customizados, comportamento por inimigo e controles avancados de replay bloqueados ate decisao propria |
| Arquivo | Mobile Universe (conceito) | `Projetos/_conceitos/mobile-universe/` | Arquivo de design | `ARQUIVO_DESIGN` | Leitura e referencia de design apenas | - | Nao criar codigo, cenas, assets ou projeto Godot a partir daqui |
| Pausado | RPG Isometrico | `Projetos/rpg-isometrico/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, expandir gates ou selecionar Next Gate sem pedido explicito |
| Pausado | RPG Turnos | `Projetos/rpg-turnos/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, selecionar track/gate, regenerar `.tres` ou alterar escopo sem pedido explicito |

## Status Aceitos

- `P0_IMPLEMENTACAO`: foco principal do trabalho de desenvolvimento, com permissao padrao para codigo, validacao e playtest.
- `P1_CONCEITO`: projeto em incubacao conceitual; permite documentos, pitch, design e referencias.
- `P2_IMPLEMENTACAO`: projeto ativo secundario; permite codigo, design, documentacao local e infraestrutura.
- `PAUSADO_INDEFINIDO`: projeto preservado, sem trabalho ativo por padrao.
- `AGUARDANDO_DECISAO`: projeto ou area sem proximo passo definido.
- `ARQUIVO_DESIGN`: material de conceito promovido - preservado apenas para leitura e referencia.
- `ARQUIVO_HISTORICO`: material preservado apenas para consulta historica.

## Regras Para Agentes

- Leia este arquivo antes de escolher projeto alvo.
- Se o pedido nao citar projeto, assuma que trabalho de implementacao pertence ao Draxos Roguelike Cardgame (P0).
- Nao mova mecanicas, decisoes ou escopo entre projetos sem documento local adotando a regra.
- Em `_conceitos/mobile-universe/`, apenas leitura e referencia de design - o projeto ativo e `draxos-mobile/`.
- Em RPG Isometrico e RPG Turnos, nao implemente nem expanda escopo sem pedido explicito do usuario.
- Ao concluir tarefa que mude status observavel, atualize este arquivo, `Estado_Atual.md` e o registro relevante em `Projetos/README.md`.
