# DraxosMobile - Architecture

- Ultima atualizacao: `2026-05-26`

---

## Stack

| Camada | Tecnologia |
|---|---|
| Client | Godot `4.6.2-stable` (GDScript) |
| Backend | Supabase Auth, Postgres, Edge Functions, Realtime |
| Comunicacao | REST via HTTPRequest do Godot |
| Autenticacao | JWT Supabase, Auth anonimo para guest/local, email/senha para Internal Alpha v0, Google OAuth2 futuro |
| Testes client | GUT `9.6.0` |
| Testes server | Deno/TypeScript tests para Edge Functions |

---

## Estrategia De Backend E Plano De Saida

Decisao para Internal Alpha v0:

- usar Supabase remoto Free agora;
- manter Postgres como centro autoritativo de dados;
- manter Edge Functions como camada HTTP server-authoritative;
- configurar ambiente remoto no cliente por `BackendConfig`, env vars e project settings publicos;
- bloquear chaves com aparencia de service role/secret no cliente Godot;
- preservar um plano de saida para Backend Proprio + Postgres.

Justificativa:

- DraxosMobile e PvE/PVP assincrono, nao multiplayer realtime com jogadores na mesma partida.
- O jogo precisa mais de transacoes, ledger, auditoria, recursos, saves, base, loja e ranking do que de salas, lobbies ou tick de partida.
- Social existe, mas e assincrono ou semi-assincrono: direct, chat de guilda, ajuda, guilda, contribuicoes e possivel transferencia de recursos.
- Postgres combina melhor com economia, historico, idempotencia e consistencia forte.

Alternativas avaliadas:

| Opcao | Papel |
|---|---|
| Supabase | Escolha atual para alpha: acelera Auth, Postgres, Edge Functions, Storage e migrations locais/remotas. |
| Backend Proprio + Postgres | Alvo de longo prazo se o jogo crescer: API propria, Postgres gerenciado, jobs, observabilidade, backups e painel admin. |
| Nakama | Alternativa futura se o produto passar a depender fortemente de realtime, matchmaking, presenca, lobbies, torneios ou social competitivo pronto. Nao e o alvo principal atual. |

Regras anti-lock-in:

- O Godot deve falar com endpoints logicos do projeto, nao com detalhes internos de tabelas ou vendor.
- `online/supabase_client.gd` deve receber configuracao de backend sem conhecer secrets.
- Contratos HTTP devem permanecer estaveis: `account`, `battle`, `base`, `social`, `competition`, `monetization`, `telemetry`.
- Edge Functions devem concentrar adaptadores de plataforma, chamando logica de dominio portavel sempre que possivel.
- Regras economicas devem gerar ledger exportavel.
- IDs internos de conta/save/player devem pertencer ao jogo; `auth.users.id` ou equivalente do fornecedor e detalhe de auth.
- Schema SQL, migrations e seeds devem ficar versionados.
- Storage de builds/manifests pode mudar de fornecedor sem alterar gameplay.

Plano de saida para Backend Proprio + Postgres:

1. Congelar contratos HTTP atuais.
2. Exportar schema/dados do Postgres.
3. Criar API propria com os mesmos endpoints logicos.
4. Migrar a logica das Edge Functions para modulos de dominio no backend proprio.
5. Manter cliente Godot apontando para uma `base_url` diferente.
6. Migrar Auth com fluxo controlado de conta/email, preservando `account_id` interno do jogo.
7. Validar ledger, ranking, saves e historico de batalha antes de desligar Supabase.

Nakama deve ser reavaliado somente se pelo menos uma destas premissas mudar:

- jogadores precisam ficar juntos em partidas conectadas;
- matchmaking/lobbies se tornam centrais;
- presenca online vira sistema principal;
- chat/guilda/leaderboards prontos passam a valer mais do que controle total de economia e dados relacionais;
- a equipe prefere operar um game backend pronto em vez de manter API propria.

---

## Status Tecnico Atual

