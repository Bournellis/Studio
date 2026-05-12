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

Proximo prompt: `P02 - Selected Class Session State`.

## Progresso

- [x] P01: catalogo gerado expoe 5 classes autoradas.
- [x] P01: `ContentLibrary` expoe helpers de classe, heroi, hero power e starter deck.
- [x] P01: testes cobrem 5 starter decks de 20 cartas e validam que cada carta existe.
- [x] P01: validacao Godot verde em 2026-05-12 com 78/78 testes e 592 asserts.

## Regras De Registro

- Atualizar o cursor e status do prompt em `linear-execution-plan.md`.
- Atualizar `Projetos/rpg-turnos/implementation/current-status.md` quando o baseline, proximo passo ou validacao mudarem.
- Atualizar `Projetos/rpg-turnos/implementation/tracks/track-02-draxos-lore-progression/current-status.md` quando o status da track mudar.
- Atualizar `08_Coordenacao_Agentes/Estado_Atual.md` quando o snapshot observavel do projeto mudar.
- Rodar validacao Godot apos mudancas de runtime, dados, cenas, recursos gerados ou testes.

## Proximo Passo

Executar P02:

1. Adicionar `selected_class` em `core/game_session.gd`.
2. Preservar compatibilidade de save/load para saves sem `selected_class`.
3. Adicionar helpers de selecao, consulta e inicializacao de deck por classe.
4. Manter fallback do starter deck antigo ate a selecao de classe ficar ativa.
5. Rodar validacao apos mudancas de runtime, save e testes.
