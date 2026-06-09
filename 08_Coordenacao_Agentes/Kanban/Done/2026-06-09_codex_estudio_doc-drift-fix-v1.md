# Doc Drift Fix v1

- Data: `2026-06-09`
- Agente: `Codex`
- Branch: `codex/estudio/doc-drift-fix-v1`
- Worktree: `D:\Estudio-worktrees\estudio--codex--doc-drift-fix-v1`
- Status: concluido

## Objetivo

Corrigir divergencias documentais encontradas na revisao completa, sem alterar
codigo/runtime, schema, builds, assets, publicacao remota ou pacote Internal
Alpha.

## Problemas Resolvidos

- DraxosMobile README usava hashes do pacote anterior `Bosque Bootstrap
  Authority v1`; agora usa os hashes vivos do pacote `Bosque Diegetic Launcher
  Foundation v1`.
- Openworld/Bosque declarava a foundation como etapa local sem publicacao em um
  doc vivo; agora reconhece a publicacao DMOB-D077 e preserva as restricoes de
  sem backend/schema/economia/recompensa/tuning/asset novo.
- Draxos Roguelike docs vivos apontavam playtest manual direto e baselines de
  validacao antigas; agora apontam o Design Lab como ponte operacional e deixam
  contagens vivas em `implementation/current-status.md`.
- A track antiga do Roguelike agora se declara snapshot historico e aponta para
  `../../current-status.md`.
- `AGENTS.md` passou a rotear `29 mapas` e manter `10 mapas legado`.
- Canon/progression/lore agora marca regras de RPG Isometrico e TBDs como
  limites intencionais, nao autoridade automatica para DraxosMobile ou Draxos
  Roguelike.

## Arquivos Alterados

- `AGENTS.md`
- `canon/design/progression-design.md`
- `canon/lore/draxos-invasion.md`
- `canon/lore/immortals.md`
- `Projetos/draxos-mobile/README.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-decision-pack.md`
- `Projetos/draxos-roguelike-cardgame/README.md`
- `Projetos/draxos-roguelike-cardgame/docs/architecture.md`
- `Projetos/draxos-roguelike-cardgame/docs/game-design-document.md`
- `Projetos/draxos-roguelike-cardgame/docs/product-brief.md`
- `Projetos/draxos-roguelike-cardgame/docs/production-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/current-status.md`

## Commits

- `7f0e739` - `Fix DraxosMobile release documentation drift`
- `186efc1` - `Align Draxos Roguelike operational documentation`
- `663f8f2` - `Clarify studio canon and routing document boundaries`

## Validacao

- Varredura de hashes antigos: aparecem somente em
  `08_Coordenacao_Agentes/Kanban/Done/2026-06-09_codex_draxos-mobile_bosque-bootstrap-authority-v1.md`,
  que e registro historico.
- Varredura de termos conflitantes: sem ocorrencias vivas para `not a
  new-content track`, `Bosque Diegetic Launcher Foundation v1 e uma etapa local,
  sem publicacao`, baselines antigas de GUT/asserts em docs vivos tocados, ou
  `ready for user playtest` como proximo passo operacional.
- `git diff --check`: PASS.
- DraxosMobile DocsOnly:
  `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly -NoProjectWrites`:
  PASS.
- Draxos Roguelike: validacao documental estatica por `rg` e `git diff
  --check`; nenhum script documental especifico foi encontrado. Nao rodei Godot
  runtime porque o escopo foi somente documental.

## Status De Portfolio

Sem mudanca de status observavel. `Prioridades_Estudio.md`,
`Estado_Atual.md` e `Projetos/README.md` ja expressavam o estado operacional
correto; as correcoes alinharam documentos satelite e limites de autoridade.

## Riscos Residuais

- Registros historicos em Done/handoff/status-history continuam contendo hashes,
  baselines e proximos passos antigos por design.
- Os TBDs de lore/progressao permanecem abertos; agora estao marcados como
  lacunas intencionais.