- `T00-P01` completo: projeto Godot, boot scene, `ProjectInfo`, validate e GUT.
- `T00-P02A` completo: migration MVP, tabelas iniciais, RLS base, seed tecnico e healthcheck standalone.
- `T00-P02B` completo: layout oficial `supabase/`, Docker Desktop, Deno via `npx`, `supabase db reset` e healthcheck pelo gateway local.
- `T00-P03` completo: autoloads `UiTokens`, `AssetIds`, `ContentLibrary`, `.gutconfig.json` e validate integrado.
- `T00-P04` completo: fixtures `MVP_ONLY`, JSONs de conteudo e catalogo gerado.
- `T00-P05` completo: conta guest MVP, convite `ALPHA-TEST`, `account/guest`, `account/state`, RPC idempotente e bloqueio de escrita direta do cliente.
- `T00-P06` completo: cliente Godot com `SessionStore`, `SupabaseClient`, Auth anonimo, `account/guest`, `account/state`, cache local nao autoritativo e erro offline controlado.
- `T00-P07` completo: `battle/request`, `battle/latest`, RPC `request_mvp_battle`, log `battle_log_v1`, recompensa `MVP_ONLY` e idempotencia server-side.
- `T00-P08` completo: replay placeholder no Godot para `battle_log_v1`, timeline ordenada por `t`/`seq`, skip e tolerancia a eventos desconhecidos.
- `T00-P10` completo e rework 2026-05-25 aplicado: `FIRST_SLICE_SIM` server-authoritative com Instrumentos Rituais, Doutrinas, Familiares, DoTs, status, resistencias, summons, anti-stall, bots de variacao, smoke runtime Supabase e replay rico no cliente.
- `T00-P11` completo: Base Manager v0 server-authoritative com `base/state`, `base/collect`, `base/upgrade`, estruturas permanentes, fila de construcao, coleta offline, ledger e idempotencia.
- `T00-P12` completo: Social/Competicao v0 server-authoritative com `social/state`, guilda alpha, chat de guilda por polling, matchmaking preview com fallback de bot e ranking de season sem bots.
- `T00-P13` completo: Monetizacao v0 server-authoritative com Battle Pass, Diamante alpha, recompensas diarias/semanais, claims free/premium, ledger, idempotencia e export smoke Android/PC/Web.
- `Track 01` completo: hardening do alpha PC local com fluxo de primeira sessao mais claro, estados ocupados/erros offline/pre-condicoes visiveis, reset seguro de sessao local, telemetria client nao autoritativa e smoke do loop alpha.
- `Track 03` com design lock completo, estrategia backend definida, T03-P02 repo-side preparado e T03-P03B completo: Supabase remoto Free para alpha, `BackendConfig` no Godot, env vars seguras, `.env` reais ignorados, smoke remoto minimo, `players.save_type` local, header `x-draxos-save-type` nos endpoints alpha, dois saves server-backed no Supabase local e Backend Proprio + Postgres como plano de saida preferido. Nakama fica apenas como alternativa futura se realtime/social competitivo virar pilar.

---

## Contratos

Antes de criar codigo ou migrations, consulte:

- `contracts/api-endpoints.md`
- `contracts/battle-event-log.md`
- `contracts/database-schema.md`
- `contracts/content-definitions.md`
- `reuse-map.md`
- `internal-alpha-v0.md`
- `internal-alpha-v0-design-lock.md`

`supabase/` e a fonte de execucao local da Supabase CLI. `server/schema/` e `server/functions/` permanecem como espelho organizado do backend durante o alpha local.

Deno e Supabase CLI sao validados via `npx -y deno` e `npx -y supabase` nesta maquina.

Runtime local validado:

- Studio: `http://127.0.0.1:54323`
- Project URL: `http://127.0.0.1:54321`
- Database: `postgresql://postgres:postgres@127.0.0.1:54322/postgres`
- Edge Functions: `http://127.0.0.1:54321/functions/v1`

---

## Fundacao Client Godot

Autoloads atuais:

| Autoload | Arquivo | Responsabilidade |
|---|---|---|
| `UiTokens` | `core/ui_tokens.gd` | Cores, estilos e tokens semanticos de UI |
| `AssetIds` | `core/asset_ids.gd` | Manifesto de ids visuais e fallback enquanto assets nao existem |
| `ContentLibrary` | `data/content_library.gd` | Gerar/carregar catalogo de conteudo e expor consultas por collection/id |
| `SessionStore` | `online/session_store.gd` | Token/cache local nao autoritativo, validacao de expiracao, snapshot de estado recebido do servidor e save ativo `normal`/`progression_lab` |
| `SupabaseClient` | `online/supabase_client.gd` | HTTPRequest para Auth e Edge Functions locais/remotas, enviando `x-draxos-save-type` |

