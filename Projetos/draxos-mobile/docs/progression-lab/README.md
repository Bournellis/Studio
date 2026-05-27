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
- como a sensacao manual no Godot compara com os dados.

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
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts
```

2. Ler primeiro:

- `generated/progression_report.html`
- `generated/reward_scaling_checks.csv`
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
`progression_lab`.

O seeder local continua existindo como ferramenta de apoio/dev:

```powershell
$env:SUPABASE_SERVICE_ROLE_KEY="<service-role-local>"
npx -y deno run --allow-net --allow-env --allow-read --allow-write tools/progression_lab/seed_supabase.ts --profile free_100_rewards --milestone 10h
```

Para validar a selecao sem tocar no Supabase:

```powershell
npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all
```

4. Abrir o Godot editor e usar `Refugio -> Progression Lab Dev`.
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
- Nao substitui Supabase como autoridade do jogo.
- Aplicacao server-backed usa `POST /progression-lab/apply` e nunca escreve no save `normal`.
- Cache local-only e read-only e nunca deve simular autenticacao online.
- Nao cria pagamento real.
- Nao muda numeros automaticamente.
- Nao promove pesos de poder sem Battle Lab + Progression Lab concordarem.
- Premium deve vender tempo e conforto, nao poder exclusivo acima do cap.

## Baseline Atual

Ultima rodada viva de Battle Lab: `2026-05-25_source_identity_balance_v02`.
Ultima rodada tecnica registrada de Progression Lab:
`2026-05-27-t04-progression-economia.md`.

- `25` saves saudaveis e `75` bots gerados.
- Status geral: `REVIEW`.
- Power recommendations: todos os componentes em `PASS` com os pesos
  `level=42`, `weapon_level=28`, `spell_level=40`, `pet_level=34`,
  `passive_level=22`, `weapon_quality_tier=30`.
- Bot pool: offsets negativos preservam o arquetipo do save e continuam usando
  spells desbloqueadas, evitando bots fracos sem kit em milestones medias.
- Premium gap: sem `CRITICAL` na escala atual, mas ainda com reviews em
  `10h` para `spender_light`/`max_spender` e em `20h` para `max_spender`.
- Reward scaling: reviews nos levels `15h`/`20h` de alguns perfis free/freemium.

O status `REVIEW` e intencional: a ferramenta ja nao bloqueia por erro numerico
critico, mas ainda precisa validacao manual no Godot/Supabase local.

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
