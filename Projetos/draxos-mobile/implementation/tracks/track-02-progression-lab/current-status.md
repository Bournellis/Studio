# Track 02 - Progression Lab - Current Status

- Last Updated: `2026-05-25`
- Status: `IN_PROGRESS - SOURCE IDENTITY BALANCE V2 + GODOT LAB RUNNERS HARDENED`
- Baseline: Track 00 completa, Track 01 alpha PC local pronta, Battle Lab e simulador economico existentes. Progression Lab v1 agora gera saves saudaveis, relatorios, bot pool, seeder local e fluxo manual dev-only no Godot. Em 2026-05-25, o Character Systems Rework atualizou instrumentos, spells, doutrinas, familiares, fontes de dano e status no catalogo, simulador, labs e testes; Source Identity Balance v2 manteve Battle Lab em `PASS`, adicionou checks de identidade de fonte e deixou Progression Lab em `REVIEW` calibravel. O runner dev-only dos labs no Godot agora sanitiza comandos acumulados, usa wrapper Windows-safe para `npx.cmd` e tem smoke real via `tools/smoke_dev_labs.gd`.

## Objetivo Atual

Criar o Progression Lab para testar e calibrar manualmente e por simulacao as primeiras `2h`, `5h`, `10h`, `15h` e `20h` de DraxosMobile.

## Implementado

- Escopo da track criado.
- Plano de implementacao criado.
- Documentacao operacional inicial criada em `docs/progression-lab/README.md`.
- Modelo `tools/progression_lab/model.v1.json` com milestones `2h`, `5h`, `10h`, `15h`, `20h` e cinco perfis fixos.
- Gerador offline `tools/progression_lab/generate.ts` com `25` saves saudaveis, checks de recompensa, gap premium, recomendacoes de poder, bot pool e relatorio HTML/CSV/JSON.
- Outputs versionados em `docs/progression-lab/generated/`.
- Seeder local `tools/progression_lab/seed_supabase.ts` com trava para Supabase local, `--dry-run`, `--all`, selecao por perfil/milestone e cache em `.progression_lab_scratch/`.
- Tela dev-only `Progression Lab Dev` no Refugio do editor para gerar relatorio, preparar save local, carregar cache no `SessionStore` e abrir checklist manual.
- `SessionStore.apply_snapshot_cache()` para aplicar o cache produzido pelo seeder.
- Battle Lab integrado aos healthy saves e bot pool do Progression Lab, com `battle_lab_progression_matrix.csv`.
- Character Systems Rework 2026-05-25 integrado ao Progression Lab e Battle Lab: `weapon_id` entra nos builds, archetypes antigos foram substituidos e os ids vivos seguem `docs/character-systems-rework.md`.
- Source Identity Balance v2 2026-05-25 integrado: Battle Lab v4 valida identidade de fonte, recalcula poder por loadout real, usa pesos `level=42`, `weapon=28`, `spell=40`, `pet=34`, `passive=22`, move anti-stall para o limite real, reduz dominancia de ataque basico/DoT/Familiar e arquiva a run oficial `2026-05-25_source_identity_balance_v02`.
- Exports Android/PC/Web excluem `tools/progression_lab/`, `docs/progression-lab/` e `.progression_lab_scratch/`.
- Smoke GUT cobre saves `2h`, `10h`, `20h` e aplicacao de snapshot do Progression Lab.
- Smoke Godot `tools/smoke_dev_labs.gd` cobre o spawn real de Battle Lab/Progression Lab via `OS.execute`, replay custom com spells/effects e geracao dos outputs do Progression Lab.

## Ultimo Resultado Local

- `npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts`: `25` saves, `75` bots, status `REVIEW`, `11` itens de review.
- `npx -y deno test tools/progression_lab`: `4/4` testes.
- `npx -y deno test tools/battle_lab`: `14/14` testes.
- `npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --archive-run 2026-05-25_source_identity_balance_v02 --compare-with 2026-05-25_initial_balance_v01`: `3132` batalhas, `212` builds, status `PASS`, duracao media `24.08s`, anti-stall `4.95%`, dominancia em poder proximo maxima `63.46%`, checks de identidade de fonte em `PASS`.
- `npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all`: selecionou `25/25` saves.
- `tools/validate.gd`: passou com GUT `28/28`, `154` asserts.
- `tools/smoke_dev_labs.gd`: passou, executando Battle Lab bridge e Progression Lab generate pelo `OS.execute` do Godot.
- `tools/smoke_exports.gd`: passou para Android Alpha, PC Windows Alpha e PC Browser Alpha.

## Proximo Passo

Rodar o seeder contra Supabase local com `SUPABASE_SERVICE_ROLE_KEY`, carregar manualmente pelo Godot os saves `2h`, `5h`, `10h`, `15h` e `20h`, registrar feedback e abrir rodada before/after para premium gap 10h, janelas 15h/20h, poder, bots e sensacao de Familiar/Funeral no replay.
