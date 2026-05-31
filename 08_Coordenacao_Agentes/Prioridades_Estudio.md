# Prioridades do Estudio

Este documento e a fonte de verdade de portfolio para agentes e para coordenacao do `D:\Estudio`.

## Foco Atual

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao (`PVE_ARENA_INITIAL_PUBLISHED_INTERNAL_ALPHA`, Track 18 publicado em `internal-alpha/v0-pve-arena-entry-20260531-6cbc853`, preservando Track 13 release safety e Track 14 agent ops): `Projetos/draxos-mobile/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/` (preservado como referencia - nao e o projeto ativo)
- Projetos pausados: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## Portfolio

| Prioridade | Projeto | Caminho | Fase | Status | Trabalho permitido | Proximo passo | Restricao operacional |
|---|---|---|---|---|---|---|---|
| P0 | Draxos Roguelike Cardgame | `Projetos/draxos-roguelike-cardgame/` | Implementacao | `P0_IMPLEMENTACAO` | Codigo, validacao, playtest, documentacao local | Playtest de usuario da Track 02 completa | Pode receber trabalho de implementacao por padrao |
| P2 | DraxosMobile | `Projetos/draxos-mobile/` | Implementacao - `PVE_ARENA_INITIAL_PUBLISHED_INTERNAL_ALPHA` | `P2_IMPLEMENTACAO` | Codigo, design, documentacao local, configuracao de infraestrutura | Fazer playtest humano da Arena PVE tutorial/3 duelos no preview/APK publicado | Track 18 PVE Arena Initial e a publicacao Internal Alpha atual (`internal-alpha/v0-pve-arena-entry-20260531-6cbc853`, preview `https://c185369d.draxos-mobile-internal-alpha.pages.dev/web/index.html`); branch viva `codex/draxos-mobile/pve-arena-integration`; direcao viva em `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`; PVP entra depois como modo competitivo com bots apenas como fallback/simulacao; iOS sem pedido explicito; mobile browser fora do escopo primario; secrets e service role nunca entram no cliente/export; publicacao remota exige `-ConfirmRemoteMutation`; mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`; novos dados devem usar `account_profiles/game_saves`; regras devem passar por `foundation_ruleset_v0`/registry; mutations economicas/social novas devem passar por RPC transacional v1 com `request_id`/`request_hash`; Battle Lab/Progression Lab precisam cobrir Arena PVE antes de tuning numerico; direct chat, ajudas, contribuicoes, moderacao, PVP, novas armas, novas spells, economia ampla, previsao de vitoria, contra-escolha por oponente, thresholds customizados, comportamento por inimigo e controles avancados de replay bloqueados ate decisao propria |
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
