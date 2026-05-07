# RPG Turnos - Track 02 Linear Execution

- Data: `2026-05-07`
- Agente: `Codex`
- Status: `Doing`
- Projeto: `Projetos/rpg-turnos`
- Track: `Track 02 - Draxos Lore And Progression Alignment`
- Plano operacional: `Projetos/rpg-turnos/implementation/tracks/track-02-draxos-lore-progression/linear-execution-plan.md`

## Objetivo

Executar a Track 02 em ordem linear, prompt a prompt, mantendo todos os registros atualizados.

## Cursor Atual

Proximo prompt: `P01 - Catalog class resource plumbing`.

## Regras De Registro

- Atualizar o cursor e status do prompt em `linear-execution-plan.md`.
- Atualizar `Projetos/rpg-turnos/implementation/current-status.md` quando o baseline, proximo passo ou validacao mudarem.
- Atualizar `Projetos/rpg-turnos/implementation/tracks/track-02-draxos-lore-progression/current-status.md` quando o status da track mudar.
- Atualizar `08_Coordenacao_Agentes/Estado_Atual.md` quando o snapshot observavel do projeto mudar.
- Rodar validacao Godot apos mudancas de runtime, dados, cenas, recursos gerados ou testes.

## Proximo Passo

Executar P01:

1. Expor `classes` no recurso gerado do catalogo.
2. Adicionar helpers de classe em `ContentLibrary`.
3. Cobrir as 5 classes e seus starter decks em testes.
4. Regenerar recursos e rodar validacao.
