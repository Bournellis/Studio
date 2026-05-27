# Track 04 - Implementation Plan

## Regra Da Track

Track 04 comeca como pos-handoff, nao como expansao de produto. Em 2026-05-27, Fabio confirmou que a rodada Internal Alpha v0 com Fabio + tester passou. O gate inicial esta concluido e a track entra em evolucao pos-alpha ativa.

O trabalho agora deve ser paralelo, mas controlado por worktrees, dependencias e ownership claro. Nenhum agente deve usar `D:\Estudio` como worktree de implementacao.

Commits esperados:

- `docs:` backlog, decisoes, playtest e status.
- `client:` cada tela/presenter extraido separadamente.
- `test:` validacao ou cobertura adicionada junto da tela afetada.
- `contracts:` somente se houver decisao de schema ou contrato.
- `backend:` somente apos gate explicito de conta/save ou bug real.

## Atualizacao Pos-Alpha - 2026-05-27

Status geral: `ACTIVE_POST_ALPHA_EVOLUTION`.

Assumptions travadas:

- O resultado "testes passaram" conclui `T04-P00` sem reexecutar a rodada.
- Nenhum bug bloqueante foi relatado como impeditivo imediato.
- A proxima evolucao prioriza estabilidade estrutural e capacidade de paralelizacao antes de features grandes.
- iOS, mobile browser, pagamento real, rework visual completo e novos modos seguem fora do escopo.

## Trilhas Paralelas Oficiais

Prompts operacionais para abrir as threads paralelas ficam em `agent-prompts.md`.

| Trilha | Prioridade | Trabalho | Dependencia |
|---|---:|---|---|
| T04-A Coordenacao | 0 | Registrar alpha aprovado, backlog inicial e plano paralelo | Nenhuma |
| T04-B Hub Scaffold | 1 | Criar plano de corte e scaffold de presenters sem mudar comportamento | T04-A |
| T04-C Shell/Login/Update | 2 | Extrair renderizacao de sessao, login, save e update gate | T04-B |
| T04-D Base/Loja | 3 | Extrair renderizacao de Base e Loja; manter actions/backend no Boot | T04-C |
| T04-E Social/Competicao | 3 | Extrair renderizacao Social e Competicao; preservar endpoints | T04-C |
| T04-F Batalha/Replay | 3 | Extrair renderizacao/controles da aba Batalha; preservar simulador | T04-C |
| T04-G Progression/Economia | 2 | Rodada humana/lab e recomendacoes de tuning | T04-A |
| T04-H Account/Save Gate | 2 | Decidir manter `players.save_type` ou planejar `account_profiles` + `game_saves` | T04-A |

## Decisoes De Implementacao Para Paralelizacao

- Modularizacao do Hub usa GDScript puro, sem editar `.tscn` como texto.
- Criar `modes/boot/surfaces/` no pacote `T04-B`.
- Primeira extracao e render-only: presenters recebem `host: Node`, chamam helpers existentes do `boot.gd`, e actions/network continuam no `boot.gd`.
- `boot.gd` permanece orquestrador de sessao, navegacao, busy state, telemetria e chamadas Supabase.
- Nao alterar contratos HTTP, Supabase schema, battle simulator, economia ou ranking durante extracoes de UI.
- Migration `account_profiles` + `game_saves` so pode virar implementacao depois de decisao documentada em `T04-H`.

## T04-P00 - Intake Pos-Handoff

Status: `COMPLETE_BY_USER_CONFIRMATION`.

- Rodar rodada fechada Fabio + tester usando `docs/internal-alpha-v0-handoff.md`.
- Registrar ambiente, plataforma, conta, save, versao e problema observado.
- Separar feedback em bug bloqueante, UX/onboarding, tuning, divida tecnica e ideia futura.
- Criar backlog curto antes de qualquer refatoracao estrutural.

Saida esperada:

- Registro de playtest e backlog priorizado.
- Decisao sobre primeiro pacote de correcao.

Resultado 2026-05-27:

- Fabio confirmou que a rodada Internal Alpha v0 com Fabio + tester passou.
- Sem bug bloqueante informado como impeditivo imediato.
- Primeiro pacote aprovado: coordenacao da evolucao pos-alpha e paralelizacao controlada da Track 04.

