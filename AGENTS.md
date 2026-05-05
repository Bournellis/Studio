# AGENTS.md

This file governs agent behavior for the `D:\Estudio` workspace.

## Workspace Roles

- `canon/` is the shared source of truth for established product identity, lore context, gameplay contracts, progression, shared architecture, mode standard, and platform strategy.
- `Projetos/rpg-isometrico/` is the active Godot implementation workspace for the campaign-first isometric action RPG.
- `Projetos/rpg-turnos/` is the initial Godot implementation workspace for a provisional turn-based RPG-cardgame that may share studio lore but owns separate mechanics.
- `migration/` is a historical archive for cutover, relocation, and legacy comparison context.
- `08_Coordenacao_Agentes/` is the coordination hub: Kanban, Handoffs, Decisoes, and the Estado_Atual.

## Read Order — Fast Lane (trabalho delimitado)

Para tarefas localizadas num unico projeto ou area (ex: corrigir bug, implementar feature isolada, ajustar documento), comece com:

1. `canon/canon-brief.md`
2. `08_Coordenacao_Agentes/Estado_Atual.md` (secao do projeto relevante)
3. A tarefa ativa em `08_Coordenacao_Agentes/Kanban/Doing/`, se existir
4. O `AGENTS.md` local do projeto Godot, se entrar no codigo

Escale para a ordem completa imediatamente se:
- a tarefa afetar mais de um projeto ou a direcao do canon;
- houver decisao de produto, arquitetura ou plataforma;
- o escopo se expandir alem dos arquivos tocados inicialmente.

## Read Order — Full (trabalho transversal ou decisao importante)

Antes de trabalho substancial que afete multiplos projetos ou o canon:

1. `canon/product/product-vision.md`
2. `canon/design/game-design-document.md`
3. `canon/design/progression-design.md`
4. `canon/architecture/shared-architecture.md`
5. `canon/architecture/game-mode-standard.md`
6. `canon/roadmap/evolution-roadmap.md`
7. `canon/roadmap/release-horizons.md`
8. `canon/platform/steam-platform.md`
9. O `AGENTS.md` local do projeto Godot
10. O `implementation/current-status.md` local do projeto
11. Este arquivo

## Canon Rule

Se o canon compartilhado conflitar com qualquer nota historica de implementacao, o canon prevalece.

Nao aplique silenciosamente a mecanica de um projeto em outro. `rpg-turnos` pode compartilhar lore com `rpg-isometrico`, mas os contratos de modo e loadout do RPG Isometrico nao sao canon do RPG Turnos a menos que um documento local do RPG Turnos os adote explicitamente.

## Godot Rule

Implementacoes Godot vivem sob `Projetos/`.

Projetos Godot ativos:
- `Projetos/rpg-isometrico/`
- `Projetos/rpg-turnos/`

Ao entrar num projeto Godot:
1. Consulte o canon compartilhado primeiro
2. Consulte `implementation/current-status.md` do projeto
3. Consulte o `AGENTS.md` local do projeto Godot e a track ativa em `implementation/tracks/`
4. Consulte docs de validacao historica apenas quando responderem uma pergunta especifica

Use caminhos relativos ao referenciar o canon compartilhado de dentro de um projeto Godot.
Versao esperada do Godot: ver `.godot-version` na raiz deste workspace.

## Historical Context Rule

Se contexto historico for necessario, consulte nesta ordem:

1. `migration/`
2. `Projetos/rpg-isometrico/implementation/phase-g1/` a `phase-g4/`
3. Apenas entao qualquer repositorio legado externo, se a tarefa for explicitamente historica

## Manutencao do Estado_Atual.md

`08_Coordenacao_Agentes/Estado_Atual.md` e o snapshot vivo dos projetos. Mantenha-o atual:

- **Quando atualizar**: ao concluir qualquer tarefa que mude o status observavel de um projeto (nova track ativa, gate concluida, proximo passo alterado, baseline nova).
- **O que atualizar**: somente as linhas que mudaram — status, track ativa, baseline, proximo passo.
- **O que nao colocar**: historico de gates, detalhes tecnicos de implementacao, listas longas de arquivos. Isso vai para Done do Kanban ou para `implementation/current-status.md` do projeto.
- **Regra do tamanho**: se o arquivo passar de 60 linhas, esta crescendo demais.

## Coordination Structure

- Estado atual dos projetos: `08_Coordenacao_Agentes/Estado_Atual.md`
- Tarefas ativas: `08_Coordenacao_Agentes/Kanban/Doing/`
- Backlog: `08_Coordenacao_Agentes/Kanban/Backlog/`
- Handoffs entre agentes: `08_Coordenacao_Agentes/Handoffs/`
- Decisoes de produto e arquitetura: `08_Coordenacao_Agentes/Decisoes/`
- Templates oficiais: `08_Coordenacao_Agentes/Templates/`

**Nomenclatura de arquivos Kanban**: `YYYY-MM-DD_agente_slug.md`
Exemplos: `2026-05-04_codex_rpg-turnos_duelo-mode.md`, `2026-05-04_claude_canon_update.md`
