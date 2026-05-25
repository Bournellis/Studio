# Track 02 - Progression Lab - Current Status

- Last Updated: `2026-05-25`
- Status: `IN_PROGRESS - INITIAL BALANCE V1 IMPLEMENTED`
- Baseline: Track 00 completa, Track 01 alpha PC local pronta, Battle Lab e simulador economico existentes. Progression Lab v1 agora gera saves saudaveis, relatorios, bot pool, seeder local e fluxo manual dev-only no Godot. Em 2026-05-25, o Character Systems Rework atualizou instrumentos, spells, doutrinas, familiares, fontes de dano e status no catalogo, simulador, labs e testes; Initial Balance v1 tirou o Battle Lab de `CRITICAL` para `PASS` e deixou Progression Lab em `REVIEW` calibravel.

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
- Initial Balance v1 2026-05-25 integrado: Battle Lab v3 recalcula poder por loadout real, pesos de poder foram atualizados, anti-stall voltou a ficar raro, Corvo aplica `pressagio`, DoTs/Familiar/Funeral receberam tuning inicial e run oficial `2026-05-25_initial_balance_v01` foi arquivada.
- Exports Android/PC/Web excluem `tools/progression_lab/`, `docs/progression-lab/` e `.progression_lab_scratch/`.
- Smoke GUT cobre saves `2h`, `10h`, `20h` e aplicacao de snapshot do Progression Lab.

## Ultimo Resultado Local

- `npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts`: `25` saves, `75` bots, status `REVIEW`, `13` itens de review.
- `npx -y deno test tools/progression_lab`: `4/4` testes.
- `npx -y deno test tools/battle_lab`: `13/13` testes.
- `npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --archive-run 2026-05-25_initial_balance_v01 --compare-with 2026-05-21_archetype_source_tuning_v02`: `3132` batalhas, `212` builds, status `PASS`, duracao media `21.13s`, anti-stall `0.96%`, dominancia em poder proximo maxima `64.46%`.
- `npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all`: selecionou `25/25` saves.
- `tools/validate.gd`: passou com GUT `26/26`, `122` asserts.
- `tools/smoke_exports.gd`: passou para Android Alpha, PC Windows Alpha e PC Browser Alpha.

## Proximo Passo

Rodar o seeder contra Supabase local com `SUPABASE_SERVICE_ROLE_KEY`, carregar manualmente pelo Godot os saves `2h`, `5h`, `10h`, `15h` e `20h`, registrar feedback e abrir rodada before/after para premium gap 10h, janelas 15h/20h, poder, bots e sensacao de Familiar/Funeral no replay.
