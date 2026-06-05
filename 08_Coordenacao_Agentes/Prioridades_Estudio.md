# Prioridades do Estudio

Este documento e a fonte de verdade de portfolio para agentes e para coordenacao do `D:\Estudio`.

## Foco Atual

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao (`TECHNICAL_HARDENING_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-technical-hardening-20260605-8e54a1f`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://2fe9393e.draxos-mobile-internal-alpha.pages.dev`; publica Track 22 Technical Hardening ja incorporado ao `master`, preservando Openworld Main Menu Sync como pacote de conteudo anterior (`internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`, evidence `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`), Bosque Mecanico Basico v2 (`internal-alpha/v0-bosque-v2-guidance-20260604-7c2d981`, evidence `https://ae049df9.draxos-mobile-internal-alpha.pages.dev`), First Access Runtime Fix `4608977`, Integrated Runtime Fix `ab5834c`, Integrated App/Arena/Bosque `99304ed`, Web Launch Resilience, Refugio Visual Cleanup, Openworld QoL regression fix e Foundation Hardening V2 (`FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`) como baselines anteriores, Track 21 Arena Loop Unlock/Friction como contexto do Autobattler, Track 20 Season 1 Arena Calibration, Remote Lab Runner, Track 13 release safety e Track 14 agent ops): `Projetos/draxos-mobile/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/` (preservado como referencia - nao e o projeto ativo)
- Projetos pausados: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## Portfolio

| Prioridade | Projeto | Caminho | Fase | Status | Trabalho permitido | Proximo passo | Restricao operacional |
|---|---|---|---|---|---|---|---|
| P0 | Draxos Roguelike Cardgame | `Projetos/draxos-roguelike-cardgame/` | Implementacao | `P0_IMPLEMENTACAO` | Codigo, validacao, playtest, documentacao local | Playtest de usuario da Track 02 completa | Pode receber trabalho de implementacao por padrao |
| P2 | DraxosMobile | `Projetos/draxos-mobile/` | Implementacao - `TECHNICAL_HARDENING_PUBLISHED_INTERNAL_ALPHA` | `P2_IMPLEMENTACAO` | Codigo, design, documentacao local, configuracao de infraestrutura | Playtest humano do pacote Technical Hardening publicado, focando Bosque/menu/Arena e regressao do hardening antes de novas expansoes | Technical Hardening publicado em 2026-06-05 no release root `internal-alpha/v0-technical-hardening-20260605-8e54a1f`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://2fe9393e.draxos-mobile-internal-alpha.pages.dev`; publica Track 22 com migrations remotas `202606050001_arena_reward_profiles_v1.sql` e `202606050002_account_reset_request_hash_v1.sql`, redeploy de Edge Functions, auth compartilhado em endpoints mutaveis/lab/release, reset com `request_hash`, Arena rewards DB-side, `Modes Ops` fora do cliente e refatores extract-only de hotspots. `FullLocal`, `RemoteReadOnly`, export, Storage upload publico, Cloudflare Pages production branch `main`, manifest remoto e smoke Web no preview passaram; stable Portal/Web ficam Cloudflare Access protected. Android APK usa `debug_fallback`, aceito para playtest funcional, com release signing adiado para distribuicao Android mais ampla. Openworld Main Menu Sync (`internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`, evidence `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`) fica preservado como pacote de conteudo anterior, mantendo Bosque/menu; Bosque Mecanico Basico v2 (`internal-alpha/v0-bosque-v2-guidance-20260604-7c2d981`, evidence `https://ae049df9.draxos-mobile-internal-alpha.pages.dev`), First Access Runtime Fix `4608977`, Integrated Runtime Fix `ab5834c`, Integrated App/Arena/Bosque `99304ed`, Web Launch Resilience, Refugio Visual Cleanup, Openworld QoL regression fix, Foundation Hardening V2 (`FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`) e Hardening Platform V1 ficam preservados como baselines anteriores. Track 21 Arena Loop Unlock/Friction e Track 20 Season 1 Arena Calibration seguem preservados como contexto do modo Autobattler/Arena PVE; Remote Lab Runner segue preservado para Battle Lab/Progression Lab no Web export; iOS sem pedido explicito; mobile browser fora do escopo primario; secrets e service role nunca entram no cliente/export; publicacao remota exige `-ConfirmRemoteMutation`; mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`; novos dados devem usar `account_profiles/game_saves`; regras devem passar por registry/ruleset versionado; mutations economicas/social novas devem passar por RPC transacional v1 com `request_id`/`request_hash`; direct chat, ajudas, contribuicoes, moderacao, PVP, novas armas, novas spells, economia ampla, previsao de vitoria, contra-escolha por oponente, thresholds customizados, comportamento por inimigo e controles avancados de replay bloqueados ate decisao propria |
| Arquivo | Mobile Universe (conceito) | `Projetos/_conceitos/mobile-universe/` | Arquivo de design | `ARQUIVO_DESIGN` | Leitura e referencia de design apenas | - | Nao criar codigo, cenas, assets ou projeto Godot a partir daqui |
| Pausado | RPG Isometrico | `Projetos/rpg-isometrico/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, expandir gates ou selecionar Next Gate sem pedido explicito |
| Pausado | RPG Turnos | `Projetos/rpg-turnos/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, selecionar track/gate, regenerar `.tres` ou alterar escopo sem pedido explicito |

Nota DraxosMobile: `Technical Hardening` foi publicado como Internal Alpha em `internal-alpha/v0-technical-hardening-20260605-8e54a1f`, mantendo a URL principal como contrato player-facing e preservando Openworld Main Menu Sync como pacote de conteudo anterior.

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
