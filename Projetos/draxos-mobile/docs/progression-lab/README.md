# DraxosMobile - Progression Lab

Progression Lab e o workflow local para calibrar as primeiras horas de gameplay ativo do DraxosMobile.

Ele complementa o Battle Lab e o simulador economico:

- o simulador economico mede progression macro de season;
- o Battle Lab mede combate em massa;
- o Progression Lab cria estados saudaveis por hora, perfil e milestone para testar o loop na mao dentro do Godot e em relatorios offline.

## Objetivo

Calibrar as primeiras `2h`, `5h`, `10h`, `15h` e `20h` de jogo.

O sistema deve responder:

- que level, build, recursos e base um jogador saudavel deve ter naquele ponto;
- quais recompensas estao fortes, fracas ou criando gargalo;
- qual diferenca premium e aceitavel;
- que poder deve ser atribuido a esse personagem;
- quais bots devem existir para pareamento inicial;
- se `ossos -> po_osso` e `Bau do Bosque -> Fogueira` sustentam estoque
  saudavel de pocoes simples por milestone;
- se a Arena PVE gera pressao aceitavel de pocoes por tentativa, considerando
  estoque vivo consumido por duelo;
- se o save saudavel exercita slot de pocao e comportamento simples na
  Preparacao;
- como a sensacao manual no Godot compara com os dados.

## Direcao Arena PVE Inicial

A proxima rodada de Progression Lab deve modelar Arena PVE antes de PVP. O laboratorio precisa representar:

- tutorial de 1 duelo;
- primeiras arenas de 3 duelos;
- arenas maiores desbloqueadas por progresso/dificuldade;
- loadout travado antes da arena;
- vida resetada a 100% antes de cada duelo;
- escolha de 1 entre 3 buffs temporarios leves de stat entre duelos;
- comportamento ajustavel antes do proximo inimigo;
- recompensas sem cooldown de combate, controladas por primeira conclusao, dificuldade, recorde, repeticao reduzida, limites diarios/semanais e caps.

O Progression Lab deve responder se leveling, upgrades, recursos, poder e base evoluem em ritmo saudavel quando o jogador repete arenas curtas, tenta dificuldade maior ou desbloqueia arenas mais longas. PVP e bot pool posterior continuam uteis, mas nao sao mais a base do early game.

## Reconciliacao Diagnostica Arena PVE

Este Lab e evidencia diagnostica, nao autoridade de tuning. `DMOB-D067` continua
`CALIBRAR` ate uma rodada representar Arena PVE com tutorial de 1 duelo,
primeiras arenas de 3 duelos, HP resetado, buffs temporarios, loadout travado,
consumo realista de pocao e recompensas por conclusao/recorde/repeticao.

Outputs do Progression Lab podem propor hipoteses de ritmo, gargalo e premium
gap, mas nao alteram runtime, rewards, economia, power, bots, ruleset ou save
normal sem pacote explicito e comparacao before/after. No Web export, o runner
remoto retorna dados em memoria para revisao interna e nao aplica healthy save.

## Perfis

| Perfil | Descricao |
|---|---|
| `free_50_rewards` | Free, completa 50% das recompensas. |
| `free_100_rewards` | Free, completa 100% das recompensas. |
| `freemium_basic` | Battle Pass + segunda fila de construcao, completa 80% das recompensas. |
| `spender_light` | Battle Pass + segunda fila + gasto leve na loja, completa 100% das recompensas. |
| `max_spender` | Tempo/gasto maximo possivel para medir teto e risco de aceleracao. |

## Workflow

1. Gerar relatorio offline:

```powershell
cd D:\Estudio-worktrees\draxos-mobile--<agent>--<slug>\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts
```

2. Ler primeiro:

