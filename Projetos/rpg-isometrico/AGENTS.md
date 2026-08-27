# AGENTS.md — RPG Isométrico

## Metadata

- status: living
- authority: operational_contract
- last_verified: 2026-08-27
- review_when: pausa, governança, canon local ou arquitetura mudar
- supersedes: AGENTS.md anterior ao cutover de governança v2
- superseded_by: none

## Estado e autoridade

O RPG Isométrico permanece `PAUSADO_INDEFINIDO`. O portfólio em `../../08_Coordenacao_Agentes/Prioridades_Estudio.md` decide o trabalho permitido.

`implementation/current-status.md` é a única autoridade técnica local. Documentos de track são história até retomada explícita.

O canon de produto vive em `docs/canon/`. `STUDIO_CORE.md` declara
`shared_foundation`, `draxos` e `imortais_troll_forja` na revisão `lore.v2` e
aponta para as autoridades temáticas exatas; nenhuma regra ou detalhe local
deste produto se aplica automaticamente aos demais projetos ou sobe ao Core.

## Ordem de leitura

1. `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `implementation/current-status.md`
3. `STUDIO_CORE.md` quando o pedido exigir lore ou universo
4. `08_Coordenacao/README.md`
5. `qa/QA_INDEX.md`
6. `docs/canon/README.md` quando o pedido exigir produto/canon
7. `implementation/history.md` e ledger/receipt somente quando o pedido exigir história exata
8. arquivos tocados

Durante a pausa, não abra track, gate ou conteúdo de produto. História de Track 02 só é lida para responder pergunta específica ou executar reparo explicitamente autorizado.

## Trabalho local

- Use worktree em `D:\Estudio-worktrees\rpg-isometrico--<agente>--<slug>` e branch `codex/rpg-isometrico/<slug>` para Codex.
- Cards e handoffs novos vivem em `08_Coordenacao/`.
- Trabalho local enfileira `global_sync_needed`; não edita estado global.
- Commits separam documentação, QA, runtime e coordenação.
- Autoria e integração Git permanecem locais; o push rotineiro pós-fechamento segue exclusivamente o contrato e o runbook globais. Deploy, release, publicação e remotos de produto continuam fora deste fluxo.

## Base técnica

- Godot `4.6.2-stable`, GDScript e GUT `9.6.0`.
- JSON gera recursos; cenas jogáveis são editor-owned, salvo gerador oficial existente.
- Não edite `.tscn` como texto. Use editor ou ferramenta Godot.
- Preserve limites Foundation, Gameplay, Presentation, Composition e Online definidos no canon local.

## QA e gates

`qa/qa_manifest.json` governa comandos; `qa/QA_INDEX.md` governa jornadas. Runtime integral só roda quando o projeto é selecionado explicitamente e deve deixar a árvore rastreada inalterada.

Não há gate humano ativo enquanto pausado. Retomada, campanha, lore, progressão, feel, visual, modo ou plataforma exigem nova decisão; automação não aprova essas escolhas.

## Hard stops

Pare diante de retomada implícita, mudança de prioridade/produto/canon, segredo, remoto/publicação fora do push Git delegado, cena/binário ambíguo, conflito histórico único ou decisão humana não existente.
