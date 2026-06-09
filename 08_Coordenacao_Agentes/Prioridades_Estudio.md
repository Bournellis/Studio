# Prioridades do Estudio

Este documento e a fonte de verdade de portfolio para agentes e para coordenacao do `D:\Estudio`.

## Foco Atual

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao (`BOSQUE_BOOTSTRAP_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-bosque-bootstrap-authority-v1-20260609-ba99e70`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://0123894f.draxos-mobile-internal-alpha.pages.dev`; publicado em Web/APK, APK/manifest `0.0.15-alpha.0`/version code `15`, minimum supported version code `13`, Bosque integrado nao renderiza mundo jogavel full-spawn antes do bootstrap canonico remoto/cache; Arena PVE Bonus Visual v1 preservado como pacote Arena anterior; Bosque Node Cooldown ACK v1 preservado como pacote Bosque anterior, seguido por Bosque Resume Exit Lifecycle v1, Bosque Feel & Spawn Authority v1, Bosque Persistence Rebase v1, Bosque Session Lifecycle & Durable Structures Hotfix v1, Bosque World Hub Domain Separation v1, Bosque Fogueira Potion Crafting v1, Bosque Durable Bau Mochila v1 e Arena PVE Menu Flow Simplification v1): `Projetos/draxos-mobile/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/` (preservado como referencia - nao e o projeto ativo)
- Projetos pausados: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## Portfolio

| Prioridade | Projeto | Caminho | Fase | Status | Trabalho permitido | Proximo passo | Restricao operacional |
|---|---|---|---|---|---|---|---|
| P0 | Draxos Roguelike Cardgame | `Projetos/draxos-roguelike-cardgame/` | Implementacao | `P0_IMPLEMENTACAO` | Codigo, validacao, playtest, documentacao local | Track 02 completa segue pronta para playtest, mas o proximo trabalho recomendado e expansao de conteudo via Design Lab proposal packs antes de promocao manual: AutoRun Gate Pack V1, Scenario Fixtures V1, Gameplay Lab V1, Lab Diff Reporter V1, Card Impact V1-V5 e Design Lab V1 ficam disponiveis para regressao/tuning explicitos; depois de promover candidatos, proteger com Card Impact V4.2/V5 e Run Lab smoke/quick antes de full-run feel playtests | Pode receber trabalho de implementacao por padrao |
| P2 | DraxosMobile | `Projetos/draxos-mobile/` | Implementacao - `BOSQUE_BOOTSTRAP_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA` | `P2_IMPLEMENTACAO` | Codigo, design, documentacao local, configuracao de infraestrutura | Playtest humano do pacote Bosque Bootstrap Authority v1; validar `Voltar -> entrar` sem flash full-spawn, cooldown/persistencia dos nodes, segunda coleta finalizando ACK, saida/reentrada e regressao rapida de Arena PVE Bonus Visual | Bosque Bootstrap Authority v1 publicado em 2026-06-09 no release root `internal-alpha/v0-bosque-bootstrap-authority-v1-20260609-ba99e70`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://0123894f.draxos-mobile-internal-alpha.pages.dev`; APK/manifest `0.0.15-alpha.0`/version code `15`, minimum supported version code `13`, `release` redeployada, remote manifest/artifact/release/Web launch smokes passaram. Arena PVE Bonus Visual v1 segue preservado como pacote Arena anterior; Bosque Node Cooldown ACK v1 segue preservado como pacote Bosque anterior; Bosque Resume Exit Lifecycle v1, Bosque Feel & Spawn Authority v1 e Bosque Persistence Rebase v1 seguem preservados com migrations remotas `202606080001_openworld_bosque_persistence_rebase_v1.sql` e `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`. Stable Portal/Web ficam Cloudflare Access protected. Android APK usa `debug_fallback`, aceito para playtest funcional; release signing adiado. iOS sem pedido explicito; mobile browser fora do escopo primario; secrets e service role nunca entram no cliente/export; novas mutacoes economicas/social devem seguir RPC transacional v1; tuning amplo, PVP, novas armas/spells/economia e visual final bloqueados ate decisao propria |
| Arquivo | Mobile Universe (conceito) | `Projetos/_conceitos/mobile-universe/` | Arquivo de design | `ARQUIVO_DESIGN` | Leitura e referencia de design apenas | - | Nao criar codigo, cenas, assets ou projeto Godot a partir daqui |
| Pausado | RPG Isometrico | `Projetos/rpg-isometrico/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, expandir gates ou selecionar Next Gate sem pedido explicito |
| Pausado | RPG Turnos | `Projetos/rpg-turnos/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, selecionar track/gate, regenerar `.tres` ou alterar escopo sem pedido explicito |

Nota Draxos Roguelike Cardgame: `Design Lab V1 Foundation` foi concluido em 2026-06-06. O sample `design_lab_sample_v1` passou gate em `user://design_lab/design_lab_sample_v1_gate` com 36 candidatos, 3 recomendacoes, 0 mecanicas bloqueadas e sem alterar `data/definitions/slice_catalog.json`. O lab agora e a ponte recomendada entre ideia de carta/mecanica/encontro e numeros jogaveis. Regressao preservada: `validate.gd` 220/220, Card Impact V5 official before gate PASS, Run Lab smoke/quick gates PASS. A baseline anterior `Enemy Card Redesign Batch 02 Using V5 Terra` segue aceita com 30/30 assinaturas inimigas e 21/21 Card Flow Expectations.

Nota DraxosMobile: `Bosque Bootstrap Authority v1` foi publicado como Internal Alpha em `internal-alpha/v0-bosque-bootstrap-authority-v1-20260609-ba99e70`, mantendo a URL principal como contrato player-facing. O pacote corrige o flash de Bosque full-spawn na reentrada: o viewport jogavel integrado fica oculto ate o bootstrap canonico remoto/cache concluir. Arena PVE Bonus Visual v1 fica preservado como pacote Arena anterior e Bosque Node Cooldown ACK v1 segue como baseline anterior de Bosque. Track 13 release safety e Track 14 agent ops seguem como guardrails operacionais.

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