Classes utilitarias:

| Classe | Arquivo | Responsabilidade |
|---|---|---|
| `BackendConfig` | `online/backend_config.gd` | Resolver ambiente `local`/`internal_alpha_v0`, URL, publishable key, env vars e validacao contra secrets no cliente |
| `BattleLogPresenter` | `ui/battle_log_presenter.gd` | Ordenar e formatar eventos `battle_log_v1` sem calcular gameplay |
| `BattleVisualMockup` | `ui/battle_visual_mockup.gd` | Apresentar `battle_log_v1` como HUD visual reutilizavel para Batalha e Battle Lab, usando placeholders nativos e asset hooks futuros sem calcular gameplay |
| `BattleStage2D` | `ui/battle_stage_2d.gd` | Palco procedural lateral com personagens parados, slots front/middle/back, efeitos temporarios e tooltips |
| `BattleActorMarker` | `ui/battle_actor_marker.gd` | Silhueta procedural de combatente, barras e pulse de feedback |
| `BattleSymbolIcon` | `ui/battle_symbol_icon.gd` | Icone procedural para evento, status, cooldown, Familiar e summon |

Regras:

- Autoloads nao possuem autoridade economica ou de batalha.
- `ContentLibrary` pode gerar catalogo local para UI, fixtures e testes.
- `SessionStore` nao possui metodos para mutar recursos/progressao; apenas aplica snapshots recebidos do servidor.

---

## Pipeline De Conteudo

```text
data/definitions/*.json
  -> tools/content_generator.gd
  -> data/generated/draxos_mobile_catalog.tres
  -> ContentLibrary
  -> UI/tests/client
```

Arquivos esperados:

- `spells.json`
- `pets.json`
- `passives.json`
- `weapons.json`
- `base_structures.json`
- `bot_builds.json`
- `power_bands.json`
- `battle_fixtures.json`
- `rewards.json`

Fixtures `MVP_ONLY` provam arquitetura, nao balanceamento final.

---

## Politica De Reuso

Referencia viva: `reuse-map.md`.

- Reutilizar diretamente: configuracao GUT, padrao de validate, centralizacao de tokens e asset ids.
- Adaptar: content generation multi-arquivo, ContentLibrary e padroes de session/cache local.
- Vetar: BattleEngines, card/deck/mana/run map, campanha action, saves autoritativos e regras de gameplay de outros projetos.

---

## Plataformas E Exports

| Plataforma | Export Godot | Notas |
|---|---|---|
| Android | Android APK | App nativo, unico canal mobile |
| PC Windows/Linux | Executavel nativo | `.zip` |
| PC Browser | HTML5/WebAssembly | Godot web export |
| Mobile browser | - | Fora do escopo |
| iOS | - | Futuro |

Input adaptado por plataforma: `InputEventScreenTouch` para Android e `InputEventMouseButton` para PC/browser.

Presets alpha em `export_presets.cfg`:

- `Android Alpha`
- `PC Windows Alpha`
- `PC Browser Alpha`

`tools/smoke_exports.gd` valida a existencia dos tres presets, plataformas,
paths de saida e exclusao de ferramentas dev (`dev/**`, `tools/battle_lab/**`,
`docs/battle-lab/**`, `.battle_lab_scratch/**`) sem exigir templates de export
instalados.

Track 03 adiciona manifest remoto para updates internos. O manifest deve viver em Supabase Storage ou endpoint equivalente sem secrets, com:

- `schema_version`;
- canal (`internal_alpha`);
- `latest_version`;
- `minimum_supported_version`;
- links de artefatos Android/PC/Web;
- `sha256` para artefatos baixaveis quando aplicavel;
- release notes curtas.

O cliente pode continuar rodando se houver update recomendado. Se a versao atual ficar abaixo de `minimum_supported_version`, o cliente deve bloquear acoes online e orientar update.

---

## Arquitetura De Conta

Fluxo completo do primeiro slice:

```text
Boot
  -> Tem token salvo?
       -> Sim: validar token e entrar
       -> Nao: tela de entrada
            -> Jogar como guest com codigo de convite
            -> Login email/senha
            -> Google Sign-In
```

Guest pode migrar para conta registrada sem perder progresso.

MVP tecnico implementa apenas guest com codigo de convite.

Internal Alpha v0 usa email/senha como caminho principal. Email confirmation fica desligado no projeto alpha para reduzir atrito entre dois testadores, mas o servidor ainda precisa validar convite/flag alpha antes de criar ou liberar save.