## T04-P01 - Bugs Bloqueantes Primeiro

Status: `AVAILABLE_IF_BLOCKER_FOUND`.

- Corrigir crash, bloqueio de login, save errado, update gate quebrado, recurso/ranking incorreto ou download/manifest quebrado antes de polish.
- Validar o menor smoke possivel para a superficie afetada.
- Publicar update apenas se o bug bloquear a rodada.

Saida esperada:

- Build segue testavel sem regressao do loop principal.

## T04-P02 - UX Android E Onboarding

Status: `AVAILABLE_AFTER_T04_B_OR_BUG_FEEDBACK`.

- Ajustar fluxo de login/criacao de conta se tester travar.
- Ajustar densidade, labels e hierarquia do Hub se Android real mostrar friccao.
- Melhorar mensagens de erro e proximo passo visivel.
- Separar mudanca de UX de refatoracao estrutural.

Saida esperada:

- Onboarding da Internal Alpha v0 mais claro sem alterar contratos backend.

## T04-P03 - Plano De Corte Do Hub

Status: `READY_AFTER_T04_A`.

- Mapear responsabilidades atuais de `modes/boot/boot.gd`.
- Definir contratos de presenter/tela para cada superficie.
- Escolher a primeira extracao com menor risco.
- Confirmar quais GUT/smokes cobrem a superficie antes de mover codigo.

Saida esperada:

- Lista curta de extracoes em ordem e validacao esperada por extracao.

## T04-P04 - Extrair Shell/Login/Update

Status: `WAITING_FOR_T04_B`.

- Extrair tela/presenter de sessao, login, account bootstrap e update gate.
- `boot.gd` continua compondo sinais, dependencias e navegacao.
- Nao alterar Auth, manifest ou backend nesta etapa.

Validacao:

- `tools/smoke_session_shell.gd`
- GUT de session shell/update quando aplicavel
- `git diff --check`

## T04-P05 - Extrair Batalha

Status: `WAITING_FOR_T04_C`.

- Extrair controles da aba Batalha e composicao do mockup/replay.
- Preservar `BattleLogPresenter`, `BattleVisualMockup` e `BattleStage2D`.
- Nao alterar simulador, reward ou contratos de batalha.

Validacao:

- `tools/smoke_battle_replay.gd`
- GUT de presenter/mockup/stage

## T04-P06 - Extrair Base

Status: `WAITING_FOR_T04_C`.

- Extrair mapa de predios, painel de detalhe, upgrade/coleta e busy/error states.
- Nao alterar endpoints `base/*`, economia ou fila dupla.

Validacao:

- Smoke alpha loop ou smoke especifico de Base se criado.
- GUT da superficie extraida.

## T04-P07 - Extrair Social, Competicao E Loja

Status: `WAITING_FOR_T04_C`.

- Extrair uma superficie por commit quando possivel.
- Preservar polling/chat/ranking/loja e tooltips existentes.
- Nao alterar ranking, monetizacao ou schema nesta etapa.

Validacao:

- Smokes de social/competicao/monetizacao afetados.
- GUT de snapshots/estado quando aplicavel.

## T04-P08 - Rodada Humana Do Progression Lab

Status: `READY_AFTER_T04_A`.

- Rodar cenarios 2h, 5h, 10h, 15h e 20h.
- Cobrir perfis free, freemium, light e max.
- Registrar sensacao de premium gap, janelas 15h/20h, poder, bots, recursos e objetivos.

Saida esperada:

- Recomendacoes de tuning antes de mexer em economia maior.

## T04-P09 - Gate Account Profiles / Game Saves

Status: `READY_AFTER_T04_A`.

- Avaliar se `players.save_type` gerou bug real, ambiguidade social, risco de isolamento ou custo alto de evolucao.
- Se sim, planejar migration `account_profiles` + `game_saves` em track/commit proprio.
- Se nao, manter schema atual ate proxima necessidade tecnica.

Regra:

- Nao executar migration junto de modularizacao do Hub.
- Nao executar migration antes do playtest inicial, salvo bug real de isolamento.

## Validacao Base

Documentacao:

```powershell
git diff --check
```

Godot quando tocar client:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
```

Backend/schema futuro:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y supabase db reset
npx -y deno task check --cwd supabase/functions
```
