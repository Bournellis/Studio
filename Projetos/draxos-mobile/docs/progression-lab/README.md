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

3. Preparar save local no Supabase:

```powershell
npx -y deno run --allow-net --allow-env --allow-read --allow-write tools/progression_lab/seed_supabase.ts --profile free_100_rewards --milestone 10h
```

4. Abrir o Godot editor e usar `Refugio -> Progression Lab Dev`.
5. Carregar o save e jogar manualmente.
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

Scratch local:

- `.progression_lab_scratch/`

Esse diretorio guarda sessoes locais e nao deve entrar no Git.

## Contrato

- Ferramenta local/dev-only.
- Nao substitui Supabase como autoridade do jogo.
- Nao cria pagamento real.
- Nao muda numeros automaticamente.
- Nao promove pesos de poder sem Battle Lab + Progression Lab concordarem.
- Premium deve vender tempo e conforto, nao poder exclusivo acima do cap.