### Modelo De Saves Da Internal Alpha v0

Cada conta alpha possui dois saves logicos:

- `normal`: progresso real do teste fechado.
- `progression_lab`: estado custom criado pelo Progression Lab.

Regras:

- Reset separado por save.
- UI sempre mostra o save ativo.
- Endpoints autoritativos devem resolver o save ativo no servidor; o cliente nao envia deltas finais.
- Ranking, social e loja do save normal nao podem ser contaminados pelo `progression_lab`.
- Implementacao inicial pode adaptar o schema atual de `players` para `save_type`, mas a direcao de longo prazo e separar conta de jogo e saves para permitir novos modos/fases sem acoplar tudo a uma linha de player.

Implementado localmente em `T03-P03B`:

- `players.save_type` aceita `normal` e `progression_lab`.
- A unicidade de jogador passa a ser `auth_user_id + save_type`.
- Edge Functions resolvem o player pelo header `x-draxos-save-type`; sem header, usam `normal`.
- Ranking retorna exclusao explicita para `progression_lab`.
- Social esta isolado por save nesta etapa local; a evolucao para social de conta inteira com marcador `lab` fica para o refinamento de Social, se necessario.

Modelo escolhido em `DMOB-D042`:

1. Cliente cria uma sessao via Supabase Auth anonimo nativo.
2. Cliente chama `POST /account/guest` com `Authorization: Bearer <anonymous_jwt>`, `invite_code` e `request_id`.
3. Edge Function valida convite e cria `players`, `resources` e `builds` usando service role.
4. Progresso guest fica vinculado a `players.auth_user_id`.
5. Conversao futura para conta registrada preserva `players.id`.

Implementado em `T00-P05`:

- `POST /account/guest`: valida JWT anonimo, `invite_code` e `request_id`, chama RPC `create_guest_account` e retorna player/resources/build inicial.
- `GET /account/state`: recupera player/resources/build e `last_battle_id` para a sessao autenticada.
- `create_guest_account`: RPC `SECURITY DEFINER` com execute restrito a `service_role`, seed `ALPHA-TEST` e idempotencia por `idempotency_keys`.

Implementado em `T00-P06`:

- `SupabaseClient`: chama `POST /auth/v1/signup`, `POST /functions/v1/account/guest` e `GET /functions/v1/account/state`.
- `SessionStore`: persiste token/cache local em `user://session_cache.json`, valida expiracao e guarda estado apenas como snapshot.
- Boot scene: botao `Entrar como guest` executa o fluxo real e mostra erro controlado quando rede ou Supabase local estao indisponiveis.

---

## Arquitetura De Batalha

O cliente Godot nunca simula batalha.

```text
Cliente
  -> POST /battle/request
Servidor
  -> seleciona oponente
  -> simula batalha completa
  -> grava resultado e recompensa
  -> retorna battle_log_v1
Cliente
  -> anima log recebido
```

Desconexao durante batalha nao altera resultado, porque o resultado ja foi gravado antes do cliente animar.

Contrato do log: `contracts/battle-event-log.md`.

MVP tecnico implementado em `T00-P07`:

- `POST /battle/request`: cria batalha contra `mvp_training_bot`, grava resultado e aplica recompensa fixture.
- `GET /battle/latest`: retorna o ultimo log gravado, sem reaplicar recompensa.
- `request_mvp_battle`: RPC transacional com `idempotency_keys`, `battles` e `resource_transactions`.
- Recompensa fixture atual: `xp +5`, `ossos +1`, aplicada uma unica vez por `request_id`.

MVP client implementado em `T00-P08`:

- `Solicitar batalha`: envia intencao para `battle/request` e recebe `battle_log_v1`.
- `Ver resultado`: busca `battle/latest` ou pula o replay atual.
- Replay rico T00-P10: lista eventos ordenados por `t`/`seq`; DoTs, status, barreiras, resistencias, summons, Familiares, cooldowns, cura e anti-stall possuem linhas dedicadas; eventos desconhecidos continuam virando fallback.
- Battle Visual Mockup 2026-05-26: a tela Batalha e o Battle Lab usam o mesmo controle visual para personagens placeholder, ataque basico, spells, buffs, dano, efeitos, icons, summons, Familiar, HP/Mana/Barreira, resultado e timeline a partir do mesmo log.
- Battle Stage 2D 2026-05-26: o mockup agora inclui palco procedural estilo luta lateral, com player na esquerda, oponente na direita, objetos em slots front/middle/back, numeros flutuantes, projeteis simples, flashes e tooltips sem assets importados.
- Cliente nao recalcula dano, HP, vencedor, XP, Ossos ou recompensa.

