# Tarefa: JogoDaCopa Track 03F Quality Hotfix V1

## Metadata

- id: `2026-06-10_codex_jogodacopa_track03f-quality-hotfix-v1`
- owner: `Codex`
- status: `Doing`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/jogodacopa/track03f-quality-hotfix-v1`
- worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03f-quality-hotfix-v1`

## Goal

Implementar `Track 03F - Quality Hotfix V1`: fixes consolidados dos code reviews das series Track 03 e Track 02C-bis/02D-bis, tuning objetivo de playtest de Fabio quando houver notas, validacao reforcada e fechamento seguro.

## Base Docs Read

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md`
- `Projetos/JogoDaCopa/docs/code-review-track03-series-v1.md`
- `Projetos/JogoDaCopa/docs/code-review-track02cbis-02dbis-v1.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`

## Intended Files

- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/gameplay/avatar/player_avatar_3d.gd`
- `Projetos/JogoDaCopa/tools/performance_sample.gd`
- `Projetos/JogoDaCopa/tools/validate.gd`
- `Projetos/JogoDaCopa/tests/`
- `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-03f-quality-hotfix-v1/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-10_codex_jogodacopa_track03f-quality-hotfix-v1.md`

## Review Fix Scope

- Super do jogador so pode consumir barra/cota quando o chute conecta.
- Avatar real deve preservar texturas PBR das surfaces, modulando tint de kit sobre materiais duplicados.
- Sobrancelha deve usar tom de cabelo/neutro escuro, nao cor de kit.
- `tools/performance_sample.gd` deve documentar metodologia e imprimir resolucao/modo de janela.
- `tools/validate.gd` deve incluir check de integridade basica para `.gd` e `.gdshader` fora de `addons/`.

## Playtest Tuning Scope

- Implementar apenas notas objetivas de Fabio em constantes, clipes ou toggles.
- Registrar valor antigo -> novo no doc da track.
- Nao implementar nota subjetiva ou ambigua; registrar pendencia em `08_Coordenacao_Agentes/Decisoes/`.
- Se o toon for decidido definitivamente ON ou OFF, fixar o estado e remover a opcao do menu preservando reversao facil.

## Guardrails

- Nao tocar a fisica base da bola.
- Preservar contratos de tap LMB/RMB.
- Manter paridade de bot para mudancas de stun/dash/player feel.
- Nao hand-edit de `.tscn` gerado.

## Validation Plan

- `tools/validate.gd` PASS, incluindo o novo check de integridade.
- Novo teste: RMB com super cheio e bola fora de alcance nao gasta barra nem cota do kickoff.
- Novo teste: surfaces do avatar real preservam `albedo_texture != null` apos tint.
- Performance sample rodado em janela real, resolucao fixa `1920x1080`, vsync off, com resolucao/modo impressos.
- `git diff --check` PASS.
- `git status --short` limpo antes de merge.
- Pos-merge em `main`: `git status --short` limpo e check de integridade rodado no worktree principal.

## Handoff Point

Ao fechar a track: merge em `main`, card movido para `Done`, worktree removido/pruned, `Estado_Atual.md` apontando proximo passo como playtest de confirmacao do hotfix + decisao da proxima serie com Claude.