- `generated/progression_report.html`
- `generated/reward_scaling_checks.csv`
- `generated/potion_affordability.csv`
- `generated/crafting_pressure.csv`
- `generated/preparation_readiness.csv`
- `generated/milestone_profiles.csv` para `arena_attempts`, `arena_duels`,
  `expected_potion_uses` e `potion_attempt_coverage_percent`
- `generated/premium_gap.csv`
- `generated/power_recommendations.csv`
- `generated/bot_pool.csv`

3. Preparar ou aplicar save no Supabase local.

Fluxo atual recomendado para a Track 03:

- entrar no app como guest;
- alternar para o save `Progression Lab`;
- criar/sincronizar a conta guest desse save;
- abrir `Refugio -> Progression Lab Dev`;
- selecionar perfil/milestone e usar `Aplicar no Save Lab`.

Esse fluxo chama `POST /progression-lab/apply`, que valida o perfil/milestone
contra o catalogo versionado de healthy saves e escreve somente no save
`progression_lab`. A partir do Foundation Solidification Follow-up, o cliente
deve enviar `request_id` e `request_hash` preparados pelo `SessionStore`; a RPC
grava/verifica o hash e faz o reset/seed Track 16 na mesma transacao.

O seeder local continua existindo como ferramenta de apoio/dev:

```powershell
$env:SUPABASE_SERVICE_ROLE_KEY="<service-role-local>"
npx -y deno run --allow-net --allow-env --allow-read --allow-write tools/progression_lab/seed_supabase.ts --profile free_100_rewards --milestone 10h
```

Para validar a selecao sem tocar no Supabase:

```powershell
npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all
```

4. Abrir o Godot editor, PC build ou Web export e usar
   `Refugio -> Progression Lab Dev`.
   - Editor/PC podem gerar relatorio pelo Deno local.
   - Web export chama `POST /lab-runner/progression` quando houver sessao
     Supabase de conta alpha por email/senha com save `normal` registrado. Esse
     caminho retorna dados em memoria, nao grava arquivos e nao substitui uma
     run oficial local.
5. Carregar ou aplicar o save e jogar manualmente. Sem `SUPABASE_SERVICE_ROLE_KEY`, `Preparar Save Local` cria um cache local-only a partir do healthy save selecionado para validar UI/fluxo em modo somente leitura. Esse cache nao tem token valido: base pode ser inspecionada como snapshot, mas batalha, coleta, upgrade e outras acoes server-authoritative exigem uma sessao real. Com uma sessao real no save `progression_lab`, `Aplicar no Save Lab` usa o endpoint server-authoritative e nao precisa expor service role ao cliente.
6. Registrar feedback de ritmo, recompensa, gargalo, poder e loja.
7. Rodar Battle Lab com as builds saudaveis.
8. Ajustar numeros em tarefa separada e comparar before/after.

## Artefatos

- `generated/progression_summary.json`
- `generated/healthy_saves.json`
- `generated/milestone_profiles.csv`
- `generated/reward_scaling_checks.csv`
- `generated/premium_gap.csv`
- `generated/power_recommendations.csv`
- `generated/bot_pool.csv`
- `generated/progression_report.html`

Battle Lab tambem passa a ler `generated/progression_summary.json` quando existir e gera:

- `docs/battle-lab/generated/battle_lab_progression_matrix.csv`

Scratch local:

- `.progression_lab_scratch/`

Esse diretorio guarda sessoes locais e nao deve entrar no Git.

## Contrato

- Ferramenta local/dev-only.
- No Web export, `Gerar Relatorio` usa o runner remoto
  `POST /lab-runner/progression` porque navegador nao executa `npx/deno`.
- O runner remoto exige a mesma conta alpha Supabase por email/senha usada para
  entrar no jogo, com save `normal` registrado. Nao existe allowlist separada
  para Labs.
- O runner remoto nao escreve arquivos, nao aplica healthy save e nao altera
  recursos, ranking, economia, XP, progresso ou ledger.
