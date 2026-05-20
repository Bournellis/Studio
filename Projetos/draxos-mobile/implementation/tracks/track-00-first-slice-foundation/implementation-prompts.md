# Track 00 - Implementation Prompts

- Ultima atualizacao: `2026-05-20`
- Uso: um prompt por execucao de agente
- Sequencia oficial: `T00-P00` a `T00-P13`, reorganizada apos o bootstrap inicial

## Regras Para Todos Os Prompts

Os caminhos listados em `Arquivos permitidos` sao relativos a raiz do projeto `Projetos/draxos-mobile/`, salvo quando comecarem com `../../../`.

- Voce nao esta sozinho no repositorio; nao reverta alteracoes de outros agentes.
- Leia `../../../AGENTS.md`, `../../current-status.md`, `current-status.md`, `scope.md`, `mvp-technical-definition.md`, `../../../docs/design-pending.md`, `../../../docs/reuse-map.md` e contratos relevantes antes de editar.
- Se faltar decisao de design, registre em `../../../docs/design-pending.md` e pare antes de inventar regra.
- Toda mudanca de contrato deve atualizar `../../../docs/contracts/`.
- Toda etapa concluida deve atualizar `../../current-status.md` e `current-status.md`.
- Nunca copiar BattleEngine, regras de deck/mana/run map, campanha action ou save autoritativo local de outros projetos.
- Cliente Godot envia intencoes e anima logs; resultado, recursos e progressao sao autoritativos no servidor.

## T00-P00 - Preparacao Documental

Status: completo.

Objetivo: preparar documentos de escopo, contratos, pendencias e prompts sem iniciar implementacao.

Arquivos permitidos: `AGENTS.md`, `README.md`, `docs/**`, `implementation/**`, `../../../08_Coordenacao_Agentes/**`, `../../../Projetos/README.md`.

Validacao: links relativos resolvem e status aponta para a Track 00.

## T00-P01 - Inicializacao Godot

Status: completo.

Objetivo: criar projeto Godot 4.6.2 minimo.

Saida esperada: `project.godot`, boot scene minima, `ProjectInfo`, `tools/validate.gd`, GUT e testes iniciais.

Validacao: Godot headless abre o projeto e `tools/validate.gd` passa.

## T00-P02A - Supabase Base Standalone

Status: completo.

Objetivo: criar base Supabase local-first sem depender ainda do runtime CLI.

Saida esperada: migration MVP, healthcheck Edge Function, README de setup e env exemplo sem secrets.

Validacao: `npx -y deno task check`, `npx -y deno task lint` e healthcheck standalone passam.

## T00-P02B - Supabase Runtime Local

Status: completo.

Objetivo: resolver ambiente real Supabase.

Arquivos permitidos: `server/**`, `docs/architecture.md`, `docs/contracts/**`, `docs/design-pending.md`, `implementation/**`, coordenacao do estudio quando o status mudar.

Saida esperada: layout oficial compativel com Supabase CLI, docs de Docker/Supabase CLI/Deno via `npx` e validacao de migrations/functions no runtime.

Validacao: `supabase db reset` e `supabase functions serve` passam localmente quando Docker/Supabase CLI estiverem disponiveis.

## T00-P03 - Fundacao Reutilizavel Do Cliente

Status: completo.

Objetivo: criar infraestrutura client reutilizavel sem importar gameplay de outros projetos.

Saida esperada: `.gutconfig.json`, autoloads `UiTokens`, `AssetIds`, `ContentLibrary`, `tools/content_generator.gd`, `data/resources/draxos_mobile_catalog.gd`, validacao integrada.

Validacao: `tools/validate.gd` gera catalogo, valida recursos/autoloads e roda GUT sem warnings.

## T00-P04 - Fixtures MVP E Catalogo Gerado

Status: completo.

Objetivo: materializar fixtures tecnicas `MVP_ONLY`.

Saida esperada: JSONs em `data/definitions/`, `mvp_training_battle`, `mvp_training_bot`, `mvp_training_reward` e `data/generated/draxos_mobile_catalog.tres`.

Validacao: GUT cobre autoloads, tokens, asset ids, colecoes esperadas, fixture MVP e validacao do catalogo.

## T00-P05 - Conta Guest MVP

Status: completo.

Objetivo: implementar convite e conta guest MVP.

Arquivos permitidos: `server/functions/account/**`, `server/schema/**`, `supabase/functions/account/**`, `supabase/migrations/**`, `docs/contracts/**`, `docs/design-pending.md`, `implementation/**`.

Saida esperada: Edge Function de conta guest, estado inicial de player/resources/build fixture, `account/state` e idempotencia por `request_id`.

Validacao: convite valido cria conta; convite invalido falha; estado inicial e recuperado via `account/state`; repetir `request_id` retorna o mesmo player; nenhuma policy libera escrita autoritativa direta do cliente.

## T00-P06 - Cliente Account/Session Shell

Status: completo.

Objetivo: fechar a camada de sessao do cliente.

Saida esperada: HTTP client via HTTPRequest, Auth anonimo local, chamada a `account/guest`, chamada a `account/state`, `SessionStore`, validacao de token, estado offline controlado e tela minima de conta.

Validacao: rede indisponivel mostra erro controlado; cache local nao altera recurso/progressao.

## T00-P07 - Battle Request MVP

Status: completo.

Objetivo: implementar batalha fixture server-authoritative.

Saida esperada: `battle/request` com seed deterministica, bot `mvp_training_bot`, log `battle_log_v1`, resultado gravado e recompensa `MVP_ONLY` idempotente.

Validacao: mesmo seed gera mesmo log; cliente nao envia resultado; repetir `request_id` nao duplica recompensa.

## T00-P08 - Battle Replay Client MVP

Status: completo.

Objetivo: exibir o log recebido sem calcular gameplay.

Saida esperada: tela de resultado/timeline placeholder, replay simples, skip e tratamento de eventos desconhecidos por versao.

Validacao: resultado exibido bate com servidor e cliente nao altera recursos.

## T00-P09 - Gate De Design Do Primeiro Slice

Objetivo: resolver bloqueios de design antes de conteudo real.

Saida esperada: pendencias de `PRIMEIRO_SLICE` classificadas como resolvidas, adiadas com justificativa ou mantidas como bloqueio explicito.

Validacao: nenhum prompt posterior implementa regra sem documento destino atualizado.

## T00-P10 - Conteudo Real E Simulador Completo

Objetivo: substituir fixtures por conteudo real versionado e simulador completo server-side.

Saida esperada: JSONs expandidos, validadores de schema e simulador deterministico com regras centrais.

Validacao: testes server cobrem replay por seed, limite de duracao e eventos conforme contrato.

## T00-P11 - Base Manager E Economia

Objetivo: implementar base e economia servidor-side.

Saida esperada: estruturas, upgrades, coleta offline, armazenamento, cotas, recompensas e ledger.

Validacao: mutacoes sao idempotentes e coleta offline respeita armazenamento.

## T00-P12 - Social, Matchmaking, Bots E Ranking

Objetivo: completar sistemas sociais e competicao.

Saida esperada: amigos, guilda, ajudas, chat por polling, matchmaking real/bot e ranking de season.

Validacao: RLS impede acesso indevido e bots nao entram no ranking.

## T00-P13 - Monetizacao Funcional E Alpha

Objetivo: fechar sistemas de alpha e monetizacao funcional.

Saida esperada: Battle Pass, Diamante, recompensas diarias/semanais e smokes de export Android, PC e PC browser.

Validacao: fluxos free/premium testados, exports geram build smoke e `../../current-status.md` marca pronto para playtest alpha.
