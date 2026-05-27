# T05-F Progression Human Pack

- Data: 2026-05-27
- Status: `READY_FOR_INTEGRATION`
- Owner worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t05-progression-human-pack`
- Branch: `codex/draxos-mobile/t05-progression-human-pack`

## Entrega

T05-F prepara a rodada humana do Progression Lab antes de tuning numerico. A entrega principal e o runbook:

- `../../../docs/progression-lab/2026-05-27-t05-progression-human-runbook.md`

O pacote nao altera economia, poder, bots, loja, recompensas, recursos, combate, schema, release remoto ou assets.

## Escopo Da Rodada

Perfis obrigatorios:

- `free_100_rewards`
- `freemium_basic`
- `spender_light`
- `max_spender`

Milestones obrigatorios:

- `2h`
- `5h`
- `10h`
- `15h`
- `20h`

Casos de foco:

- `spender_light_10h`
- `max_spender_10h`
- `max_spender_20h`
- `free_100_rewards_20h`
- `freemium_basic_20h`

Guardrail opcional:

- `free_50_rewards_15h`
- `free_50_rewards_20h`

## Criterios De Decisao

Premium gap:

- `spender_light_10h`, `max_spender_10h` e `max_spender_20h` devem provar que premium acelera tempo/conforto sem virar poder obrigatorio.
- Se a sensacao for injusta, priorizar matchmaking/bots por banda antes de mexer em economia, exceto se a loja/passe claramente vender poder imediato demais.

Janela `20h`:

- `free_100_rewards_20h` e `freemium_basic_20h` estao em L17 contra alvo L18.
- Decidir se L17 e aceitavel com objetivo claro ou se L18 e requisito real de produto.
- Se L17 for aceitavel, revisar target em tarefa separada; se L18 for requisito, tuning numerico separado.

Bots ponte:

- Observar transicao `band_004` -> `band_005` nos casos `10h` e `20h`.
- Se nao houver oponente plausivel, abrir tarefa de bots ponte antes de alterar pesos de poder.

Recursos:

- `resource_debt` tecnico esta `PASS`, entao a pergunta humana e clareza/pressao, nao solvencia.
- Segunda fila deve parecer conforto liquido; `max_spender_20h` deve manter objetivo claro mesmo com sink de qualidade de arma.

Pesos de poder:

- Pesos atuais permanecem ate Battle Lab e rodada humana discordarem.
- Qualquer mudanca exige comparacao before/after em Battle Lab + Progression Lab.

## Handoff Para Tuning

Nao iniciar tuning enquanto a rodada nao preencher:

- status humano por caso;
- decisao de premium gap;
- decisao da janela `20h`;
- decisao de bots ponte;
- decisao de recursos;
- decisao de pesos de poder.

Estados aceitos para o handoff:

- `KEEP`: manter baseline e registrar evidencia.
- `MATCHMAKING_FIRST`: criar tarefa de bot/pareamento antes de economia.
- `TUNING_NEEDED`: abrir tarefa numerica separada com validacao completa.
- `BATTLE_LAB_POWER_REVIEW`: rodar Battle Lab focado antes de alterar pesos.

## Validacao

- Pass: `npx -y deno test tools/progression_lab`.
- Pass: `npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts` na validacao inicial da branch.
- Pass: `npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all`.
- Pass: `tools/smoke_dev_labs.gd`.
- Pass: `git diff --check`.