---

## Dados Autoritativos No Servidor

| Dado | Onde vive |
|---|---|
| Recursos | Postgres, mutado so por Edge Functions |
| Level, XP e build | Postgres |
| Resultado de batalhas e ranking | Postgres, calculado no servidor |
| Dados de guilda e social | Postgres |
| Battle Pass, claims e compras alpha | Postgres |
| Pool de oponentes | Postgres |
| Preferencias de UI e cache visual | Local, sem impacto em progressao |
| Producao da base | Calculada no servidor na reconexao |

RLS deve impedir acesso indevido. Mutacoes economicas devem usar idempotencia e ledger.

Regra resolvida em `DMOB-D043`: cliente nao recebe policies de insert/update/delete para estado autoritativo no MVP. Escritas em `players`, `resources`, `builds`, `battles`, `idempotency_keys` e `resource_transactions` passam por Edge Functions com service role.

---

## Matchmaking E Ranking

MVP tecnico usa bot fixture `mvp_training_bot`.

Primeiro slice completo:

- Calcula poder do solicitante no servidor.
- Filtra pool por faixa de poder e diferenca percentual.
- Expande tolerancia por tempo de busca: 10% nos primeiros 5s, 20% ate 15s e 35% depois disso.
- Sorteia oponente real ou bot simulado quando nao houver jogador compativel.
- Bots simulados nao aparecem em ranking.
- Ranking usa pontos de arena por season e snapshot no encerramento.

Formula alpha de poder apos balance v1: `(Level x 42) + (ArmaLevel x 30) + (SpellLevelsTotal x 35) + (PetLevel x 30, se Familiar equipado) + (PassiveLevel x 22, se Doutrina equipada) + (WeaponQualityTier x 30)`.

Formula inicial de ranking:

- Vitoria base: `+20` pontos.
- Derrota base: `-10` pontos.
- Ajuste por diferenca de poder, limitado pela tolerancia maxima de matchmaking.
- Vitoria contra mais forte pode chegar a `+30`; vitoria contra mais fraco pode cair ate `+12`.
- Derrota contra mais forte pode cair ate `-5`; derrota contra mais fraco pode chegar a `-15`.
- Bots ficam fora do ranking no alpha.
- Pontos nao ficam abaixo de 0.
- Encerramento de season gera snapshot de ranking.

## Social, Guilda E Chat

Social do primeiro slice usa polling simples, Postgres + RLS e Edge Functions para mutacoes.

Regras de guilda:

- Guilda desbloqueia no level 10.
- Guilda tem level 1-10 e capacidade de 10 a 50 membros.
- Jogador participa de 1 guilda por vez.
- Sair de guilda aplica cooldown de 24h.
- Contribuicoes e ajudas sao server-authoritative, idempotentes e registradas em ledger quando alteram recurso ou progresso.

Regras de ajuda:

- Jogador pode enviar ate 30 ajudas por dia.
- Cada construcao pessoal pode receber ate 10 ajudas.
- Cada ajuda reduz 1,5% do tempo restante da construcao, max 15%.
- Ajuda e unica por `helper_id + construction_job_id`.

Politica de chat v0:

- Canais: guilda e direct entre amigos.
- Chat global interno fica fora do primeiro slice.
- Polling simples no alpha; Realtime fica para evolucao futura.
- Retencao padrao: 30 dias para mensagens de guilda e direct.
- Mensagem apagada usa soft delete: conteudo deixa de aparecer para usuarios, mas metadados minimos ficam para auditoria.
- Usuario pode bloquear outro usuario; bloqueio oculta direct e impede novas mensagens diretas.
- Denuncia cria registro de moderacao para revisao manual no alpha.
- Filtro automatico v0: limite de tamanho, rate limit por usuario/canal e bloqueio de mensagens vazias ou repetidas.
- Dados de chat nao concedem progresso economico direto.

## Monetizacao E Recompensas Alpha

Monetizacao do alpha e funcional para validar fluxo e contrato, mas nao usa gateway real de pagamento.

