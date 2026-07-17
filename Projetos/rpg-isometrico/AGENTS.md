# AGENTS.md — RPG Isométrico

## Metadata

- status: living
- authority: operational_contract
- last_verified: 2026-07-16
- review_when: pausa, governança, canon local ou arquitetura mudar
- supersedes: AGENTS.md anterior ao cutover de governança v2
- superseded_by: none

## Estado e autoridade

O RPG Isométrico permanece `PAUSADO_INDEFINIDO`. O portfólio em `../../08_Coordenacao_Agentes/Prioridades_Estudio.md` decide o trabalho permitido.

`implementation/current-status.md` é a única autoridade técnica local. Documentos de track são história até retomada explícita.

O canon de produto vive em `docs/canon/`; lore compartilhado vive em `../../canon/shared-lore/`. Nenhuma regra deste produto se aplica automaticamente aos demais projetos.

## Ordem de leitura

1. `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `implementation/current-status.md`
3. `08_Coordenacao/README.md`
4. `qa/QA_INDEX.md`
5. `docs/canon/README.md` quando o pedido exigir produto/canon
6. arquivos tocados

Durante a pausa, não abra track, gate ou conteúdo de produto. História de Track 02 só é lida para responder pergunta específica ou executar reparo explicitamente autorizado.

## Trabalho local

- Use worktree em `D:\Estudio-worktrees\rpg-isometrico--<agente>--<slug>` e branch `codex/rpg-isometrico/<slug>` para Codex.
- Cards e handoffs novos vivem em `08_Coordenacao/`.
- Trabalho local enfileira `global_sync_needed`; não edita estado global.
- Commits separam documentação, QA, runtime e coordenação.
- Git é local. Push, fetch, pull, deploy e publicação são exclusivos de Fabio.

## Base técnica

- Godot `4.6.2-stable`, GDScript e GUT `9.6.0`.
- JSON gera recursos; cenas jogáveis são editor-owned, salvo gerador oficial existente.
- Não edite `.tscn` como texto. Use editor ou ferramenta Godot.
- Preserve limites Foundation, Gameplay, Presentation, Composition e Online definidos no canon local.

## QA e gates

`qa/qa_manifest.json` governa comandos; `qa/QA_INDEX.md` governa jornadas. Runtime integral só roda quando o projeto é selecionado explicitamente e deve deixar a árvore rastreada inalterada.

Não há gate humano ativo enquanto pausado. Retomada, campanha, lore, progressão, feel, visual, modo ou plataforma exigem nova decisão; automação não aprova essas escolhas.

## Hard stops

Pare diante de retomada implícita, mudança de prioridade/produto/canon, segredo, remoto/publicação, cena/binário ambíguo, conflito histórico único ou decisão humana não existente.
