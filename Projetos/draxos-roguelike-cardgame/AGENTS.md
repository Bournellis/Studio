# AGENTS.md

## Metadata

- status: active
- authority: operational_contract
- last_verified: 2026-08-27
- review_when: governanca local, produto ou validacao mudar
- supersedes: AGENTS.md before Governance v2
- superseded_by: none

Este arquivo governa `Projetos/draxos-roguelike-cardgame`.

## Autoridade e pausa

1. `../../08_Coordenacao_Agentes/Prioridades_Estudio.md` define foco e trabalho permitido.
2. `implementation/current-status.md` e a unica autoridade tecnica local.
3. Contratos de produto e arquitetura em `docs/` governam mecanicas locais.
4. `08_Coordenacao/` governa cards, handoffs e gates humanos novos.
5. Tracks e registros antigos sao historia.

Enquanto o portifolio mantiver o projeto pausado, permita somente consulta, governanca e integridade explicitamente autorizadas. Nao retome conteudo, tuning ou produto por inferencia.

## Identidade e fronteiras

- roguelike cardgame menu-first com comandante Draxos, Ship Hub, mapa de run, Souls, reliquias e batalhas por lanes;
- classes Arcano, Invocador e Necromante;
- regras de deck, mana, compra, run, recompensa e combate sao locais;
- `rpg-turnos`, `rpg-isometrico` e DraxosMobile nao sao fontes automaticas de mecanica;
- `STUDIO_CORE.md` adota somente `shared_foundation`, `draxos` e `draxos_elemental_expedition` da revisao `lore.v2` e aponta para cada autoridade tematica exata;
- a janela da expedicao e a unica autoridade para o recorte compartilhado com RPG Turnos: lore, personagens, classes, narrativa e objetivo geral;
- mecanica, runtime, encontros, economia, progressao, apresentacao e implementacao continuam locais a cada jogo.

## Leitura

1. `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `../../08_Coordenacao_Agentes/Estado_Atual.md`
3. `STUDIO_CORE.md` quando lore ou universo forem relevantes
4. `implementation/current-status.md`
5. `08_Coordenacao/TRIAGE.md` e card vivo
6. `qa/QA_INDEX.md`
7. contrato e arquivo tocado

Para decisao ampla de produto, acrescente `docs/product-brief.md`, `docs/game-design-document.md`, `docs/architecture.md` e os contratos da Track 02 indicados pelo estado local.

## Local-first e Git

- escreva somente em worktree externa dedicada e branch propria;
- novos cards e handoffs locais ficam em `08_Coordenacao/`;
- trabalho local apenas enfileira `global_sync_needed`; nao edita snapshots globais;
- separe commits de coordenacao, documentacao, QA e runtime;
- valide antes/depois de rebase e entregue arvore limpa;
- autoria e integracao Git permanecem locais; o push rotineiro pos-fechamento segue exclusivamente o contrato e o runbook globais. Login, deploy, release, publicacao e remotos de produto continuam fora deste fluxo.

## Godot e conteudo

- engine: Godot `4.6.2-stable`; linguagem: GDScript; testes: GUT `9.6.0`;
- JSON em `data/definitions/` e a fonte de verdade; `data/generated/` e derivado;
- nao edite `.tscn` manualmente; use o gerador oficial;
- geradores e validadores devem ser deterministas e nao alterar arquivos rastreados;
- labs escrevem em `user://` e nao aprovam promocao, balanceamento ou sensacao.

## Validacao

- manifesto executavel: `qa/qa_manifest.json`;
- jornadas e gates: `qa/QA_INDEX.md`;
- Runtime integral: `tools/validate.gd`;
- rode Runtime duas vezes apos mudanca de geracao/validacao e compare o estado Git;
- `VALIDATOR_SIDE_EFFECT` e falha; nao restaure automaticamente.

## Gates humanos

- promocao de candidatos do Design Lab;
- balanceamento e pacing;
- sensacao da run completa;
- visual, feel e publicacao.

Pare diante de conflito semantico, recurso gerado inesperado, cena/binario ambiguo, segredo, remoto fora do push Git delegado, mudanca de produto/prioridade ou nova decisao humana.