- Nao substitui Supabase como autoridade do jogo.
- Aplicacao server-backed usa `POST /progression-lab/apply` com `request_hash` obrigatorio e nunca escreve no save `normal`.
- Cache local-only e read-only e nunca deve simular autenticacao online.
- Nao cria pagamento real.
- Nao muda numeros automaticamente.
- Nao promove pesos de poder sem Battle Lab + Progression Lab concordarem.
- Nao vira tuning runtime sem pacote explicito. O pacote vivo atual e Arena PVE inicial.
- Premium deve vender tempo e conforto, nao poder exclusivo acima do cap.
- Track 16 consumables sao cobertura de laboratorio: `po_osso`,
  `craft_pocao_vida`, `pocao_vida`, slot de pocao e comportamentos default. Isso
  nao libera novas pocoes, custos, thresholds ou comportamento avancado.

## Baseline Atual

Ultima rodada viva de Battle Lab versionada:
`2026-05-25_source_identity_balance_v02`.
Generated atual dos labs: Track 16 Lab Alignment em `2026-05-30`.
Ultima rodada tecnica registrada de Progression Lab:
`2026-05-27-t04-progression-economia.md`.
Runbook humano Track 05:
`2026-05-27-t05-progression-human-runbook.md`.

- `25` saves saudaveis e `75` bots gerados.
- Status geral: `REVIEW`.
- Track 16 consumables: `50` checks de consumivel em `PASS`.
- Healthy saves agora incluem `consumables`, inventario de `po_osso` e
  `pocao_vida`, `potion_slots`, `spell_behaviors` e `combat_build` com
  `potionSlot` quando aplicavel.
- `POST /progression-lab/apply` preserva o estado Track 16 do healthy save no
  save `progression_lab`; consumables, potion slots, spell behaviors e item
  transactions sao resetados/recriados dentro da RPC, e o cache local-only
  tambem carrega `build_state` com potion slots, inventario e comportamentos.
- Power recommendations: todos os componentes em `PASS` com os pesos
  `level=42`, `weapon_level=28`, `spell_level=40`, `pet_level=34`,
  `passive_level=22`, `weapon_quality_tier=30`.
- Bot pool: offsets negativos preservam o arquetipo do save e continuam usando
  spells desbloqueadas, evitando bots fracos sem kit em milestones medias.
- Premium gap: sem `CRITICAL` na escala atual, mas ainda com reviews em
  `10h` para `spender_light`/`max_spender` e em `20h` para `max_spender`.
- Reward scaling: reviews nos levels `15h`/`20h` de alguns perfis free/freemium.

O status `REVIEW` e intencional: a ferramenta ja nao bloqueia por erro numerico
critico, mas ainda precisa validacao manual no Godot/Supabase local. Depois da
decisao de `2026-05-31`, esta rodada tambem passa a ser historica para PVP-first;
a proxima evidencia promovivel precisa incluir Arena PVE.

## Rodada Humana Track 05

Antes de tuning numerico, executar o runbook
`2026-05-27-t05-progression-human-runbook.md`.

Casos obrigatorios de foco:

- `spender_light_10h`
- `max_spender_10h`
- `max_spender_20h`
- `free_100_rewards_20h`
- `freemium_basic_20h`

A rodada deve decidir premium gap, janela `20h`, impacto de `pocao_vida` no
anti-stall, pressao de `ossos/po_osso`, inimigos PVE, bots ponte, recursos,
recompensas de arena e pesos de poder.
Qualquer ajuste de economia, poder, bots, loja, recompensas, custos de crafting
ou combate deve virar tarefa separada com comparacao before/after.

## Validacao Local

```powershell
npx -y deno test tools/progression_lab
npx -y deno test tools/battle_lab
npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts
npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_dev_labs.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_dev_lab_ui.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_exports.gd
```

O seed real exige Supabase local ativo, `SUPABASE_SERVICE_ROLE_KEY` e URL local. O script recusa URLs fora de `localhost`, `127.0.0.1` ou `::1`.