Sistemas implementados em `T00-P13`:

- Battle Pass ativo `bp_s1_01` com trilhas free e premium.
- Progresso em `battle_pass_progress`, criado sob demanda.
- Rewards diarias e semanais no Edge Function `monetization`.
- Claims em `reward_claims`, unicos por periodo.
- Compras alpha em `alpha_purchases`, idempotentes por `request_id`.
- Produtos alpha: premium pass, 500 Diamantes e pacote pequeno de Energia.

Regras:

- Cliente envia apenas intencao (`reward_id` ou `product_id`), nunca delta final.
- Toda mutacao economica passa por `resource_transactions`.
- Premium required e periodo de claim sao validados no servidor.
- Repetir o mesmo `request_id` retorna o mesmo payload; repetir reward no mesmo periodo com novo request nao duplica recurso.

## Telemetria E Simulacoes

O primeiro slice deve coletar telemetria minima de combate e matchmaking para balanceamento.

Fontes:

- `server`: batalha real, matchmaking, recompensa e snapshot de build.
- `client`: sessao, entrada/saida de telas, erros controlados e replay assistido/pulado.
- `simulation_job`: batalhas bot-vs-bot para medir duracao, win rate por archetype, escalada de poder e frequencia de anti-stall.

Eventos minimos:

- `battle_requested`
- `match_selected`
- `battle_simulated`
- `reward_applied`
- `build_snapshot`
- `bot_balance_simulated`
- `screen_opened`
- `action_start`
- `action_success`
- `action_failure`
- `replay_start`
- `replay_skip`
- `replay_end`
- `network_failure`

Regras:

- Bot-vs-bot nao concede recompensa nem altera ranking.
- Dados de combate para balanceamento ficam no servidor; o cliente recebe apenas o log visual necessario.
- Payloads de telemetria devem usar `schema_version` para permitir evolucao durante o alpha.
- `POST /telemetry/client-event` aceita apenas `telemetry_client_v1`, grava `source = client`, usa `session_id` local persistido e nao altera estado autoritativo.

---

## Politica Offline

| Situacao | Comportamento |
|---|---|
| Sem internet | Estado cacheado exibido, batalha e chat desabilitados |
| Producao da base offline | Servidor calcula delta na reconexao |
| Desconexao durante batalha | Cliente busca log gravado |
| Coleta offline | Servidor acumula respeitando armazenamento |

---

## Anti-Cheat

| Vetor | Mitigacao |
|---|---|
| Forjar resultado | Batalha 100% servidor |
| Injetar recursos | Edge Functions validam toda mutacao |
| Escolher oponente facil | Servidor controla matchmaking |
| Farm abusivo | Rate limiting no endpoint de batalha |
| Acesso a dados alheios | RLS do Supabase |
| Duplicar recompensa | Idempotencia por `request_id` e ledger |
| Duplicar reward diario/semanal | `reward_claims` unico por periodo |
| Forjar compra alpha | Produto validado no servidor e registrado em `alpha_purchases` |
| Engenharia reversa do oponente | Log retorna eventos animaveis, nao build completa |

---

## Estrutura De Pastas - Codigo

```text
draxos-mobile/
|-- supabase/
|   |-- config.toml
|   |-- migrations/
|   `-- functions/
|       |-- account/
|       |-- base/
|       |-- battle/
|       |-- competition/
|       |-- healthcheck/
|       |-- monetization/
|       |-- social/
|       |-- telemetry/
|       `-- _shared/
|-- server/
|   |-- schema/
|   `-- functions/
|-- core/
|-- data/
|   |-- definitions/
|   |-- generated/
|   `-- resources/
|-- modes/
|-- ui/
|-- social/
|-- tools/
`-- tests/
```

---

## Pendencias Arquiteturais

Pendencias vivas:

- Nenhuma pendencia arquitetural bloqueante para o MVP tecnico atual.

Pendencias operacionais resolvidas em 2026-05-19:

- Layout Supabase CLI (`DMOB-D040`): `supabase/`.
- Ambiente local (`DMOB-D041`): Docker Desktop + Supabase CLI via `npx` + Deno via `npx`.
- Modelo de conta guest (`DMOB-D042`): Supabase Auth anonimo nativo + Edge Function com convite.
- Escrita SQL service-role-only (`DMOB-D043`): sem write policies client-side para estado autoritativo no MVP.
